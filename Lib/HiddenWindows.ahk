class HiddenWindowsMenu extends WindowsMenu {  
    static windows := Map()
    
    __New() {
        global showProcessName
        super.__New("Hidden " . (showProcessName ? "apps" : "windows"))      

        this.RestoreMenu()
        this.AddOptions([
            ["&Settings", ShowSettings,     "settings.ico"],
            ["&Exit",     (*) => ExitApp(), "close.ico"]
        ])
        
        OnExit(this.ShowWindows.bind(this))
    }
    
    RestoreMenu(*) {
        for id, _ in this.class.windows
            this.InsertWindow(id, this.ShowWindow.Bind(this, id))
    }
    
    ShowWindows(*) {
        for id, _ in this.class.windows
            try WinShow("ahk_id " id)
    }
    
    ShowWindow(id := 0, itemName := "Window", itemPos := 2, *) {    
        try {
            if !id
                id := WinGetID("A")
            
            WinShow("ahk_id " id)
    
            this.class.windows.Delete(id)
            this.Delete(itemPos . "&")
        } catch as e {
            LogError(e, this.GetProcessName(id))
        }
    }
    
    HideWindow(id := 0, itemName := "Window", itemPos := 2, *) {    
        try {
            if !id
                id := WinGetID("A")
        
            if (this.class.windows.Has(id))
                return

            WinHide("ahk_id " id)
            this.InsertWindow(id, this.ShowWindow.Bind(this, id))    
        } catch as e {
            LogError(e, this.GetProcessName(id))
        }
    }
}