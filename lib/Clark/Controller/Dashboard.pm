package Clark::Controller::Dashboard;

use strict;
use warnings;
use experimental qw(say);
use Data::Dumper;
use Mojo::Base 'Mojolicious::Controller', -signatures;
use Clark::Util::Inflate;

#| This renders the Vue app as an index
sub index {
    my $self = shift;
    return $self->render;
}

#| This is for the vue dev server
sub dev {
    my $self = shift;
    return $self->redirect_to('http://localhost:5173/dashboard');
}

sub create {
    my $self = shift;
    my $json = $self->req->json;

    $json->{'name'} ||= 'Unnamed Dashboard';
    $json->{'owner'} = $self->session('user');

    my @errors = @{ $self->dashboard_validator->validate($json) };
    if ( scalar @errors ) {
        return $self->render(
            json   => { err => 400, msg => \@errors },
            status => 400
        );
    }

    my $db = $self->dashboard_repository->create($json);
    $self->app->log->info( 'Creating dashboard with ID - ' . $db->id );
    return $self->render( json => { $db->get_inflated_columns } );
}

sub update {
    my $self = shift;
    my $json = $self->req->json;
    my $id   = $self->stash('id');
    my $uid  = $self->session('user');

    return $self->render(
        json   => { err => 404, msg => 'Not found' },
        status => 404
    ) unless my $orig = $self->dashboard_repository->find( { id => $id } );

    return $self->render(
        json   => { err => 403, msg => 'Unauthorized' },
        status => 403
    ) unless $orig->owner eq $uid;

    $json->{'name'} ||= 'Unnamed Dashboard';

    my @errors = @{ $self->dashboard_validator->validate($json) };
    if ( scalar @errors ) {
        return $self->render(
            json   => { err => 400, msg => \@errors },
            status => 400
        );
    }

    return $self->render(
        json   => { err => 404, msg => 'Not found' },
        status => 404
        )
        unless my $db
        = { $self->dashboard_repository->find( { id => $id } )->update($json)
            ->get_inflated_columns };

    return $self->render( json => $db );
}

sub find {
    my $self = shift;
    my $id   = $self->session('user');

    my $dashboards = Clark::Util::Inflate->many(
        $self->dashboard_repository->search(
            { owner   => $id },
            { columns => [qw[id name query]] }
        )
    );
    $self->render( json => $dashboards );
}

1;
