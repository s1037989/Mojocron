package Mojolicious::Plugin::Mojocron;
use Mojo::Base 'Mojolicious::Plugin';

our $VERSION = '0.01';

use Mojocron;
use Scalar::Util 'weaken';

sub register {
  my ($self, $app, $conf) = @_;

  $app->log->warn("Not development mode; remember to install your mojocron commands in your system's cron") and return
    unless $app->mode eq 'development' || $app->mode eq delete $conf->{allow};

  push @{$app->commands->namespaces}, 'Mojocron::Command';

  my $mojocron = Mojocron->new(each %$conf);
  weaken $mojocron->app($app)->{app};
  $app->helper(mojocron => sub {$mojocron});

  $app->hook(before_server_start => sub { $mojocron->server(shift)->start });
}

1;
__END__

=encoding utf8

=head1 NAME

Mojolicious::Plugin::Mojocron - Mojolicious Plugin

=head1 SYNOPSIS

  # Mojolicious
  $self->plugin('Mojocron');

  # Mojolicious::Lite
  plugin 'Mojocron';

=head1 DESCRIPTION

L<Mojolicious::Plugin::Mojocron> is a L<Mojolicious> plugin.

=head1 METHODS

L<Mojolicious::Plugin::Mojocron> inherits all methods from
L<Mojolicious::Plugin> and implements the following new ones.

=head2 register

  $plugin->register(Mojolicious->new);

Register plugin in L<Mojolicious> application.

=head1 SEE ALSO

L<Mojolicious>, L<Mojolicious::Guides>, L<https://mojolicious.org>.

=cut
