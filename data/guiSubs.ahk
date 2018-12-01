guiDropFiles:
loop,parse,a_guiEvent,`n
{
    if(getFileext(newScript:=a_loopField)!="ahk"){
        msgbox,,Error: Incorrect FileType,Only AutoHotkey files are allowed.
        continue
    }
    gui,+disabled
    guiControl,addScript:,pathText,% newScript
    gui,addScript:show,,Add Script
    winWaitClose,% "ahk_id " . ghwnd2
}
gui,-disabled
return

addScriptFinal:
gui,addScript:submit
iniWrite,% newScript . "?" . dllType,% sini,scripts,% getFilename(newScript)
gosub,genList
worker.ahkFunction("do","genList","","")
worker.ahkPostFunction("do","run",getFilename(newScript),"")
return

genList:
gui,% ghwnd . ":default"
lv_delete()
iniRead,allScripts,% sini,scripts
loop,parse,allScripts,`n
{
    regExMatch(a_loopField,"O)([^=]+)=([^?]+)\?([a-zA-Z0-9]+)",t)
    lv_add(,t.1,,t.3)
}
lv_modifyCol(1,"sort")
return

setDll:
gui,+ownDialogs
fileSelectFile,nDllPath,3,% fileLastDir,% "Set " . a_guiControl . " DLL",(*.dll)
if(errorlevel||!nDllPath)
    return
if(getFileext(nDllPath)!="dll"){
    msgbox,,Error: Incorrect FileType,Only a AutoHotkey_H.dll should be selected.
    return
}

; save last file dir for fileSelectFile
splitPath,nDllPath,,fileLastDir

; std or mini
nDllType:=inStr(a_guiControl,"Std")?"Std":"Mini"
gosub setDllFinal
return

setDllFinal:
worker.ahkPostFunction("do","setDll",nDllType,nDllPath)
return

libShort:
fileDelete,% a_scriptDir . "\Lib.lnk"
if(!ahkDir)
    splitPath,a_ahkPath,,ahkDir
fileCreateShortcut,% ahkDir . "\Lib",% a_scriptDir . "\Lib.lnk"
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
gui,show,,ScriptUp
return

guiClose:
gui,cancel
return

aboutLink:
run,https://github.com/Masonjar13
return
