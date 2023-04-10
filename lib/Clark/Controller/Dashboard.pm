package Clark::Controller::Dashboard;

use strict;
use warnings;
use experimental qw(say);
use Data::Dumper;
use Mojo::Base 'Mojolicious::Controller', -signatures;
use Clark::Util::Inflate;

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
    return $self->render(
        json => { $db->get_inflated_columns( [qw[name query owner]] ) } );
}

# TODO: Make me
sub update {
    my $self = shift;
    my $json = $self->req->json;
    my $id   = $self->stash('id');

    $json->{'name'} ||= 'Unnamed Dashboard';
    $json->{'owner'} = $self->session('user');

    my @errors = @{ $self->dashboard_validator->validate($json) };
    if ( scalar @errors ) {
        return $self->render(
            json   => { err => 400, msg => \@errors },
            status => 400
        );
    }

    my $db
        = { $self->dashboard_repository->find( { id => $id } )->update($json)
            ->get_inflated_columns }
        || undef;

    return $self->render(
        json   => { err => 404, msg => 'Not found' },
        status => 404
    ) unless $db;
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
