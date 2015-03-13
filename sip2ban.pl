#!/usr/bin/perl -w
use strict;
use File::Copy;

if($#ARGV != 0) {
  print "usage: sip2ban.pl faliedtimes\n";
  exit;
}

#initial variables
my $logfile = '/var/log/asterisk/full';
my $count = $ARGV[0];
my $key = 'failed for';
my $i = 0;
my @ip;

#read asterisk log file
open(my $fh, '<', $logfile) or die "Could not open file '$logfile' $!";
while (my $row = <$fh>) {
  chomp $row;
  if(index($row, $key) != -1) {
      my @data = split /[',:, ]/, $row;
      $ip[$i++] = $data[19];
  }
}
close $fh;

#count failed if >= faled times, it will be blacklist
my %seen;
foreach my $item (@ip) {
  $seen{$item}++;
}

my $countip=0;
my @blockedip;
foreach my $item (keys %seen) {
   if($seen{$item} >= $count) {
       $blockedip[$countip++] = $item;
   }
}
