; wim-jus.ahk
; vim:set ts=8 sts=0 sw=4 tw=0: (see :help modeline)
; vim:set foldmethod=marker foldcolumn=1 foldlevel=1:
; --------------------------------------------------------------------
; zi 折りたたみの有効無効の切り替え
; za 折りたたみの開閉
; zR 全ての折りたたみを開く
; zM 全ての折りたたみを閉じる
;
; history {{{1
; --------------------------------------------------------------------
;
; ----------------------------------------------------------------------------
; ¦*rel¦*F1 ¦*F2 ¦*F3 ¦*F4 ¦*F5 ¦*F6 ¦*F7 ¦*F8 ¦*F9 ¦*F10¦*F11¦*F12¦*Ins¦*Del¦
; ¦Esc ¦1 ! ¦2 @ ¦3 # ¦4 $ ¦5 % ¦6 ^ ¦7 & ¦8 * ¦9 ( ¦0 ) ¦- _ ¦= + ¦\ | ¦BS  ¦
; ----------------------------------------------------------------------------
; ¦      ¦    ¦    ¦    ¦    ¦    ¦^Y  ¦    ¦ins*¦opn*¦    ¦PgUp¦PgDn¦       ¦
; ¦Tab   ¦q Q ¦w W ¦e E ¦r R ¦t T ¦y Y ¦u U ¦i I ¦o O ¦p P ¦[ { ¦] } ¦Enter  ¦
; ---------------------------------------------------------------------      ¦
; ¦       ¦apd*¦sub*¦    ¦    ¦    ¦Lt  ¦Dn  ¦Up  ¦Rt  ¦BS  ¦Del ¦    ¦      ¦
; ¦Eisu   ¦a A ¦s S ¦d D ¦f F ¦g G ¦h H ¦j J ¦k K ¦l L ¦; : ¦' " ¦\ | ¦      ¦
; ----------------------------------------------------------------------------
; ¦         ¦^Z  ¦^X  ¦^C  ¦^V  ¦    ¦    ¦    ¦Home¦End ¦Entr¦    ¦         ¦
; ¦Shift    ¦z Z ¦x X ¦c C ¦v V ¦b B ¦n N ¦m M ¦, < ¦. > ¦/ ? ¦` ~ ¦Shift    ¦
; ----------------------------------------------------------------------------
; ¦    ¦    ¦    ¦    ¦      ¦          ¦      ¦    ¦    ¦    ¦              ¦
; ¦Ctrl¦Fn  ¦Win ¦ALt ¦Mu    ¦          ¦He    ¦Hira¦Menu¦Ctrl¦              ¦
; ----------------------------------------------------------------------------
;

WimVersion := "2024-07-03"

; 2024-07-03 for AutoHotkey v2
; 2024-06-30 reverse He-Mu and Mu-He
; 2024-06-30 wim-jus.ahk from wim-jus-minimal.ahk
; 2024-06-30 remap *rel/*F1--12/*Ins/*Del only when HenkanFN
; 2024-06-28 Wim JUS minimal 2024-06-28 from wim-jus draft 2024-06-26
; 2024-06-26 draft 2024-06-26
; 2024-06-26 wim-jus.ahk from wim-jis.ahk: draft 2024-06-25-1
; --------------------------------------------------------------------
; }}}

; Misc {{{1
; --------------------------------------------------------------------

#SingleInstance
#Warn
SendMode "Input"
SetWorkingDir A_ScriptDir

; XXX
; SendMode "Event"
SetKeyDelay 40

; --------------------------------------------------------------------
; Usehook
; --------------------------------------------------------------------

InstallKeybdHook
#UseHook

; --------------------------------------------------------------------
; }}}

; 変数 {{{1
; --------------------------------------------------------------------

; ico
g_icon_text := A_LineFile "\..\wim-text.ico"
g_icon_cursor := A_LineFile "\..\wim-cursor.ico"

; モード
g_cursor := 0

set_mode(0)

; --------------------------------------------------------------------
; }}}

; アクティブウィンドウ切り替わりのイベント検出 {{{1
; --------------------------------------------------------------------

; - Windowsのイベントを拾う - hoge
; - https://sites.google.com/site/agkh6mze/howto/winevent

; Persistent

myFunc := CallbackCreate(WinActivateHandler)

myHook := DllCall("SetWinEventHook"
    , "UInt", 0x00000003 ; eventMin      : EVENT_SYSTEM_FOREGROUND
    , "UInt", 0x00000003 ; eventMax      : EVENT_SYSTEM_FOREGROUND
    , "UInt", 0          ; hModule       : self
    , "UInt", myFunc     ; hWinEventProc :
    , "UInt", 0          ; idProcess     : All process
    , "UInt", 0          ; idThread      : All threads
    , "UInt", 0x0003     ; dwFlags       : WINEVENT_SKIPOWNTHREAD | WINEVENT_SKIPOWNPROCESS
    , "UInt")

WinActivateHandler(hWinEventHook, event, hwnd, idObject, idChild, thread, time) {
    set_mode(0)
}

; OnClipboardChange
; --------------------------------------------------------------------

OnClipboardChange ClipChanged

ClipChanged(Type) {
    if Type = 1 {
        ; long text
        maxLength := 100
        length := StrLen(A_Clipboard)
        if length > maxLength {
            str := SubStr(A_Clipboard, 1, maxLength)
            ToolTip "テキストをコピーしました`n" str "...`n(" length " 文字)"
        } else {
            ; short text
            ToolTip "テキストをコピーしました`n" A_Clipboard
        }
    } else if Type = 2 {
        ; non text
        ToolTip "テキストでないものをコピーしました"
    }
    SetTimer RemoveToolTip, 1500
}

RemoveToolTip() {
    ; SetTimer RemoveToolTip, 0
    ToolTip
}

; --------------------------------------------------------------------
; }}}

; Tray Icon / Menu {{{1
; --------------------------------------------------------------------

; wim-jus.ini
IniFile := A_Linefile "\..\wim-jus.ini"
Section := "wim-jus"

strWimVersion := "Wim JUS Version " WimVersion
WimURL := "https://github.com/yoyuse/wim-jus"

EnableDateStamp := "1"
strEnableDateStamp := "Date Stamp"
EnableDateStamp := IniRead(IniFile, Section, "EnableDateStamp", EnableDateStamp)

EnableNaturalScroll := "1"
strEnableNaturalScroll := "Natural Scroll"
EnableNaturalScroll := IniRead(IniFile, Section, "EnableNaturalScroll", EnableNaturalScroll)

MyMenu := A_TrayMenu
; 区切り線
MyMenu.Add
; バージョン情報
MyMenu.Add strWimVersion, menuWimVersion
; 日付入力を使うか
MyMenu.Add strEnableDateStamp, menuEnableDateStamp
if EnableDateStamp = 1 {
    MyMenu.Check strEnableDateStamp
}
; ナチュラルスクロールを使うか
MyMenu.Add strEnableNaturalScroll, menuEnableNaturalScroll
if EnableNaturalScroll = 1 {
    myMenu.Check strEnableNaturalScroll
}

; Auto-execute Section の終わり
return

menuWimVersion(ItemName, ItemPos, MyMenu)
{
    global WimURL
    Run WimURL
}

menuEnableDateStamp(ItemName, ItemPos, MyMenu)
{
    global EnableDateStamp, IniFile, Section, strEnableDateStamp
    if EnableDateStamp = 1 {
        MyMenu.Uncheck strEnableDateStamp
        EnableDateStamp := 0
    } else {
        MyMenu.Check strEnableDateStamp
        EnableDateStamp := 1
    }
    IniWrite EnableDateStamp, IniFile, Section, "EnableDateStamp"
}

menuEnableNaturalScroll(ItemName, ItemPos, MyMenu)
{
    global EnableNaturalScroll, IniFile, Section, strEnableNaturalScroll
    if EnableNaturalScroll = 1 {
        MyMenu.Uncheck strEnableNaturalScroll
        EnableNaturalScroll := 0
    } else {
        MyMenu.Check strEnableNaturalScroll
        EnableNaturalScroll := 1
    }
    IniWrite EnableNaturalScroll, IniFile, Section, "EnableNaturalScroll"
}

; --------------------------------------------------------------------
; }}}

; Reload Script {{{1
; --------------------------------------------------------------------

~vk1C & Esc::Reload

; --------------------------------------------------------------------
; }}}

; wim {{{1
; --------------------------------------------------------------------

set_icon() {
    global g_cursor, g_icon_text, g_icon_cursor
    icon := ""
    if g_cursor = 1 {
        icon := g_icon_cursor
    } else {
        icon := g_icon_text
    }
    if FileExist(icon) {
        TraySetIcon icon
    }
}

; --------------------------------------------------------------------
; }}}

; モード表示 {{{1
; --------------------------------------------------------------------

set_mode(mode, show := 1) {
    global g_cursor
    g_cursor := mode
    if show = 1 {
        show_mode()
    }
    set_icon()
}

show_mode() {
    global g_cursor
    s := g_cursor ? "◆ カーソル" : "◇ テキスト"
    if CaretGetPos(&x, &y) {
        ToolTip s, x, y + 20, 2
    } else {
        ToolTip s, , , 2
    }
    SetTimer hide_mode, 4000
}

hide_mode() {
    SetTimer , 0
    ToolTip , , , 2
}

; --------------------------------------------------------------------
; }}}

; モード切り替え {{{1
; --------------------------------------------------------------------

~*RShift::show_mode()

#HotIf

; 変換を修飾キーとして扱うための準備
; 変換を押し続けている限りリピートせず待機
$vk1C::
{
    startTime := A_TickCount
    KeyWait "vk1C"
    keyPressDuration := A_TickCount - startTime
    ; 変換を押している間に他のホットキーが発動した場合は入力しない
    ; 変換を長押ししていた場合も入力しない
    If A_ThisHotkey = "$vk1C" && keyPressDuration < 300 {
        set_mode(1)
    }
}

; 無変換を修飾キーとして扱うための準備
; 無変換を押し続けている限りリピートせず待機
$vk1D::
{
    startTime := A_TickCount
    KeyWait "vk1D"
    keyPressDuration := A_TickCount - startTime
    ; 無変換を押している間に他のホットキーが発動した場合は入力しない
    ; 無変換を長押ししていた場合も入力しない
    If A_ThisHotkey = "$vk1D" && keyPressDuration < 300 {
        set_mode(0)
    }
}

; --------------------------------------------------------------------
; }}}

; HenkanFN {{{1
; --------------------------------------------------------------------

#HotIf GetKeyState("vk1C", "P")

*Enter::
{
    Send "{Blind}{Enter}"
    set_mode(0)
}

*vkF3::Reload
*vkF4::Reload
*1::Send "{Blind}{F1}"
*2::Send "{Blind}{F2}"
*3::Send "{Blind}{F3}"
*4::Send "{Blind}{F4}"
*5::Send "{Blind}{F5}"
*6::Send "{Blind}{F6}"
*7::Send "{Blind}{F7}"
*8::Send "{Blind}{F8}"
*9::Send "{Blind}{F9}"
*0::Send "{Blind}{F10}"
*vkBD::Send "{Blind}{F11}"
*vkDE::Send "{Blind}{F12}"
*vkDC::Send "{Blind}{Ins}"
*BS::Send "{Blind}{Del}"

*q::return
*w::return
*e::return
*r::return
*t::return
*y::Send "{Blind}^y"
*u::return
*i::return
*o::return
*p::return
*vkC0::Send "{Blind}{PgUp}"
*vkDB::Send "{Blind}{PgDn}"

*a::return
*s::return
*d::return
*f::return
*g::return
*h::Send "{Blind}{Left}"
*j::Send "{Blind}{Down}"
*k::Send "{Blind}{Up}"
*l::Send "{Blind}{Right}"
*vkBB::Send "{Blind}{BS}"
*vkBA::Send "{Blind}{Del}"
*vkDD::return

*z::Send "{Blind}^z"
*x::Send "{Blind}^x"
*c::Send "{Blind}^c"
*v::Send "{Blind}^v"
*b::return
*n::return
*m::return
*vkBC::Send "{Blind}{Home}"
*vkBE::Send "{Blind}{End}"
*vkBF::Send "{Blind}{Enter}"
*vkE2::return

#HotIf

; --------------------------------------------------------------------
; }}}

; MuhenkanFN {{{1
; --------------------------------------------------------------------

#HotIf GetKeyState("vk1D", "P") && g_cursor = 1

*vkF3::Send "{Blind}^{Esc}"
*vkF4::Send "{Blind}^{Esc}"
*1::Send "{Blind}^{F1}"
*2::Send "{Blind}^{F2}"
*3::Send "{Blind}^{F3}"
*4::Send "{Blind}^{F4}"
*5::Send "{Blind}^{F5}"
*6::Send "{Blind}^{F6}"
*7::Send "{Blind}^{F7}"
*8::Send "{Blind}^{F8}"
*9::Send "{Blind}^{F9}"
*0::Send "{Blind}^{F10}"
*vkBD::Send "{Blind}^{F11}"
*vkDE::Send "{Blind}^{F12}"
*vkDC::Send "{Blind}^{Ins}"
*BS::Send "{Blind}^{Del}"

*vkC0::Send "{Blind}^{PgUp}"
*vkDB::Send "{Blind}^{PgDn}"

*h::Send "{Blind}^{Left}"
*j::Send "{Blind}^{Down}"
*k::Send "{Blind}^{Up}"
*l::Send "{Blind}^{Right}"
*vkBB::Send "{Blind}^{BS}"
*vkBA::Send "{Blind}^{Del}"

*vkBC::Send "{Blind}^{Home}"
*vkBE::Send "{Blind}^{End}"
*vkBF::Send "{Blind}^{Enter}"

#HotIf GetKeyState("vk1D", "P")

*1::Send "{Blind}^1"
*2::Send "{Blind}^2"
*3::Send "{Blind}^3"
*4::Send "{Blind}^4"
*5::Send "{Blind}^5"
*6::Send "{Blind}^6"
*7::Send "{Blind}^7"
*8::Send "{Blind}^8"
*9::Send "{Blind}^9"
*0::Send "{Blind}^0"
*a::Send "{Blind}^a"
*b::Send "{Blind}^b"
*c::Send "{Blind}^c"
*d::Send "{Blind}^d"
*e::Send "{Blind}^e"
*f::Send "{Blind}^f"
*g::Send "{Blind}^g"
*h::Send "{Blind}^h"
*i::Send "{Blind}^i"
*j::Send "{Blind}^j"
*k::Send "{Blind}^k"
*l::Send "{Blind}^l"
*m::Send "{Blind}^m"
*n::Send "{Blind}^n"
*o::Send "{Blind}^o"
*p::Send "{Blind}^p"
*q::Send "{Blind}^q"
*r::Send "{Blind}^r"
*s::Send "{Blind}^s"
*t::Send "{Blind}^t"
*u::Send "{Blind}^u"
*v::Send "{Blind}^v"
*w::Send "{Blind}^w"
*x::Send "{Blind}^x"
*y::Send "{Blind}^y"
*z::Send "{Blind}^z"
*vkBA::Send "{Blind}^{vkBA}"
*vkBB::Send "{Blind}^{vkBB}"
*vkBC::Send "{Blind}^{vkBC}"
*vkBD::Send "{Blind}^{vkBD}"
*vkBE::Send "{Blind}^{vkBE}"
*vkBF::Send "{Blind}^{vkBF}"
*vkC0::Send "{Blind}^{VKC0}"
*vkDB::Send "{Blind}^{vkDB}"
*vkDC::Send "{Blind}^{vkDC}"
*vkDD::Send "{Blind}^{vkDD}"
*vkDE::Send "{Blind}^{vkDE}"
*vkE2::Send "{Blind}^{vkE2}"
*Space::Send "{Blind}^{Space}"
*Tab::Send "{Blind}^{Tab}"
*Enter::Send "{Blind}^{Enter}"
*BS::Send "{Blind}^{BS}"
*vkF3::Send "{Blind}^{vkF3}"
*vkF4::Send "{Blind}^{vkF4}"
; *vk1C::Send "{Blind}^{vk1C}"
; *vk1D::Send "{Blind}^{vk1D}"
*vkF2::Send "{Blind}^{vkF2}"
*vkF0::Send "{Blind}^{vkF0}"
*AppsKey::Send "{Blind}^{AppsKey}"

; --------------------------------------------------------------------
; }}}

; カーソルモード {{{1
; --------------------------------------------------------------------

#HotIf g_cursor = 1

~*Enter::set_mode(0)

*vkF3::Send "{Blind}{Esc}"
*vkF4::Send "{Blind}{Esc}"
1::return
2::return
3::return
4::return
5::return
6::return
7::return
8::return
9::return
0::return
*vkBD::return
*vkDE::return
*vkDC::return
~*BS::return

*q::return
*w::return
*e::return
*r::return
*t::return
*y::Send "{Blind}^y"
*u::return
*i::
{
    if GetKeyState("Shift") {
        Send "{Home}"
    }
    set_mode(0)
}
*o::
{
    SendMode "Event"
    if GetKeyState("Shift") {
        Send "{End}"
        Send "{Home}"
        Send "{Enter}"
        Send "{Up}"
    } else {
        Send "{End}"
        Send "{Enter}"
    }
    set_mode(0)
}
*p::return
*vkC0::Send "{Blind}{PgUp}"
*vkDB::Send "{Blind}{PgDn}"

*a::
{
    if GetKeyState("Shift") {
        Send "{End}"
    }
    set_mode(0)
}
*s::
{
    if GetKeyState("Shift") {
        SendMode "Event"
        Send "{End}"
        Send "{Home}"
        Send "{Home}"
        Send "+{End}"
        Send "+{Right}"
        set_mode(1)
    } else {
        send "+{Right}"
        set_mode(0)
    }
}
*d::return
*f::return
*g::return
*h::Send "{Blind}{Left}"
*j::Send "{Blind}{Down}"
*k::Send "{Blind}{Up}"
*l::Send "{Blind}{Right}"
*vkBB::Send "{Blind}{BS}"
*vkBA::Send "{Blind}{Del}"
*vkDD::return

*z::Send "{Blind}^z"
*x::Send "{Blind}^x"
*c::Send "{Blind}^c"
*v::Send "{Blind}^v"
*b::return
*n::return
*m::return
*vkBC::Send "{Blind}{Home}"
*vkBE::Send "{Blind}{End}"
*vkBF::Send "{Blind}{Enter}"
*vkE2::return

; --------------------------------------------------------------------
; }}}

; テキストモード {{{1
; --------------------------------------------------------------------

#HotIf g_cursor = 0

*vkF3::Send "{Blind}{Esc}"
*vkF4::Send "{Blind}{Esc}"

 +vk32::Send "{@}"
 +vk36::Send "{^}"
+*vk37::Send "{Blind}{&}"
+*vk38::Send "{Blind}{*}"
+*vk39::Send "{Blind}{(}"
+*vk30::Send "{Blind}{)}"
+*vkBD::Send "{Blind}{_}"
+*vkDE::Send "{Blind}{+}"
 *vkDE::Send "{Blind}{=}"

*vkC0::Send "{Blind}{[}"
*vkDB::Send "{Blind}{]}"

 +vkBB::Send "{:}"
+*vkBA::Send "{Blind}{`"}"
 *vkBA::Send "{Blind}{'}"

 *vkDD::Send "{Blind}{\}"
+*vkDD::Send "{Blind}{|}"

+*vkE2::Send "{Blind}{~}"
 *vkE2::Send "{Blind}{``}"

; --------------------------------------------------------------------
; }}}

; Misc {{{1
; --------------------------------------------------------------------

#HotIf

; disable S-無変換
+vk1D::return

; disable W-無変換
#vk1D::return

; disable 英数
vkF0::return

; カタカナ ひらがな → 半角/全角
*vkF2::Send "{Blind}{vkF3}"

#HotIf

; 変換 と 無変換 の入力
vk1C & vk1D::Send "{vk1C}"
vk1D & vk1C::Send "{vk1D}"

#HotIf EnableDateStamp = 1

; date stamp
+<^vkBB::Send A_YYYY "-" A_MM "-" A_DD
+<^vkBA::Send FormatTime(, "yyMMdd")

#HotIf EnableNaturalScroll = 1

; natural scroll
WheelUp::WheelDown
WheelDown::WheelUp
WheelLeft::WheelRight
WheelRight::WheelLeft

#HotIf

; --------------------------------------------------------------------
; }}}
