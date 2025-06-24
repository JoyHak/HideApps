/*
    UI updates global variables after user actions
    and displays their values as checkboxes, options, etc.

    All values are saved to the INI only after clicking OK
*/

ShowSettings(*) {
    global
    ReadValues()

    ; Options that affects subsequent controls
    ui := Gui()
    ui.Opt("-E0x200 -SysMenu +AlwaysOnTop")  ; hide window border and header
    ui.SetFont("q5 s9", "Tahoma")           ; clean quality

    ; Edit fields: fixed width, one row, max 6 symbols, no multi-line word wrap and vertical scrollbar
    local edit := "w128 r1 -Wrap -vscroll"

    ; Split settings to the tabs
    tab := ui.Add("Tab3", "-Wrap AltSubmit vLastUiTab Choose" . lastUiTab, ["Menu", "App"])

    /*
        To align "Edit" fields to the right after the "Text" fields,
        we memorize the YS position of the 1st "Text" fields using the "Section" keyword.
        Then when all the controls on the left are added one after another,
        we add "Edits" on the right starting from the memorized YS position.
        The X position is chosen automatically depending on the length of the widest "Text" field.
    */

    ;       type        options                        variable content     text
    tab.UseTab(1) ;───────────────────────────────────────────────────────────────────────────────────────────────────────

    ui.Add("CheckBox",  "vShowIcons checked"         . showIcons,           "Show i&cons in the Menus")
    ui.Add("CheckBox",  "vShowMenuAgain checked"     . showMenuAgain,       "Show Menu again after selection")
    ui.Add("CheckBox",  "vShowProcessName checked"   . showProcessName,     "Show the process &name, not the title")

    ui.Add("Text",      "y+20 Section",                                     "Window titles &length")
    ui.Add("Text",      "y+13",                                             "I&cons size")

    ui.Add("Edit",      "ys-4 Limit4 " . edit)
    ui.Add("UpDown",    "Range1-9999 vTitleLength",                         titleLength)
    ui.Add("Edit",      "y+4 Limit4 "  . edit)
    ui.Add("UpDown",    "Range1-9999 vIconSize",                            iconSize)

    tab.UseTab(2) ;───────────────────────────────────────────────────────────────────────────────────────────────────────

    ui.Add("CheckBox",  "vAutoStartup checked"       . autoStartup,         "Enable &Auto Startup")
    ui.Add("Text",      "y+13 Section",                                     "Icon in the &tray")
    ui.Add("Text",      "y+13",                                             "Where to get i&cons")
    
    ui.Add("Edit",      "ys-4 vIconMain "            . edit,                iconMain)
    ui.Add("Edit",      "y+4  vIconsDir "            . edit,                iconsDir)

    tab.UseTab()

    ui.Add("Button", "w74 xm+20 Default", "&OK").OnEvent("Click", SaveSettings.bind(ui))
    ui.Add("Button", "wp x+20 yp", "&Cancel").OnEvent("Click", (*) => ui.Destroy())
    ui.Add("Button", "wp x+20 yp", "&Reset").OnEvent("Click", ResetSettings.bind(ui))
    ui.OnEvent("Escape", (*) => ui.Destroy())

    ui.Show("AutoSize")
}