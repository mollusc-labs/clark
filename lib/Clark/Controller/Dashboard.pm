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
    if ( $json->{'owner'} ) {
        $json->{'owner'} = $self->session('user') unless $json->{'owner'} eq $self->session('user');
    }
    else {
        $json->{'owner'} = $self->session('user');
    }
    my @errors = @{ $self->dashboard_validator->validate($json) };
    if ( scalar @errors ) {
        return $self->render( json => { err => 400, msg => 'Invalid JSON supplied' }, status => 400 );
    }

    my $db = $self->dashboard_repository->create($json);
    return $self->render( json => { $db->get_inflated_columns( [qw[name query owner]] ) } );
}

sub update {

}

sub find {
    my $self = shift;
    my $id   = $self->session('user');

    my $dashboards = Clark::Util::Inflate->many( $self->dashboard_repository->search( { owner => $id }, { columns => [qw[id name query]] } ) );
    $self->render( json => $dashboards );
}

1;
