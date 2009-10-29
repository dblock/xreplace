@echo off

setlocal

set DOCS=..\..\docs
set INSTALLBIN=..\..\..\InstallBin
set PROGRAM=..\xrep32.exe
set DISKBIN=%INSTALLBIN%\disk

@echo Cleaning up ...
if exist data\ rd /s /q data
mkdir data

@echo Copying %PROGRAM% ...
copy %PROGRAM% data /y > nul

@echo Copying regdll.dll ...
copy ..\RegDll.dll data\regdll.dll /y > nul

@echo Copying docs ...
xcopy %DOCS% data\docs /s/i /y > nul

if exist data.z del data.z
%INSTALLBIN%\icomp -i data\*.* data.z

if not exist disk mkdir disk
move data.z disk

%INSTALLBIN%\compile setup\setup.rul
copy setup\setup.ins disk

%INSTALLBIN%\packlist setup\setup.lst
move setup.pkg disk
if exist data\ rd /s /q data

copy %DISKBIN%\*.* disk > nul

endlocal