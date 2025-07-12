---

## 📂 FolderTextMenu

A small AutoHotkey v2 script that lets you browse a folder (and its subfolders) of `.txt` files via a popup menu, then instantly paste the chosen file’s contents—temporarily swapping your clipboard so you don’t lose what was there.

---

### 🔧 Requirements

* [AutoHotkey v2.0+](https://www.autohotkey.com/) installed on Windows.

---

### 🚀 Installation

1. Clone or download this repository.
2. Place `FolderTextMenu.ahk` in the folder you want to browse.
3. Double-click `FolderTextMenu.ahk` to launch.

---

### ⚙️ Key Features & Hotkeys

* **Esc** (anywhere): Reloads the script so changes take effect immediately.
* **System Tray menu**

  * Standard AHK tray items
  * **Open Folder**: opens the script’s directory in Explorer
* **F1**: Display a recursive browsing menu of `.txt` files.

---

### 💡 How It Works

1. **SingleInstance & Reload**

   ```ahk
   #SingleInstance Force     ; Allow only one script instance, terminating any existing one
   ~*Esc::Reload             ; Reload the script when Esc is pressed
   ```

2. **Tray Setup**

   ```ahk
   Tray := A_TrayMenu                                     ; Get the default tray menu object
   Tray.Delete()                                          ; Remove existing tray menu items
   Tray.AddStandard()                                     ; Add standard menu items (Exit, Pause, etc.)
   Tray.Add("Open Folder", (*) => Run(A_ScriptDir))       ; Add "Open Folder" item that opens the script directory
   Tray.SetIcon("Open Folder", "shell32.dll", 5)          ; Set a folder icon for the "Open Folder" item
   ```

3. **ShowMenu()**

   ```ahk
   F1::ShowMenu                                          ; Bind F1 key to the ShowMenu function

   ShowMenu() {                                          ; Define the menu display function
       folderMenu := Menu()                              ; Create a new popup menu object
       BuildMenu(folderMenu, A_ScriptDir)                ; Populate it with submenus and files
       folderMenu.Show()                                 ; Display the menu at the current cursor position
   }
   ```

4. **BuildMenu(parentMenu, folderPath)**

   ```ahk
   BuildMenu(parentMenu, folderPath) {                   ; Recursively builds menu items for folders and files
       hasContent := false                                ; Flag to track if the menu has any items
       Loop Files, folderPath "\*", "D" {                ; Loop through each directory in folderPath
           subMenu := Menu()                             ; Create a submenu for this directory
           if BuildMenu(subMenu, A_LoopFileFullPath) {   ; Recursively build submenu items
               parentMenu.Add(A_LoopFileName, subMenu)   ; Add the submenu under the parent menu
               hasContent := true                        ; Mark that we added items
           }
       }
       Loop Files, folderPath "\*.txt" {                  ; Loop through each .txt file in folderPath
           parentMenu.Add(A_LoopFileName, CreateHandler(A_LoopFileFullPath)) ; Add file item with handler
           hasContent := true                            ; Mark that we added items
       }
       return hasContent                                  ; Return whether we added any menu items
   }
   ```

5. **CreateHandler(filePath)**

   ```ahk
   CreateHandler(filePath) {                             ; Wrap the file path in a closure for menu callbacks
       return (*) => PasteContent(filePath)               ; Returns a function that calls PasteContent with filePath
   }
   ```

6. **PasteContent(filePath)**

   ```ahk
   PasteContent(filePath) {                              ; Reads file and pastes its contents, restoring clipboard
       try {                                             ; Begin error handling block
           originalClip := A_Clipboard                  ; Save the current clipboard contents
           A_Clipboard := FileRead(filePath)            ; Read the file into the clipboard
           if ClipWait(2) {                             ; Wait up to 2 seconds for clipboard to update
               Send("^v")                               ; Send Ctrl+V to paste the clipboard contents
               SetTimer(() => A_Clipboard := originalClip, -500) ; After 500ms, restore the original clipboard
           }
       } catch as err {                                  ; If an error occurs during file read or paste
           MsgBox("Error: " err.Message)                ; Show an error message with details
       }
   }
   ```

---

### 🔧 Customization

* **File types**: to support other formats (e.g. `.ahk`, `.md`), change the `Loop Files, folderPath "\*.txt"` filter.
* **Hotkey**: change `F1::ShowMenu` to another key or combination.
* **Startup folder**: edit the path passed to `BuildMenu` if you want to point somewhere other than the script’s folder.

---

### 📄 License

This project is released under the MIT License. Feel free to adapt and extend!
