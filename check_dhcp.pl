#!/usr/bin/perl
# Simple DHCP client - sending a broadcasted DHCP Discover request


my $DHCP_SERVER_IP = 'DHCP_SERVER_IP'; ###### CHANGE THIS TO YOUR DHCP SERVER IP
my $TFTP_FILE = '/usr/local/nagios/var/tmp/tftp_dl.log'; ###### PATH TO COLLECT TFTP FILE NAME (ONLY NAME)
my $RELAY_IP = 'NAGIOS_SERVER_IP'; ###### THIS MUST BE SET TO NAGIOS SERVER IP AND DHCP SERVER MUST HAVE A UDP CONNECTION TO IT. THIS REACTS AS A CMTS RELAY IP

use IO::Socket::INET;
use Net::DHCP::Packet;
use Net::DHCP::Constants;
use strict;


open FILE, ">$TFTP_FILE";

my $LEASE_TIME = 3600;

my $mac = $ARGV[0];

$mac =~ s/://g;
$mac =~ s/ //g;
$mac =~ s/\.//g;




# send packet
my $handle = IO::Socket::INET->new(Proto => 'udp',
                                 PeerPort => '67',
                                 LocalPort => '67',
                                 Timeout => 2,
                                 PeerAddr => $DHCP_SERVER_IP);
if (!$handle) { print "CRITICAL - SOCKET UNAVAILABLE"; exit 2};     # yes, it uses $@ here



  # DISCOVER
  &send_packet('0.0.0.0',1,'0.0.0.0');
  # OFFER
  my $recv_packet = &recv_packet;
  # REQUEST
  &send_packet($recv_packet->yiaddr(),3,$recv_packet->getOptionValue(DHO_DHCP_SERVER_IDENTIFIER()));
  # ACK
  $recv_packet = &recv_packet;
  print FILE $recv_packet->getOptionValue(DHO_TFTP_SERVER()) . ":" . $recv_packet->getOptionValue(DHO_BOOTFILE());
  close FILE;
  print "OK - IP: " . $recv_packet->yiaddr();
  exit 0;




$handle->close();

sub send_packet {

  # create DHCP Packet
  my $discover = Net::DHCP::Packet->new(
  #                      xid => int(rand(0xFFFFFFFF)), # random xid
                      Chaddr => $mac,
                      Ciaddr => '',
                      Giaddr => $RELAY_IP,
                      Flags => 0x8000,              # ask for broadcast answer
                      DHO_DHCP_MESSAGE_TYPE() => $_[1],
                      DHO_DHCP_PARAMETER_REQUEST_LIST() => "1 2 3 4 7 6 66 67",
                      DHO_VENDOR_CLASS_IDENTIFIER() => "docsis3.0",
                      );

  $discover->addSubOptionValue(DHO_VENDOR_ENCAPSULATED_OPTIONS(), VSI_SERIAL_NUMBER(), '12342523');
  $discover->addSubOptionValue(DHO_VENDOR_ENCAPSULATED_OPTIONS(), VSI_HARDWARE_VERSION(), 'MY_VERSION');
  $discover->addSubOptionValue(DHO_VENDOR_ENCAPSULATED_OPTIONS(), VSI_SOFTWARE_VERSION(), '3.5');
  $discover->addSubOptionValue(DHO_VENDOR_ENCAPSULATED_OPTIONS(), VSI_BOOT_ROM_VERSION(), 'AAA');
  $discover->addSubOptionValue(DHO_VENDOR_ENCAPSULATED_OPTIONS(), VSI_OUI(), '001122');
  $discover->addSubOptionValue(DHO_VENDOR_ENCAPSULATED_OPTIONS(), VSI_MODEL_NUMBER(), 'BadAss80085');
  $discover->addSubOptionValue(DHO_VENDOR_ENCAPSULATED_OPTIONS(), VSI_VENDOR_NAME(), '80085 inc.');

  $discover->addSubOptionValue(DHO_DHCP_AGENT_OPTIONS(), 1, '8008135e');
  $discover->addSubOptionValue(DHO_DHCP_AGENT_OPTIONS(), 2, $mac);

  if ($_[1] == 3) {
    $discover->addOptionValue(DHO_DHCP_REQUESTED_ADDRESS(),$_[0]);
    $discover->addOptionValue(DHO_DHCP_SERVER_IDENTIFIER(),$_[2]);

  }

  $handle->send($discover->serialize())
              or die "Error sending broadcast inform:$!\n";

}

sub recv_packet {


  my $newmsg;
  if (!$handle->setsockopt(SOL_SOCKET, SO_RCVTIMEO, pack('l!l!', 2, 0))){
    print "CRITICAL - SOCKET TIMEOUT";
    exit 2;
  }
  $handle->recv($newmsg, 1024) or die $!;
  my $packet = Net::DHCP::Packet->new($newmsg);
  return $packet;

}
