@echo off

:: installation path can be passed as argument
if [%1]==[] (
   set "installpath=%ProgramFiles%\Environment Modules"
) else (
   set "installpath=%1"
)

:: remove bin directory from system path
set "binpath=%installpath%\bin"
setlocal enableextensions enabledelayedexpansion
set "NEWPATH=!PATH:%binpath%;=!"
if not "%NEWPATH%" == "%PATH%" (
   set "PATH=%NEWPATH%"
   :: 'reg add' is used instead of 'setx /M' as the latter silently
   :: truncates the value it persists to 1024 characters
   reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v PATH /t REG_EXPAND_SZ /d "%NEWPATH%" /f
)
if errorlevel 1 ( exit /b 1 )

:: remove installation directory and content
rd /s /q "%installpath%"
:: quit on error if directory still exists
if exist "%installpath%" ( exit /b 2 )

:: vim:set tabstop=3 shiftwidth=3 expandtab autoindent:
