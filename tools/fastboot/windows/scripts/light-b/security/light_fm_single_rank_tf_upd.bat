:: Script to upgrade images via fastboot

@echo off
ping 127.0.0.1 -n 5 >nul

echo NOTE: The CMD can't return back successfully due to system reboot.
echo Please ignore the fastboot execution status returned from fastboot. Also, 
echo you can check reboot behavior at serial windows

call:RunACmd "..\..\..\fastboot.exe flash stashtf ..\..\..\..\..\..\images\light-fm-b\tf.ext4"


pause
exit

:RunACmd
SETLOCAL
set CmdStr=%1
echo IIIIIIIIIIIIIIII Run Cmd:  %CmdStr% 
%CmdStr:~1,-1% || goto RunACmd

GOTO:EOF
