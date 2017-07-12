package ViewX::Web::Controller::Console;

use strict;
use warnings;
use utf8;
use parent qw(ViewX::Web::Controller);
use Encode;
use Smart::Args;

sub view_console {
    args
        my $self;

    $self->create_response(
        body => Encode::encode('utf-8', $self->create_html(
            filename => 'view/console.html',
            args => +{
            },
        )),
    );
}

1;
