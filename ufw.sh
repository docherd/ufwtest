#!/bin/sh

# Simple admin script to install ufw (firewall) on a remote host and
# perform an update of all packages.
# Assume that either an RSA key has been created and/or /etc/sudoers
# allows root access for the user on the remote machine.
#

SSH=/usr/bin/ssh
SUDO=/usr/bin/sudo
LOGFILE=/tmp/ufw.log
TIMEOUT=30

# list of connections to allow (example)
CONNECTIONS="ftp www"

# Usage: ufw.sh user@host
#
usage()
{
        echo "ufw.sh user@host" && exit 1
}

fatal()
{
        echo "Fatal Error" >&2
        exit 1
}

test $# -ne 1 && usage 
REMOTE=$1

# Test user@hosts
#
$SSH -oNumberOfPasswordPrompts=0 $REMOTE ls >/dev/null || exit 1

# Finally, check sudo.
#
echo "xxxxxx" | $SSH $REMOTE $SUDO -S /bin/echo >/dev/null || exit 1

# First update all packages.
$SSH $REMOTE $SUDO apt-get update 
test $? -ne 0 && fatal

$SSH $REMOTE $SUDO apt-get upgrade 
test $? -ne 0 && fatal

# Install ufw.
#
$SSH $REMOTE $SUDO apt-get install ufw 
test $? -ne 0 && fatal

# Status check
#
$SSH $REMOTE $SUDO ufw status 
test $? -ne 0 && fatal

# Make sure SSH is allowed !
#
$SSH $REMOTE $SUDO ufw allow ssh 
test $? -ne 0 && fatal

# Now set up specfic connections as defined above.
#
for con in $CONNECTIONS
do
        $SSH $REMOTE $SUDO ufw allow $con 
        test $? -ne 0 && fatal
done

# Now start ufw
#
$SSH $REMOTE $SUDO ufw enable 
test $? -ne 0 && fatal

# Seems to have worked, now a reboot
# Note: normally would check for users/apps before the reboot
# but assuming I am in a maintenance window at the moment.
echo "System Going Down in $TIMEOUT Seconds" | \
$SSH $REMOTE $SUDO /usr/bin/wall
sleep $TIMEOUT
$SSH $REMOTE $SUDO /sbin/reboot
sleep 10

# At this point, busy loop waiting for sever to come back online
SERVER=`expr $REMOTE : '.*[@]\([^@]*\)'`
while true
do
        ping -q -c1 -w1 $SERVER >/dev/null
        test $? -eq 0 && break
done

sleep 10

# Check ufw status
$SSH $REMOTE $SUDO ufw status 

# Check uptime
/bin/echo -n "$SERVER Uptime: "
$SSH $REMOTE $SUDO /usr/bin/uptime 

exit 0
