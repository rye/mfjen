#!/bin/bash

# Detects if include/*/*.{h,c} src/*/*.{h,c} is a thing
# (only detects first-level subdirectories, symlink if necessarily)
detect_multi_src_folders ()
{
	SUBDIRECTORY_NAME_ARRAY=(include/*/ src/*/)

	for ((i=0;i<${#SUBDIRECTORY_NAME_ARRAY[@]};i+=1));
	do
		if [ "$(basename ${SUBDIRECTORY_NAME_ARRAY[$i]})" = "*" ];
		then

			return

		fi
	done
}

# Prints, with given color (Argument #1), the given string (Argument #2)
# Uses ANSI escape sequences, tested on XTerm and Terminator
print_with_color ()
{
	case $1 in
		"black")
			COLORSTR="\033[30m"
			;;

		"red")
			COLORSTR="\033[31m"
			;;

		"green")
			COLORSTR="\033[32m"
			;;

		"yellow")
			COLORSTR="\033[33m"
			;;

		"blue")
			COLORSTR="\033[34m"
			;;

		"magenta")
			COLORSTR="\033[35m"
			;;

		"cyan")
			COLORSTR="\033[36m"
			;;

		"white")
			COLORSTR="\033[37m"
			;;

		*)
			COLORSTR="\033[39m"
			;;
	esac

	echo -en "$COLORSTR"
	echo -en "$2"
	echo -e "\033[39m"
}

# Tests to make sure that src exists
src_test ()
{
	if [ "$SRC_MUST_EXIST" != "1" ];
	then

		printf "%-32s" "'src' test... "

	fi

	if test -d src;
	then

		print_with_color "green" "OK!"

	else

		if [ "$SRC_MUST_EXIST" = "1" ];
		then

			print_with_color "red" "Something went bad!"
			exit -1;

		else

			echo -n "FAIL, creating... "
			mkdir src
			SRC_MUST_EXIST=1
			src_test

		fi
	fi
}

# Tests to make sure that obj exists
obj_test ()
{
	if [ "$OBJ_MUST_EXIST" != "1" ];
	then

		printf "%-32s" "'obj' test... "

	fi

	if test -d obj;
	then

		print_with_color "green" "OK!"

	else
		if [ "$OBJ_MUST_EXIST" = "1" ];
		then

			print_with_color "red" "Something went bad!"
			exit -1;

		else

			echo -n "FAIL, creating... "
			mkdir obj
			touch obj/.gitkeep
			OBJ_MUST_EXIST=1
			obj_test

		fi
	fi
}

# Makes sure that there are Cxx source files in src
src_code_test ()
{
	array=(src/*.c*)

	if [ "${array[0]}" = "src/*.c*" ];
	then

		print_with_color "red" "No source detected in 'src/', create some!"
		EXIT_AFTER_TESTS=1

	else

		printf "%-32s" "'source code' test... "
		print_with_color "green" "OK!"

	fi
}

# Detects the language
detect_language ()
{
	array=(src/*.c*)

	for ((i=0;i<${#array[@]};i+=1));
	do

		filename=$(basename ${array[$i]})

		case "${filename##*.}" in
			"c")
				LANGUAGE="C"
				;;

			*)
				# if it's got a weird file extension, it's c++, right?
				LANGUAGE="C++"
				;;
		esac

		FILE_EXTENSION="${filename##*.}"

	done
}

# Detects the header files in src
detect_header_files ()
{
	if [ $SUBDIRECTORIES ];
	then

		array=(include/ include/*/ src/ src/*/)

		for header_path in "${array[@]}"
		do

			header_path_files="$header_path*.h*"
			header_path_files_array=( $header_path_files )

			if test -e ${header_path_files_array};
			then

				HEADER_DIRS_INCLUDE="$HEADER_DIRS_INCLUDE -I $header_path "

			fi
		done

		array=(include/*.h* include/*/*.h* src/*.h* src/*/*.h*)

		if test -e ${array[0]};
		then

			HEADERS="${array[0]}";

		fi

		for ((i=0;i<${#array[@]};i+=1));
		do

			if test -e ${array[$i]};
			then

				HEADERS="$HEADERS ${array[$i]}"

			fi
		done
	else

		array=(include/)

		for header_path in "${array[@]}"
		do

			header_path_files="$header_path*.h*"
			header_path_files_array=( $header_path_files )
			if test -e ${header_path_files_array};
			then
				HEADER_DIRS_INCLUDE="$HEADER_DIRS_INCLUDE -I $header_path "
			fi
		done

		array=(include/*.h* src/*.h*)

		if [[ "${array[0]}" = "include/*.h*" || "${array[0]}" = "src/*.h*" ]];
		then

			print_with_color "yellow" "No headers detected in 'src/' or 'include/'."

		else

			HEADERS="${array[0]}"
			for ((i=1;i<${#array[@]};i+=1));
			do

				if test -e ${array[$i]};
				then

					HEADERS="$HEADERS ${array[$i]}"

				fi
			done
		fi
	fi

}

# Detects the object code to generate based on the names of the source files in C
detect_objects ()
{
	if [ $SUBDIRECTORIES ];
	then

		sourcearray=(src/*.c* src/*/*.c*)
		last=${#soucearray[@]}-1

		for ((i=0;i<${#sourcearray[@]};i+=1));
		do

			if [ "${sourcearray[$i]}" = "src/*/*.c*" ];
			then

				BRK=0

			fi

			if [ "$BRK" != "0" ];
			then

				dir_name="$(dirname ${sourcearray[$i]})"
				dir_basename="$(basename $dir_name)"
				filename="$(basename ${sourcearray[$i]})"

				echo -n "${sourcearray[$i]}: dn \"$dir_name\" db \"$dir_basename\" fn \"$filename\"; "

				if [ "$dir_basename" = "src" ];
				then

					echo "base-level source"
					if [ "$i" = "0" ];
					then

						OBJECTS="obj/${filename%.*}.o"

					else

						OBJECTS="$OBJECTS obj/${filename%.*}.o"

					fi

				else

					echo "subdir source"

					mkdir -p obj/${dir_basename}

					if [ "$i" = "0" ];
					then

						OBJECTS="obj/${dir_basename}/${filename%.*}.o"

					else

						OBJECTS="$OBJECTS obj/${dir_basename}/${filename%.*}.o"

					fi
				fi
			fi
		done
	else

		sourcearray=(src/*.c*)

		for ((i=0;i<${#sourcearray[@]};i+=1));
		do

			filename="$(basename ${sourcearray[$i]})"

			if [ $i -eq 0 ];
			then

				OBJECTS="obj/${filename%.*}.o"

			else

				OBJECTS="$OBJECTS obj/${filename%.*}.o"

			fi
		done
	fi
}

detect_libraries ()
{
	arg=("$@")

	for ((i=0;i<${#arg[@]};i+=1));
	do

		case "${arg[$i]}" in

			"-f" | "--flags")
				FLAGS="${arg[$i+1]}"
				;;

			"-l" | "-lf" | "--linkflags")
				LINKFLAGS="-l${arg[$i+1]}"
				;;

			"-cf" | "--compileflags")
				COMPILEFLAGS="${arg[$i+1]}"
				;;

			*)
				;;

		esac
	done

	# prepend to the thing, $FLAGS is global flags
	LINKFLAGS="$FLAGS $LINKFLAGS"
	COMPILEFLAGS="$FLAGS $COMPILEFLAGS"

	print_with_color "magenta" "LINKFLAGS=\$(FLAGS) $LINKFLAGS"
	print_with_color "magenta" "COMPILEFLAGS=\$(FLAGS) $COMPILEFLAGS"
}

generate_makefile ()
{
	if [ $SUBDIRECTORIES ];
	then

		EXTRASTRING="obj/*/%.o: src/*/%.$FILE_EXTENSION \$(HEADERS)
	\$(COMPILER) -c -o \$@ \$< \$(COMPILEFLAGS) -fPIC"

	fi

	PROJECT_NAME=$(basename `pwd`)

	echo \
"# Makefile, autogenerated by mfjen
# Edit at will, regenerating obliterates changes, fair warning

COMPILER=$COMPILER

COMPILEFLAGS=\$(FLAGS) $COMPILEFLAGS
LINKFLAGS=\$(FLAGS) $LINKFLAGS

HEADERS=$HEADERS
HEADER_DIRS_INCLUDE=$HEADER_DIRS_INCLUDE

PROGRAMOBJECTS=$OBJECTS

PROGRAM=src/$PROJECT_NAME.\$(shell arch)

all: \$(PROGRAM)

$EXTRASTRING

include/%.h:

obj/%.o: src/%.$FILE_EXTENSION
	\$(COMPILER) -c -o \$@ \$< \$(COMPILEFLAGS) \$(HEADER_DIRS_INCLUDE) -fPIC

\$(PROGRAM): \$(PROGRAMOBJECTS)
	\$(COMPILER) -o \$(PROGRAM) \$(PROGRAMOBJECTS) \$(LINKFLAGS)
" > Makefile
}

print_with_color "cyan" "Running some tests on your tree!"

src_test
obj_test

detect_multi_src_folders

if [ "${#SUBDIRECTORY_NAME_ARRAY[@]}" = "1" ] && [ "$(basename ${SUBDIRECTORY_NAME_ARRAY[0]})" = "*" ];
then

	echo "No subdirectories detected!"
	SUBDIRECTORIES=0

else

	for ((i=0;i<${#SUBDIRECTORY_NAME_ARRAY[@]};i+=1));
	do

		echo "Subdirectories: ${SUBDIRECTORY_NAME_ARRAY[$i]}"

	done

	SUBDIRECTORIES=0

fi

src_code_test

if [ "$EXIT_AFTER_TESTS" = "1" ];
then

	print_with_color "red" "A test complained, stopping!"
	exit 0;

fi

print_with_color "cyan" "Tests done, generating!"

detect_language

if [ "$LANGUAGE" != "" ];
then

	print_with_color "yellow" "Language: $LANGUAGE"

fi

if [ "$LANGUAGE" = "C" ];
then

	COMPILER="gcc"

else

	COMPILER="g++"

fi

detect_header_files

if [ "$HEADERS" != "" ];
then

	print_with_color "magenta" "Header files: $HEADERS"

fi

detect_objects

if [ "$OBJECTS" != "" ];
then

	print_with_color "magenta" "Objects: $OBJECTS"

else

	print_with_color "red" "No Objects! D:"
	exit -1

fi

print_with_color "cyan" "Detecting libraries from arguments!"
detect_libraries "$@"

print_with_color "cyan" "Generating Makefile now!"
generate_makefile

print_with_color "cyan" "SUCCESS \\o/"
