#!/usr/bin/perl -w
use strict;
use File::Copy;

if($#ARGV != 0) {
  print "usage: sip2ban.pl faliedtimes\n";
  print "ex: sip2ban.pl 5\n";
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

#if failed times >= count, it will be blacklist
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

if($countip > 0) {
   #read iptables configuration file
   open($fh, '<',"/etc/sysconfig/iptables") or die "Could not open file!";
   my @lines=<$fh>;
   my $linenum = scalar(@lines) - 2;
   close $fh;

   #backup iptables configuration file
   move("/etc/sysconfig/iptables","/etc/sysconfig/iptables.old");

   #save and apply new iptables rules
   open($fh, '>',"/etc/sysconfig/iptables") or die "Could not open file!";
   $i = 0;
   foreach my $line (@lines) {
      for(my $j=0; $j < $countip; $j++) {
         my $str = "-A RH-Firewall-1-INPUT -s $blockedip[$j] -j DROP\n";
         if($line eq $str) {
           $blockedip[$j]="";
         }
      }

      if($i == $linenum) {
         for(my $j=0; $j < $countip; $j++) {
           if($blockedip[$j] ne "") {
             #update an iptables rule in iptables configuration file
             print $fh "-A RH-Firewall-1-INPUT -s $blockedip[$j] -j DROP\n";
             #apply an iptables rule
             my $returncode = system("/sbin/iptables -I RH-Firewall-1-INPUT 2 -s $blockedip[$j] -j DROP");
             if($returncode != 0) {
                 print "Could not add $heckip[$j] in iptables rule!\n";
             } else {
                print "Bloacked IP Address : $heckip[$j]\n";          
             }
           }
         }
         print $fh $line;
      } else {
         print $fh $line;
      }
      $i++;
   }
}
