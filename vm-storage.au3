#include <Array.au3>
#include <array.au3> ; just to show result
HotKeySet("{ESC}", "_Exit") ;If you press ESC the script will stop

ClipPut("")
While ClipGet() = ""
	Sleep(100)
WEnd
Global $aClip = Split(ClipGet())
Global $chr = 99 ; aka starting with drive sdc
Dim $history
Global $aCmd[1]
_ArrayAdd($aCmd,"cat /etc/fstab")
If UBound($aClip, 2) = 0 Or UBound($aClip, 2) < 2 Then
	MsgBox(0, "muci", "pe tavan")
	Exit
EndIf

For $i = 0 To UBound($aClip) - 1

	If $aClip[$i][0] = "" Then ExitLoop
	$scurt = StringSplit($aClip[$i][0], "/")
;~ 	_ArrayDisplay($aClip)
;~ 	_ArrayDisplay($scurt)
    $fullpath = $aClip[$i][0]
	$path = $scurt[$scurt[0]]
	$size = $aClip[$i][1]
	$disk = Chr($chr + $i)
	$duplicate = StringInStr($history, $path)
	If $duplicate <> 0 Then
;~ 		ConsoleWrite("WE HAZ DUPLICATES!!!" & @TAB & $scurt[$scurt[0] - 1] & @CRLF)
		$path = $scurt[$scurt[0] - 1] & "_" & $scurt[$scurt[0]]
	EndIf
	$history &= $path & ","
;~ 	_ArrayDisplay(_ArrayUnique(StringSplit($history, ",",2),0,0,0,0))
;~ 	_ArrayDisplay(StringSplit($history, ",",2))
	If UBound(StringSplit($history, ",", 2)) <> UBound(_ArrayUnique(StringSplit($history, ",", 2), 0, 0, 0, 0)) Then
		MsgBox(0, "Duplicate", "we haz a duplicate: " & $path)
		Exit
	EndIf
	Cmd($path, $size, $disk, $fullpath)
Next
ConsoleWrite($history & @CRLF)
_ArrayAdd($aCmd, "service cscape stop; umount /opt/app/*; umount /opt/app; mv /opt/app/cscape /opt/; mount -av; mv /opt/cscape /opt/app/; service cscape start")
_ArrayAdd($aCmd, "cat /etc/fstab ; mount -av")
_ArrayAdd($aCmd, "df -hP"&@LF)
_ArrayToClip($aCmd,@LF,-1,-1,@LF)

;~ _ArrayDisplay($aCmd)

Func Cmd($path, $size, $disk, $fullpath)
;~ 	_ArrayAdd($aCmd, 'echo -e "n\np\n\n\n\nt\n8e\nw" | fdisk /dev/sd' & $disk,0,".@.")
	_ArrayAdd($aCmd, "yes y|vgcreate " & $path & "_vg /dev/sd" & $disk ,0,".@.")
	_ArrayAdd($aCmd, "lvcreate -l+100%FREE -n " & $path & "_lv " & $path & "_vg")
	_ArrayAdd($aCmd, "mkfs -t xfs /dev/" & $path & "_vg/" & $path & "_lv")
	_ArrayAdd($aCmd, 'echo -e "/dev/' & $path & '_vg/' & $path & '_lv\t' & $fullpath & '\txfs\tdefaults\t1\t3" >> /etc/fstab')
	_ArrayAdd($aCmd, "mkdir -p " & $fullpath)
	_ArrayAdd($aCmd, "mount " & $fullpath)
EndFunc   ;==>Cmd


Func Split($var, $sSeparator = @TAB)
	Local $aRows = StringSplit(StringStripCR($var), @LF), $aColumns, $aClip[$aRows[0]][1]
	For $iRow = 1 To $aRows[0]
		$aColumns = StringSplit($aRows[$iRow], $sSeparator)
		If $aColumns[0] > UBound($aClip, 2) Then ReDim $aClip[$aRows[0]][$aColumns[0]]
		For $iColumn = 1 To $aColumns[0]
			$aClip[$iRow - 1][$iColumn - 1] = $aColumns[$iColumn]
		Next
	Next
	Return $aClip
EndFunc   ;==>Split

Func _Exit()
	Sleep(100)
	Exit
EndFunc   ;==>_Exit
