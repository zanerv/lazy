#include <Array.au3>
#include <File.au3>
#AutoIt3Wrapper_Run_Debug_Mode=n
Dim $cOUT
$IP = "192.168.0.107"
$UName = "root"
$UPass = "chip"
$ping = Ping($IP, 250)

If $ping <> 0 And Not @error Then
	MsgBox(0, "ping it`s working", $ping)
Else
	If @error = 1 Then MsgBox(0, "timeout", $IP & " is offline")
	If @error = 2 Then MsgBox(0, "timeout", $IP & " is unreachable")
	If @error = 3 Then MsgBox(0, "timeout", "Bad destination")
	If @error = 4 Then MsgBox(0, "timeout", "Unknown host " & $IP)
;~ 	Exit
EndIf

$PID = _Connect($IP)
If $PID = False Then
	MsgBox(0, "Login Error", "Error logging into device: " & $IP, 8)
	Exit
Else
	MsgBox(0, "Output from func", $cOUT)

EndIf

If ProcessExists($PID) Then ProcessClose($PID)

Func _Connect($cIP)
	Global $timeout = ($ping + 5000)
	MsgBox(0, "timeout", $timeout)
	Global $cOUT = ""
	$cPID = Run(@ScriptDir & "\plink.exe -ssh -l " & $UName & " -pw " & $UPass & " " & $cIP & "  uptime", @ScriptDir, Default, 0x1 + 0x8)
	$waitForOutputStartTime = TimerInit()
	$plinkFeedback = ""

	Do
		Sleep(100)
		$cOUT = StdoutRead($cPID)
		If StringInStr($cOUT, "Store key") Then
			StdinWrite($cPID, "y" & @CRLF & @CRLF)
			Sleep(2000)
			$cOUT = StdoutRead($cPID)
		EndIf
		If StringInStr($cOUT, "test") Then
			Return $cPID
		EndIf
		If $cOUT <> "" Then
			Return $cPID
		EndIf
		$plinkFeedback &= StdoutRead($cPID)
		$stdoutReadError = @error

	Until $stdoutReadError Or ($timeout And TimerDiff($waitForOutputStartTime) > $timeout)

	Return False
EndFunc   ;==>_Connect
