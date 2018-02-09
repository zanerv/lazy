#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=..\..\Autoit\Icons\Proxifier_128.ico
#AutoIt3Wrapper_Outfile_x64=..\Proxifier.exe
#AutoIt3Wrapper_UseUpx=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

Local $sFile = "C:\Program Files (x86)\Proxifier\Proxifier.exe"

If WinExists("[CLASS:Proxifier32Cls]") Then
	ConsoleWrite("deja pornit..."&@CRLF)
	Exit
EndIf

ShellExecute($sFile, '', '', '', @SW_MINIMIZE)
$hndw = WinWait("Proxifier Trial", "", 1)

If WinExists("[CLASS:#32770; TITLE:Proxifier Trial]", "Your trial version has expired.") Then ; if expired
	$hndw = WinGetHandle("[CLASS:#32770; TITLE:Proxifier Trial]", "Your trial version has expired.")
	ProcessClose($sFile) ;WinClose($hndw)
	Run('reg delete "HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\Main" /v DefaultWANProfile /f')
	Run('reg delete "HKEY_CURRENT_USER\Software\Initex\Proxifier\Settings" /v DefaultWANProfile /f')
	ConsoleWrite("stergem..."&@CRLF)
EndIf
If WinExists("[CLASS:#32770; TITLE:About Proxifier","This trial version has expired.") Then ; if expired
;~ 	MsgBox(0,"meh","tzo")
	$hndw = WinGetHandle("[CLASS:#32770; TITLE:About Proxifier","This trial version has expired.")
	ProcessClose($sFile) ;WinClose($hndw)
	Run('reg delete "HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\Main" /v DefaultWANProfile /f')
	Run('reg delete "HKEY_CURRENT_USER\Software\Initex\Proxifier\Settings" /v DefaultWANProfile /f')
	ConsoleWrite("stergem..."&@CRLF)
EndIf


If WinExists($hndw) Then
	ControlClick($hndw, "[CLASS:Button; INSTANCE:1]", 1)
	ConsoleWrite("existam..."&@CRLF)
EndIf
