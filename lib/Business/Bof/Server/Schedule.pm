package Business::Bof::Server::Schedule;

use warnings;
use strict;
use DateTime::Event::Cron;
use POE::Component::Cron;
use XML::Dumper;

use Business::Bof::Server qw(Fw Task);

our $VERSION = 0.07;

sub new {
  my ($type) = @_;
  my $self = {};
  return bless $self,$type;
}

sub new_schedule {
  my ($self, $schedule) = @_;
  my $fwsch = Business::Bof::Data::Fw::fw_schedule->create({
    user_id => $schedule->{user_id},
    class => $schedule->{class},
    method => $schedule->{method},
    title => $schedule->{title},
    parameters => pl2xml($schedule->{data}),
  });
  $fwsch->dbi_commit();
  my $schedule_id = $fwsch->schedule_id;
}

sub upd_schedule {
  my ($self,$values) = @_;
  my $fwsch = Business::Bof::Data::Fw::fw_schedule->retrieve($values->{schedule_id});
  if ($values->{data}) {
    $values->{parameters} = pl2xml($values->{data}),
    delete $values->{data};
  }
  $fwsch->set(%$values);
  $fwsch->update();
  $fwsch->dbi_commit();
}

sub get_schedule {
  my ($self,$values) = @_;
  my $fwsch = Business::Bof::Data::Fw::fw_schedule->retrieve($values->{schedule_id});
  $fwsch->{data} = xml2pl($fwsch->parameters);
  return $fwsch;
}

sub init_schedules {
  my ($self,$poe_session) = @_;
  for my $schlist (Business::Bof::Data::Fw::fw_schedule->retrieve_all) {
    POE::Component::Cron->add(
      $poe_session => handleSchedules => DateTime::Event::Cron->from_cron($schlist->schedule)->iterator(
        span => DateTime::Span->from_datetimes(
          start => DateTime->now,
          end   => DateTime::Infinite::Future->new
        )
      ),
      $schlist->title, 
      $schlist->user_id->user_id,
      $schlist->class,
      $schlist->method,
      $schlist->parameters
    );
  }
}

1;
__END__

=head1 NAME

Business::Bof::Server::Schedule -- Schedule schedules to be run

=head1 SYNOPSIS

  use Business::Bof::Server::Schedule;

  my $sch = new Business::Bof::Server::Schedule($db);
##
  my $scheduleId = $sch->newSchedule({
     user_id => $user_id,
     class => "$class",
     method => "$method",
     data => $data
  });
  ...
  my $schedule = $sch->getSchedule({schedule_id => $scheduleId});
  ...

=head1 DESCRIPTION

Bof::Server::Schedule creates, updates and reads the schedules that Bof (Business 
Oriented Framework) uses to keep track of its batch processes.

When a client process wants to have a schedule executed at a later time,
and when there is a recurring scheduled schedule, this module handles the
necessary schedules.

=head1 AUTHOR

Kaare Rasmussen <kar at kakidata.dk>

