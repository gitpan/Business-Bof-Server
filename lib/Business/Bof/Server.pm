package Business::Bof::Server;

use strict;
use Carp qw( croak );

our $VERSION = '0.07';

sub import {
  my $self = shift;
  my $package = caller();
  my @failed;
  foreach my $module (@_) {
    my $code = "package $package; use Business::Bof::Server::$module;";
    eval($code);
    if ($@) {
      warn $@;
      push(@failed, $module);
    }
  }
  @failed and croak "could not import qw(" . join(' ', @failed) . ")";
}

1;
__END__

=head1 NAME

Business::Bof::Server -- Application Server featuring User Control and Remote Object Execution

=head1 DESCRIPTION

Business::Bof::Server contains these modules:

=over 4

=item Business::Bof::Server::CLI -- Server of The Business Oriented Framework

=item Business::Bof::Server::Connection -- Server methods for The Business Oriented Framework

=item Business::Bof::Server::Docprint -- Handles printing of documents

=item Business::Bof::Server::Fw -- Framework support for CLI and utility methods

=item Business::Bof::Server::Schedule -- Schedule schedules to be run

=item Business::Bof::Server::Session -- Session handling methods

=item Business::Bof::Server::Task -- Handle Bof task creation, updating and reading

=back

=head1 AUTHOR

Kaare Rasmussen <kar at kakidata.dk>