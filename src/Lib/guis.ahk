; gui: main
gui,main:default
gui,margin,13,15
gui,% "+hwndghwnd +minSize" . lvw+30 . "x420 +maxSize" . lvw+30 . "x +resize"
gui,font,s11,courier new
gui,add,listview,% "w" . lvw+4 . " r20 altsubmit glvCallback vscriptLV" . lvo,Script Name|State|DLL Type
lv_modifyCol(1,lvHdr1w)
lv_modifyCol(2,lvHdr2w)
lv_modifyCol(3,lvHdr3w)
sList.genList()
gui,font,,arial
;gui,add,button,gaddScript section,Add script
;gui,add,button,greloadScript ys,Reload script
;gui,add,button,gremoveScript ys,Remove script
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
menu,settings,add,Disable file remove warning,deleteWarning,+radio
menu,settings,add,Start on User Login,logonRun,+radio
menu,settings,add,Set DLL: Std,setDll
menu,settings,add,Set DLL: Mini,setDll

menu,main,add,Actions,:actions
menu,main,add,Settings,:settings
menu,main,add,About,about
gui,menu,main

; menu: tray
if(!debug)
    menu,tray,nostandard
menu,tray,add,Open GUI,showMain
menu,tray,default,Open GUI
menu,tray,add,Exit,cleanup

; menu: LV context
menu,cmain,add,Reload,reloadScript
menu,cmain,add,Pause,pauseScript
menu,cmain,add,Suspend,suspendScript
menu,cmain,add,Open ListLines,listlinesScript
menu,cmain,add,Remove,removeScript