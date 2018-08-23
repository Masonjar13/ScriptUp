; main Window
if(!a_isCompiled)
    menu,tray,icon,% imgs . "\ICONMX.ico",,,1
gui,+hwndghwnd
gui,color,c0c0c0
gui,add,picture,x400 y200 w400 h-1,% imgs . "\MXIII.png"
gui,add,tab3,xm ym,List|Options|About

; list tab
gui,tab,List
gui,color,,c0c0c0
lvw:=300
lvHdr3w:=60
lvHdr2w:=100
lvHdr1w:=lvw-lvHdr2w-lvHdr3w
gui,add,listview,% "+hwndlvhwnd r20 w" . lvw . " -E0x200 glvCallback altsubmit",Script Name|State|DLL
hideFocusBorder(ghwnd)
gui,color,,default
gosub,genList
lv_modifyCol(1,lvHdr1w)
lv_modifyCol(2,lvHdr2w)
lv_modifyCol(3,lvHdr3w)

; options tab
gui,tab,Options
gui,color,c0c0c0
gui,add,checkbox,% "-wrap gdeleteWarning vdeleteWarningc checked" . hideDeleteWarning,Disable file remove warning
gui,add,checkbox,% "-wrap glogonRun vlogonRunc checked" . (loginRun?1:0),Start on User Login
gui,add,picture,gsetDll vStd,% imgs . "\b1.png"
gui,add,picture,gsetDll vMini,% imgs . "\b2.png"

; about tab
gui,tab,About
gui,font,s12,arial
gui,add,text,section,Written by
gui,font,cBlue underline
gui,margin,5,9
gui,add,text,ys gaboutLink,Masonjar13
gui,font,norm s12
gui,margin,1
gui,add,text,ys,% ".   "
gui,margin,15,9
gui,font,s9 cBlack

; gui: addScript
gui,% "addScript:+owner" . ghwnd . " +hwndghwnd2"
gui,addScript:font,s10,arial
gui,addScript:add,edit,w240 r2 vpathText section
gui,addScript:add,ddl,w50 vdllType ys,Std||Mini
gui,addScript:add,button,gaddScriptFinal xm,Add

; gui: execCode
gui,% "execCode:+owner" . ghwnd . " +hwndghwnd4"
gui,execCode:font,,courier new
gui,execCode:add,edit,vexecScriptCode w500 r10
gui,execCode:font,s12,arial
gui,execCode:add,button,gexecScriptFinal w500,Execute Code

; menu: tray
menu,tray,nostandard
menu,tray,add,Open GUI,showMain
menu,tray,default,Open GUI
menu,tray,add,Exit,cleanup


; menu: LV context
menu,cmain,add,Reload,reloadScript
menu,cmain,add,Pause,pauseScript
menu,cmain,add,Suspend,suspendScript
menu,cmain,add,Open ListLines,listlinesScript
menu,cmain,add,Edit,editScript
menu,cmain,add,Remove,removeScript
menu,cmain,add,Execute Code,execScript
