@echo off
REM Switch node_modules to Windows platform
cd /d "%~dp0"

REM Save current if it's Linux (has no .exe)
if exist node_modules\electron\dist\electron (
  if not exist node_modules\electron\dist\electron.exe (
    echo Saving Linux node_modules...
    if exist node_modules_linux rmdir /s /q node_modules_linux
    ren node_modules node_modules_linux
  )
)

REM Remove existing node_modules (junction or dir)
if exist node_modules (
  rmdir node_modules 2>nul
  if exist node_modules rmdir /s /q node_modules
)

if exist node_modules_win (
  mklink /J node_modules node_modules_win
  echo Linked node_modules -^> node_modules_win
) else (
  echo Installing for Windows...
  mkdir node_modules_win
  mklink /J node_modules node_modules_win
  call npm install
)
