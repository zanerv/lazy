#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=..\..\Autoit\Icons\CopyPasta.ico
#AutoIt3Wrapper_Outfile_x64=..\CopyPasta.exe
#AutoIt3Wrapper_UseUpx=y
#AutoIt3Wrapper_Res_Description=CopyPasta
#AutoIt3Wrapper_Res_Field=ProductName|CopyPasta
#AutoIt3Wrapper_Res_Fileversion=1.0.0.13
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_LegalCopyright=pana ti se face rau
#AutoIt3Wrapper_Run_Tidy=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <Misc.au3>
TrayTip("Press", "ESC to quit" & @CRLF & "Middle click to paste", 4)
While 1
	If _IsPressed("04") Then
		; Keep the window active when using the Send function.
		SendKeepActive("[ACTIVE]")
		Send(ClipGet(), 1) ; Middle mouse button
		SendKeepActive("")
	EndIf
	If _IsPressed("1B") Then
		SendKeepActive("")
		Exit ; ESC key
	EndIf
	Sleep(100)
WEnd

