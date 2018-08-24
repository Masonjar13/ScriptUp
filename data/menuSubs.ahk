reloadScript:
lv_getText(scr,selectedRow)
worker.execAFunc("do","reload",scr,"")
return

pauseScript:
lv_getText(scr,selectedRow)
worker.execAFunc("do","pause",scr,"")
return

suspendScript:
lv_getText(scr,selectedRow)
worker.execAFunc("do","suspend",scr,"")
return

listlinesScript:
lv_getText(scr,selectedRow)
worker.execAFunc("do","listlines",scr,"")
return

editScript:
lv_getText(scr,selectedRow)
worker.execAFunc("do","edit",scr,"")
return

removeScript:
if(!selectedRow){
    if(!hideDeleteWarning)
        msgbox,,Make a selection,No file was selected.
    return
}
lv_getText(scr,selectedRow)
if(!hideDeleteWarning){
    msgbox,4,Confirm,Are you sure you want to remove this script? This will not delete the actual script.
    ifMsgbox,yes
        gosub removeScriptFinal
}else
    gosub removeScriptFinal
return

removeScriptFinal:
iniDelete,% sini,scripts,% scr
worker.execFunc("do","remove",scr,"")
worker.execAFunc("do","genList","","")
gosub genList
return

execScript:
lv_getText(scrx,selectedRow)
guiControl,execCode:,execScriptCode,
gui,execCode:show,,% "Execute code on thread: " . scrx
return

execScriptFinal:
gui,execCode:submit,nohide
worker.execAFunc("do","exec",scrx,execScriptCode)
return
