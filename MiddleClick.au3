#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=..\..\Autoit\Icons\au3.ico
#AutoIt3Wrapper_Outfile_x64=..\CopyPasta.exe
#AutoIt3Wrapper_Res_Fileversion=1.0.0.7
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_Description=copypasta
#AutoIt3Wrapper_Res_LegalCopyright=pana ti se face rau
#AutoIt3Wrapper_Run_Tidy=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <Misc.au3>
TrayTip("Press", "ESC to quit" & @CRLF & "Middle click to paste", 4)
While 1
	If _IsPressed("04") Then

		$aCoords = WinGetPos("[ACTIVE]")

		If Not @error Then
			; If no error occurs, then trap the mouse cursor between the window client.
			_MouseTrap($aCoords[0], $aCoords[1], $aCoords[0] + $aCoords[2], $aCoords[1] + $aCoords[3])
		EndIf

		Send(ClipGet(), 1) ; Middle mouse button

	EndIf

	If _IsPressed("1B") Then
		_MouseTrap()
		Exit ; ESC key
		Sleep(100)
	EndIf

WEnd

