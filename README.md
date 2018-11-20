# CHeck DOCSIS Provisioning

I had a lot of problems with our DHCP server so I had to check the system via Nagios. So I created the following perl scripts.

# Requirements
- Net::DHCP
- Net::TFTP

# Installation
/usr/bin/perl -MCPAN -e 'install Net::DHCP'
/usr/bin/perl -MCPAN -e 'install Net::TFTP'

