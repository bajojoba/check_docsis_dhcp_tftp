# CHeck DOCSIS Provisioning

I had a lot of problems with our DHCP server so I had to check the system via Nagios. So I created the following perl scripts.

# Requirements
- Nagios must have a UDP connection enabled to DHCP/TFTP SERVER
- Net::DHCP
- Net::TFTP

# Installation
- /usr/bin/perl -MCPAN -e 'install Net::DHCP'
- /usr/bin/perl -MCPAN -e 'install Net::TFTP'
- edit check_dhcp.pl/check_tftp.pl and change the required fields

# RUNNING
- perl check_dhcp.pl '00:11:22:33:44:55' 
- perl check_tftp.pl
