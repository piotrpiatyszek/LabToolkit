#!/usr/bin/with-contenv bash
if [ ! -z "$SSH_KEY" ]
then
	if [ ! -d "/root/.ssh" ]
	then
    		mkdir /root/.ssh/
		chmod 700 /root/.ssh/
	fi
	if [ ! -d "/root/.ssh/authorized_keys" ]
	then
		echo "$SSH_KEY" > /root/.ssh/authorized_keys
		chmod 600 /root/.ssh/authorized_keys
	fi

fi
