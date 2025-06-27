class WindowsMenu extends Menu {
    /*
        Creates a menu with the specified title and 
        calculates the coordinates to display Menu in the center. 
        Ñontains methods for adding windows and customizing their display.
        
        To display in the center, it calculates the offset of the coordinates of the upper-left corner of the menu 
        from the center of the screen based on the size of the elements (icon size, indentation, name length). 
        Each magic number is calculated for centering with high accuracy in all cases.
    */
    
    static windows := Map()
    
    __New(header := "Windows") {
        global 
        Menu()  
        
        ; Permanent window appearance parameters
        this.showIcons   := showIcons
        this.iconsDir    := iconsDir
        this.iconSize    := iconSize
        this.showAgain   := showMenuAgain
        this.showProcess := showProcessName
        this.titleLength := titleLength
        this.class       := %this.__Class%

        ; Calculate position offset based on the icon size and visibility
        this.iconOffset  := Max(iconSize, 16) * showIcons / 4   ; 0 if the icons are turned off. Min. is 16
        this.offsetX     := this.iconOffset                     ; Initial offset, increases if long windows are added.
        this.offsetY     := 0                                   ; Increases only if windows are added
        
        ; Set the initial position of the menu
        this.posY        := A_ScreenHeight / 2                             ; Screen center
        this.posX        := A_ScreenWidth  / 2 - (110 + this.iconOffset)   ; Screen center minus menu margins (including icons)
        
        this.AddHeader(header)
    }

    ; Adds a header item
    AddHeader(title) {
        this.Add(title, this.__NoOperation)
        this.Disable(title)
        this.__IncreaseOffset(title)
    }

    /*
        Adds options after windows or updates existing ones.
        
        The options must be defined as an array of arrays, where each inner
        array contains the option title, callback function, and icon name.
    */
    AddOptions(options) {
        this.Add()   ; separator
        this.AddHeader("Options")
        
        for _, option in options {
            title := option[1]
            this.Add(title, option[2])
            this.EditIcon(title, this.iconsDir . "\" . option[3])
            this.__IncreaseOffset(title)
        }        
    }

    ; Inserts a new window with its associated icon and callback at a specified position.
    InsertWindow(id, callback, icon := "", pos := 2) {
        icon  := WinGetProcessPath("ahk_id " id)
        title := this.showProcess 
               ? this.GetProcessName(id) 
               : this.GetShortTitle(id, this.titleLength) 
                       
        this.Insert(pos . "&", title, this.__ShowAgain.bind(this, callback))
        this.EditIcon(title, icon)
        
        this.class.windows[id] := true
        this.__IncreaseOffset(title)            
    }

    /*
        Edits the icon for a specified menu item.        
        If icons are enabled and a icon path is provided, sets
        the icon for the specified menu item.
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
    GetShortTitle(id, maxLength) {
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
            name := this.GetProcessName(id)
            LogError(e, name)
            return name
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
        
        VERTICAL OFFSET: constant height of the item plus the necessary offset for large icons.u.
    */
    __IncreaseOffset(lastOption) {
        this.offsetX := Max(this.offsetX, (StrLen(lastOption) ** 2 / 16) + this.iconOffset)
        this.offsetY += 10 + this.iconOffset / 2
    }
    
    ; Call the function and show the Menu
    __ShowAgain(callback, *) {
        callback.call()
        
        if this.showAgain
            this.ShowCenter()
    }
    
    ; Placeholder for special items
    __NoOperation(*) => 0
}