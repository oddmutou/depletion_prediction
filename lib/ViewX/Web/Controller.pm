package ViewX::Web::Controller;

use strict;
use warnings;
use Class::Accessor::Lite (ro => [qw(request)]);
use Plack::Response;
use Smart::Args;
use Text::Xslate;

sub new {
    args
        my $class,
        my $request;

    bless +{request => $request} => $class;
}

sub create_response {
    args
        my $self,
        my $body => 'Str',
        my $content_type => +{isa => 'Str', default => 'text/html'},
        my $status => +{isa => 'Int', default => 200};

    my $res = Plack::Response->new($status);
    $res->content_type($content_type);
    $res->body($body);
    return $res;
}

sub create_html {
    args
        my $self,
        my $args,
        my $filename;

    my $tx = Text::Xslate->new(
        syntax => 'TTerse',
    );

    $tx->render($filename,$args);
}

1;
