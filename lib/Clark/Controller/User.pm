package Clark::Controller::User;

use strict;
use warnings;
use experimental qw(signatures);
use Mojo::Util   qw(secure_compare);
use Mojo::Base 'Mojolicious::Controller', -signatures;
use Clark::Util::Crypt;
use Data::Dumper;

sub _validate_username_uniqueness {
    my $self     = shift;
    my $username = pop;

    return not $self->user_repository->find( { name => $username } );
}

sub create {
    my $self = shift;
    my $user = $self->req->json;

    return $self->render(
        status => 400,
        json   => { err => 400, msg => 'Username is not unique' }
    ) unless $self->_validate_username_uniqueness( $user->{'username'} );

    $user->{'password'} = Clark::Util::Crypt->hash( $user->{'password'} );

    $self->user_repository->new_result($user)->insert;
}

sub update_password {
    my $self = shift;
    my $user = $self->user_repository->find( { id => $self->session('user') } );
    my $old_password = $self->req->json->{'old_password'};
    my $new_password = $self->req->json->{'new_password'};

    if ( $user->password ne Clark::Util::Crypt->hash($old_password) ) {
        return $self->render(
            status => 400,
            json   => { err => 400, msg => 'Old password is incorrect.' }
        );
    }

    $user->update( { password => Clark::Util::Crypt->hash($new_password) } );

    return $self->render( status => 204 );
}

sub update {
    my $self = shift;
    my $uid  = $self->session('user');

    my $req_user = $self->user_repository->find( { id => $uid } );
    my $user     = $self->user_repository->find( { id => $self->stash('id') } );

    return $self->render(
        json => { err => 403, msg => 'You cannot modify other elevated users' },
        status => 403
        )
        if ( $user->is_root
        || ( $user->is_admin && ( $user->id ne $req_user->id ) ) )
        && not( $req_user->is_root );

    return $self->render(
        json   => { err => 403, msg => 'Only the root user can modify admins' },
        status => 403
        )
        if ( $user->is_admin
        && not( $req_user->is_root ) );

    my $req_password = $self->req->json->{'req_password'};
    my $password     = $self->req->json->{'password'};
    my $username     = $self->req->json->{'username'};
    my $is_admin     = $self->req->json->{'is_admin'};

    delete $self->req->json->{'req_password'};
    delete $self->req->json->{'password'};

    return $self->render(
        json   => { err => 400, msg => 'You cannot make yourself admin' },
        status => 400
    ) if $is_admin && not( $req_user->is_admin );

    return $self->render(
        status => 400,
        json   => { err => 400, msg => 'Invalid password' }
    ) if ( $req_user->password ne Clark::Util::Crypt->hash($req_password) );

    return $self->render(
        status => 400,
        json   => { err => 400, msg => 'Username already in use' }
        )
        if $username ne $user->name
        && not( $self->_validate_username_uniqueness($username) );

    $user->update( $self->req->json );

    my $sanitized_user
        = $self->user_repository->find( { id => $self->stash('id') },
        { columns => [qw/name is_admin is_root/] } );

    return $self->render( json => $sanitized_user->get_inflated_columns );
}

sub identify {
    my $self = shift;
    my %user = $self->user_repository->identify( $self->session('user') )
        ->get_inflated_columns;
    return $self->render( json => \%user );
}

sub find {
    my $self = shift;
    return $self->render( json =>
            Clark::Util::Infalate->many( $self->user_repository->active->all )
    );
}

sub delete {
    my $self = shift;
    my $req_user
        = $self->user_repository->find( { id => $self->session('user') } );
    my $user = $self->user_repository->find( { id => $self->stash('id') } );

    return $self->render(
        json => { err => 403, msg => 'Only the root user can modify admins' } )
        if $user->is_root && not( $req_user->is_root );
}

1;