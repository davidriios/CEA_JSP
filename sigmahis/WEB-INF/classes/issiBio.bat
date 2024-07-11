@echo off
cls
rem DO NOT CALL THIS BATCH FROM IDE (JCreator), INSTEAD CALL genBiometricJar.bat OR EXECUTE DIRECTLY

rem must be classes dir
set CURDIR=%cd%
if "%1" == "" goto :doStartup
set CURDIR=%1
echo CURDIR=%CURDIR%

:doStartup
rem set project home
cd ../../../..
set PROJECT_HOME=%cd%
echo PROJECT_HOME=%PROJECT_HOME%

rem return to classes dir
cd %CURDIR%

set WEB_DIR=%PROJECT_HOME%\build\web
set REQ_DIR=%PROJECT_HOME%\Fingerprint\jar_requirements
set BUILD_DIR=%PROJECT_HOME%\Fingerprint\build

echo.
echo * * * * *   L O A D   R E Q U I R E M E N T S   T O   B U I L D   * * * * *
if not exist %BUILD_DIR% mkdir %BUILD_DIR%
XCOPY %REQ_DIR%\* %BUILD_DIR% /s /i /q /y /e
cd %BUILD_DIR%
if not exist %BUILD_DIR%\classes\issi\admin mkdir %BUILD_DIR%\classes\issi\admin
if not exist %BUILD_DIR%\classes\issi\applet mkdir %BUILD_DIR%\classes\issi\applet
if not exist %BUILD_DIR%\classes\issi\biometric mkdir %BUILD_DIR%\classes\issi\biometric
if not exist key mkdir key

echo.
echo * * * * *   D E L E T I N G   C L A S S E S   * * * * *
cd %BUILD_DIR%\classes\issi\admin
del /Q *
cd %BUILD_DIR%\classes\issi\applet
del /Q *
cd %BUILD_DIR%\classes\issi\biometric
del /Q *

echo.
echo * * * * *   C O P Y I N G   R E Q U I R E D   C L A S S E S   * * * * *
cd %PROJECT_HOME%\build\web\WEB-INF\classes\issi\admin
copy AppServObject.class %BUILD_DIR%\classes\issi\admin
copy ConsoleOutput.class %BUILD_DIR%\classes\issi\admin
copy ConsoleOutputFormatter.class %BUILD_DIR%\classes\issi\admin
copy IBIZEscapeChars.class %BUILD_DIR%\classes\issi\admin

cd %PROJECT_HOME%\build\web\WEB-INF\classes\issi\applet
copy *.class %BUILD_DIR%\classes\issi\applet

cd %PROJECT_HOME%\build\web\WEB-INF\classes\issi\biometric
copy Fingerprint.class %BUILD_DIR%\classes\issi\biometric


echo.
echo * * * * *   D E L E T I N G   K E Y   * * * * *
cd %BUILD_DIR%\key
del /Q *

echo.
echo %BUILD_DIR%
cd %BUILD_DIR%

echo.
echo * * * * *   G E N E R A T I N G   K E Y S T O R E   * * * * *
"%JAVA_HOME%\bin\keytool.exe" -genkey -alias biokey -keystore .\key\biostore.keystore -dname "cn=Bio Demo, ou=Developing, o=ISSI c=PA" -storepass biodemo -keypass biodemo -validity 365 -noprompt

echo.
echo * * * * *   G E N E R A T I N G   J K S   * * * * *
"%JAVA_HOME%\bin\keytool.exe" -genkey -alias biokey -keystore .\key\biostore.jks -dname "cn=Bio Demo, ou=Developing, o=ISSI c=PA" -keypass biodemo -storepass biodemo -validity 365 -noprompt

echo.
echo * * * * *   E X P O R T   C E R T I F I C A T E   A U T H O R I T Y   * * * * *
"%JAVA_HOME%\bin\keytool.exe" -export -alias biokey -keystore .\key\biostore.jks -storepass biodemo -file .\key\biostore.crt -noprompt

echo.
echo * * * * *   C R E A T I N G   J A R   * * * * *
"%JAVA_HOME%\bin\jar.exe" cvf issibio.jar -C classes .

echo.
echo * * * * *   V E R I F Y I N G   J A R   * * * * *
"%JAVA_HOME%\bin\jar.exe" tvf issibio.jar

echo.
echo * * * * *   S I G N I N G   J A R   * * * * *
"%JAVA_HOME%\bin\jarsigner.exe" -keystore .\key\biostore.jks -storepass biodemo -keypass biodemo  issibio.jar biokey

rem echo.
rem echo * * * * *   V E R I F Y I N G   J A R   S I G N   * * * * *
rem "%JAVA_HOME%\bin\jarsigner.exe" -verify -verbose -certs issibio.jar

echo.
echo * * * * *   C O P Y I N G   J A R   * * * * *
xcopy %BUILD_DIR%\issibio.jar %WEB_DIR%\applet /Y

cd %CURDIR%

if not "%1" == "" goto :doEnd
pause

:doEnd