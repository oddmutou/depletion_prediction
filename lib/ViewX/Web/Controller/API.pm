package ViewX::Web::Controller::API;

use strict;
use warnings;
use parent qw(ViewX::Web::Controller);
use Smart::Args;

sub generate_graph {
    args
        my $self;

    $self->create_response(body => "hogehoge");
}

1;
