#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_UseX64=n
#AutoIt3Wrapper_Change2CUI=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <ie.au3>
#include <MsgBoxConstants.au3>
#include <StringConstants.au3>
#include <Array.au3>
#include <TrayConstants.au3>

; STEP 1
; YOU MUST SET ANY COM ERROR HANDLER IN ONE OF THE FOLLOWING WAY

; STEP 1: CASE 1
; you should set COM Error Handler Function for ie.au3 UDF
_IEErrorHandlerRegister(_User_ErrFunc)
HotKeySet("{F6}", "_OnExit")

; STEP 1: CASE 2
; eventually if you not want to recieve additional information
; you can use just the same function without parameter
; _IEErrorHandlerRegister()

; STEP 1: CASE 3
; or use your own global COM Error Handler
;~ Global $oCOMErrorHandler = ObjEvent("AutoIt.Error", _User_ErrFunc)

; STEP 2
; if you do not wish to get in Console Output Pane information like the following:
;           --> IE.au3 T3.0-2 Error from function _IEAction(click), $_IESTATUS_InvalidDataType
;   You can uncomment this following line:
;       _IEErrorNotify(False)
#AutoIt3Wrapper_Run_Debug_Mode=n

Global $oIE = _IECreate('https://service-now.com/login.do')
;_IEAction($oIE, "invisible")

_Login()
Func _Login()

	; First lets create some IE Object
	; you should always check for @error in any function (even you own made)
	If @error Then
		MsgBox($MB_ICONERROR, '_IECreate', '@error = ' & @error & @CRLF & '@extended = ' & @extended)
		; Set @error when you return from function with Failure
		Return SetError(1, 0, 0)
	EndIf

	; Hide the browser window and login
	Local $oForm = _IEFormGetObjByName($oIE, "loginpage")
	Local $user_name = _IEFormElementGetObjByName($oForm, "user_name")
	Local $user_password = _IEFormElementGetObjByName($oForm, "user_password")

	; Assign input focus to the field and then send the text string
	_IEAction($user_name, "focus")

	; Select existing content so it will be overwritten.
	_IEAction($user_name, "selectall")

	; Get a handle to the IE window.
	Local $hIE = _IEPropertyGet($oIE, "hwnd")
	ControlSend($hIE, "", "[CLASS:Internet Explorer_Server; INSTANCE:1]", "Username")
	; Input password
	_IEAction($user_password, "focus")
	_IEAction($user_password, "selectall")
	ControlSend($hIE, "", "[CLASS:Internet Explorer_Server; INSTANCE:1]", "Password")
	;_IEAction($oIE, "visible")

	; here we try to get reference to Login button
	Local $blogin = _IEGetObjByName($oIE, 'not_important')
	; you should always check for @error in any function (even you own made)
	If @error Then
		$errlog = FileOpen("SNC_error.log", 1)
		FileWrite($errlog, '_Login' & '@error = ' & @error & @CRLF & '@extended = ' & @extended)
		FileClose($errlog)
		; Set @error when you return from function with Failure
		Return SetError(2, 0, 0)
	EndIf

	; here we try to click Login button with previously achieved Object which is a reference to HTML DOM OBJECT in IE Instance
	_IEAction($blogin, 'click')

	; you should wait when page is loading
	_IELoadWait($oIE)
EndFunc   ;==>_Login

_IELoadWait($oIE)
_IENavigate($oIE, "https://service-now.com/task_sla_list.do?sysparm_userpref_module=9d32fd940a0a0bb3006d3d6aa93a4462&sysparm_query=active=true^task.active=true^task.assignment_group=javascript:getMyGroups%28%29^task.state!=-5^task.assigned_to=^EQ&sysparm_cancelable=true")
_IELoadWait($oIE)
$INCnrOld = "none"
$found = 1
Global $tsm = "tsm"
Global $san = "san"
Global $ignore = "hmm"
;ConsoleWrite(@ScriptLineNumber & " " & $found & @CRLF)
Func _seachforinc()
	_IEAction($oIE, "refresh")
	_IELoadWait($oIE)
	$sText = _IEBodyReadText($oIE)
	Local $sString = StringReplace($sText, $ignore, 0)
	$sINCnr = StringRegExp($sString, 'INC[0-9][0-9][0-9][0-9][0-9][0-9][0-9]', $STR_REGEXPARRAYMATCH)
	If $sINCnr = 0 Then
		Global $found = 0
		ConsoleWrite(">no inc found " & @HOUR & ":" & @MIN & ":" & @SEC & " " & "Last INC: " & $INCnrOld & " Ignoring: " & $ignore & @LF)
	Else
		Global $found = 1
		ConsoleWrite("!found " & @HOUR & ":" & @MIN & ":" & @SEC & " " & $sINCnr[0] & @LF)
		SoundPlay("D:\alert.wav", 1)
		TrayTip("SNC", "New incident: " & $sINCnr[0], 0, $TIP_ICONASTERISK)
		Local $oLinks = _IELinkGetCollection($oIE)
		For $oLink In $oLinks
			Local $sLinkText = _IEPropertyGet($oLink, "innerText")
			If StringInStr($sLinkText, $sINCnr[0]) Then
				_IELoadWait($oIE)
				_IEAction($oLink, "click")
				_IELoadWait($oIE)
				ExitLoop
			EndIf
		Next
		$oForm = _IEFormGetObjByName($oIE, "incident.do")
		$INCdescval = _IEFormElementGetObjByName($oForm, "incident.short_description")
		$INCnrval = _IEFormElementGetObjByName($oForm, "sys_readonly.incident.number")
		$INCcival = _IEFormElementGetObjByName($oForm, "sys_display.incident.cmdb_ci")
		$INCsevval = _IEFormElementGetObjByName($oForm, "sys_readonly.incident.priority")
		$INCdesc = _IEFormElementGetValue($INCdescval)
		Global $INCnr = _IEFormElementGetValue($INCnrval)
		Global $INCci = _IEFormElementGetValue($INCcival)
		If $INCci == 0 Then
			Global $ignore = $INCnr
			Global $found = 1
			ConsoleWrite("incident is closed" & " ignoring " & $ignore & @LF)
			_IENavigate($oIE, "https://service-now.com/task_sla_list.do?sysparm_userpref_module=9d32fd940a0a0bb3006d3d6aa93a4462&sysparm_query=active=true^task.active=true^task.assignment_group=javascript:getMyGroups%28%29^task.state!=-5^task.assigned_to=^EQ&sysparm_cancelable=true")
			_IELoadWait($oIE)
			Sleep(1000)
		Else
			$INCurl = _IEPropertyGet($oIE, "locationurl")
			$INCsev = _IEFormElementGetValue($INCsevval)
			$sWords = "(?i)(tsm|backup|BRARCHIVE|BRBACKUP|ANR|ANS|restore|RMAN)"
			Global $iResult = StringRegExp($INCdesc, $sWords, 0)
			Global $tsm_nr = "00000000000000"
			Global $san_nr = "00000000000000"
			If $iResult <> 0 Then
				Global $phone = $tsm_nr
			Else
				Global $phone = $san_nr
			EndIf
			$smsLink = "https://www.nonoh.net/myaccount/sendsms.php?username=Username&Password=YOU_NEED_TO_GET_A_ACCOUNT&from=Username&to=" & $phone & "&text="
			ConsoleWrite("found " & @LF & $INCnr & @LF & $INCci & @LF & $INCdesc & @CRLF)
			TrayTip("Sev " & $INCsev, $INCnr & @CRLF & $INCci & @CRLF & $INCdesc, 0)
			If $INCsev < 3 Then ConsoleWrite("POZOOOOOOOOR")
			If $INCnr <> $INCnrOld Then
				$INClog = FileOpen("SNC.log", 1)
				FileWrite($INClog, $INCnr & "	Sev " & $INCsev & "	" & $INCci & "	" & $INCdesc & "	" & $INCurl & @CRLF)
				FileClose($INClog)
			EndIf
			ConsoleWrite("$INCsev: " & $INCsev & @CRLF & "$INCnr: " & $INCnr & @CRLF & "$INCci: " & $INCci & @CRLF & "$INCdesc: " & $INCdesc & @CRLF & "$INCnrOld: " & $INCnrOld & @CRLF)
			;_assign() ; assign all the inc to tsm
			_SANvsTSM()
			_IELoadWait($oIE)
		EndIf
	EndIf
	If @error Then
		$errlog = FileOpen("SNC_error.log", 1)
		FileWrite($errlog, '_seachforinc' & '@error = ' & @error & @CRLF & '@extended = ' & @extended)
		FileClose($errlog)
		; Set @error when you return from function with Failure
		Return SetError(2, 0, 0)
	EndIf
EndFunc   ;==>_seachforinc

Func _SANvsTSM()
	_IELoadWait($oIE)
	;ConsoleWrite("found " & @LF & $INCnr & @LF & $INCci & @LF & $INCdesc & @LF)
	If $iResult <> 0 Then
		ConsoleWrite($iResult & "<- TSM INC(1=yes)| errors -> " & @error & @LF)
		_assign($tsm)
	Else
		_assign($san)
		ConsoleWrite($iResult & "<- SAN INC(0=yes)| errors -> " & @error & @LF)
	EndIf
	If @error Then
		$errlog = FileOpen("SNC_error.log", 1)
		FileWrite($errlog, '_SANvsTSM' & '@error = ' & @error & @CRLF & '@extended = ' & @extended)
		FileClose($errlog)
		; Set @error when you return from function with Failure
		Return SetError(2, 0, 0)
	EndIf
	_IELoadWait($oIE)
EndFunc   ;==>_SANvsTSM

While 1
	If $found = 1 Then
		_seachforinc()
		$sleep = 0
	Else
		$sleep = 60000
	EndIf
	ConsoleWrite("Next scan in: " & $sleep & @CRLF)
	Sleep($sleep)
	_seachforinc()
WEnd

Func _OnExit()
	_IEQuit($oIE)
	Exit
EndFunc   ;==>_OnExit

Func _assign($to)
	Local $oForm = _IEFormGetObjByName($oIE, "incident.do")
	Local $assign_to = _IEFormElementGetObjByName($oForm, "sys_display.incident.assigned_to")
	_IEAction($assign_to, "focus")
	_IEAction($assign_to, "selectall")
	If $assign_to <> 0 Then
		Local $hIE = _IEPropertyGet($oIE, "hwnd")
		ControlSend($hIE, "", "[CLASS:Internet Explorer_Server; INSTANCE:1]", $to)
		Sleep(500)
		ControlSend($hIE, "", "[CLASS:Internet Explorer_Server; INSTANCE:1]", "{tab}")
		Sleep(2000)
		_clickUpdate()
		_IELoadWait($oIE)
		ConsoleWrite("incident assigned" & @LF)
	EndIf
	Global $INCnrOld = $INCnr
	If @error Then
		$errlog = FileOpen("SNC_error.log", 1)
		FileWrite($errlog, '_assign' & '@error = ' & @error & @CRLF & '@extended = ' & @extended)
		FileClose($errlog)
		; Set @error when you return from function with Failure
		Return SetError(2, 0, 0)
	EndIf
	_IEAction($oIE, 'back') ; after the inc is assigned go back
	_IEAction($oIE, "refresh")
	_IELoadWait($oIE)
EndFunc   ;==>_assign

Func _clickUpdate()
	_IELoadWait($oIE)
	; here we try to get reference to Update button
	Local $blogout = _IEGetObjById($oIE, 'sysverb_update')
	; you should always check for @error in any function (even you own made)
	If @error Then
		$errlog = FileOpen("SNC_error.log", 1)
		FileWrite($errlog, '_clickUpdate' & '@error = ' & @error & @CRLF & '@extended = ' & @extended)
		FileClose($errlog)
		; Set @error when you return from function with Failure
		Return SetError(2, 0, 0)
	EndIf

	; here we try to click Update button with previously achieved Object which is a reference to HTML DOM OBJECT in IE Instance
	_IEAction($blogout, 'click')

	; you should wait when page is loading
	_IELoadWait($oIE)
	Sleep(1000)
EndFunc   ;==>_clickUpdate

; User's COM error function.
; After SetUp with ObjEvent("AutoIt.Error", ....) will be called if COM error occurs
Func _User_ErrFunc($oError)
	; Do anything here.
	ConsoleWrite(@ScriptFullPath & " (" & $oError.scriptline & ") : ==> COM Error intercepted !" & @CRLF & _
			@TAB & "err.number is: " & @TAB & @TAB & "0x" & Hex($oError.number) & @CRLF & _
			@TAB & "err.windescription:" & @TAB & $oError.windescription & @CRLF & _
			@TAB & "err.description is: " & @TAB & $oError.description & @CRLF & _
			@TAB & "err.source is: " & @TAB & @TAB & $oError.source & @CRLF & _
			@TAB & "err.helpfile is: " & @TAB & $oError.helpfile & @CRLF & _
			@TAB & "err.helpcontext is: " & @TAB & $oError.helpcontext & @CRLF & _
			@TAB & "err.lastdllerror is: " & @TAB & $oError.lastdllerror & @CRLF & _
			@TAB & "err.scriptline is: " & @TAB & $oError.scriptline & @CRLF & _
			@TAB & "err.retcode is: " & @TAB & "0x" & Hex($oError.retcode) & @CRLF & @CRLF)
EndFunc   ;==>_User_ErrFunc

