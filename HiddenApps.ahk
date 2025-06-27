; Hide window at cursor from Alt-Tab list and taskbar

#Requires AutoHotkey v2.0.19
#Warn
#SingleInstance force
SetWinDelay(-1)
DetectHiddenWindows(true)
CoordMode("Menu", "Screen")

#Include <Log>
#Include <Values>
#Include <Settings>
#Include <WindowsMenu>
#Include <HiddenWindows>
#Include <AltTabWindows>

SetDefaultValues()
ReadValues()

TraySetIcon(iconMain)
InitAutoStartup()

InitAutoStartup() {
    ; Creates a shortcut to the application in shell:startup
    global autoStartup

    base  := SubStr(A_ScriptName, 1, -4)
	mask  := A_Startup "\" base "*"
    link  := A_Startup "\" base ".lnk"

	if autoStartup {
		if !FileExist(link) {
            ; Clear every possible script instances from Startup dir
            try FileDelete(mask)
			FileCreateShortcut(A_ScriptFullPath, link, A_WorkingDir)
		}
	} else {
		try FileDelete(mask)
	}
}

; Win + Mouse Forward
#XButton2::HiddenWindowsMenu().HideWindow()    
; Alt + Tilde ~ (backtick `)
!sc029::HiddenWindowsMenu().ShowCenter()   
; Win + Tilde ~ (backtick `)
#sc029::AltTabWindowsMenu().ShowCenter()




