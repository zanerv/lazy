#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Monitoring.ico
#AutoIt3Wrapper_Outfile=\\192.168.3.113\c\Monitoring.exe
#AutoIt3Wrapper_Outfile_x64=Monitoring.exe
#AutoIt3Wrapper_UseX64=n
#AutoIt3Wrapper_Change2CUI=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#pragma compile(FileDescription, Monitoring Sametime and Firefox)
#pragma compile(ProductName, Monitor)
#pragma compile(ProductVersion, 1.0)
#pragma compile(FileVersion, 1.0.2.8) ; The last parameter is optional.
#pragma compile(LegalCopyright, Z)
#pragma compile(CompanyName, 'MK')
;#AutoIt3Wrapper_Run_Debug_Mode=Y
Opt("WinWaitDelay", 0)
#include <Misc.au3>
#include <MsgBoxConstants.au3>
#include <Timers.au3>

; Check if it's already running
If _Singleton("Monitoring", 1) = 0 Then
	ConsoleWrite("Don't be like sap")
	Exit
EndIf

; Check which pc is it?
If @ComputerName = "PC HOSTNAME" Then
	Global $pc = " (x86)"
	Global $ffl = 5000
	Global $xl = '"C:\Program Files (x86)\CounterPath\X-Lite3\x-lite.exe" -dial=sip:00000000000000'
ElseIf @ComputerName = "PC2 HOSTNAME" Then
	Global $pc = ""
	Global $ffl = 30000
	Global $xl = '"C:\Program Files\CounterPath\X-Lite\x-lite.exe" -dial=sip:00000000000000'
EndIf
ConsoleWrite(@CRLF & "Punem razoare pe " & @ComputerName)

Global $st = "C:\Program Files" & $pc & "\IBM\Sametime Connect\rcp\rcplauncher.exe"
Global $ff = "C:\Program Files" & $pc & "\Mozilla Firefox\firefox.exe"
Global $pf = "C:\Program Files" & $pc & "\Proxifier\Proxifier.exe"
Global $Paused = 0
Global $start = _Timer_Init()
Global $shift = "30600000";8 hours and 30 min
Global $sPID = ProcessExists('sametime.exe')
Global $fPID = ProcessExists('firefox.exe')
Global $pPID = ProcessExists('proxifier.exe')
Global $stloggedoff = "IBM Sametime Connect"
Global $stloggedin = "IBM Sametime Connect - "
HotKeySet("{ESC}", "TABKey")
Dim $i = 0, $PushTime = 500
$haltsleep = False

; Register OnAutoItExit to be called when the script is closed.
;  OnAutoItExitRegister("_OnExit")

Func TABKey()
	$i += 1
	Sleep($PushTime)
	Switch $i
		Case 1
			ConsoleWrite(@CRLF & "chill for a bit" & @CRLF)
			TogglePause()
		Case 2
			ConsoleWrite(@CRLF & "sho pe ei")
			WakeUp()
		Case 3
			ConsoleWrite(@CRLF & "RAUS")
			_OnExit()
	EndSwitch
	$i = 0
EndFunc   ;==>TABKey

; Check if Sametime process is running.
If $sPID <> 0 And WinExists("[CLASS:SWT_Window0]", "") = 0 Then
	ProcessClose($sPID)
	Sleep(2000)
	Run($st)
	ConsoleWrite(@CRLF & "uite`o pula fara cap")
ElseIf $sPID = 0 Then
	TrayTip("Starting", "Sametime", 0)
	ConsoleWrite(@CRLF & "bagam lemne`n godin pana porneste sametimeu")
	Run($st)
EndIf

; Check if Sametime is logged in.
If $sPID <> 0 Then st_login()

; Check if Firefox process is running.
If $fPID = 0 Then
	TrayTip("Starting", "Firefox", 0)
	ConsoleWrite(@CRLF & "bagam lemne`n godin pana porneste leo firefoxu")
	Run($ff)
	WinWait("[CLASS:MozillaWindowClass]", "", 10)
	Sleep($ffl) ; Wait for webpage to load
	ControlSend("[CLASS:MozillaWindowClass]", "", "", "{ENTER}")
Else
	TrayTip("Firefox", "Refreshing SNC", 0)
	ConsoleWrite(@CRLF & "leo refresh deo snc" & @CRLF & @CRLF)
	ControlSend("[CLASS:MozillaWindowClass]", "", "", "{F5}")
	Sleep(5000) ; Wait for webpage to load
	ControlSend("[CLASS:MozillaWindowClass]", "", "", "{ENTER}")
EndIf

Local $hCurrHandle, $hOldHandle = WinGetHandle("[CLASS:MozillaWindowClass]")
Local $hOriHandle = WinGetHandle("[CLASS:MozillaWindowClass]")

;ShellHook notification codes:
Global Const $HSHELL_FLASH = 32774;
Global $bHook = 1
;GUI stuff:
Global $hGui = GUICreate("", 1, 1, -100, -100)
;Hook stuff:
GUIRegisterMsg(RegisterWindowMessage("SHELLHOOK"), "HShellWndProc")
ShellHookWindow($hGui, $bHook)

; Check if Proxifier is running.
If $pPID = 0 Then
	Run($pf)
	ConsoleWrite(@CRLF & "dc kkt ai oprit mizeria de proxifier?")
EndIf

; Function to exit.
Func _OnExit()
	If MsgBox(262433, "Log Out from Sametime", "Sametime will log out in 5 minutes..." & @CRLF & @CRLF & "Press CANCEL to abort the logout.", 300) = 2 Then
		; do not Logout
		If _Timer_Diff($start) > $shift Then
			Global $ot = ($shift + 3600000)
			Global $shift = $ot
			TrayTip("Overtime?", "Auto Logout delayed by an hour", 0)
		EndIf
		TrayTip("Auto Logout", "Auto Logout aborted", 0)
		ConsoleWrite(@CRLF & "da, vai ce sa`ti spun, viata n`ai?")
	Else
		st_logout()
		Sleep(2000)
		If WinExists($stloggedin) Then ProcessClose("sametime.exe")
		Exit
	EndIf
EndFunc   ;==>_OnExit

; Keep it busy
While 1
	If _Timer_Diff($start) > $shift Then _OnExit() ;+8:30
	ToolTip("●◌◌", 0, 0, @HOUR & ":" & @MIN & ":" & @SEC, 1, Sleep(1000))
	ToolTip("◌●◌", 0, 0, @HOUR & ":" & @MIN & ":" & @SEC, 1, Sleep(1000))
	ToolTip("◌◌●", 0, 0, @HOUR & ":" & @MIN & ":" & @SEC, 1, Sleep(1000))
	ToolTip("◌●◌", 0, 0, @HOUR & ":" & @MIN & ":" & @SEC, 1, Sleep(1000))
	ff_monitor()
	diditwork()
WEnd

; Function to monitor Firefox.
Func ff_monitor()
	$hCurrHandle = WinGetHandle("[CLASS:MozillaWindowClass]")
	If $hCurrHandle = "" Then Exit
	If $hOldHandle <> $hCurrHandle And $hCurrHandle <> $hOriHandle Then
		TrayTip("Firefox", "Alert", 0)
		ConsoleWrite(@CRLF & "NEIN! NEIN! leo firefox")
		xlite()
		$hOldHandle = $hCurrHandle
		TrayTip("Firefox", "Re-check", 0)
		ConsoleWrite(@CRLF & "beleste ochii sau belesti pula")
	EndIf
EndFunc   ;==>ff_monitor

; Function to monitor Sametime
Func HShellWndProc($hWnd, $Msg, $wParam, $lParam)
	Switch $wParam
		Case $HSHELL_FLASH
			ToolTip(4, 0, 0, "Sametime Alert", 1, Sleep(50))
			ConsoleWrite(@CRLF & "blink blink cocalaru` ce sametamuieste")
			xlite()
	EndSwitch
EndFunc   ;==>HShellWndProc

; Register/unregister ShellHook
Func ShellHookWindow($hWnd, $bFlag)
	Local $sFunc = 'DeregisterShellHookWindow'
	If $bFlag Then $sFunc = 'RegisterShellHookWindow'
	Local $aRet = DllCall('user32.dll', 'int', $sFunc, 'hwnd', $hWnd)
	Return $aRet[0]
EndFunc   ;==>ShellHookWindow

; Register window message
Func RegisterWindowMessage($sText)
	Local $aRet = DllCall('user32.dll', 'int', 'RegisterWindowMessageW', 'wstr', $sText)
	Return $aRet[0]
EndFunc   ;==>RegisterWindowMessage

; Function to start X-light.
Func xlite()
	If $Paused = 0 Then
		ToolTip(5, 0, 0, "Dial for 10 sec", 1, Sleep(1000))
		ConsoleWrite(@CRLF & "mananca cacat ca sta 11 secunde pana suna")
		Run($xl)
		Sleep(10000)
		ToolTip(6, 0, 0, "Calling for 2 min", 1, Sleep(50))
		ConsoleWrite(@CRLF & "suna fu`tu`ti mortii ma-ti pana crapi")
		callSleep(120000);sleep while calling for 2 minutes unless woken up
		;Sleep(120000)
		ControlSend("[Class:Funky Window]", "", "", "^h")
		Sleep(2000)
		ToolTip(7, 0, 0, "Hung up", 1, Sleep(50))
		ConsoleWrite(@CRLF & "cineva a cedat...nu`stu cine")
	EndIf
EndFunc   ;==>xlite

; Function to hangup xlite call.
Func callSleep($tt)
	Local $begin = TimerInit()

	While TimerDiff($begin) < $tt
		If $haltsleep Then
			$haltsleep = False
			Return
		EndIf
		Sleep(20)

	WEnd
EndFunc   ;==>callSleep

Func WakeUp()
	$haltsleep = True
	ConsoleWrite(@CRLF & "vai ce inteligent esti, s`o trezesti pe mata!!!!")
	$Paused = 0
EndFunc   ;==>WakeUp

; Function to login Sametime.
Func st_login()
	If WinExists($stloggedin) = 1 Then
		TrayTip("Sametime", "Already logged in", 0)
		ConsoleWrite(@CRLF & "but why?")
	Else
		TrayTip("Sametime", "Restarting Sametime", 0)
		ConsoleWrite(@CRLF & "aratam begiu la sametime")
		If WinExists($stloggedoff) <> 0 Then ProcessClose("sametime.exe")
		Sleep(2000)
		Run($st)
		ConsoleWrite(@CRLF & "mda, parca se uita pulea la el daca e logat sau nu")
	EndIf
EndFunc   ;==>st_login

; Function to logout Sametime.
Func st_logout()
	; Log out
	If WinExists($stloggedin) Then
		ProcessClose($sPID)
		ConsoleWrite(@CRLF & "Dobby has no master, Dobby is a free elf")
	EndIf
EndFunc   ;==>st_logout

Func diditwork()
	If WinExists($stloggedin) = 0 Then
		ProcessClose($sPID)
		TrayTip("Sametime", "Restarting", 0)
		ConsoleWrite(@CRLF & "da`i un spritz poate o ia" & @CRLF)
		Sleep(2000)
		Run($st)
		WinWait("[CLASS:SWT_Window0]", "", 20)
		WinWait($stloggedin, "", 30)
	EndIf
	If WinExists($stloggedin) = 0 Then
		TrayTip("Sametime", "Call master, i`m sick", 0)
		ConsoleWrite(@CRLF & "nope, n`a luato...POZOR CALU")
		xlite()
	EndIf
EndFunc   ;==>diditwork

; Function to pause and resume.
Func TogglePause()
	$Paused = Not $Paused
	While $Paused
		ToolTip("Paused", 0, 0, "Script is : ", 2, Sleep(1000))
		; If idle for more than 2 min
		If _Timer_GetIdleTime() > 2 * 60 * 1000 Then
			; Assume Idle
			$Paused = 0
		EndIf
	WEnd
	ToolTip("")
EndFunc   ;==>TogglePause
