#!/bin/bash
# Script for Installation / Upgrade of Microsoft Linux Integration Services on RHEL / CentOS

PWD=`pwd`
#Checking root users
if [ "$(id -u)" != "0" ]; then
   echo ""
   echo "Please run the script with root user or prefix \"sudo\" before the command" 
   echo "exiting..";echo ""
   exit 1
fi

###############
Wget_check ()
{
echo "Checking for wget"
	which wget > /dev/null
	if [ `echo $?` = 0 ]; then
	LIS_install $1 
	else	
		sudo yum -y install wget
		if [ `echo $?` = 0 ];then
		LIS_install $1 
		else
			echo "Exiting...wget command is not available and we are unable to install it using yum"
			exit
		fi
	fi
}

LIS_install ()
{

echo "Downloading Microsoft LIS"
wget -N https://github.com/pankajpandey9/simple-scripts/raw/master/lis4.0.11.tar.gz > /dev/null
if [ `echo $?` = 0 ];then
	echo "Uncompressing Microsoft LIS file"
	tar xvzf lis4.0.11.tar.gz
	echo "IPerformin Microsoft LIS "$1" "
	cd lis4.0.11
	./"$1".sh > /dev/null
	if [ `echo $?` = 0 ]; then
	
		/sbin/modinfo hv_vmbus # module information for each installed kernel module
		/sbin/lsmod | grep hv  # verify all subcomponents are running in the kernel
		
		echo ""$1" complete.. please, Reboot your server to reflect the changes"
	else
		echo "Failed to install LIS on `hostname`...use any of the following options to install it manually"
		echo "1- Please install it manually from the downloaded package"
		echo "2- go to \"https://www.microsoft.com/en-us/download/details.aspx?id=46842\" -> download the package and install it"
	fi
	cd $PWD
fi
}
###############
#------Main----#

echo "Checking for previous installation"

sudo rpm -qa |grep microsoft-hyper > /dev/null
if [ `echo $?` = 0 ]; then
	echo "packages are available"
	sudo rpm -qa |grep microsoft-hyper|grep 20150728 > /dev/null
	if [ `echo $?` = 0 ]; then
		echo "installed version is \"lis4.0.11\""
		echo "Nothing to do, Exiting"
		exit
	else
		echo "installed version is different than \"lis4.0.11\", performing upgrade/reinstall"
		Wget_check "upgrade" 
	fi
else
		Wget_check "install" 
fi

