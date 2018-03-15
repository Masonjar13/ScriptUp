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
gui,addScript:cancel
gui,about:cancel
gui,main:cancel
sList.closeAll()
exitApp
