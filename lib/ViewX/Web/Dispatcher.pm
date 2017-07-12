package ViewX::Web::Dispatcher;

use strict;
use warnings;
use Class::Accessor::Lite (ro => [qw(router)]);
use Plack::Util;
use Router::Simple;
use Smart::Args;
use YAML::XS;

sub new {
    args
        my $class;

    my $mapping = YAML::XS::Load(join('', <DATA>));
    my $router = Router::Simple->new();
    for (@$mapping) {
        Plack::Util::load_class($_->{controller});
        $router->connect(
            $_->{uri},
            {
                controller => $_->{controller},
                action => $_->{action}
            },
        );
    }

    bless +{ router => $router } => $class;
}

sub dispatch {
    args
        my $self,
        my $request;

    my $match = $self->router->match($request->env);
    my $controller_class = $match->{controller};
    my $method = $match->{action};
    Plack::Util::load_class($controller_class);
    my $controller = $controller_class->new(request => $request);
    $controller->$method($request);
};

1;

__DATA__
- uri: /
  controller: ViewX::Web::Controller::Index
  action: view_index
- uri: /api
  controller: ViewX::Web::Controller::API
  action: generate_graph
- uri: /console
  controller: ViewX::Web::Controller::Console
  action: view_console
