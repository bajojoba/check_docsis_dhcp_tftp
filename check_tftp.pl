#!/usr/bin/perl

use strict;
use Net::TFTP;

my $TFTP_FILE = '/usr/local/nagios/var/tmp/tftp_dl.log'; ### THIS MUST BE THE SAME AS IN check_dhcp.pl
my $DOWNLOAD_FILE = '/usr/local/nagios/var/tmp/test.cfg'; ### the file to be saved

open FILE,"<$TFTP_FILE" or exit 3;
my @tmp = <FILE>;
my @tftp_params = split(":",$tmp[0]);



my $tftp = Net::TFTP->new($tftp_params[0], BlockSize => 512, Retires => 2, Timeout => 2, Mode => 'binary');

$tftp->get($tftp_params[1], "/usr/local/nagios/var/tmp/test.cfg");

if ($tftp->error()) {
   print "CRITICAL - " . $tftp->error;
   exit 2;
}

print "OK - File DOWNLOADED";
exit 0;
