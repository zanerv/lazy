#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=..\..\Autoit\Icons\SecureCRT_128.ico
#AutoIt3Wrapper_Outfile_x64=..\Secure CRT.exe
#AutoIt3Wrapper_UseUpx=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
If FileExists(@LocalAppDataDir & "\VanDyke Software\SecureCRT\SecureCRT.exe") Then $sFile = @LocalAppDataDir & "\VanDyke Software\SecureCRT\SecureCRT.exe"
If FileExists("C:\Program Files\VanDyke Software\SecureCRT\SecureCRT.exe") Then $sFile = "C:\Program Files\VanDyke Software\SecureCRT\SecureCRT.exe"

If WinExists("[CLASS:VanDyke Software - SecureCRT]") Then
	ShellExecute($sFile)
	Exit
EndIf

ShellExecute($sFile, '', '', '', @SW_MINIMIZE)
$hndw = WinWait("[CLASS:#32770]", "License Agreement", 5)

If WinExists("[CLASS:#32770]", "SecureCRT®") Then ; trial
	ConsoleWrite("am gasit gusteru" & $hndw & @CRLF)
	ControlClick($hndw, "[CLASS:Button; INSTANCE:6]", 2042)
EndIf

If WinExists($hndw) Then ; trial about to end
	ControlClick($hndw, "[CLASS:Button; INSTANCE:6]", 1)
EndIf

If WinExists("[CLASS:#32770; TITLE:SecureCRT]", "expired") Then ; if expired
	$hndw = WinGetHandle("[CLASS:#32770; TITLE:SecureCRT]", "expired")
	ControlClick($hndw, "[CLASS:Button; INSTANCE:2]", 2)
	Run('reg delete "HKEY_CURRENT_USER\Software\VanDyke\SecureCRT\Evaluation License" /f')
EndIf
If WinExists("[CLASS:#32770; TITLE:SecureCRT]", "evaluation ") Then ; if expired
	$hndw = WinGetHandle("[CLASS:#32770; TITLE:SecureCRT]", "evaluation ")
	ControlClick($hndw, "[CLASS:Static; INSTANCE:2]", 2042)
	Run('reg delete "HKEY_CURRENT_USER\Software\VanDyke\SecureCRT\Evaluation License" /f')
EndIf

$hndw1 = WinWait("not connected - SecureCRT", "", 5)
WinSetState($hndw1, "", @SW_MAXIMIZE)

;If @MDAY = 26 then run('reg delete "HKEY_USERS\S-1-5-21-1371090946-594628281-134157935-397421\Software\VanDyke\SecureCRT\Evaluation License" /f')
