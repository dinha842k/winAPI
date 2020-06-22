# main fuction


## classic main func

```c
int main(void);
int main(int args, char ** argv);
int main(int args, char *argv[]);

```
## main func with unicode character

```c
int wmain(void);
int wmain(int args, wchar_t **argv);
int wmain(int args, wchar_t *argv[]);
```
1. wchar_t -> new datatype -> ref.
2. wmain -> wide main
```c
//unicode example
#include <windows.h>  //for PDWORD,HANDLE,STD_OUTPUT_HANDLE,INVALID_HANDLE_VALUE,GetStdHandle(),GetLastError(),WriteConsoleW(),CloseHandle()
#include <wchar.h>    //for wchar_t,wprintf() 

int wmain(int args,wchar_t ** argv){
  PDWORD c = NULL;
  HANDLE std = GetStdHandle(STD_OUTPUT_HANDLE);
  if(std == INVALID_HANDLE_VALUE){
    wprintf(L"error on get handle (%d)",GetLastError());
   }
  if(argv[1]){
    WriteConsoleW(std,argv[1],wcslen(argv[1]),c,NULL);
   }
  CloseHandle(std);
   return 0;
 }
  
```
## main fuc combine all
#### prototype
```c
int _tmain(void);
int _tmain(int args,_TCHAR **argv);
int _tmain(int args,_TCHAR *argv[]);
```
#### example
```c
#define _UNICODE
#define UNICODE
// if not define it will use ANSI
#include <windows.h>
#include <tchar.h>

int _tmain(int args,_TCHAR **argv){
  PDWORD c = NULL;
  HANDLE std = GetStdHandle(STD_OUTPUT_HANDLE);
  if(std == INVALID_HANLE_VALUE){
    _tprintf(L"error on get handle (%d)",GetLastError());
   }
   if(argv[1]){
     WriteConsole(std,argv[1],_tcslen(argv[]1),c,NULL);
    }
   CloseHandle(std);
   return 0;
}
```
