#singleInstance force
#persistent
#noEnv
#include <threadMan>
menu,tray,tip,ScriptUp

; compiled installs
if(a_isCompiled){
    fileInstall,Lib\dlls\mini32.dll,Lib\dlls\mini32.dll
    fileInstall,Lib\dlls\mini64.dll,Lib\dlls\mini64.dll
    fileInstall,Lib\dlls\std32.dll,Lib\dlls\std32.dll
    fileInstall,Lib\dlls\std64.dll,Lib\dlls\std64.dll
    fileInstall,Lib\imgs\b1.png,Lib\imgs\b1.png
    fileInstall,Lib\imgs\b2.png,Lib\imgs\b2.png
    fileInstall,Lib\imgs\MXIII.png,Lib\imgs\MXIII.png
    fileInstall,Lib\workerH.ahk,Lib\workerH.ahk
}

; setup config
;sini:=(siniD:=a_appData . "\..\Local\ScriptUp") . "\config.ini"
setWorkingDir,% a_scriptDir
sini:=a_scriptDir . "\Lib\config.ini"
dlls:=a_scriptDir . "\Lib\dlls"
imgs:=a_scriptDir . "\Lib\imgs"
workerdll:=dlls . "\std" . (a_ptrSize*8) . ".dll"
workerfile:=a_scriptDir . "\Lib\workerH.ahk"
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
#include <guiMake>
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

#include <guiSubs>
#include <optionSubs>
#include <menuSubs>

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
