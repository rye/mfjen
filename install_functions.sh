#!/bin/bash

uninstall ()
{
	if test -e /home/$USER/.bin/.mfjen;
	then
		rm -rf /home/$USER/.bin/.mfjen
		rm /home/$USER/.bin/mfjen

		echo "Should be gone now!"
	else
		echo "Didn't look like it was installed in the first place!"
	fi
	
	exit 0;
}

install ()
{
	z=$(echo $PATH | egrep -o "/home/$USER/.bin")
	if [ "$z" = "" ];
	then
		echo "Path does not contain /home/$USER/.bin!"
		echo "Appending (restart bash)!"
		echo "PATH=\$PATH:/home/\$USER/.bin" >> ~/.bashrc
	else
		echo "Path is already set!"
	fi
	
	mkdir -p /home/$USER/.bin/.mfjen
	cp functions.sh /home/$USER/.bin/.mfjen
	cp generate.sh /home/$USER/.bin/.mfjen
	ln -s /home/$USER/.bin/.mfjen/generate.sh /home/$USER/.bin/mfjen
}
