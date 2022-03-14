@ECHO OFF

REM Install to AppData\Local directory
:: The following code has been written by referring to the following pages:
:: https://docs.microsoft.com/ko-kr/windows-server/administration/windows-commands/xcopy
SET "DIR_CURRENT=%~dp0\.." &call:getRealPath DIR_CURRENT
SET "DIR_INSTALLED=%LOCALAPPDATA%\dns"

ECHO "install to local appdata directory: %DIR_INSTALLED%"
xcopy %DIR_CURRENT% %DIR_INSTALLED% /s /e /y /i


::--------------------------------------------------------
::-- DEPRECATED
::REM Register itself as a startup program of Windows OS by creating link file(.lnk)
:::: The following code has been written by referring to the following pages:
:::: https://superuser.com/questions/392061/how-to-make-a-shortcut-from-cmd
:::: https://stackoverflow.com/questions/30028709/how-do-i-create-a-shortcut-via-command-line-in-windows
:::: https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/call#batch-parameters
::
::SET "STARTUP_DIR=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"
::SET "SHORTCUT_PATH=%STARTUP_DIR%\%~n0.lnk"
::SET "TARGET_PATH=%~f0"
::call SET TARGET_PATH=%%TARGET_PATH:%DIR_CURRENT%=%=%%DIR_INSTALLED%%%
::
::IF NOT EXIST "%SHORTCUT_PATH%" (
::    ECHO "register this script(add internal DNS) as startup script"
::    PowerShell -Command "$s=(New-Object -ComObject WScript.Shell).CreateShortcut('%SHORTCUT_PATH%'); $s.TargetPath='%TARGET_PATH%'; $s.Save()"
::)
::-- DEPRECATED
::--------------------------------------------------------


REM Run PowerShell script by bypassing the execution policy of Windows OS and running as administrator 
:: The following code has been written by referring to the following pages:
:: https://docs.microsoft.com/en-us/azure/cloud-services/cloud-services-startup-tasks-common#create-a-powershell-startup-task
:: https://stackoverflow.com/questions/50765949/redirect-stdout-stderr-from-powershell-script-as-admin-through-start-process

::--------------------------------------------------------
::-- DEPRECATED
::SET "TARGET_SCRIPT=%~dp0\register_dns.ps1" &call:getRealPath TARGET_SCRIPT
::call SET TARGET_SCRIPT=%%TARGET_SCRIPT:%DIR_CURRENT%=%=%%DIR_INSTALLED%%%
::-- DEPRECATED
::--------------------------------------------------------
SET "TARGET_SCRIPT=%~dp0\register_as_schedule.ps1" &call:getRealPath TARGET_SCRIPT
call SET TARGET_SCRIPT=%%TARGET_SCRIPT:%DIR_CURRENT%=%=%%DIR_INSTALLED%%%

REM   Run an unsigned PowerShell script and log the output
PowerShell -Command "&{Start-Process PowerShell -Wait -Verb RunAs -ArgumentList '-ExecutionPolicy Unrestricted -NoExit ""%TARGET_SCRIPT%""'}"
::PowerShell -Command "&{Start-Process PowerShell -Wait -Verb RunAs -ArgumentList '-ExecutionPolicy Unrestricted ""%TARGET_SCRIPT%""'}"

REM   If an error occurred, return the errorlevel.
EXIT /B %errorlevel%


::--------------------------------------------------------
::-- DEPRECATED
REM CAUTION:
::      register_dns.ps1 script is written for PowerShell version 1.0.
::      Therefore, the script below doesn't work.

::REM   Attempt to set the execution policy by using PowerShell version 2.0 syntax.
::PowerShell -Version 2.0 -ExecutionPolicy Unrestricted %TARGET_SCRIPT% >> "%TEMP%\%LOG_FILENAME%" 2>&1
::
::REM   If PowerShell version 2.0 isn't available. Set the execution policy by using the PowerShell
::IF %ERRORLEVEL% EQU -393216 (
::    ECHO "PowerShell version 2.0 isn't available. Run as version 1.0."
::    PowerShell -Command "Set-ExecutionPolicy Unrestricted" >> "%TEMP%\%LOG_FILENAME%" 2>&1
::    PowerShell %TARGET_SCRIPT% >> "%TEMP%\%LOG_FILENAME%" 2>&1
::)
::
::REM   If an error occurred, return the errorlevel.
::EXIT /B %errorlevel%
::-- DEPRECATED
::--------------------------------------------------------


REM Bash functions
:: The following code has been written by referring to the following pages:
:: https://www.dostips.com/DtTutoFunctions.php

goto:eof
::--------------------------------------------------------
::-- Function section starts below here
::--------------------------------------------------------
:getRealPath                &:: get real path of directory
                             :: -- %~1: path string
SETLOCAL
call SET "RELPATH=%%%~1%%"
SET "ABSPATH=%RELPATH%"     &:: set local variable
pushd .                     &:: push a current directory
cd "%RELPATH%"
IF "%ERRORLEVEL%"=="0" (    REM verify that the argument is a folder and exists
    set "ABSPATH=%CD%"
) ELSE (
    echo.path: "%RELPATH%"
)
popd                        &:: go back to the previous directory
(ENDLOCAL                   REM return local variable to referenced variable
    SET "%~1=%ABSPATH%"
)
goto:eof
