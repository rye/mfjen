#include <stdio.h>
#include <stdbool.h>

#include <src/osdetect.h>

#include <src/main.h>

bool succeeded = true;

int main(int argc, char *argv[])
{
	/* will remove when program is done */
	printf("You are running %s\n", OS_STRING);
	
	printf("mfjen starting...\n");

	/* do stuff */

	printf("mfjen %s!\n", succeeded ? "created Makefile at -insert file location-" : "failed to create Makefile at -blah-");

	return 0;
}
