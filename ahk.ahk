#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

;*** MY CODE ***
;******************************************************************************
; Terminal Ctrl+Backspace match title
; RegEx or digits: 1 - title must start with the specified WinTitle, 2 - title can contain WinTitle anywhere inside it, 3 - title must exactly match WinTitle.
SetTitleMatchMode 2

; RUN AS ADMIN
;******************************************************************************
full_command_line := DllCall("GetCommandLine", "str")
if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\S)")) {
  try {
    if A_IsCompiled
      Run *RunAs "%A_ScriptFullPath%" /restart
    else
      Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
    }
  ExitApp
}
;******************************************************************************

; BRIGHTNESS
;******************************************************************************
ChangeBrightness(ByRef brightness, timeout = 1) {
  if (brightness > 0 && brightness < 100) {
    For property in ComObjGet("winmgmts:\\.\root\WMI").ExecQuery("SELECT * FROM WmiMonitorBrightnessMethods")
      property.WmiSetBrightness(timeout, brightness)
  } else if (brightness >= 100) {
    brightness := 100
  } else if (brightness <= 0) {
    brightness := 0
  }
}
GetCurrentBrightNess() {
  For property in ComObjGet("winmgmts:\\.\root\WMI").ExecQuery("SELECT * FROM WmiMonitorBrightness")
    currentBrightness := property.CurrentBrightness
  return currentBrightness
}
CurrentBrightness := GetCurrentBrightNess()
!F1::ChangeBrightness(CurrentBrightness -= 9) ;decrease
!F2::ChangeBrightness(CurrentBrightness += 9) ;increase
;******************************************************************************
; Volume
^F1::Volume_Down
^F2::Volume_Up

; JKL; + Ctrl, Shift, Alt, Win
;*** Remap arrow keys onto JKLI whenever holding down a certain modifier key
;******************************************************************************
MoveCursor(key) {
  control := GetKeyState("CONTROL","P")
  shift := GetKeyState("SHIFT","P")
  alt := GetKeyState("ALT","P")
  win := GetKeyState("LWIN","P")
  ctrlShift := control && shift
  ctrlAlt := control && alt
  altShift := alt && shift
  ctrlAltShift := control && alt && shift
  if ctrlAltShift {
    Send, ^!+%key%
  } else if altShift {
    Send, !+%key%
  } else if ctrlShift {
    Send, ^+%key%
  } else if ctrlAlt {
    Send, ^!%key%
  } else if control {
    Send, ^%key%
  } else if shift {
    Send, +%key%
  } else if alt {
    Send, !%key%
  } else if win {
    Send, #%key%
  } else {
    Send, %key%
  }
}
SC163 & j::MoveCursor("{LEFT}")
SC163 & k::MoveCursor("{DOWN}")
SC163 & l::MoveCursor("{UP}")
SC163 & `;::MoveCursor("{RIGHT}")
SC163 & m::MoveCursor("{HOME}")
SC163 & ,::MoveCursor("{PGDN}")
SC163 & .::MoveCursor("{PGUP}")
SC163 & /::MoveCursor("{END}")
SC163 & BS::MoveCursor("{DEL}")
;******************************************************************************

; Ctrl+Tab to Alt+Tab
LCtrl & Tab::AltTab
; Ctrl+Esc to Ctrl+Tab
LCtrl & Esc::Send {Ctrl Down}{Tab}{Ctrl Up}
; Context menu Shift+F10 / AppsKey
SC163 & Enter::AppsKey
; Reload ahk
SC163 & CapsLock::reload
; Close active window (Alt+F4)
+^w::Send {Alt down}{F4}{Alt up}
; Show Desktop Alt+D
!d::Send {LWin Down}{d}{LWin Up}
; Change language Alt+Space
!Space::Send {LWin Down}{Space}{LWin Up}
; Windows Search or PowerToys Run
^Space::Send {LWin Down}{s}{LWin Up}

; Maximize active window
SC163 & f::
WinGet MX, MinMax, A
  if MX
    WinRestore A
  else WinMaximize A
return


; SPACE KEY
;******************************************************************************
; Run Apps with Space key
; Goal: make reliable key combination to run apps faster without interruptions
; Task: Press "space+key" to open specific application
; Issue: While typing text, sometimes "space+key" is pressed accidentally and typing is being interrupted
; Ways to resolve:
; - use delay
; - use key combination blocking/suspend
; - send right sequence
; SOURCES:
; - https://www.autohotkey.com/boards/viewtopic.php?t=31113
; - https://www.autohotkey.com/boards/viewtopic.php?t=36437
; - KeyWait, Space, T0.1
; TODO: Send "space+key" without innterruption
; DOING: Send "space+key" only if "space" is down and "key" is up, no other keys should be able to be pressed in this combination otherwise they should interrupt combination
; RESULTS:
; if run with: "space+key up" (also require space:: send {space} to work) it causing small delays - what interrup typing.
; if run with: "#if GetKeyState("space", "P") key:: Send ..." delays are smaller, but still random interrupts occur, but "sapce + key up" must be in script to work properly.
; Current requirements to work with small interrupts:
; space::send {space}
; space + key up::send ...
; #if GetKeyState("space", "P") key::send ...


; IMPORTANT! Send "space" alone, need to work with other "space + key up" shortcuts
;Space::Send {Space}
; Change language Alt+Space
;!Space::Send {LWin Down}{Space}{LWin Up}
; Windows Search or PowerToys Run
;^Space::Send {LWin Down}{s}{LWin Up}
;^Space::Send {LAlt Down}{Space}{LAlt Up}
; Taskbar
; Space & 1::#1
; Space & 2::#2
; Space & 3::#3
; Space & 4::#4
; Space & 5::#5
; Space & 6::#6
; Space & q up::Send {LWin Down}{6}{LWin Up} ; Quick Notes
; Space & a up::Send {LWin Down}{0}{LWin Up} ; Terminal
; Space & s up::Send {LWin Down}{7}{LWin Up} ; Browser Search
; Space & d up::Send {LWin Down}{8}{LWin Up} ; CoDe Editor
; Space & f up::Send {LWin Down}{9}{LWin Up} ; File Explorer
; Space & ` up::Send {LWin Down}{0}{LWin Up} ; Terminal


; Key modification ideas:

; $Space::
; Send {Space down}
; Sleep 250
; Send {Space up}
; Return

; Space & `;::
; GetKeyState, state, CapsLock, T ; D if CapsLock is ON or U otherwise.
; If state := GetKeyState("Capslock", "T") ; True if CapsLock is ON, false otherwise.
; {
; Send A
; }
; Else
; {
; Send a
; }
; Return
; Toggle := False
; $Space::
;   KeyWait, Space, T0.15 ; Adjust this value to control the delay before switching modes
;   If ErrorLevel
;     Toggle := True
;   Else
;     Send {Space}
;   Return
; #If Toggle
; Space UP::Toggle := False
; q::p
; w::o
; #if ;if at the end ??????????

; LShift up::
;     if (A_PriorHotkey == "*~LShift")
;     {
;         Send, {space}
;     }
;     Return

;'::
; if (A_PriorHotKey = "!^h" and A_TimeSincePriorHotkey < 600 and A_TimeSincePriorHotkey > -1)
; {
; Send, '
; }
; Return

; ~!^h::return
; #if (A_PriorHotKey = "~!^h" and A_TimeSincePriorHotkey < 600)
; '::Sendraw, '

; Send space if it's pressed less then 0.1s, otherwise send text
; *Space::
;   KeyWait, Space, T0.1
;   if (ErrorLevel == 0) {
;     Send {Blind}{Space}
;   } Else {
;     Send {Blind}{Text} test_text_here
;   }
; return

; a::
; if (A_PriorKey = "Space") {
; Send, a
; }
; MsgBox, %A_ThisHotkey%
; Return


; Google Translate
;Space & CapsLock up::
KeyWait, CapsLock
SetTitleMatchMode 3
if WinActive("Google Translate") {
  WinMinimize A
} else if WinExist("Google Translate") {
  WinActivate, Google Translate
} else {
  Run, "C:\Users\user\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Chrome Apps\Google Translate.lnk"
  WinWait, Google Translate
  WinActivate, Google Translate
}
return
; Calculator
SC163 & n up::
SetTitleMatchMode 3
if WinActive("Calculator") {
  WinMinimize A
} else if WinExist("Calculator") {
  WinActivate, Calculator
} else {
  Run, "C:\Windows\System32\calc.exe"
  WinWait, Calculator
  WinActivate, Calculator
}
return
; Snip & Sketch
+!s::
  Run, ms-screensketch:
  WinWait, ahk_exe ApplicationFrameHost.exe
  WinActivate, ahk_exe ApplicationFrameHost.exe
  if WinActive("ahk_exe ApplicationFrameHost.exe") {
    Send {Ctrl Down}{n}{Ctrl Up}
  } else {
    return
  }
return

; Alias backward/forward
SC163 & h::Send {Alt Down}{Left}{Alt Up}
SC163 & '::Send {Alt Down}{Right}{Alt Up}
; VSCode console.log()
SC163 & i::Send {Ctrl Down}{Shift Down}{Alt Down}{i}{Alt Up}{Shift Up}{Ctrl Up}
SC163 & o::Send {Ctrl Down}{Shift Down}{Alt Down}{o}{Alt Up}{Shift Up}{Ctrl Up}

; Fold/Unfold, Send different keys with single key RemNote, Obsidian, VSCode
variable1 = 0 ; Set variable
;SC163 & Space::
;Ctrl & s::
if (variable1 == 1){
; Fold/Collapse
if WinActive("ahk_exe RemNote.exe") {
  ; RemNote collapse descendants of children
  if GetKeyState("Shift"){
    Send {Ctrl Down}{Shift Down}{p}{Shift Up}{Ctrl Up}
    Sleep, 200
    Send coll
    Sleep, 600
    Send {Enter}
    return
  }
}
Send {Ctrl Down}{Shift Down}{[}{Shift Up}{Ctrl Up}
variable1 = 2
return
} else if (variable1 == 2){
  ; Special for Obsidian "toggle fold"
  if WinActive("ahk_exe Obsidian.exe") {
    Send {Ctrl Down}{Shift Down}{[}{Shift Up}{Ctrl Up}
  }
  ; Unfold/Expand
  Send {Ctrl Down}{Shift Down}{]}{Shift Up}{Ctrl Up}
  variable1 = 1
  return
} else {
  ; Initiate variable
  variable1 = 1
  return
}
return
; Use shift+space
; shiftSpaceSuper(key) {
;   shift := GetKeyState("SHIFT","P")
;   if shift {
;     Send {Ctrl Down}{Shift Down}{up}{Shift Up}{Ctrl Up}
;   } else {
;     Send {Ctrl Down}{Shift Down}{down}{Shift Up}{Ctrl Up}
;     return
;   }
; }
; SC163 & Space::shiftSpaceSuper("{Space}")
; return

;if "ctrl+shift+space" send File Explorer, if "ctrl+space" send Windows Search
; shiftSpace(key) {
;   shift := GetKeyState("SHIFT","P")
;   if shift {
;     ; if ctrl+shift+space open new File Explorer or toggle existing
;     if WinActive("ahk_class CabinetWClass") {
;       WinMinimize A
;     } else if WinExist("ahk_class CabinetWClass") {
;       WinActivate, ahk_class CabinetWClass
;     } else {
;       Run, explorer.exe
;       WinWait, ahk_class CabinetWClass
;       ;WinMove, ahk_class CabinetWClass,,-8,0,976,1028
;       WinActivate, ahk_class CabinetWClass
;     }
;     return
;     ; +!e::
;     ;   Run, explorer.exe
;     ;   WinWait, ahk_class CabinetWClass
;     ;   WinMove, ahk_class CabinetWClass,,952,0,976,1038
;     ;   WinActivate, ahk_class CabinetWClass
;     ; return
;   } else {
;     ; if ctrl+space open Windows Search
;     Send {LWin Down}{s}{LWin Up}
;     return
;   }
; }
; LCtrl & Space::shiftSpace("{Space}")
;return
;******************************************************************************


; #if GetKeyState("space", "P")
; 1::#1
; 2::#2
; 3::#3
; 4::#4
; 5::#5
; 6::#6
; q::Send {LWin Down}{6}{LWin Up} ; Quick Notes
; a::Send {LWin Down}{0}{LWin Up} ; Terminal
; s::Send {LWin Down}{7}{LWin Up} ; Browser Search
; d::Send {LWin Down}{8}{LWin Up} ; CoDe Editor
; e::Send {LWin Down}{9}{LWin Up} ; File Explorer
; f::Send {LWin Down}{s}{LWin Up} ; File Explorer
; ;`::Send {LWin Down}{0}{LWin Up} ; Terminal
; return


; #if WinActive("ahk_exe WindowsTerminal.exe")
; ^a::Send {End}{Shift Down}{Home}{Shift Up}
; return

; ; Sublime open recent files
; #if WinActive("ahk_exe sublime_text.exe")
; ^r::Send {Alt Down}{f}{Alt Up}{r}
; return

; ; Microsoft Edge or Google Chrome: Search Tab
; #if (WinActive("ahk_exe msedge.exe") or WinActive("ahk_exe chrome.exe"))
; +^f::Send {Ctrl Down}{Shift Down}{a}{Shift Up}{Ctrl Up}
; SC163 & i::Send {f7}
; return

; ; Fman switch panes
; #if WinActive("ahk_exe fman.exe")
; LCtrl & Esc::Send {Tab}
; return

; ; RemNote shortcuts (browser like)
; variable2 = 0 ; Set variable
; #if WinActive("ahk_exe RemNote.exe")
; ; Switch panes with ctrl+esc
; LCtrl & Esc::
; if (variable2 == 1){
;   Send {Ctrl Down}{Shift Down}{t}{Shift Up}{Ctrl Up}
;   variable2 = 2
; } else if (variable2 == 2){
;   Send {Alt Down}{Shift Down}{t}{Shift Up}{Alt Up}
;   variable2 = 1
; } else {
;   variable2 = 1
; }
; return
; ; Navigate to sibling above/below
; ; modKey1(key) {
; ;   control := GetKeyState("CONTROL","P")
; ; if control {
; ;   Send {Ctrl Down}{l}{Ctrl Up}
; ; } else {
; ;   Send %key%
; ; }}
; ; SC163 & l::modKey1("{Up}")
; ; modKey2(key) {
; ;   control := GetKeyState("CONTROL","P")
; ; if control {
; ;   Send {Ctrl Down}{k}{Ctrl Up}
; ; } else {
; ;   Send %key%
; ; }}
; ; SC163 & k::modKey2("{Down}")
; ;Zoom into rem
; ^Enter::Send {Ctrl Down}{`;}{Ctrl Up}
; +^Enter::Send {Ctrl Down}{Shift Down}{:}{Shift Up}{Ctrl Up}
; ; ;Add child without splitting text
; ; ^Enter::Send {Alt Down}{Enter}{Alt Up}
; ; ;Zoom out of rem
; ; LAlt & BackSpace::Send {Ctrl Down}{j}{Ctrl Up}
; return


; ; Info ***********************************************************************
; ; This symbol "`" is used for escaping in AHK, for example `n is a new line character. You can escape it with itself (``) to display the symbol.
; ; Add simple mappings like "SC163 & n::Send {..}" above "#if WinActive()", because it breaks code.
; ; GetKeyState, state, space ; Check key state "D" = down, "U" = up, "P" = physical state, "T" = toggle



;
; AutoHotkey Version: 1.x
; Language:       English
; Platform:       Win9x/NT
; Author:         cy18 <thecy18@gmail.com>
;
; An improved script to use space as modifier
; In normal cases, if space is pressed for more than 0.1 second, it becomes a modifier, this time could be modified in the script
; If no other keys are pressed during space is pressed, a space is output when space is released
; Severial tunes are made so that the script works well when typing in fast speed
; Note that repeating space no longer works

#NoEnv  ; Recommended for performesfsfsdfspts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

AnyKeyPressedOtherThanSpace(mode = "P") {
  ;keys = 1234567890-=qwertyuiop[]\asdfghjkl;'zxcvbnm,./
  keys = qwerasdf
  Loop, Parse, keys
  {
    isDown :=  GetKeyState(A_LoopField, mode)
    if (isDown)
      return True
  }
  return False
}

Space Up::
  space_up := true
  Send, {F18}
  return
Space::
  if AnyKeyPressedOtherThanSpace() {
    SendInput, {Blind}{Space}
    Return
  }
  space_up := False
  inputed := False
  input, UserInput, L1 T0.05, {F18}
  if (space_up) {
    Send, {Blind}{Space}
    return
  } else if (StrLen(UserInput) == 1) {
    Send, {Space}%UserInput%
    return
  }
  while true {
    input, UserInput, L1, {F18}
    if (space_up) {
      if (!inputed) {
        Send, {Blind}{Space}
      }
      break
    } else if (StrLen(UserInput) == 1) {
      inputed := True
      StringLower, UserInput, UserInput
      if      (UserInput == "a")
        Send, {Blind}{LWin Down}{7}{LWin Up}
      else if (UserInput == "s")
        Send, {Blind}{LWin Down}{8}{LWin Up}
      else if (UserInput == "d")
        Send, {Blind}{LWin Down}{9}{LWin Up}
      else if (UserInput == "e")
        Send, {Blind}{LWin Down}{0}{LWin Up}
      else if (UserInput == "f")
        Send, {Blind}{LCtrl Down}{f12}{LCtrl Up}
      else
        Send, {Blind}%UserInput%
    }
  }
return