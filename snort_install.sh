#! /bin/bash


#********************************************************************
#
# Snort Docker installation		
#								
# Author: Sakari Järvinen		2018-10-01
#
#
# Snort Docker Installation for Centos7.4.1708
#
# NOTE: run as sudo,
# 		run $sudo yum update before installation script
#
#********************************************************************



SDIR="/etc/snort"					#snort configuration directory
SRDIR="/etc/snort/rules"			#snort rules directory
FDIR="/opt/snort_monitor/"			#snort install configuration files
S=$(sleep 2)						#sleep between installation steps

# Install DAQ 2.0.6
echo "INSTALLING DAQ 2.0.6"
yum -y install \
       https://snort.org/downloads/snort/daq-2.0.6-1.centos7.x86_64.rpm
$S

# Install Snort dependencies
echo "INSTALLING SNORT DEPENDENCIES"
yum -y install \
	gcc \
	flex \
	bison \
	zlib \
	libpcap \
	pcre \
	libdnet-devel \
	tcpdump \
	epel-release \
	libnghttp2
$S

# Install Snort 2.9.11.1
echo "INSTALLING SNORT 2.9.11.1"
yum -y install\
       https://snort.org/downloads/snort/snort-2.9.12-1.centos7.x86_64.rpm
$S

# Create folders and files for Snort
echo "CREATING FOLDERS AND FILES FOR SNORT"
touch /etc/snort/white_list.rules \
      /etc/snort/black_list.rules \
      /usr/local/lib/snort_dynamicrules
$S

# backup installed snort.conf and copy modified snort.conf as main conf file
# NOTE: Uncomment if needed (for Docker containers)
#echo "Backup snort.conf and copy pre-configured snort.conf & local rules"
#cd $SDIR
#mv snort.conf snort.conf.bak
#cd $FDIR
#cp snort.conf $SDIR
#cp local.rules $SRDIR
#$S

# set Snort permissions
echo "SETTING PERMISSIONS FOR SNORT"
chmod -R 5775 /etc/snort
chmod -R 5775 /var/log/snort
chmod -R 5775 /usr/local/lib/snort_dynamicrules
chown -R snort:snort /etc/snort
chown -R snort:snort /var/log/snort
$S

# Create link
echo "CREATING LINK"
ln -s /usr/lib64/libdnet.so.1.0.1 /usr/lib64/libdnet.1
$S

# Start and enable Snort in systemctl
echo "STARTING AND ENABLING SNORT DAEMON"
systemctl start snortd
systemctl enable snortd
$S

# Test Snort config file
echo "TESTING SNORT CONFIGURATION FILE"
$S
snort -T -c /etc/snort/snort.conf
