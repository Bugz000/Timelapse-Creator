WTSEnumProcesses( Mode := 1 ) { ;        By SKAN,  http://goo.gl/6Zwnwu,  CD:24/Aug/2014 | MD:25/Aug/2014 
  Local tPtr := 0, pPtr := 0, nTTL := 0, LIST := ""

  If not DllCall( "Wtsapi32\WTSEnumerateProcesses", "Ptr",0, "Int",0, "Int",1, "PtrP",pPtr, "PtrP",nTTL )
    Return "", DllCall( "SetLastError", "Int",-1 )        
         
  tPtr := pPtr
  Loop % ( nTTL ) 
    LIST .= ( Mode < 2 ? NumGet( tPtr + 4, "UInt" ) : "" )           ; PID
         .  ( Mode = 1 ? A_Tab : "" )
         .  ( Mode > 0 ? StrGet( NumGet( tPtr + 8 ) ) "`n" : "," )   ; Process name  
  , tPtr += ( A_PtrSize = 4 ? 16 : 24 )                              ; sizeof( WTS_PROCESS_INFO )  
  
  StringTrimRight, LIST, LIST, 1
  DllCall( "Wtsapi32\WTSFreeMemory", "Ptr",pPtr )      

Return LIST, DllCall( "SetLastError", "UInt",nTTL ) 
}