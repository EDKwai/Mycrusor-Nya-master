@echo off
setlocal
set "NODE_BIN=%NEKO_NODE%"
if not defined NODE_BIN set "NODE_BIN=C:\Program Files\nodejs\node.exe"
if not exist "%NODE_BIN%" set "NODE_BIN=node"
"%NODE_BIN%" "%~dp0hook.js" %*
