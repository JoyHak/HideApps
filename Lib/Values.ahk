/*
    Contains all global variables necessary for the application,
    functions that read/write INI configuration,
    functions that check (validate) values for compliance
    with the requirements of different libraries.

    "ini" param must be a path to a write-accessible file (with any extension)
 */

lastUiTab  :=  1
configName :=  "HiddenApps"
configDir  :=  A_ScriptDir
ini        :=  configDir "\" configName ".ini"

SetDefaultValues() {
    /*
        Sets defaults without overwriting existing INI.

        These values are used if:
        - INI settings are invalid
        - INI doesn't exist (yet)
        - the values must be reset
    */
    
    global
    titleLength      :=  50
    iconSize         :=  20
                     
    autoStartup      :=  true
    showIcons        :=  true
    showMenuAgain    :=  false
    showProcessName  :=  false
    iconsDir         :=  A_ScriptDir "\Icons"
    iconMain         :=  iconsDir "\hidden.ico" 
}

WriteValues(ui) {
    ; Writes all values from the UI to the INI
    global ini
    
    values := ""
    for variable, value in ui.Submit().OwnProps() {
        values .= variable "=" value "`n"
    }

    IniWrite(values, ini, "Global")
}

ReadValues() {
    ; Reads values from INI
    global

    if !FileExist(ini)
        return

    local data, values    
    Loop parse, IniRead(ini, "Global"), "`n" {
        data := StrSplit(A_LoopField, "=")
        %data[1]% := data[2]
    }
}

SaveSettings(ui, *) {
    ; Write current UI values, re-create everything
    global iconMain
    
    WriteValues(ui)
    ReadValues()
    TraySetIcon(iconMain)
    
    InitMenus()
    InitAutoStartup()
    HiddenWinMenu.ShowCenter()
}

ResetSettings(ui, *) {
    ; Roll back values and show them in settings
    global ini, iconMain
    FileDelete(ini)
    
    SetDefaultValues()
    
    TraySetIcon(iconMain)
    InitMenus()
    InitAutoStartup()
    
    ui.Destroy()
    ShowSettings()
}