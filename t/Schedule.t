#!/usr/bin/perl -w

use strict;
use Test::More tests => 5;

use lib './lib';

BEGIN { use_ok('Business::Bof::Server::Fw'); };
BEGIN { use_ok('Business::Bof::Server::Schedule'); };

  my $fw = Business::Bof::Server::Fw->new('t/bof.xml');

  my %key = (
    name     => 'Freemoney',
    password => 'test'
  );
  my $ui = $fw->get_userinfo(\%key);

  my $sch = new Business::Bof::Server::Schedule();
  my $scheduleId = $sch->new_schedule({
    user_id => 1,
    class => "class",
    method => "method",
    data => 'Some schedule data'
  });
  like($scheduleId, qr/^[+‐]?\d+$/, 'New schedule');

  my $schData = {
    schedule_id => $scheduleId,
    schedule => '* * * * *',
    class => "subscription",
    method => "calc_subscription",
    data => "{invoicedate => 'today'}"
  };
  my $res = $sch->upd_schedule($schData);
  is($res, 1, 'Update Task');

  my $schedule = $sch->get_schedule({schedule_id => $scheduleId});
  isa_ok($schedule, 'Business::Bof::Data::Fw::fw_schedule', 'Get Schedule');

