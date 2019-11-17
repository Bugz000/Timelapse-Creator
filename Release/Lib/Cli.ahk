
class cli {
    __New(sCmd, sDir="",codepage="") {
      DllCall("CreatePipe","Ptr*",hStdInRd,"Ptr*",hStdInWr,"Uint",0,"Uint",0)
      DllCall("CreatePipe","Ptr*",hStdOutRd,"Ptr*",hStdOutWr,"Uint",0,"Uint",0)
      DllCall("SetHandleInformation","Ptr",hStdInRd,"Uint",1,"Uint",1)
      DllCall("SetHandleInformation","Ptr",hStdOutWr,"Uint",1,"Uint",1)
      if (A_PtrSize=4) {
         VarSetCapacity(pi, 16, 0)
         sisize:=VarSetCapacity(si,68,0)
         NumPut(sisize, si,  0, "UInt"), NumPut(0x100, si, 44, "UInt"),NumPut(hStdInRd , si, 56, "Ptr"),NumPut(hStdOutWr, si, 60, "Ptr"),NumPut(hStdOutWr, si, 64, "Ptr")
         }
      else if (A_PtrSize=8) {
         VarSetCapacity(pi, 24, 0)
         sisize:=VarSetCapacity(si,96,0)
         NumPut(sisize, si,  0, "UInt"),NumPut(0x100, si, 60, "UInt"),NumPut(hStdInRd , si, 80, "Ptr"),NumPut(hStdOutWr, si, 88, "Ptr"), NumPut(hStdOutWr, si, 96, "Ptr")
         }
      pid:=DllCall("CreateProcess", "Uint", 0, "Ptr", &sCmd, "Uint", 0, "Uint", 0, "Int", True, "Uint", 0x08000000, "Uint", 0, "Ptr", sDir ? &sDir : 0, "Ptr", &si, "Ptr", &pi)
      DllCall("CloseHandle","Ptr",NumGet(pi,0))
      DllCall("CloseHandle","Ptr",NumGet(pi,A_PtrSize))
      DllCall("CloseHandle","Ptr",hStdOutWr)
      DllCall("CloseHandle","Ptr",hStdInRd)
         ; Create an object.
		this.hStdInWr:= hStdInWr, this.hStdOutRd:= hStdOutRd, this.pid:=pid
		this.codepage:=(codepage="")?A_FileEncoding:codepage
	}
    __Delete() {
        this.close()
    }
    close() {
       hStdInWr:=this.hStdInWr
       hStdOutRd:=this.hStdOutRd
       DllCall("CloseHandle","Ptr",hStdInWr)
       DllCall("CloseHandle","Ptr",hStdOutRd)
      }
   write(sInput="")  {
		If   sInput <>
			FileOpen(this.hStdInWr, "h", this.codepage).Write(sInput)
      }
	readline() {
       fout:=FileOpen(this.hStdOutRd, "h", this.codepage)
	   this.AtEOF:=fout.AtEOF
       if (IsObject(fout) and fout.AtEOF=0)
         return fout.ReadLine()
      return ""
      }
	read(chars="") {
       fout:=FileOpen(this.hStdOutRd, "h", this.codepage)
       this.AtEOF:=fout.AtEOF
	   if (IsObject(fout) and fout.AtEOF=0)
         return chars=""?fout.Read():fout.Read(chars)
      return ""
      }
}
