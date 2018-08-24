#singleInstance force
#persistent
#noEnv
#noTrayIcon
setWorkingDir,% a_scriptDir
sini:=a_scriptDir . "\config.ini"
onExit,clean

threadList:=new fileList(sini)
threadList.genList()
threadList.runAll()
setTimer,updateStatus,100
return

do(funct,p1,p2){ ; execAFunc does not support varadic functions or optional params
    global threadList
    params:=[]
    loop 2
        if(p%a_index%)
            params.push(p%a_index%)
    threadList[funct](params*)
}

updateStatus:
stateList:=threadList.returnStates()
return

clean:
threadList:=
exitApp

class fileList {
    __new(sini){
        this.quitTimeout:=3000
        this.scripts:=[]
        this.sini:=sini
        this.loadDlls()
    }
    __delete(){
        for i,a in this.scripts {
            this.close(a.name)
        }
    }
    genList(){
        iniRead,allScripts,% this.sini,scripts
        loop,parse,allScripts,`n
        {
            ctn:=0
            regExMatch(a_loopField,"O)([^=]+)=([^?]+)\?([a-zA-Z0-9]+)",t)
            for i,a in this.scripts {
                if(a.name=t.1){
                    ctn:=1
                    break
                }
            }
            if(!ctn){
                tn:={name: t.1,path: t.2,dll: t.3}
                this.scripts[t[1]]:=tn
            }
        }
    }
    runAll(reload:=0){
        for i,a in this.scripts {
            if(reload)
                err:=this.reload(a.name)
            else
                err:=this.run(a.name)
            if(err){
                if(err=-1){
                    if(err1){
                        if(!inStr(err1,a.dll))
                            err1.=", " . a.dll
                    }else
                        err1:=a.dll
                }
                else if(err=-2){
                    if(err2){
                        if(!inStr(err2,a.dll))
                            err2.=", " . a.dll . " (" . this.getDll(a.dll) . ")"
                    }else
                        err2:=a.dll . " (" . this.getDll(a.dll) . ")"
                }else if(err=-3)
                    err3:=(err3?err3 . ", ":"") . a.name . " (" . a.path . ")"
            }
        }
        if(err1||err2||err3)
            msgbox,,Error,% "There were errors while trying to run scripts:`n`n    "
                . (err1?"DLL path not specified: " . err1 . "`n`n    ":"")
                . (err2?"DLL not found at path: " . err2 . "`n`n     ":"")
                . (err3?"File path invalid: " . err3 . "`n`n    ":"")
    }
    reloadAll(){
        this.runAll(1)
    }
    closeAll(){
        global debug
        for i,a in this.scripts {
            if(debug)
                tooltip,% "Closing " . a.name
            this.close(a.name)
        }
        toolTip
    }
    edit(scriptName){
        try
            run,% "edit """ . this.scripts[scriptName].path . """"
    }
    exec(scriptName,code){
        if(this.pauseState(scriptName))
            msgbox,,Limitation Error,Code can not be executed while thread is paused.
        else
            return this.scripts[scriptName].thread.ahkExec(code)
    }
    reload(scriptName){
        this.scripts[scriptName].thread.ahkReload()
    }
    listlines(scriptName){
        if(this.scripts[scriptName].dll="Mini")
            msgbox,,Limitation Error,Mini DLL doesn't support ListLines.
        else
            this.exec(scriptName,"ListLines")
    }
    pause(scriptName,pauseState:="tog"){
        if(pauseState="tog"){
            pauseState:=!this.pauseState(scriptName)
        }
        pauseState:=this.scripts[scriptName].thread.ahkPause(pauseState)
        return pauseState
    }
    pauseState(scriptName){
        return this.scripts[scriptName].thread.ahkPause()
    }
    suspend(scriptName){ ; Helgef - https://autohotkey.com/boards/viewtopic.php?p=207480#p207480
        static WM_COMMAND := 0x111
        static ID_FILE_SUSPEND := 65404
        local dhwLast

        if(this.scripts[scriptName].dll="Mini")
            msgbox,,Limitation Error,Mini DLL doesn't support hotkeys.
        else{
            if(a_detectHiddenWindows="Off"){
                dhwLast:=a_detectHiddenWindows
                detectHiddenWindows,on
            }
            postMessage,WM_COMMAND,ID_FILE_SUSPEND,,,% "ahk_id " this.scripts[scriptName].thread.ahkGetVar("a_scripthwnd")
            if(dhwLast)
                detectHiddenWindows,% dhwLast
        }
    }
    getState(scriptName){
        if(this.scripts[scriptName].thread.ahkReady()){
            pauseState:=this.pauseState(scriptName)
            suspendState:=this.scripts[scriptName].thread.ahkGetVar("a_isSuspended")
            return pauseState?(suspendState?"P/S":"Paused"):(suspendState?"Suspended":"Running")
        }
        return "Stopped"
    }
    returnStates(){
        local str,i,a
        for i,a in this.scripts
            str.=!str?this.getState(a.name):"," . this.getState(a.name)
        return str
    }
    run(scriptName){
        setWorkingDir,% a_scriptDir
        dllPath:=this.getDll(this.scripts[scriptName].dll)

        ; error checking
        if(!dllPath)
            return -1
        else if(!fileExist(dllPath))
            return -2
        else if(!fileExist(this.scripts[scriptName].path))
            return -3
        this.scripts[scriptName].thread:=ahkThread(this.scripts[scriptName].path,,1,dllPath)
    }
    close(scriptName){
        try{
            try{
                this.scripts[scriptName].thread.ahkTerminate()
                MemoryFreeLibrary(this.scripts[scriptName].thread[""])
            }
            this.scripts[scriptName].thread:=""
        }
    }
    remove(scriptName){
        this.close(scriptName)
        this.scripts.delete(scriptName)
    }
    loadDlls(){
        iniRead,dlltypes,% this.sini,dllTypes
        loop,parse,dlltypes,`n
        {
            regExMatch(a_loopField,"O)([^=]+)=([^$]+)",t)
            this.dllTypes[t[1]]:=t.2
        }
    }
    setDll(dllType,path){
        this.dllTypes[dllType]:=path
        iniWrite,% path,% this.sini,dlltypes,% dllType
    }
    getDll(dllType){
        return this.dllTypes[dllType]
    }
}

ahkthread_free(obj:=""){
  static objects
  if !objects
    objects:=[]
  if (obj="")
      objects:=[]
  else if !IsObject(obj)
	return objects
  else If objects.HasKey(obj)
	objects.Remove(obj)
}
ahkthread(s:="",p:="",IsFile:=0,dll:=""){
  static ahkdll,ahkmini,base,functions
  if !base
    base:={__Delete:"ahkthread_release"},UnZipRawMemory(LockResource(LoadResource(0,hRes:=DllCall("FindResource","PTR",0,"Str","F903E44B8A904483A1732BA84EA6191F","PTR",10,"PTR"))),SizeofResource(0,hRes),ahkdll)
    ,UnZipRawMemory(LockResource(LoadResource(0,hRes:=DllCall("FindResource","PTR",0,"Str","FC2328B39C194A4788051A3B01B1E7D5","PTR",10,"PTR"))),SizeofResource(0,hRes),ahkmini)
    ,functions:={_ahkFunction:"s==stttttttttt",_ahkPostFunction:"i==stttttttttt",ahkFunction:"s==sssssssssss",ahkPostFunction:"i==sssssssssss",ahkdll:"ut==sss",ahktextdll:"ut==sss",ahkReady:"",ahkReload:"i==i",ahkTerminate:"i==i",addFile:"ut==sucuc",addScript:"ut==si",ahkExec:"ui==s",ahkassign:"ui==ss",ahkExecuteLine:"ut==utuiui",ahkFindFunc:"ut==s",ahkFindLabel:"ut==s",ahkgetvar:"s==sui",ahkLabel:"ui==sui",ahkPause:"i==s",ahkIsUnicode:""}
  obj:={(""):lib:=MemoryLoadLibrary(dll=""?&ahkdll:dll="FC2328B39C194A4788051A3B01B1E7D5"?&ahkmini:dll),base:base}
  for k,v in functions
    obj[k]:=DynaCall(MemoryGetProcAddress(lib,A_Index>2?k:SubStr(k,2)),v)
  If !(s+0!="" || s=0)
    obj.hThread:=obj[IsFile?"ahkdll":"ahktextdll"](s,"",p)
  ahkthread_free(true)[obj]:=1 ; keep dll loaded even if returned object is freed
  return obj
}