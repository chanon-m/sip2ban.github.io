#!/usr/bin/perl -w
use strict;
use File::Copy;

my $times = usage();

#Check Unauthorized attacks
my @auth_failure = blacklist('/var/log/freeswitch/freeswitch.log','auth failure',16,$times);

#Check RTP without registration attacks
my @rtp_attacks = blacklist('/var/log/freeswitch/freeswitch.log','Rejected by acl',5,$times);

#IP address of attackers
my @ip_blacklist = whitelist(@auth_failure,@rtp_attacks);

#Block the attacker
blacklist2iptables(@ip_blacklist) if(@ip_blacklist > 0);

sub blacklist2iptables {

        my @blockedip = @_;
        my $datetime = localtime;

        #read iptables configuration file
        open(my $fh, '<',"/etc/sysconfig/iptables") or die "Could not open file!";
        my @lines=<$fh>;
        close $fh;

        foreach my $line (@lines) {
           for(my $i=0; $i < @blockedip; $i++) {
                my $str = "-A INPUT -s $blockedip[$i] -j DROP";
                if($line =~ /$str/) {
                    $blockedip[$i]="";
                }
           }
        }

        #apply new iptables rules
        my $newiptables;
        foreach my $ip (@blockedip) {
              if($ip ne "") {
                  $newiptables .= "-A INPUT -s $ip -j DROP\n";
                  my $returncode = system("/sbin/iptables -I INPUT 2 -s $ip -j DROP");
                  if($returncode != 0) {
                      print "$datetime Could not add $ip in iptables rule!\n";
                  } else {
                      print "$datetime Bloacked IP Address : $ip\n";
                  }
              }
        }

        if(defined($newiptables)) {
            #backup iptables configuration file
            move("/etc/sysconfig/iptables","/etc/sysconfig/iptables.$datetime") or die "Can not backup iptables file!\n";

            #save new iptables rules
            open($fh, '>',"/etc/sysconfig/iptables") or die "Could not open file!";
            foreach my $line (@lines) {
                my $search = "-A INPUT -i lo -j ACCEPT";
                print $fh $line;
                print $fh $newiptables if($line =~ /$search/);
            }
            close $fh;
        }

}

sub whitelist {

        my @blockedip = @_;

        #read and apply whitelist
        if(open(my $fh, '<', '/etc/sip2ban/whitelist.ini')) {
            my @whitelistlines=<$fh>;
            close $fh;
            foreach my $whitelist (@whitelistlines) {
                chomp $whitelist;
                for(my $i=0; $i < @blockedip; $i++) {
                     if($whitelist =~ /$blockedip[$i]/) {
                         $blockedip[$i] = "";
                     }
                }
            }
        }

        return @blockedip;
}

sub blacklist {

        my ($logfile,$key,$index,$count) = ($_[0],$_[1],$_[2],$_[3]);
        my (@ip, $i) = (0, 0);
        #read opensips log file
        open(my $fh, '<', $logfile) or die "Could not open file '$logfile' $!";
        while (my $row = <$fh>) {
          chomp $row;
          if(index($row, $key) != -1) {
              my @data = split / /, $row;
              $ip[$i++] = $data[$index];
          }
        }
        close $fh;

        #if failed times >= count, it will be blacklist
        my %seen;
        foreach my $item (@ip) {
          $seen{$item}++;
        }

        $i=0;
        my @blockedip;
        foreach my $item (keys %seen) {
           if($seen{$item} >= $count) {
               $blockedip[$i++] = $item;
           }
        }

        return @blockedip;
}

sub usage {

        if($#ARGV != 0) {
            print "usage: sip2ban_freeswitch.pl faliedtimes\n";
            print "ex: sip2ban_freeswitch.pl 5\n";
            exit;
        }

        return $ARGV[0];

}
