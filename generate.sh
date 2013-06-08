#!/bin/bash

source functions.sh

src_test
obj_test
bin_test

src_code_test

if [ "$EXIT_AFTER_TESTS" = "1" ];
then
	print_with_color "red" "A test complained, stopping!"
	exit 0;
fi

print_with_color "green" "Continuing with the generation!"

sleep 0.5s
detect_language
if [ "$LANGUAGE" != "" ];
then
	print_with_color "green" "Language: $LANGUAGE"
fi

if [ "$LANGUAGE" = "C" ];
then
	COMPILER="gcc"
else
	COMPILER="g++"
fi

echo

sleep 0.5s

detect_header_files
if [ "$HEADERS" != "" ];
then
	print_with_color "green" "Header files: $HEADERS"
fi

sleep 0.5s

detect_objects
if [ "$OBJECTS" != "" ];
then
	print_with_color "green" "Objects: $OBJECTS"
else
	print_with_color "red" "No Objects! D:"
	exit -1
fi

sleep 0.5s

echo

print_with_color "green" "Detecting libraries from arguments"
detect_libraries "$@"

sleep 0.5s

print_with_color "cyan" "Generating Makefile now!"
generate_makefile

sleep 0.5s

print_with_color "magenta" "SUCCESS \\o/"
