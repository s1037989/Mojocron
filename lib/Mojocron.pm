package Mojocron;
use Mojo::Base -base;

use Mojo::IOLoop;
use Mojo::Server;
use Mojo::Loader qw(find_modules load_class);
use Mojo::Util 'camelize';

use Time::Piece;

has app => sub { shift->server->build_app('Mojo::HelloWorld') };
has server => sub { Mojo::Server->new };
has namespaces => sub { [camelize(shift->app->moniker).'::Mojocron'] };
has jobs => sub { {} };

sub start {
  my ($self) = @_;
  my $mojocron_subprocess = Mojo::IOLoop->subprocess->run(
    sub {
      my $mojocron_subprocess = shift;
      $self->_set_process_name(sprintf '%s mojocron', $self->app->moniker);
      $mojocron_subprocess->ioloop->recurring(1 => sub { $self->_start($mojocron_subprocess) unless localtime->sec });
      $self->server->on(finish => sub {
        my ($server, $graceful) = @_;
        $self->app->log->info(sprintf "Ended mojocron subprocess %s %s %s", $$, ref $server, $graceful||0);
        $mojocron_subprocess->ioloop->stop if $mojocron_subprocess->ioloop->is_running;
      });
      $mojocron_subprocess->ioloop->start unless $mojocron_subprocess->ioloop->is_running;
    },
    sub {
      $self->app->log->error("I've never seen this: $_[1]");
    }
  );
  $self->app->log->info(sprintf 'Started mojocron subprocess %s', $mojocron_subprocess->pid);
  return $self;
}

sub _set_process_name { $0 = pop }

sub _start {
  my ($self, $mojocron_subprocess) = @_;
  my $time = time;
  my @namespaces = map { find_modules $_ } grep { $_ } @{$self->namespaces};
  $self->app->log->warn("No mojocron jobs found") unless @namespaces;
  for my $module ( @namespaces ) {
    my $e = load_class $module;
    $self->app->log->warn(sprintf 'Loading "%s" failed: %s', $module, $e) and next if ref $e;
    my $job = $module->new(mojocron => $self, app => $self->app, mojocron_subprocess => $mojocron_subprocess, server => $self->server, time => $time)->start or next;
    $self->jobs->{$job->name} = $job->job->pid;
  }
}

1;
