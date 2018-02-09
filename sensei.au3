#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=..\..\Autoit\Icons\au3.ico
#AutoIt3Wrapper_Outfile_x64=..\sensei.Exe
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <IE.au3>
#include <array.au3>
#include <StringConstants.au3>
HotKeySet("{Esc}", "_Exit")
$SoIEURL = "https://meh/index.php"
If Not ProcessExists("iexplore.exe") Then Run("iexplore.exe")
$SoIE = _IECreate($SoIEURL, True)
Sleep(2000)
_IELoadWait($SoIE)
While StringInStr(_IEPropertyGet($SoIE, "locationurl"), $SoIEURL) = 0 Or @error
	Sleep(500)
	_IELoadWait($SoIE)
	If @error = $_IESTATUS_InvalidObjectType Then Exit
	If StringRegExp(_IEBodyReadHTML($SoIE), "Log On Successful", $STR_REGEXPMATCH) Then
		ConsoleWrite("tzo am gasit Log On" & @CRLF)
		_IELoadWait($SoIE)
		_IEAction($SoIE, "refresh")
		$oLinks = _IETagNameGetCollection($SoIE, "input")

		For $oLink In $oLinks
			;ConsoleWrite($oLink.value&@CRLF)
			If String($oLink.value) = "    OK    " Then
				;ConsoleWrite("successOK"&@CRLF)
				_IEAction($oLink, "click")
				ExitLoop
			EndIf
		Next
	EndIf
WEnd
_IELoadWait($SoIE)
$oIE = $SoIE

;Get $Status
Local $oForm = _IEFormGetObjByName($oIE, "userid_search")
Local $oTag = _IEFormElementGetObjByName($oForm, "disp_status")
Local $oSearch = _IEGetObjByName($oForm, "Search")

_IEAction($oTag, "focus") ;
Func GetStatus($oTag)
	Local $oOptions_coll = $oTag.Options
	For $oOption_enum In $oOptions_coll
		If $oOption_enum.selected Then Return $oOption_enum.innertext
	Next
EndFunc   ;==>GetStatus
Local $Status = GetStatus($oTag)

If $Status == "--Choose Status--" Then
	$oForm = _IEFormGetObjByName($oIE, "userid_search")
	$oSelectStatus = _IEFormElementGetObjByName($oForm, "disp_status")
	_IEFormElementOptionSelect($oSelectStatus, "notify")

	$oLinks = _IETagNameGetCollection($oIE, "input")

	For $oLink In $oLinks
		If String($oLink.type) = "submit" And String($oLink.value) = "Search" Then
			_IEAction($oLink, "click")
			ExitLoop
		EndIf
	Next

EndIf
;--> initial load
_IELoadWait($oIE, 1000)

Local $sHTML = _IEBodyReadHTML($oIE)
Local $aArray = StringRegExp($sHTML, 'id=resp_\d{1,2}', 3)
While IsArray($aArray) = 1
	ConsoleWrite("a inceput while" & @CR)

	For $i = 0 To UBound($aArray) - 1
		$oResponseType = _IEGetObjById($oIE, "resp_" & $i)
		_IEFormElementOptionSelect($oResponseType, "rsp_direct0_6")
	Next
	$oLinks = _IETagNameGetCollection($oIE, "input")

	For $oLink In $oLinks
		If String($oLink.type) = "submit" And String($oLink.value) = "Update Tickets" Then
			_IEAction($oLink, "click")
			ExitLoop
		EndIf
	Next
	_IELoadWait($oIE, 1000)
	Local $sHTML = _IEBodyReadHTML($oIE)
	Local $aArray = StringRegExp($sHTML, 'id=resp_\d{1,2}', 3)
WEnd
Func _Exit()
	Exit
EndFunc   ;==>_Exit
