class fileList {
    quitTimeout:=30000
    scripts:=[]
    
    __new(sini){
        this.sini:=sini
        this.loadDlls()
    }
    
    __delete(){
        for i,a in this.scripts {
            a.thread:=""
        }
    }
    
    genList(){
        iniRead,allScripts,% this.sini,scripts
        loop,parse,allScripts,`n
        {
            ctn:=0
            regExMatch(a_loopField,"O)([^=]+)=([^?]+)\?([a-zA-Z0-9]+)",t)
            tn:={name: t.1,path: t.2,dll: t.3}
            for i,a in this.scripts {
                if(a.name=t.1){
                    ctn:=1
                    break
                }
            }
            if(!ctn)
                this.scripts[t[1]]:=tn

            if(!lv_modify(a_index,,t.1,,t.3))
                lv_add(,t.1,,t.3)
        }
        lv_modifyCol(1,"sort")
    }
    
    runAll(reload:=0){
        for i,a in this.scripts {
            if(reload)
                err:=this.reload(a.name)
            else
                err:=this.run(a.name)
            
            ; error checking
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
        
        ; report errors
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
        for i,a in this.scripts {
            this.close(a.name)
        }
    }
    
    reload(scriptName){
        this.close(scriptName)
        return this.run(scriptName)
    }
    
    listlines(scriptName){
        if(this.scripts[scriptName].dll="Mini")
            msgbox,,Limitation Error,Mini DLL doesn't support ListLines.
        else
            this.scripts[scriptName].thread.exec("ListLines")
    }
    
    pause(scriptName){
        return this.scripts[scriptName].thread.pause()
    }
    
    suspend(scriptName){
        if(this.scripts[scriptName].dll="Mini")
            msgbox,,Limitation Error,Mini DLL doesn't support hotkeys.
        else
            this.scripts[scriptName].thread.exec("Suspend")
    }
    
    getStateAll(){
        for i,a in this.scripts{
            lv_getText(pstate,a_index,2)
            state:=this.getState(a.name)
            if(state!=pstate)
                lv_modify(a_index,,,state)
        }
    }
    
    getState(scriptName){
        return this.scripts[scriptName].thread.state()
    }
    
    run(scriptName){
        dllPath:=this.getDll(this.scripts[scriptName].dll)
        
        ; error checking
        if(!dllPath)
            return -1
        else if(!fileExist(dllPath))
            return -2
        else if(!fileExist(this.scripts[scriptName].path))
            return -3
        
        this.scripts[scriptName].thread:=new threadMan(dllPath)
        this.scripts[scriptName].thread.quitTimeout:=this.quitTimeout
        this.scripts[scriptName].thread.newFromFile(this.scripts[scriptName].path)
    }
    
    close(scriptName){
        try
            this.scripts[scriptName].thread:=""
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
