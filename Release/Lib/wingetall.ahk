WinGetAll(InType = "", in = "", outtype = "")
{ ;made by bugz000
WinGet,wParam, List
Window:={}
loop %wParam%
	{
		WinGetpos, X%A_Index%, Y%A_Index%, Width%A_index%, Height%A_index%, % "ahk_id " wParam%A_Index%
		WinGetTitle, WinName%A_Index%, % "ahk_id " wParam%A_Index%
		winget, State%A_index%, MinMax, % "ahk_id " wParam%A_Index%
		winget, ID%A_index%,ID , % "ahk_id " wParam%A_Index%
		winget, PID%A_index%,PID, % "ahk_id " wParam%A_Index%
		winget, Proc%A_index%, ProcessName, % "ahk_id " wParam%A_Index%
		winget, Proc%A_index%, ProcessPath, % "ahk_id " wParam%A_Index%
		Window[ A_index , "Name" ]		:= WinName%A_index%
		Window[ A_index , "State" ]		:= State%A_Index%
		Window[ A_index , "AHK_ID" ]	:= wParam%A_Index%
		Window[ A_index , "ID" ]		:= ID%A_Index%
		Window[ A_index , "PID" ]		:= PID%A_Index%
		Window[ A_index , "Proc" ]		:= Proc%A_Index%
		Window[ A_index , "Path" ]		:= PAth%A_Index%
		Window[ A_index , "X" ]			:= X%A_Index%
		Window[ A_index , "Y" ]			:= Y%A_index%
		Window[ A_index , "Width" ]		:= Width%A_Index%
		Window[ A_index , "Height" ]	:= Height%A_Index%
		Window[ A_index , "Area" ]		:= Width%A_Index% * Height%A_Index%
		if (intype) AND (in) AND (outtype) 	 	;check if you're looking for something specific
			if (Window[A_index, intype] = in) 		;check if there is a match
				return % window[a_index, outtype] 	;output the outtype of that match
	}
	if (intype) AND (in) AND (outtype)				;check as above ^ you should have returned already
		return % st_printarr(window) ;if you're at this point then the 2nd if statement above failed
	return % window								
}
