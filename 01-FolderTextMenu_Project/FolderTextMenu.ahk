#SingleInstance Force
#Requires AutoHotkey v2.0+
~*Esc::Reload
Tray := A_TrayMenu, Tray.Delete(), Tray.AddStandard(), Tray.Add()
Tray.Add("Open Folder", (*) => Run(A_ScriptDir)), Tray.SetIcon("Open Folder", "shell32.dll", 5)

F1::ShowMenu

ShowMenu() {
    folderMenu := Menu()
    BuildMenu(folderMenu, A_ScriptDir)
    folderMenu.Show()
}

BuildMenu(parentMenu, folderPath) {
    hasContent := false
    
    Loop Files, folderPath "\*", "D" {
        subMenu := Menu()
        if BuildMenu(subMenu, A_LoopFileFullPath) {
            parentMenu.Add(A_LoopFileName, subMenu)
            hasContent := true
        }
    }
    
    Loop Files, folderPath "\*.txt" {
        ; Create proper closure by forcing value capture
        parentMenu.Add(A_LoopFileName, CreateHandler(A_LoopFileFullPath))
        hasContent := true
    }
    
    return hasContent
}

CreateHandler(filePath) {
    return (*) => PasteContent(filePath)
}

PasteContent(filePath) {
    try {
        originalClip := A_Clipboard
        A_Clipboard := FileRead(filePath)
        if ClipWait(2) {
            Send("^v")
            SetTimer(() => A_Clipboard := originalClip, -500)
        }
    } catch as err {
        MsgBox("Error: " err.Message)
    }
}












