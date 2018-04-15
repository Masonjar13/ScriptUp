#singleInstance force
#persistent
#noEnv
#include <threadMan>
#include <fileList>
menu,tray,tip,ScriptUp

; setup config
debug:=1
sini:=(siniD:=a_appData . "\..\Local\ScriptUp") . "\config.ini"
lvw:=500
lvo:=" -LV0x10 -multi +sort"
lvHdr3w:=100
lvHdr2w:=100
lvHdr1w:=lvw-lvHdr2w-lvHdr3w
stateUpInt:=1000

if(!fileExist(siniD)){
    firstRun:=1
    fileCreateDir,% siniD
}
sList:=new fileList(sini)

onExit,cleanup
onMessage(0x46,"isMoving")

; load settings
fileLastDir:=a_scriptFullPath
iniRead,hideDeleteWarning,% sini,settings,hideDeleteWarning,0
regRead,loginRun,% regStartupPath:="HKCU\Software\Microsoft\Windows\CurrentVersion\Run",ScriptUp
if(!errorLevel) ; auto-correct if the script has been moved
    if(loginRun!=a_scriptFullPath)
        regWrite,REG_SZ,% regStartupPath,ScriptUp,% a_scriptFullPath
iniRead,guiLastHeight,% sini,settings,guiLastHeight,500

#include <guis>

; menu settings
if(hideDeleteWarning)
    menu,settings,check,Disable file remove warning
if(loginRun)
    menu,settings,check,Start on User Login

; start scripts
sList.runAll()

; state checker
setTimer,checkStates,% stateUpInt

; open menu automatically for first run
if(firstRun)
    gosub showMain
return

; subs
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
gosub checkStates
return

reloadScript:
gui,main:default
lv_getText(reloadScript,selectedRow)
sList.reload(reloadScript)
gosub checkStates
return

listlinesScript:
gui,main:default
lv_getText(listlinesScript,selectedRow)
sList.listlines(listlinesScript)
return

pauseScript:
gui,main:default
lv_getText(pauseScript,selectedRow)
sList.pause(pauseScript)
gosub checkStates
return

suspendScript:
gui,main:default
lv_getText(suspendScript,selectedRow)
sList.suspend(suspendScript)
gosub checkStates
return

removeScript:
if(!selectedRow){
    if(!hideDeleteWarning)
        msgbox,,Make a selection,No file was selected.
    return
}
gui,main:default
lv_getText(delKey,selectedRow)
if(hideDeleteWarning)
    goto removeScriptFinal
msgbox,4,Confirm,Are you sure you want to remove this script? This will not delete the actual script.
ifMsgbox,yes
    gosub removeScriptFinal
return

removeScriptFinal:
gui,main:default
sList.remove(delKey)
iniDelete,% sini,scripts,% delKey
lv_delete()
gosub refreshList
return

execScript:
gui,main:default
lv_getText(execScript,selectedRow)
gui,execCode:default
guiControl,,execCodeCode,
gui,show,,% "Execute code on thread: " . execScript
return

execScriptCode:
gui,execCode:default
gui,submit,nohide
sList.exec(execScript,execCodeCode)
return

reloadScripts:
sList.reloadAll()
gosub checkStates
return

refreshList:
gui,main:default
sList.genList()
gosub checkStates
return

checkStates:
gui,main:default
sList.getStateAll()
return

deleteWarning:
menu,settings,toggleCheck,Disable file remove warning
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
gui,main:+disabled
return

aboutLink:
run,% a_guiControl="Masonjar13"?"https://github.com/Masonjar13"
    :""
return

lvCallback:
if(a_guiEvent="Normal")
    selectedRow:=a_eventInfo
else if(a_guiEvent="RightClick"){
    if(selectedRow:=a_eventInfo)
        menu,cmain,show
}
return

showMain:
gui,main:show,,ScriptUp
return

#include <guiSubs>

isMoving(wparam,lparam,msg,hwnd){
    global stateUpInt,ghwnd
    if(hwnd=ghwnd || hwnd=ghwnd2 || hwnd=ghwnd3 || hwnd=ghwnd4)
        setTimer,checkStates,% getKeyState("LButton","P")?"Off":stateUpInt
}
