echo off
rem Build COM File
cd SRC

echo on
C:\IBMMASM\MASM COM.ASM COM.OBJ,COM.LST,COM.CRF
if ERRORLEVEL 1 GOTO QUIT
C:\IBMMASM\LINK COM.OBJ,COM.EXE,,,
if ERRORLEVEL 1 GOTO QUIT
C:\TOOLS\EXE2BIN COM.EXE
if ERRORLEVEL 1 GOTO QUIT
copy COM.BIN C:\BIN\COM.COM
echo off
del *.BIN
del *.CRF
del *.EXE
del *.LST
del *.MAP
del *.OBJ

:QUIT
cd ..