#!/bin/bash

source "install_functions.sh"

if [ "$1" == "uninstall" ];
then
	uninstall
else
	install
fi
