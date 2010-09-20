/*
 * =============================================================================================== *
 * Author           : RaptorX	<graptorx@gmail.com>
 * Script Name      : Hotshow
 * Script Version   : 1.0
 * Homepage         : 
 *
 * Creation Date    : September 22, 2010
 * Modification Date: 
 *
 * Description      :
 * ------------------
 *
 * -----------------------------------------------------------------------------------------------
 * License          :           Copyright ©2010 RaptorX <GPLv3>
 *
 *          This program is free software: you can redistribute it and/or modify
 *          it under the terms of the GNU General Public License as published by
 *          the Free Software Foundation, either version 3 of  the  License,  or
 *          (at your option) any later version.
 *
 *          This program is distributed in the hope that it will be useful,
 *          but WITHOUT ANY WARRANTY; without even the implied warranty  of
 *          MERCHANTABILITY or FITNESS FOR A PARTICULAR  PURPOSE.  See  the
 *          GNU General Public License for more details.
 *
 *          You should have received a copy of the GNU General Public License
 *          along with this program.  If not, see <http://www.gnu.org/licenses/gpl-3.0.txt>
 * -----------------------------------------------------------------------------------------------
 *
 * [GUI Number Index]
 *
 * GUI 01 - Main [Background]
 * GUI 02 - HotkeyText
 *
 * =============================================================================================== *
 */

;+--> ; ---------[Includes]---------
#include *i %a_scriptdir%
#include lib\klist.ahk
;-
 
;+--> ; ---------[Directives]---------
#NoEnv
#SingleInstance Force
; --
SetBatchLines -1
SendMode Input
SetTitleMatchMode, Regex
SetWorkingDir %A_ScriptDir%
onExit, Clean
;-

;+--> ; ---------[Basic Info]---------
s_name      := "Hotshow"                ; Script Name
s_version   := "1.0"                    ; Script Version
s_author    := "RaptorX"                ; Script Author
s_email     := "graptorx@gmail.com"     ; Author's contact email
getparams()
update(s_version)
;-

;+--> ; ---------[General Variables]---------
sec       :=  1000                      ; 1 second
min       :=  sec * 60                  ; 1 minute
hour      :=  min * 60                  ; 1 hour
; --
SysGet, mon, Monitor                    ; Get the boundaries of the current screen
SysGet, wa_, MonitorWorkArea            ; Get the working area of the current screen
mid_scrw  :=  a_screenwidth / 2         ; Middle of the screen (width)
mid_scrh  :=  a_screenheight / 2        ; Middle of the screen (heigth)
; --
s_ini     :=                            ; Optional ini file
s_xml     :=                            ; Optional xml file
;-

;+--> ; ---------[User Configuration]---------
BgColor := "BG-Green.png"
mods    := "Ctrl,Shift,Alt,LWin,RWin"
keylist := klist("all")
;-

;+--> ; ---------[Main]---------
if !FileExist("res")
{
    FileCreateDir, % "res"
    FileInstall, res\BG-Blue.png, res\BG-Blue.png, 1 ;Background Image
    FileInstall, res\BG-Red.png, res\BG-Red.png, 1
    FileInstall, res\BG-Green.png, res\BG-Green.png, 1
}

; Background GUI  [Main]
;{
Gui, +owner +AlwaysOnTop +Disabled +Lastfound -Caption 
Gui, Color, FFFFFF
Gui, Add, Picture,,res\%BgColor%
Winset, transcolor, FFFFFF 0

Gui, Show, Hide, % "Background"
;}

; Hotkey Text GUI
;{
Gui, 2: +Owner +AlwaysOnTop +Disabled +Lastfound -Caption
Gui, 2: Color, 026D8D
Gui, 2: Font, Bold s15 Arial
Gui, 2: Add, Text, Center cWhite w250 vhotkeys
Winset, transcolor, 026D8D 0

Gui, 2: Show, Hide, % "HotkeyText"
;}

Loop, Parse, keylist, %a_space%
    if strLen(a_loopfield) = 1
        Hotkey, % "~*`" a_loopfield, Display
    else
        Hotkey, % "~*" a_loopfield, Display

Return ; End of autoexecute area
;-

;+--> ; ---------[Labels]---------
Display:
If a_thishotkey =
	Return
    
Loop, Parse, mods,`,
{
	GetKeyState, mod, %a_loopfield%
	If mod = D
		prefix = %prefix%%a_loopfield% +
}

StringTrimLeft, key, a_thishotkey, 2
if key=%a_space%
	key=Space
Gosub, Show
Return

Show:
Alpha=0
Duration=150
Imgx=23
Imgy=630
StringUpper, key, key, T
GuiControl, 2: Text, Hotkeys, %prefix% %key%
prefix := key :=
Gui, Show, x%imgx% y%imgy% NoActivate
imgx-=10
imgy+=15
Gui, 2: Show, x%imgx% y%imgy% NoActivate

Gosub, Fadein
Sleep 2000
Gosub, Fadeout
Gui, Hide
Gui, 2: Hide
Return

Fadein:
If faded=1 ;Do not fade if the window already faded in.
{
	Winset, transcolor, FFFFFF 255, Background
	Winset, transcolor, 026D8D 255, HotkeyText
	return
}

Loop, %duration% ; Fade in routine.
{
	Alpha+=255/duration
	Winset, transcolor, FFFFFF %Alpha%, Background
	Winset, transcolor, 026D8D %Alpha%, HotkeyText
	faded=1
}
Return

Fadeout:
Loop, %duration% ; Fade out routine
{
	Alpha-=255/duration
	Winset, transcolor, FFFFFF %Alpha%, Background
	Winset, transcolor, 026D8D %Alpha%, HotkeyText
	faded=0
}
return

Clean:
    if a_iscompiled
        FileDelete, res\*.png
    ExitApp
;-

;+--> ; ---------[Functions]---------
getparams(){
    global
    ; First we organize the parameters by priority [-sd, then -d , then everything else]
    ; I want to make sure that if i select to save a debug file, the debugging will be ON
    ; since the beginning because i use the debugging inside the next parameter checks as well.
    Loop, %0%
        param .= %a_index% .  a_space           ; param will contain the whole list of parameters
    
    if (InStr(param, "-h") || InStr(param, "--help")
    ||  InStr(param, "-?") || InStr(param, "/?")){
        debug ? debug("* ExitApp [0]", 2)
        Msgbox, 64, % "Accepted Parameters"
                  , % "The script accepts the following parameters:`n`n"
                    . "-h    --help`tOpens this dialog.`n"
                    . "-v    --version`tOpens a dialog containing the current script version.`n"
                    . "-d    --debug`tStarts the script with debug ON.`n"
                    . "-sd  --save-debug`tStarts the script with debug ON but saves the info on the `n"
                    . "`t`tspecified txt file.`n"
                    . "-sc  --source-code`tSaves a copy of the source code on the specified dir, specially `n"
                    . "`t`tuseful when the script is compiled and you want to see the source code."
        ExitApp
    }
    if (InStr(param, "-v") || InStr(param, "--version")){
        debug ? debug("* ExitApp [0]", 2)
        Msgbox, 64, % "Version"
                  , % "Author: " s_author " <" s_email ">`n" "Version: " s_name " v" s_version "`t"
        ExitApp
    }
    if (InStr(param, "-d") 
    ||  InStr(param, "--debug")){
        sparam := "-d "                         ; replace sparam with -d at the beginning.
    }
    if (InStr(param, "-sd") 
    ||  InStr(param, "--save-debug")){
        RegexMatch(param,"-sd\s(\w+\.\w+)", df) ; replace sparam with -sd at the beginning
        sparam := "-sd " df1  a_space           ; also save the output file name next to it
    }
    Loop, Parse, param, %a_space%
    {
        if (a_loopfield = "-d" || a_loopfield = "-sd" 
        ||  InStr(a_loopfield, ".txt")){        ; we already have those, so we just add the
            continue                            ; other parameters    
        }
        sparam .= a_loopfield . a_space
    }        
    sparam := RegexReplace(sparam, "\s+$","")   ; Remove trailing spaces. Organizing is done
    
	Loop, Parse, sparam, %a_space%
    {
        if (sdebug && !debugfile && (!a_loopfield || !InStr(a_loopfield,".txt") 
        || InStr(a_loopfield,"-"))){
            debug ? debug("* Error, debug file name not specified. ExitApp [1]", 2)
            Msgbox, 16, % "Error"
                      , % "You must provide a name to a txt file to save the debug output.`n`n"
                        . "usage: " a_scriptname " -sd file.txt"
            ExitApp
        }
        else if (sdebug){
            debugfile ? :debugfile := a_loopfield
            debug ? debug("") 
        }
        if (a_loopfield = "-d" 
        ||  a_loopfield = "--debug"){
            debug := True, sdebug := False
            debug ? debug("* " s_name " Debug ON`n* " s_name " [Start]`n* getparams() [Start]", 1)
        }
        if (a_loopfield = "-sd" 
        ||  a_loopfield = "--save-debug"){
            sdebug := True, debug := True
        }
        if (a_loopfield = "-sc" 
        ||  a_loopfield = "--source-code"){
            sc := True
            debug ? debug("* Copying source code")
            FileSelectFile, instloc, S16, source_%a_scriptname%
                          , % "Save source file to..."
                          , % "AutoHotkey Script (*.ahk)"
            if (!instloc){
                debug ? debug("* Canceled. ExitApp [1]", 2)
                ExitApp
            }
            FileInstall,HotShow.ahk,%instloc%
            if (!ErrorLevel){
                debug ? debug("* Source code successfully copied")
                MsgBox, 64, % "Source code copied"
                          , % "The source code was successfully copied"
                          , 10 ; 10s timeout
            }
            else 
            {
                debug ? debug("* Error while copying the source code")
                Msgbox, 16, % "Error while copying"
                          , % "There was an error while copying the source code.`nPlease check that "
                          . "the file is not already present in the current directory and that "
                          . "you have write permissions on the current folder."
                          , 10 ; 10s timeout
            }
        }
    }
    debug ? : debug("* " s_name " Debug OFF")
    if (sdebug && !debugfile){                      ; needed in case -sd is the only parameter given
        debug ? debug("* Error, debug file name not specified. ExitApp [1]", 2)
        Msgbox, 16, % "Error"
                  , % "You must provide a name to a txt file to save the debug output.`n`n"
                  .   "usage: " a_scriptname " -sd file.txt"
        ExitApp
    }
    if (sc = True){
        debug ? debug("* ExitApp [0]", 2)
        ExitApp
    }
    debug ? debug("* getparams() [End]", 2)
    return
}
debug(msg,delimiter = False){
    global
    static ft := True   ; First time
    
    t := delimiter = 1 ? msg := "* ------------------------------------------`n" msg
    t := delimiter = 2 ? msg := msg "`n* ------------------------------------------"
    t := delimiter = 3 ? msg := "* ------------------------------------------`n" msg 
                             .  "`n* ------------------------------------------"
    if (!debugfile){
        sdebug && ft ? (msg := "* ------------------------------------------`n"
                            .  "* " s_name " Debug ON`n* " s_name "[Start]`n"
                            .  "* getparams() [Start]`n" msg, ft := 0)
        OutputDebug, %msg%        
    }
    else if (debugfile){
        ft ? (msg .= "* ------------------------------------------`n"
                  .  "* " s_name " Debug ON`n* " s_name 
                  .  " [Start]`n* getparams() [Start]", ft := 0)
        FileAppend, %msg%`n, %debugfile%
    }
}
update(lversion, rfile="github", logurl="", vline=5){
    global s_author, s_name
    
    debug ? debug("* update() [Start]", 1)
    t := rfile = "github" ? logurl := "http://www.github.com/" s_author "/" s_name "/raw/master/Changelog.txt"
    UrlDownloadToFile, %logurl%, %a_temp%\logurl
    FileReadLine, logurl, %a_temp%\logurl, %vline%
    RegexMatch(logurl, "v(.*)", version)
    if (rfile = "github"){
        if (a_iscompiled)
            rfile := "http://github.com/downloads/" s_author "/" s_name "/" s_name "-" Version "-Compiled.zip"
        else 
            rfile := "http://github.com/" s_author "/" s_name "/zipball/" Version
    }
    if (version1 > lversion){
        Msgbox, 68, % "New Update Available"
                  , % "There is a new update available for this application.`n"
                    . "Do you wish to upgrade to " Version "?"
                  , 10 ; 10s timeout
        IfMsgbox, Timeout
            return 1 debug ? debug("* Update message timed out", 3)
        IfMsgbox, No
            return 2 debug ? debug("* Update aborted by user", 3)
        FileSelectFile, lfile, S16, %a_temp%
        UrlDownloadToFile, %rfile%, %lfile%
        Msgbox, 64, % "Download Complete"
                  , % "To install the new version simply replace the old file with the one`n"
                  .   "that was downloaded.`n`n The application will exit now."
        Run, %lfile%
        ExitApp
    }
    debug ? debug("* update() [End]", 2)
    return 0
}
;-

;+--> ; ---------[Hotkeys/Hotstrings]---------
~*Esc::ExitApp
Pause::Suspend, toggle
;-
