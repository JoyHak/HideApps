class HiddenWindowsMenu extends WindowMenu {
    __New(header := "Hidden windows") {
        super.__New(header)
        this.RestoreMenu()
        
        .AddOptions([
            ["&Settings", ShowSettings,   "settings.ico"],
            ["&Exit",     (*) => ExitApp, "close.ico"]
        ])
        
        OnExit(this.ShowWindows)
    }
    
    RestoreMenu(*) {
        for id, _ in WindowMenu.windows
            this.InsertWindow(id, this.ShowWindow.Bind(this, id))
    }
    
    ShowWindows(*) {
        for id, _ in WindowMenu.windows
            try WinShow("ahk_id " id)
    }
    
    ShowWindow(id := 0, itemName := "Window", itemPos := 2, *) {    
        try {
            if !id
                id := WinGetID("A")
            
            WinShow("ahk_id " id)
    
            WindowMenu.windows.Delete(id)
            this.Delete(itemPos . "&")
        } catch TargetError as e {
            LogError(e, this.GetProcessName(id))
        }
    }
    
    HideWindow(id := 0, itemName := "Window", itemPos := 2, *) {    
        try {
            if !id
                id := WinGetID("A")
        
            if (WindowMenu.windows.Has(id))
                return

            WinHide("ahk_id " id)
            this.InsertWindow(id, this.ShowWindow.Bind(this, id))    
        } catch TargetError as e {
            LogError(e, this.GetProcessName(id))
        }
    }
}