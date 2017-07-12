package ViewX::Web::Controller::API;

use strict;
use warnings;
use parent qw(ViewX::Web::Controller);
use File::Slurp;
use Smart::Args;
use ViewX::Plot;

sub generate_graph {
    args
        my $self;

    my $tmp_filename = rand(10000) . ".png";
    ViewX::Plot->plot(
        drivename => $self->request->param('drive'),
        filename => $tmp_filename,
        hostid => $self->request->param('host'),
    );
    my $bin_data = File::Slurp::read_file($tmp_filename, binmode => ':raw');
    unlink $tmp_filename;
    return $self->create_response(body => $bin_data, content_type => 'image/png');
}

1;
