package Mojocron::Command::mojocron;
use Mojo::Base 'Mojolicious::Command';

has description => 'Mojolicious Cron processor';
has usage => sub { shift->extract_usage };

use Mojo::IOLoop;

sub run {
  my $self = shift;
  # if -l print the crontab entry that one should install in an actual crond crontab
  $self->app->mojocron->start;
  Mojo::IOLoop->start unless Mojo::IOLoop->is_running;  
}

1;
