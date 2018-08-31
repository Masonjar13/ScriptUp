#singleInstance force
#persistent
#noEnv
setWorkingDir,% a_scriptDir
#include %a_scriptDir%\data\threadMan.ahk
menu,tray,tip,ScriptUp

; compiled installs
if(a_isCompiled){
    fileCreateDir,data\dlls
    fileCreateDir,data\imgs
    fileInstall,data\dlls\mini32.dll,data\dlls\mini32.dll
    fileInstall,data\dlls\mini64.dll,data\dlls\mini64.dll
    fileInstall,data\dlls\std32.dll,data\dlls\std32.dll
    fileInstall,data\dlls\std64.dll,data\dlls\std64.dll
    fileInstall,data\imgs\b1.png,data\imgs\b1.png
    fileInstall,data\imgs\b2.png,data\imgs\b2.png
    fileInstall,data\imgs\MXIII.png,data\imgs\MXIII.png
    fileInstall,data\workerH.ahk,data\workerH.ahk
}

; setup config
;sini:=(siniD:=a_appData . "\..\Local\ScriptUp") . "\config.ini"
sini:=a_scriptDir . "\data\config.ini"
dlls:=a_scriptDir . "\data\dlls"
imgs:=a_scriptDir . "\data\imgs"
workerdll:=dlls . "\std" . (a_ptrSize*8) . ".dll"
workerfile:=a_scriptDir . "\data\workerH.ahk"
fileLastDir:=a_scriptDir
if(!fileExist(sini))
    firstRun:=1

; load settings
iniRead,hideDeleteWarning,% sini,settings,hideDeleteWarning,0
regRead,loginRun,% regStartupPath:="HKCU\Software\Microsoft\Windows\CurrentVersion\Run",ScriptUp
if(!errorLevel) ; auto-correct if the script has been moved
    if(loginRun!=a_scriptFullPath)
        regWrite,REG_SZ,% regStartupPath,ScriptUp,% a_scriptFullPath

; start worker
#include %a_scriptDir%\data\guiMake.ahk
worker:=new threadMan(workerdll)
worker.newFromFile(workerfile)
onExit,cleanup

; set DLLs/open gui automatically for first run
if(firstRun){
    nDllType:="Std",nDllPath:="dlls\std" . (a_ptrSize*8) . ".dll"
    gosub setDllFinal
    nDllType:="Mini",nDllPath:="dlls\mini" . (a_ptrSize*8) . ".dll"
    gosub setDllFinal
    gosub showMain
}
setTimer,checkStates,1000
return

#include %a_scriptDir%\data\guiSubs.ahk
#include %a_scriptDir%\data\optionSubs.ahk
#include %a_scriptDir%\data\menuSubs.ahk
#include %a_scriptDir%\data\functions.ahk

checkStates:
stateList:=worker.varGet("stateList")
loop,parse,stateList,`,
{
    lv_getText(pstate,a_index,2)
    if(pstate!=a_loopField)
        lv_modify(a_index,,,a_loopField)
}
return

cleanUp:
worker.quit(30000)
exitApp
