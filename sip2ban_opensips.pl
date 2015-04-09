#!/usr/bin/perl -w
use strict;

if($#ARGV != 0) {
  print "usage: sip2ban_opensips.pl faliedtimes\n";
  print "ex: sip2ban_opensips.pl 5\n";
  exit;
}

#initial variables
my $logfile = '/var/log/opensips.log';
my $datetime = localtime;
my $count = $ARGV[0];
my $key = 'Auth_error';
my @ip;
my $i = 0;

#read opensips log file
open(my $fh, '<', $logfile) or die "Could not open file '$logfile' $!";
while (my $row = <$fh>) {
  chomp $row;
  if(index($row, $key) != -1) {
      my @data = split / /, $row;
      $ip[$i++] = $data[10];
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
  #read and apply whitelist
  if(open(my $fh, '<',"/etc/failed2ban3000/whitelist.ini")) {
      my @whitelistlines=<$fh>;
      close $fh;
      foreach my $whitelist (@whitelistlines) {
          chomp $whitelist;
          for(my $j=0; $j < $count; $j++) {
               if($whitelist =~ /$blockedip[$j]/) {
                   $blockedip[$j] = "";
               }
          }

      }
  }
  
   #read iptables configuration file
   open($fh, '<',"/etc/sysconfig/iptables") or die "Could not open file!";
   my @lines=<$fh>;
   close $fh;

   foreach my $line (@lines) {
      for(my $j=0; $j < $countip; $j++) {
         my $str = "-A RH-Firewall-1-INPUT -s $blockedip[$j] -j DROP";
         if($line =~ /$str/) {
           $blockedip[$j]="";
           $countip--;
         }
      }
   }

   if($countip > 0) {
      #backup iptables configuration file
      move("/etc/sysconfig/iptables","/etc/sysconfig/iptables.old");

      #apply new iptables rules
      my $newiptables;
      foreach my $ip (@blockedip) {
          if($ip ne "") {
             $newiptables .= "-A RH-Firewall-1-INPUT -s $ip -j DROP\n";
             my $returncode = system("/sbin/iptables -I RH-Firewall-1-INPUT 2 -s $ip -j DROP");
             if($returncode != 0) {
                 print "$datetime Could not add $ip in iptables rule!\n";
             } else {
                print "$datetime Bloacked IP Address : $ip\n";
             }

          }
      }

      #save new iptables rules
      open($fh, '>',"/etc/sysconfig/iptables") or die "Could not open file!";

      foreach my $line (@lines) {
          my $search = "-A RH-Firewall-1-INPUT -i lo -j ACCEPT";
          print $fh $line;
          if($line =~ /$search/) {
               print $fh $newiptables;
          }
      }
   }
}
