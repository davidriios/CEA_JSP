@echo off

rem TO USE WITH JCREATOR AND HAVING MULTIPLE PROJECTS:
rem MOVE THIS FILE ONE UPPER LEVEL OF THE CURRENT PROJECT DIRECTORY
rem CONFIGURE JCREATOR'S TOOL (PROGRAM) AND SELECT THIS FILE, THEN SET ARGUMENTS PROJECT OUTPUT PATH

echo project classes directory = %1

if "%1" == "" goto :doEnd

rem CHANGE DRIVE
set CURDIR=%1
echo drive = %CURDIR:~0,2%
%CURDIR:~0,2%

cd %1

rem create jar file
call issiBio %1

:doEnd