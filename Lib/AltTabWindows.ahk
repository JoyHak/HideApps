GetAltTabWindows() { 
    ; https://www.autohotkey.com/boards/viewtopic.php?f=83&t=99157&p=440330&hilit=alt+tab#p440330
    static WS_EX_APPWINDOW  :=  0x40000   ; has a taskbar button
    static WS_EX_TOOLWINDOW :=  0x80      ; does not appear on the Alt-Tab list
    static GW_OWNER         :=  4         ; identifies as the owner window
    static GA_ROOTOWNER     :=  3         ; owned root window
    
    ; Make IsWindowVisible and DWMWA_CLOAKED calls unnecessary
    DetectHiddenWindows(false)     
    
    AltTabList := []
    for hwnd in WinGetList() {
        ; Find the top-most owner of the child window.
        owner := DllCall("GetAncestor", "ptr", hwnd, "uint", GA_ROOTOWNER, "ptr") 
        ; If owner is null
        owner := owner || hwnd  
        
        ; Make sure that the active window is also the owner
        if (hwnd == DllCall("GetLastActivePopup", "ptr", owner)) {        
            ; Get window extended style.
            exStyle := WinGetExStyle(hwnd)
        
            ; Must appear on the Alt+Tab list, have a taskbar button, and not be a Windows 10 background app
            if (!(exStyle & WS_EX_TOOLWINDOW) || (exStylees & WS_EX_APPWINDOW))
                AltTabList.push(hwnd)
        }
    }

    DetectHiddenWindows(true)
    return AltTabList
}

; Register Win + Tilde to show Alt-Tab menu in the center of the screen
altTabMenu := Menu()
$!sc029::{
    for id in GetAltTabWindows() {
        title := showProcessName ? GetProcessName(id) : WinGetTitle("ahk_id " id)
    }


    altTabMenu.Add()
    
    altTabMenu.Add(autoStartupTitle, AutoStartupToggle)
    altTabMenu.Add(exitTitle, RestoreWindows)
    
    if showIcons {
        altTabMenu.SetIcon(autoStartupTitle, iconsDir "\enable.ico",, iconSize)
        altTabMenu.SetIcon(exitTitle, iconsDir "\close.ico",, iconSize)
    }

    static x := A_ScreenWidth  / 2 
    static y := A_ScreenHeight / 2 
    altTabMenu.Show(x, y)
}


