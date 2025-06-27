;@Ahk2Exe-Base C:\Program Files\AutoHotkey\v2\AutoHotkey32.exe, %A_ScriptDir%\Releases\%A_ScriptName~\.ahk%-x32.exe 
;@Ahk2Exe-Base C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe, %A_ScriptDir%\Releases\%A_ScriptName~\.ahk%-x64.exe 

;@Ahk2Exe-SetVersion %A_ScriptName~[^\d\.]+%
;@Ahk2Exe-SetMainIcon Icons\hidden.ico
;@Ahk2Exe-SetDescription https://github.com/JoyHak/Flow-Launcher-windows-key
;@Ahk2Exe-SetCopyright Rafaello
;@Ahk2Exe-SetLegalTrademarks GPL-3.0 license
;@Ahk2Exe-SetCompanyName ToYu studio

;@Ahk2Exe-Let U_name = %A_ScriptName~\.ahk%
;@Ahk2Exe-PostExec "C:\Program Files\7-Zip\7zG.exe" a "%A_ScriptDir%\Releases\%U_name%".zip -tzip -sae -- "%A_ScriptDir%\%U_name%.ahk" "%A_ScriptDir%\Lib" "%A_ScriptDir%\Icons",, A_ScriptDir

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




