@echo off
setlocal enabledelayedexpansion

:: ENVML, setup environment with module then run specified command
:: Copyright (C) Modules Contributors
::
:: This program is free software: you can redistribute it and/or modify
:: it under the terms of the GNU General Public License as published by
:: the Free Software Foundation, either version 2 of the License, or
:: (at your option) any later version.
::
:: This program is distributed in the hope that it will be useful,
:: but WITHOUT ANY WARRANTY; without even the implied warranty of
:: MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
:: GNU General Public License for more details.
::
:: You should have received a copy of the GNU General Public License
:: along with this program.  If not, see <http://www.gnu.org/licenses/>.
::

set progpath=%~dpnx0
set prog=%~nx0
set kind_of_arg=mod
set modarglist=
set maymodarglist=
set maycmdarglist=
set cmdarglist=


:: command help is asked
if "x%~1" equ "x" goto:echo_usage&goto:end_script
if "%~1" equ "-h"  goto:echo_usage&goto:end_script
if "%~1" equ "--help"  goto:echo_usage&goto:end_script

:: parse arguments
set ERRORLEVEL=
call :parse_args %*
if %ERRORLEVEL% NEQ 0 exit /B %ERRORLEVEL%&goto:end_script

:: if a cmd separator has been found what we thought
:: to be module-related is really module-related
if "%kind_of_arg%" equ "cmd" (
    set modarglist=%modarglist%;%maymodarglist%
) else (
    set cmdarglist=%maycmdarglist% %cmdarglist%
)

:: initialize Modules if not already done
if not defined MODULES_CMD (
   call "%~dp0..\init\cmd.cmd"
)

:: load all required modules
call :load_mod "%modarglist%"

:: now execute the real command with its interpreter
if "x%cmdarglist%" equ "x" goto:end_script

set CALLARG=
set t=%cmdarglist:"=%
if "%t:.bat=%" neq "%t%" set "CALLARG=call "

%CALLARG%%cmdarglist% %maymodarglist%

:end_script
endlocal &set ERRORLEVEL=%ERRORLEVEL%

goto:eof


:: print message on stderr then exit
:echo_error
    echo %prog%: %~1 >&2
    exit /B 1
goto:eof

:arg_into_mod
set MODACTION=%~1
if "!kind_of_arg!" equ "mod" (
    set modarglist=!modarglist!;%~1
) else (
    set maymodarglist=!maymodarglist!;%~1
    set maycmdarglist=!maycmdarglist! %~1
)
call :decompose_mod "%%~2"

goto:eof


:arg_into_modaction

for /F "tokens=1,* delims==" %%I in ("%~1") do (
    if "!kind_of_arg!" equ "mod" (
        set modarglist=!modarglist!;!MODACTION! %%~I
    ) else (
        set maymodarglist=!maymodarglist!;!MODACTION! %%~I
        set maycmdarglist=!maycmdarglist! %%~I
    )
    call :decompose_mod "%%~J"
)

goto:eof

:decompose_mod

for /F "tokens=1,* delims=;" %%I in ("%~1") do (
    if "!kind_of_arg!" equ "mod" (
        set modarglist=!modarglist! %%~I
    ) else (
        set maycmdarglist=!maycmdarglist! %%~I
    )
    if "%%~J" neq "" call :decompose_mod "%%~J"
)

goto:eof


:: print usage message
:echo_usage

echo(Usage: %progpath% [MODULE_ACTION]... [--] COMMAND [ARG]...
echo(Run MODULE_ACTION(s) to setup environment then run COMMAND.
echo.
echo(Syntax of supported MODULE_ACTIONs:
echo(  purge                  unload all loaded modulefiles
echo(  restore[=coll]         restore module list from collection named coll or
echo(                         default collection if no collection name provided
echo(  unload=mod1[;mod2...]  remove modulefile(s) mod1, (mod2...)
echo(  switch=mod1;mod2       unload modulefile mod1 and load mod2
echo(  [load=]mod1[;mod2...]  load modulefile(s) mod1, (mod2...)
echo.
echo(To clearly separate command-line arguments from the module action arguments
echo(a '--' argument can be used. Without this '--' separator, first argument is
echo(considered module action and following arguments are part of command-line.
echo.
echo(Examples:
echo(  %progpath% restore command arg1 arg2
echo(  %progpath% purge:mod1:mod2 command arg1 arg2
echo(  %progpath% restore load=mod1;mod2 -- command arg1 arg2

goto:eof


:: parse command-line arguments
:parse_args

:parse_start
if "x%~1" equ "x" goto:parse_end
if "%~1" equ "--" set kind_of_arg=cmd&shift&goto:parse_start
if "!kind_of_arg!" equ "cmd" set cmdarglist=%cmdarglist% "%~1"&shift&goto:parse_start

if "%~1" equ "purge" set action=%~1&shift&call :arg_into_mod "%~1"&goto:parse_start
if "%~1" equ "restore" set action=%~1&shift&call :arg_into_mod "%~1" "%~2"&shift&goto:parse_start
if "%~1" equ "unload" set action=%~1&shift&call :arg_into_mod "%~1" "%~2"&shift&goto:parse_start
if "%~1" equ "switch" set action=%~1&shift&call :arg_into_mod "%~1" "%~2"&shift&goto:parse_start
if "%~1" equ "load" set action=%~1&shift&call :arg_into_mod "%~1" "%~2"&shift&goto:parse_start

:: replace & by ; to avoid batch incompatibility
set "ARG0=%~1"
set ARG0=!ARG0:^&=;!

call :arg_into_modaction "!ARG0!"
shift

goto:parse_start

:parse_end
goto:eof

:load_mod

for /F "tokens=1,* delims=;" %%I in ("%~1") do (
    if defined MODULE_DEBUG echo "module %%~I"
    module %%~I
	if !ERRORLEVEL! NEQ 0 exit /B !ERRORLEVEL!
    if "%%~J" neq "" call :load_mod "%%~J"
)

goto:eof
