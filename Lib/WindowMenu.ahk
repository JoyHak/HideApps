class WindowMenu extends Menu {
    /*
        Creates a menu with the specified title and 
        calculates the coordinates to display Menu in the center. 
        Ñontains methods for adding windows and customizing their display.
        
        To display in the center, it calculates the offset of the coordinates of the upper-left corner of the menu 
        from the center of the screen based on the size of the elements (icon size, indentation, name length). 
        Each magic number is calculated for centering with high accuracy in all cases.
        
        @param header The gray title of the menu
    */
    
    static windows := Map()
    
    __New(header := "Windows") {
        global 
        Menu.Call()  
        
        ; Permanent window appearance parameters
        this.showIcons   := showIcons
        this.iconsDir    := iconsDir
        this.iconSize    := iconSize

        ; Calculate position offset based on the icon size and visibility
        this.iconOffset  := Max(iconSize, 16) * showIcons / 4  ; 0 if the icons are turned off. Min. is 16
        this.offsetX     := this.iconOffset                     ; Initial offset, increases if long windows are added.
        this.offsetY     := 0                                   ; Increases only if windows are added
        
        ; Set the initial position of the menu
        this.posY        := A_ScreenHeight / 2                             ; Screen center
        this.posX        := A_ScreenWidth  / 2 - (110 + this.iconOffset)   ; Screen center minus menu margins (including icons)
        
        ; Show menu again after callback
        this.callbackFn  := showMenuAgain ? this.__ShowAgain.bind(this) : (callback, *) => callback.call()
        
        ; Show windown process name
        this.getTitleFn  := showProcessName ? this.GetProcessName.bind(this) : this.GetShortTitle.bind(this, titleLength)
        
        this.AddHeader(header)
    }

    /*
        Adds a header to the menu and increases the offset accordingly.
        
        This method creates a header item in the menu and updates the offsets
        to account for the header's size.
        
        @param title   The title of the header to be added.
    */
    AddHeader(title) {
        this.Add(title, this.__NoOperation)
        this.Disable(title)
        this.__IncreaseOffset(title)
    }

    /*
        Adds options after windows or updates existing ones.
        
        The options must be defined as an array of arrays, where each inner
        array contains the option title, callback function, and icon name. This method
        also updates the offsets based on the titles of the added options.
        
        @param options   An array of options to be added to the menu
    */
    AddOptions(options) {
        this.Add()   ; separator
        this.AddHeader("Options")
        
        longTitle := ""
        for _, option in options {
            title := option[1]
            this.Add(title, option[2])
            this.EditIcon(title, this.iconsDir . "\" . option[3])
            this.__IncreaseOffset(title)
        }        
    }

    /*
        Inserts a new window into the menu at a specified position.
        
        This method allows for the insertion of a new menu item at a specific
        position, along with its associated icon and callback function. The
        offsets are updated accordingly.
        
        @param title     The title for the window in the menu
        @param callback  The callback function to be executed when the window is selected.
        @param icon      The icon associated with the window (optional).
        @param pos       The position at which to insert the window (optional).
    */
    InsertWindow(id, callback, icon := "", pos := 2) {
        title := this.getTitleFn.Call(id)
        icon  := WinGetProcessPath("ahk_id " id)
        
        this.Insert(pos . "&", title, this.callbackFn.Bind(callback))
        this.EditIcon(title, icon)
        
        WindowMenu.windows[id] := true
        this.__IncreaseOffset(title)            
    }

    /*
        Edits the icon for a specified menu item.
        
        If icons are enabled and a icon path is provided, this method sets
        the icon for the specified menu item. It also updates the vertical offset.
        
        @param title  The title of the menu item for which the icon is to be set.
        @param icon   The full path to the icon file (optional).
    */
    EditIcon(title, icon := "") {
        if !(this.showIcons && icon)
            return
    
        try {
            this.SetIcon(title, icon,, this.iconSize)
            this.offsetY += this.iconOffset
        } catch as e {
            LogError(e)
        }
    }
    
    ; Slice everything before extension: name.exe -> name
    GetProcessName(id) => SubStr(WinGetProcessName("ahk_id " id), 1, -4)
    
    ; Slice everything before maxLength: LongLongTitle -> Long...
    GetShortTitle(maxLength, id) {
        try {
            title := WinGetTitle("ahk_id " id)
            style := WinGetstyle("ahk_id " id)
    
            ; If active window has titlebar
            ; and its too long: slice it
            if ((style & 0xC00000)
            && (StrLen(title) > maxLength)) {
                title := SubStr(title, 1, maxLength) . "..."
            }
    
            return title
    
        } catch as e {
            LogError(e, id)
            return "Window"
        }
    }
    
    ; Displays the menu centered on the screen based on the calculated offsets.
    ShowCenter() {
        this.Show(this.posX - this.offsetX, this.posY - this.offsetY)
    }
    
    /*
        Increases the offset values based on the last option added to the menu.
        
        HORIZONTAL OFFSET: the length of the option name is squared to increase the offset when the option name is long.         
        Further division is used to prevent big offset for small length.
        
        The icon offset is added to the result. The larger the icon, the greater the offset. 
        To ensure that the result is not less than existing offset, Max() is used. 
        
        VERTICAL OFFSET: constant height of the item plus the necessary offset for large icons.
        @param lastOption   The title of the last option added to the menu.
    */
    __IncreaseOffset(lastOption) {
        this.offsetX := Max(this.offsetX, (StrLen(lastOption) ** 2 / 16) + this.iconOffset)
        this.offsetY += 10 + this.iconOffset / 2
    }
    
    ; Call the function and show the Menu
    __ShowAgain(callback, *) {
        callback.call()
        this.ShowCenter()
    }
    
    ; This method is used as a placeholder for menu headers
    __NoOperation(*) => 0
}