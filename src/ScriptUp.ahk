#singleInstance force
#persistent
#noEnv
#include <threadMan>
menu,tray,tip,ScriptUp

; setup config
sini:=(siniD:=a_appData . "\..\Local\ScriptUp") . "\config.ini"
lvw:=400
;lvr:=20
lvo:=" -LV0x10 -multi +sort"
lvHdr2w:=100
lvHdr1w:=lvw-lvHdr2w

if(!fileExist(siniD)){
    firstRun:=1
    fileCreateDir,% siniD
}else
    sList:=new fileList(sini)

onExit,cleanup

; load settings
fileLastDir:=a_scriptFullPath
iniRead,hideDeleteWarning,% sini,settings,hideDeleteWarning,0
regRead,loginRun,% regStartupPath:="HKCU\Software\Microsoft\Windows\CurrentVersion\Run",ScriptUp
if(!errorLevel) ; auto-correct if the script has been moved
    if(loginRun!=a_scriptFullPath)
        regWrite,REG_SZ,% regStartupPath,ScriptUp,% a_scriptFullPath
iniRead,guiLastHeight,% sini,settings,guiLastHeight,500

; gui: main
gui,main:default
gui,margin,13,15
gui,% "+hwndghwnd +minSize" . lvw+30 . "x420 +maxSize" . lvw+30 . "x +resize"
gui,font,s11,courier new
gui,add,listview,% "w" . lvw+4 . " r10 altsubmit glvCallback vscriptLV" . lvo,Script Name|DLL Type
lv_modifyCol(1,lvHdr1w)
lv_modifyCol(2,lvHdr2w)
sList.genList()
gui,font,,arial
gui,add,button,gaddScript section,Add script
gui,add,button,greloadScript ys,Reload script
gui,add,button,gremoveScript ys,Remove script
gui,show,hide ; set GUI form
gui,show,% "h" . guiLastHeight " w" . lvw+30 . " hide" ; set last size

; gui: addScript
gui,addScript:+ownermain +hwndghwnd2
gui,addScript:font,s10,arial
gui,addScript:add,edit,w240 r2 vpathText section +readonly
gui,addScript:add,ddl,w50 vdllType ys,Std||Mini
gui,addScript:add,button,gaddScriptFinal xm,Add

; gui: about
gui,about:+ownermain
gui,about:font,s12,arial
gui,about:add,text,section,Written by
gui,about:font,cBlue underline
gui,about:margin,5,9
gui,about:add,text,ys gaboutLink,Masonjar13
gui,about:font,norm s12
gui,about:margin,1
gui,about:add,text,ys,% ".   "
gui,about:margin,15,9
gui,about:font,s9 cBlack
gui,about:add,button,xm gaboutGuiClose w40,Ok

; menu: main
menu,actions,add,Reload all Scripts,reloadScripts
menu,actions,add,Refresh list,refreshList
menu,settings,add,Disable file delete warning,deleteWarning,+radio
menu,settings,add,Start on User Login,logonRun,+radio
menu,settings,add,Set DLL: Std,setDll
menu,settings,add,Set DLL: Mini,setDll

menu,main,add,Actions,:actions
menu,main,add,Settings,:settings
menu,main,add,About,about
gui,menu,main

; menu: tray
menu,tray,nostandard
menu,tray,add,Open GUI,showMain
menu,tray,default,Open GUI
menu,tray,add,Exit,cleanup

; menu settings
if(hideDeleteWarning)
    menu,settings,check,Disable file delete warning
if(loginRun)
    menu,settings,check,Start on User Login

; start scripts
sList.runAll()

; open menu automatically for first run
if(firstRun)
    gosub showMain
return

addScript:
gui,main:default

; select file
gui,+ownDialogs
fileSelectFile,newScript,3,% fileLastDir,Add Script,(*.ahk)
if(errorlevel||!newScript)
    return

; ext checking
if(getFileext(newScript)!="ahk"){
    msgbox,,Error: Incorrect FileType,Only AutoHotkey files are allowed.
    return
}

; save last file dir for fileSelectFile
splitPath,newScript,,fileLastDir

; show gui: addScript
gui,main:+disabled
guiControl,addScript:,pathText,% newScript
gui,addScript:show,,Add Script
return

addScriptFinal:
gui,main:default
gui,addScript:submit
gui,-disabled
iniWrite,% newScript . "?" . dllType,% sini,scripts,% getFilename(newScript)
lv_delete()
gosub refreshList
sList.run(getFilename(newScript))
return

reloadScript:
gui,main:default
lv_getText(reloadScript,selectedRow)
sList.reload(reloadScript)
return

removeScript:
if(!selectedRow){
    if(!hideDeleteWarning)
        msgbox,,Make a selection,No file was selected.
    return
}
if(hideDeleteWarning)
    goto removeScriptFinal
msgbox,4,Confirm,Are you sure you want to remove this script? This will not delete the actual script.
ifMsgbox,yes
    gosub removeScriptFinal
return

removeScriptFinal:
gui,main:default
lv_getText(delKey,selectedRow)
sList.close(delKey)
iniDelete,% sini,scripts,% delKey
lv_delete()
gosub refreshList
return

reloadScripts:
sList.reloadAll()
return

refreshList:
gui,main:default
sList.genList()
return

deleteWarning:
menu,settings,toggleCheck,Disable file delete warning
if(!settingsHwnd)
    settingsHwnd:=dllCall("GetSubMenu","UInt",dllCall("GetMenu","UInt",ghwnd),"Int",1)
sendMessage,0x116,settingsHwnd,0,,% "ahk_id " . ghwnd
if(dllCall("GetMenuState","UInt",settingsHwnd,"UInt",0,"UInt",0x400) >> 3 & 1)
    iniWrite,% hideDeleteWarning:=1,% sini,settings,hideDeleteWarning
else
    iniWrite,% hideDeleteWarning:=0,% sini,settings,hideDeleteWarning
return

logonRun:
menu,settings,toggleCheck,Start on User Login
if(!settingsHwnd)
    settingsHwnd:=dllCall("GetSubMenu","UInt",dllCall("GetMenu","UInt",ghwnd),"Int",1)
sendMessage,0x116,settingsHwnd,0,,% "ahk_id " . ghwnd
if(dllCall("GetMenuState","UInt",settingsHwnd,"UInt",1,"UInt",0x400) >> 3 & 1)
    regWrite,REG_SZ,% regStartupPath,ScriptUp,% a_scriptFullPath
else
    regDelete,% regStartupPath,ScriptUp
return

setDll:
gui,main:default

gui,+ownDialogs
fileSelectFile,nDllPath,3,% fileLastDir,Add Script,(*.dll)
if(errorlevel||!nDllPath)
    return

if(getFileext(nDllPath)!="dll"){
    msgbox,,Error: Incorrect FileType,Only a AutoHotkey_H.dll should be selected.
    return
}

; save last file dir for fileSelectFile
splitPath,nDllPath,,fileLastDir

; std or mini
nDllType:=inStr(a_thisMenuItem,"Std")?"Std":"Mini"

sList.setDll(nDllType,nDllPath)
return

about:
gui,about:show,,About
return

aboutLink:
run,% a_guiControl="Masonjar13"?"https://github.com/Masonjar13"
    :""
return

lvCallback:
if(a_guiEvent="Normal")
    selectedRow:=a_eventInfo
return

showMain:
gui,main:show,,ScriptUp
return

; gui-prefixed labels
mainGuiDropFiles:
loop,parse,a_guiEvent,`n
{
    if(getFileext(newScript:=a_loopField)!="ahk"){
        msgbox,,Error: Incorrect FileType,Only AutoHotkey files are allowed.
        continue
    }
    gui,main:+disabled
    guiControl,addScript:,pathText,% newScript
    gui,addScript:show,,Add Script
    winWaitClose,% "ahk_id " . ghwnd2
}
return

mainGuiSize:
gui,main:default
if(a_eventInfo=1)
    return
AutoXYWH("h","scriptLV")
AutoXYWH("y","Add script","Reload script","Remove script")
iniWrite,% a_guiHeight,% sini,settings,guiLastHeight
return

mainGuiClose:
gui,main:cancel
return

addScriptGuiClose:
gui,addScript:cancel
gui,main:-disabled
return

aboutGuiClose:
gui,about:cancel
gui,main:-disabled
return

cleanup:
exitApp

; functions
getFilename(path){
    splitPath,path,,,,fname
    return fname
}

getFileext(path){
    splitPath,path,,,ext
    return ext
}    

AutoXYWH(DimSize, cList*){       ; http://ahkscript.org/boards/viewtopic.php?t=1079
  static cInfo := {}
 
  If (DimSize = "reset")
    Return cInfo := {}
 
  For i, ctrl in cList {
    ctrlID := A_Gui ":" ctrl
    If ( cInfo[ctrlID].x = "" ){
        GuiControlGet, i, %A_Gui%:Pos, %ctrl%
        MMD := InStr(DimSize, "*") ? "MoveDraw" : "Move"
        fx := fy := fw := fh := 0
        For i, dim in (a := StrSplit(RegExReplace(DimSize, "i)[^xywh]")))
            If !RegExMatch(DimSize, "i)" dim "\s*\K[\d.-]+", f%dim%)
              f%dim% := 1
        cInfo[ctrlID] := { x:ix, fx:fx, y:iy, fy:fy, w:iw, fw:fw, h:ih, fh:fh, gw:A_GuiWidth, gh:A_GuiHeight, a:a , m:MMD}
    }Else If ( cInfo[ctrlID].a.1) {
        dgx := dgw := A_GuiWidth  - cInfo[ctrlID].gw  , dgy := dgh := A_GuiHeight - cInfo[ctrlID].gh
        For i, dim in cInfo[ctrlID]["a"]
            Options .= dim (dg%dim% * cInfo[ctrlID]["f" dim] + cInfo[ctrlID][dim]) A_Space
        GuiControl, % A_Gui ":" cInfo[ctrlID].m , % ctrl, % Options
} } }

; class
class fileList {
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

            if(!lv_modify(a_index,,t.1,t.3))
                lv_add(,t.1,t.3)
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
    
    reload(scriptName){
        this.close(scriptName)
        return this.run(scriptName)
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
        this.scripts[scriptName].thread.newFromFile(this.scripts[scriptName].path)
    }
    
    close(scriptName){
        this.scripts[scriptName].thread:=""
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