deleteWarning:
gui,submit,nohide
if(deleteWarningc)
    iniWrite,% hideDeleteWarning:=1,% sini,settings,hideDeleteWarning
else
    iniWrite,% hideDeleteWarning:=0,% sini,settings,hideDeleteWarning
return

logonRun:
gui,submit,nohide
if(logonRunc)
    regWrite,REG_SZ,% regStartupPath,ScriptUp,% a_scriptFullPath
else
    regDelete,% regStartupPath,ScriptUp
return
