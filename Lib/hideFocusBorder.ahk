; https://autohotkey.com/boards/viewtopic.php?f=7&t=9919
hideFocusBorder(wParam,lParam:="",msg:="",handle:=""){ ; by 'just me'
    static affected:=[]
    static WM_UPDATEUISTATE:=0x0128
    static SET_HIDEFOCUS:=0x00010001 ; UIS_SET << 16 | UISF_HIDEFOCUS
    static init:=onMessage(WM_UPDATEUISTATE,func("hideFocusBorder"))
    
    if(msg=WM_UPDATEUISTATE){
        if(wParam=SET_HIDEFOCUS)
            affected[handle]:=true
        else if(affected[handle])
            dllCall("user32\PostMessage","ptr",handle,"uint",WM_UPDATEUISTATE,"ptr",SET_HIDEFOCUS,"ptr",0)
    }else if(dllCall("IsWindow","ptr",wParam,"uint"))
        dllCall("user32\PostMessage","ptr",wParam,"uint",WM_UPDATEUISTATE,"ptr",SET_HIDEFOCUS,"ptr",0)
}