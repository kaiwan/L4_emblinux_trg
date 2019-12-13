#!/bin/sh
#------------------------------------------------------------------
# common.sh
#
# Common convenience routines
# 
# (c) Kaiwan NB.
# GPL / LGPL
#------------------------------------------------------------------

export TOPDIR=$(pwd)

# Display a string in "title" form
# Parameter(s):
#  $1 : String to display [required]
ShowTitle()
{
	[ $# -ne 1 ] && return 1
	SEP='-------------------------------------------------------------------------------'
	echo $SEP
	echo $1
	echo $SEP
}

# Check whether we are running as root user; if not, exit with failure!
# Parameter(s):
#  None.
# "AIA" = Abort If Absent :-)
check_root_AIA()
{
	if [ `id -u` -ne 0 ]; then
		echo "Error: need to run as root! Aborting..."
		exit 1
	fi
}

# Check whether the file, passed as a parameter, exists; if not, exit with failure!
# Parameter(s):
#  $1 : Pathname of file to check for existence. [required]
# "AIA" = Abort If Absent :-)
check_file_AIA()
{
	[ $# -ne 1 ] && return 1
	[ ! -f $1 ] && {
		echo "Error: file \"$1\" does not exist. Aborting..."
		exit 1
	}
}

# Check whether the directory, passed as a parameter, exists; if not, exit with failure!
# Parameter(s):
#  $1 : Pathname of folder to check for existence. [required]
# "AIA" = Abort If Absent :-)
check_folder_AIA()
{
	[ $# -ne 1 ] && return 1
	[ ! -d $1 ] && {
		echo "Error: folder \"$1\" does not exist. Aborting..."
		exit 1
	}
}

# Display the error message string.
# Parameter(s):
#  $1 : Error string to display [required]
ShowError()
{
	echo $1
	cd ${TOPDIR}
	exit -1 
}

# Extract IP address from ifconfig output
# Parameter(s):
#  $1 : name of network interface (string)
GetIP()
{
	[ $# -ne 1 ] && return 1
	ifconfig $1 >/dev/null 2>&1 || return 2
	ifconfig $1 |grep 'inet addr'|awk '{print $2}' |cut -f2 -d':'
}
