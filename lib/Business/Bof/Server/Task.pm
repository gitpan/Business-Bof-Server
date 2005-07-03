package Business::Bof::Server::Task;

use warnings;
use strict;
use XML::Dumper;

use Business::Bof::Data::Fw;
use Business::Bof::Server qw(Fw Session);

our $VERSION = 0.07;

our ($fw, $logger);

sub set_fw {
  $fw = shift;
}

sub new {
  my ($type) = @_;
  my $self = {};
  return bless $self,$type;
}

sub new_task {
  my ($self, $values) = @_;
  my $parms;
  if (defined $values->{data}) {
    $parms = pl2xml($values->{data});
  } else {
    $parms = $values->{parameters};
  }
  my $fwtask = Business::Bof::Data::Fw::fw_task->create({
    user_id => $values->{user_id},
    class => $values->{class},
    method => $values->{method},
    title => $values->{title},
    status => $values->{status},
    parameters => $parms
  });
  $fwtask->dbi_commit();
  my $task_id = $fwtask->task_id;
}

sub upd_task {
  my ($self, $values) = @_;
  my $fwtask = Business::Bof::Data::Fw::fw_task->retrieve($values->{task_id});
  $values->{parameters} = pl2xml($values->{data}) if defined $values->{data};
  delete $values->{data};
  $fwtask->set(%$values);
  $fwtask->update();
  $fwtask->dbi_commit();
}

sub get_task {
  my ($self, $values) = @_;
  my $ro = $values->{ro};
  delete $values->{ro};
  my @fwtask = Business::Bof::Data::Fw::fw_task->search(%$values)
   or return;
  my $fwtask = $fwtask[0];
  if (!$ro) {
    $fwtask->status(150);
    $fwtask->update;
    $fwtask->dbi_commit();
  }
  $fwtask->{data} = xml2pl($fwtask->parameters) if $fwtask->parameters;
#  delete $fwtask->{parameters};
  $fwtask->{result} = xml2pl($fwtask->result) if $fwtask->result;
  return $fwtask;
}

sub get_tasklist {
  my ($self, $userInfo) = @_;
  my $db = $self->{db};
  my @task = Business::Bof::Data::Fw::fw_task->search(
    user_id => $userInfo->{user_id},
    { order_by=>'task_id DESC' }
  );
  my @ret;
  for my $task (@task) {
    push @ret, {(
      task_id => $task->task_id,
      title => $task->title,
      status => $task->status
    )};
  }
  return \@ret;
}

sub run_tasks {
  my ($self) = @_;
  my $session_id = 0; # Special session!
  Business::Bof::Server::Session::set_timestamp($session_id, DateTime->now());
  while (my $task = $self->get_task({status => 100})) {
    my $userinfo = $fw->get_userinfo( {user_id => $task->user_id} );
    Business::Bof::Server::Session::set_userinfo($session_id, $userinfo);
    my $class = $task->{class};
    my $method = $task->{method};
    my $data;
    eval '$data=' . $task->{data} if $task->{data};
    my $fw_task = $task->{task_id};
    my %parms = (
      class => $class,
      method => $method,
      data => $data
    );
    Business::Bof::Server::Connection::call_method($session_id, \%parms);
  }
}

1;
__END__

=head1 NAME

Business::Bof::Server::Task -- Handle Bof task creation, updating and reading

=head1 SYNOPSIS

  use Business::Bof::Server::Task;

  my $task = new Business::Bof::Server::Task($db);
  my $taskId = $fw -> newTask({
     user_id => $user_id,
     class => $class,
     method => $method,
     data => $data,
     status => 100
  });
  ...
  my $task = getTask({task_id => $taskId});
  ...

=head1 DESCRIPTION

Business::Bof::Server::Task creates, updates and reads the tasks that Bof
(Business Oriented Framework) uses to keep track of its batch processes.

When a client process wants to have a task executed at a later time,
and when there is a recurring scheduled task, this module handles the
necessary tasks.

=head1 AUTHOR

Kaare Rasmussen <kar at kakidata.dk>

