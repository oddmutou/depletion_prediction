package ViewX::Web;

use strict;
use warnings;
use Class::Accessor::Lite (ro => [qw(dispatcher)]);
use Plack::Request;
use Smart::Args;
use ViewX::Web::Dispatcher;

sub new {
    args
        my $class;

    my $dispatcher = ViewX::Web::Dispatcher->new;
    bless +{ dispatcher => $dispatcher } => $class;
}

sub handler {
    args
        my $self;

    sub {
        my $env = shift;
        my $request = Plack::Request->new($env);
        my $response = $self->dispatcher->dispatch(request => $request);
        $response->finalize;
    };
};

1;
