class AltTabWindowsMenu extends WindowsMenu {
    ;static windows := Map() 
     __New() {
        global showProcessName
        super.__New("Recent " . (showProcessName ? "apps" : "windows"))
        
        this.AddOptions([
            ["&Settings", ShowSettings,     "settings.ico"],
            ["&Exit",     (*) => ExitApp(), "close.ico"]
        ])

        this.AddWindows()
    }

    AddWindows() { 
        ; https://www.autohotkey.com/boards/viewtopic.php?f=83&t=99157&p=440330&hilit=alt+tab#p440330
        static WS_EX_APPWINDOW  :=  0x40000   ; has a taskbar button
        static WS_EX_TOOLWINDOW :=  0x80      ; does not appear on the Alt-Tab list
        static GW_OWNER         :=  4         ; identifies as the owner window
        static GA_ROOTOWNER     :=  3         ; owned root window
        
        ; Make IsWindowVisible and DWMWA_CLOAKED calls unnecessary
        DetectHiddenWindows(false)     
        
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
                if (!HiddenWindowsMenu.windows.Has(hwnd) 
                && (!(exStyle & WS_EX_TOOLWINDOW) 
                  || (exStyle & WS_EX_APPWINDOW))) {
                    this.InsertWindow(hwnd, WinActivate.bind("ahk_id " hwnd)) 
                }
            }
        }
    
        DetectHiddenWindows(true)
    }
}


