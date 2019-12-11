
FileDelete, %A_Scriptdir%\lib\list.txt
FileDelete, %A_Scriptdir%\out.mp4
SendMode Input
SetWorkingDir %A_ScriptDir%\lib\
SendMode Input
#singleinstance, force
#persistent
setbatchlines -1
Programname:="Timelapser"
version := "v0.1a"
Gui, Font,cF0F0F0
gui, Color, 202020, 202020
gui, +toolwindow
Gui, Add, Edit, x82 y9 w280 h20 r1 vPathDisplay +BackGround0x191919,
Gui, Add, picture, x12 y10 w60 h18 gSelectFolder, %A_Scriptdir%/img/Select.png
Gui, Add, GroupBox, x152 y39 w220 h85 vFileCount , Files Found: 0
Gui, Add, Edit, x162 y59 w200 h55 vFileList +BackGround0x191919,
Gui, Add, Text, x22 y43 w50 h20 , FPS
Gui, Add, Edit,  x52 y39 w30 h20 vFPS +BackGround0x191919, 30
Gui, Add, picture, x86 y38 w60 h20 +BackGround0x191919 grefresh, %A_Scriptdir%/img/refresh.png
Gui, Add, Text, x22 y62 w110 h20 vEst, est out: n/a
Gui, Add, picture, x22 y92 w60 h25 +BackGround0x191919 gstart, %A_Scriptdir%/img/start.png
Gui, Add, picture, x85 y92 w60 h25 +BackGround0x191919 gstop, %A_Scriptdir%/img/stop.png
Gui, Add, Progress, x0 		y-5 	w384 	h10 	vProgressbar1 Background0066aa, 100
Gui, Add, Progress, x379 	y-3 	w10 		h233 vertical vProgressbar2 Background0066aa, 100
Gui, Add, Progress, x0 		y228	w384 	h10 	vProgressbar3 Background0066aa, 100
Gui, Add, Progress, x-5 	y-3	w10 		h233 vertical vProgressbar4 Background0066aa, 100
Gui, Add, GroupBox, x12 y129 w360 h80, Console:
Gui, Add, Edit, x22 y149 w340 h50 r3  vGuiConsole,
Gui, Font,c000cFF s8
Gui, Add, Text, x260 y212 vdonate gdonate, >>Support me [paypal]
Gui, Show,h233 w384, %programname% %version%
UDC("Finished loading GUI")
settimer, chroma, 100
Return
refresh:
gui, submit, nohide
guicontrol,, Est, % "est out: " round(i / fps) " sec"
return
donate:
run http://paypal.me/bugz000
return
start:
gui, submit, nohide
fileappend, %ffmpeglist%, %a_Scriptdir%\lib\list.txt
sleep 100
;ffmpeg -pattern_type glob -framerate 30 -i 'C:/path/to/images/*.png' -c:v libx264 -pix_fmt yuv420p out.mp4
UDC("Launching embedded Cli...")
CMD := new cli("CMD.exe","","CP850")
command := chr(34) A_Scriptdir "\lib\ffmpeg.exe" chr(34) " -f concat -safe 0 -r " fps " -i " chr(34) A_scriptdir "\lib\list.txt" chr(34) " -c:v libx264 -pix_fmt yuv420p " chr(34) A_Scriptdir "\out.mp4" chr(34)
UDC("Launching ffmpeg")
cmd.write(command "`r`n")
loop 10
	{
		PIDs:=WTSEnumProcesses(1)
		loop, parse, PIDs,`n,`r
			{
					param := strsplit(A_loopfield, A_Tab)
					if (param[2] = "ffmpeg.exe")
						ffPID:=param[1], break
			}
		if (ffPID)
			break
		sleep 100
	}
if !(ffPID)
	UDC("could not find ffmpeg PID.")
else
	UDC("ffmpeg PID: " ffPID)
loop
	{
		sleep 200
		string := cmd.read()
		if !(instr(string, "frame="))
			continue
		loop 4
			string := strreplace(strreplace(string, "= ","="), A_space A_Space, A_space)
		vars := strsplit(StrTail(1, string), A_space)
		if instr(vars[1], "frame=")
			Frame := RegExReplace(vars[1], "\D")
		if instr(vars[2], "fps=")
			fps := RegExReplace(vars[2], "\D")
		if instr(vars[4], "size=")
			Size := RegExReplace(vars[4], "\D")
		prgbr((100/i)*Frame)
		UDC("FPS rend: " FPS "  size: " size "kb  frame:" frame)
		if instr(string, "kb/s:")
			break
	}
UDC("Done.")
return
stop:
if !(ffpid)
	{
		UDC("ffmpeg isn't running.")
		return
	}
UDC("killing ffmpeg " ffpid)
process, close, %ffpid%
prgbr(100)
return
GuiClose:
onexit:
UDC("exiting...")
process, close, %ffpid%
cmd.close()
sleep 1000
exitapp
return
chroma:
p+=1
if (p>100)
	p:=1
Chroma(p)
return
SelectFolder:
FileSelectFolder, Path,,, Target the directory containing the images you wish to timelapse
if !(path)
	return
guicontrol,, PathDisplay, %Path%
gui, submit, nohide
images := FindImages(Path)
return
StrTail(k,str) {
      Return RegExReplace(str,".*(?=(\n[^\n]*){" k "}$)")
}
UDC(s)
	{
		static log := {}
		log.insertat(1, S)
		if log.count() > 3
			log.pop()
		loop % log.count()
			o.=log[a_Index] "`n" 
		guicontrol,, GUiConsole, %o%
	}
FindImages(path)
	{
		global fps, filelist, estout, ffmpeglist, Filecount, i
		UDC("Parsing directory")
		Images:={}
		i:=0
		FileList :=""
		lastpost:=A_tickcount
		FileCount:=ComObjCreate("Scripting.FileSystemObject").GetFolder(path).Files.Count
		Loop, Files, %Path%\*.*
			if (A_LoopFileExt = "Jpg") OR (A_LoopFileExt = "jpeg") OR (A_LoopFileExt = "png") OR (A_LoopFileExt = "bmp")
				{
					i+=1
					images[i, "fullpath"]:=A_LoopFileFullPath
					images[i, "fileName"]:=A_LoopFileName
					images[i, "ext"]:=A_LoopFileext
					FileList .=A_LoopFileName "`n"
					ffmpeglist.= "file '"  A_loopfilefullpath "'`n"
					if (mod(A_index, (filecount//50))=0) OR (A_index > (filecount-5))
						{
							guicontrol,, FileCount, Files Found: %i%
							guicontrol,, FileList, %FileList%
							guicontrol,, Est, % "est out: " round(i / fps) " sec"
							prgbr((100/filecount)*A_Index)
							lastpost:=A_tickcount
						}
				}
		prgbr(100)
		UDC(i " images found.")
		return % images
	}
hexify(in, total=100)
	{
		global debug
		hue := 35
		Clip := 15
		;total += clip
		in := (in+hue) 
		if (in > total)
			in := in - total
		sec := round(total/6)
		If (in//sec = 0 || in//sec = 3)
		   R := (in//sec = 0) ? 255 : 0, G := (in//sec = 0) ? 0 : 255, B := (in//sec = 0) ? Round((in/sec - in//sec) * 255) : 255 - Round((in/sec - in//sec) * 255)
		Else If (in//sec = 1 || in//sec = 4)
		   R := (in//sec = 1) ? 255 - Round((in/sec - in//sec) * 255) : Round((in/sec - in//sec) * 255), G := (in//sec = 1) ? 0 : 255, B := (in//sec = 1) ? 255 : 0
		Else If (in//sec = 2 || in//sec = 5)
		   R := (in//sec = 2) ? 0 : 255, G := (in//sec = 2) ? Round((in/sec - in//sec) * 255) : 255 - Round((in/sec - in//sec) * 255), B := (in//sec = 2) ? 255 : 0
		if (R="") || (G="") || (B="")
			return % "FAILSAFE" "`n" " R:" R " G:" G " B:" B "`ntotal: " total " in:" in " stage:" in/sec "`nthis.in:" in " this.sec:" sec "`n`n"
		return %  tohex(R) tohex(G) tohex(B)  
	}
ToHex(input)
	{
		;made by bugz000
		SetFormat Integer, H
		(input := input+0)
		SetFormat Integer, D
		StringTrimLeft, input, input, 2
		length := StrLen(input)
		if (length = 0)
			exitapp
		if (length = 1)
				input := "0"  .  input
		return, input
	}
prgbr(p)
	{
		if (p>75)
		{
			GuiControl,move, Progressbar1,% "X" 0 "Y" -5 "w" 384 "h" 10 	
			GuiControl,move, Progressbar2,% "X" 379 "Y" -3 "w" 10 "h" 233 
			GuiControl,move, Progressbar3,% "X" 0 "Y" 228 "w" 384 "h" 10 	
			GuiControl,move, Progressbar4,% "X" -5 "Y" 230-pcof(((p-75) * 4),230) "w" 10 "h" 233 
		}                                                                      								                                							             
	else if (p>50)                                                      								                                						             
		{                                                                      								                                						             
			GuiControl,move, Progressbar1,% "X" 0 "Y" -5 "w" 384 "h" 10 	
			GuiControl,move, Progressbar2,% "X" 379 "Y" -3 "w" 10 "h" 233 
			GuiControl,move, Progressbar3,% "X" 379-pcof(((p-50) * 4),379) "Y" 228 "w" 384 "h" 10
			GuiControl,move, Progressbar4,% "X" -5 "Y" -3 "w" 0 "h" 0
		}                                                                      								                								                						             
	else if (p>25)                                                      								                								                						             
		{                                                                      								                								                						             
			GuiControl,move, Progressbar1,% "X" 0 "Y" -5 "w" 384 "h" 10
			GuiControl,move, Progressbar2,% "X" 379 "Y" -233+pcof(((p-25) * 4),233) "w" 10 "h" 233
			GuiControl,move, Progressbar3,% "X" 0 "Y" 228 "w" 0 "h" 0 
			GuiControl,move, Progressbar4,% "X" -5 "Y" -3 "w" 0 "h" 0
		}                                                                      								                								                						             
	else                                                                     								                								                						             
		{                                                                      								                								                						             
			GuiControl,move, Progressbar1,% "X" -384+pcof((p * 4),384) "Y" -5 "w" 384 "h" 10
			GuiControl,move, Progressbar2,% "X" 379 "Y" -3 "w" 0 "h" 0
			GuiControl,move, Progressbar3,% "X" 0 "Y" 228 "w" 0 "h" 0
			GuiControl,move, Progressbar4,% "X" -5 "Y" -3 "w" 0 "h" 0 
		}							
	}
pcof(in, max)
	{
		return % ((max/100)*in)
	}
Chroma(p)
	{
		c := hexify(p)
		GuiControl,+c%c% +background%c%, Progressbar1
		GuiControl,+c%c% +background%c%, Progressbar2
		GuiControl,+c%c% +background%c%, Progressbar3
		GuiControl,+c%c% +background%c%, Progressbar4
		Gui, Font, c%c%
		GuiControl, Font, donate
	}


#include %A_Scriptdir%\lib\CLi.ahk
#include %A_Scriptdir%\lib\st_printarr.ahk
#include %A_Scriptdir%\lib\wingetall.ahk
#include %A_Scriptdir%\lib\WTSEP.ahk
