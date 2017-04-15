#!/bin/bash

# Install latest modsecurity version for wordpress

# Install epel repository and wget
echo "Installing epel repositoty and wget....Please wait"
yum install -y epel-release wget >> /tmp/waf_reports.log
echo "Done..........................................[OK]"
echo -e "******************************************\n" >> /tmp/waf_reports.log

# Install codeit repository to install the apache lastest version (Ver. 2.5.25)  
echo "Installing codeit repositoty...........Please wait"
cd /etc/yum.repos.d && wget https://repo.codeit.guru/codeit.el`rpm -q --qf "%{VERSION}" $(rpm -q --whatprovides redhat-release)`.repo 2>> /tmp/waf_reports.log
echo "Done..........................................[OK]"
echo -e "******************************************\n" >> /tmp/waf_reports.log

# Install packets in order to install modsecurity and crs_rules
echo "Installing packets needed..............Please wait"
yum -y install httpd libtool automake curl httpd-devel pcre-devel libxml2-devel unzip git 2>> /tmp/waf_reports.log | >> /tmp/waf_reports.log
echo "Done..........................................[OK]"
echo -e "******************************************\n" >> /tmp/waf_reports.log

# Install latest mod_security version
echo "Installing mod_security................Please wait"
cd /tmp && wget https://github.com/SpiderLabs/ModSecurity/archive/master.zip 2>>  /tmp/waf_reports.log && unzip master.zip >> /tmp/waf_reports.log && cd ModSecurity-master/
echo "Done..........................................[OK]"
echo -e "******************************************\n" >> /tmp/waf_reports.log

# Run autogen.sh
echo "Run autogen.sh.........................Please wait"
./autogen.sh 2>> /tmp/waf_reports.log | >> /tmp/waf_reports.log
echo "Done..........................................[OK]"
echo -e "******************************************\n" >> /tmp/waf_reports.log

# Run configure
echo "Run configure..........................Please wait"
./configure >> /tmp/waf_reports.log
echo "Done..........................................[OK]"
echo -e "******************************************\n" >> /tmp/waf_reports.log

# Run make
echo "Run make...............................Please wait"
make >> /tmp/waf_reports.log
echo "Done..........................................[OK]"
echo -e "******************************************\n" >> /tmp/waf_reports.log

# Run make install
echo "Run make...............................Please wait"
make install >> /tmp/waf_reports.log
echo "Done..........................................[OK]"
echo -e "******************************************\n" >> /tmp/waf_reports.log

# create modsecurity.conf
echo "Create modsecurity.conf................Please wait"
sed 's/DetectionOnly/On/g' modsecurity.conf-recommended | sed 's/\/var\/log\/modsec_audit.log/\/var\/log\/httpd\/modsec_audit.log/g' > /etc/httpd/conf.d/modsecurity.conf
echo "Done..........................................[OK]"

# create unicode.mappaing
echo "Create unicode.mappaing................Please wait"
cp unicode.mapping /etc/httpd/conf.d/
echo "Done..........................................[OK]"

# add rules on httpd.conf
echo "Adding rules on httpd.conf.............Please wait"
echo -e "\nLoadModule security2_module modules/mod_security2.so\n \n<IfModule security2_module>\n   Include modsecurity.d/owasp-modsecurity-crs/crs-setup.conf\n   Include modsecurity.d/owasp-modsecurity-crs/rules/*.conf\n</IfModule>\n" >> /etc/httpd/conf/httpd.conf
echo "Done..........................................[OK]"

# crs rules download
echo "Crs rules downloading..................Please wait"
mkdir /etc/httpd/modsecurity.d/ && cd /etc/httpd/modsecurity.d/ && git clone --quiet https://github.com/SpiderLabs/owasp-modsecurity-crs && >> /tmp/waf_reports.log
echo "Done..........................................[OK]"

# create crs-setup.conf
echo "Creating crs-setup.conf................Please wait"
cp /etc/httpd/modsecurity.d/owasp-modsecurity-crs/crs-setup.conf.example /etc/httpd/modsecurity.d/owasp-modsecurity-crs/crs-setup.conf
echo "Done..........................................[OK]"

# enable and start httpd
echo "Restarting httpd service...............Please wait"
systemctl restart httpd.service
echo "Done..........................................[OK]"

# Add crs_rules update process on crontab
echo "Adding crontab update crs_rules........Please wait"
echo "0 2 * * * root /etc/httpd/modsecurity.d/owasp-modsecurity-crs/util/upgrade.py --crs --geoip" >> /etc/crontab
systemctl restart crond.service
echo "Done..........................................[OK]"

echo "********************************************************************************************"
echo "* Mod_security install complete ************************************************************"
echo "* To visualize logs about this installation access /tmp/waf_reports.log ********************"
echo "* To visualize mod_security logs access /var/log/httpd/modsec_audit.log ********************"
echo "********************************************************************************************"
echo "************************************************************************* by 5h0ckw4v3 *****"
echo "********************************************************************************************"
