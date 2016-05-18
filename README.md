
There are several ways perform this task or different languages one
can use. I have chosen the time tested way of using a simple shell
script as it is portable, easy to read and does not rely on having
to install other packages or rely on third party software.

Simple admin script to install ufw (firewall) on a remote host and
perform an update of all packages.

Assume that either an RSA key has been created and/or /etc/sudoers
allows root access for the user on the remote machine.
For example: ssh darren@server sudo echo "Hello, World"

Usage: ufw.sh user@server

Errors logged to stderr and output to stdout.


 
