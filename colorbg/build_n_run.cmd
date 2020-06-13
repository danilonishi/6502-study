@echo off
cd C:\Users\Danilo\Desktop\6052\colorbg
if exist build (
	del build
)
echo Building...
dasm colorbg.asm -f3 -v0 -obuild
if %ERRORLEVEL% NEQ 0 (
	del build
	echo Press any key to end.
	pause>nul
	goto die
)

echo Checking cart file...
if exist build (
::	echo checking current file...
	goto createbackup
) else (
	echo Build Failed.
	goto die
)

:removeoldbackup
if exist cart_old.bin (
	echo deleting backup...
	del cart_old.bin
	goto removeoldbackup
) else (
	echo backing up current cart...
	ren cart.bin cart_old.bin
	goto createbackup
)

:createbackup
if exist cart.bin (
	echo Checking backup...
	goto removeoldbackup
) else (
	echo Renaming...
	ren build cart.bin
	goto launchstella
)



:launchstella
echo Launching Stella...
stella cart.bin


:die
echo Process Ended.
EXIT /b 0