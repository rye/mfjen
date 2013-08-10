#ifndef OSDETECT_H
#define OSDETECT_H

#ifdef _WIN64
#define OS 0
#define OS_STRING "Windows"
#elif _WIN32
#define OS 0
#define OS_STRING "Windows"
#elif __APPLE__
#define OS 2
#define OS_STRING "Mac"
#elif __linux
#define OS 1
#define OS_STRING "Linux"
#elif __unix
#define OS 1
#define OS_STRING "Linux"
#elif __posix
#define OS 1
#define OS_STRING "Linux"
#else
#define OS -1
#define OS_STRING "undef"
#endif

#define WINDOWS 0
#define LINUX 1
#define MAC 2

#if OS == WINDOWS
#define PATH_SEP "\\"
#else
#define PATH_SEP "/"
#endif

#endif
