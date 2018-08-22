reloadScript:
lv_getText(scr,selectedRow)
worker.exec("threadList.reload(""" . scr . """)")
return

pauseScript:
lv_getText(scr,selectedRow)
worker.exec("threadList.pause(""" . scr . """)")
return

suspendScript:
lv_getText(scr,selectedRow)
worker.exec("threadList.suspend(""" . scr . """)")
return

listlinesScript:
lv_getText(scr,selectedRow)
worker.exec("threadList.listlines(""" . scr . """)")
return

editScript:
lv_getText(scr,selectedRow)
worker.exec("threadList.edit(""" . scr . """)")
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
worker.exec("threadList.remove(""" . scr . """)`nthreadList.genList()")
gosub genList
return

execScript:
lv_getText(scrx,selectedRow)
guiControl,execCode:,execScriptCode,
gui,execCode:show,,% "Execute code on thread: " . scrx
return

execScriptFinal:
gui,execCode:submit,nohide
worker.exec("threadList.exec(""" . scrx . """,""" . execScriptCode . """)")
return
