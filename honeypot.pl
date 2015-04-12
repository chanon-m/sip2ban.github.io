#!/usr/bin/perl -w

use strict;
use IO::Socket::INET;

if($#ARGV != 0) {
  print "usage: rtphotpot.pl port\n";
  print "ex: rtphotpot.pl 22222\n";
  exit;
}

my $port = $ARGV[0];
my ($socket,$received_data);
my ($peeraddress,$peerport);

$socket = new IO::Socket::INET (
        LocalPort => $port,
        Proto => 'udp',
) or die "ERROR in Socket Creation : $!\n";

while(1) {
   #read date on the socket
   $socket->recv(my $recieved_data,1024);

   #get the source ip address.
   my $src_ip = $socket->peerhost();

   #get udp/rtp header
   my $rtpheader = lc substr($recieved_data,0,10);

   #check rtp header match
   if($rtpheader =~ /invite sip/) {
       my $datetime = substr(localtime,4,-5);
       my @data = split / /, $recieved_data;

       #write a notice in asterisk log file
       open(my $fh, '>>',"/var/log/asterisk/full") or die "Could not open file!";
       my $log = "[$datetime] NOTICE[RTPHOTPOT] rtphotpot.pl: RTP from '$src_ip $data[1]' failed for '$src_ip' - RTP attacks\n";
       print $log;
       print $fh $log;
       close $fh;
   }

}

$socket->close();
