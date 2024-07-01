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

WimVersion := "2024-06-30"

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

#NoEnv
#Warn
SendMode Input
SetWorkingDir %A_ScriptDir%

; XXX
;SendMode, Event
SetKeyDelay, 40

; --------------------------------------------------------------------
; Usehook
; --------------------------------------------------------------------

#InstallKeybdHook
#UseHook

; --------------------------------------------------------------------
; }}}

; 変数 {{{1
; --------------------------------------------------------------------

; ico
g_icon_text := % A_LineFile . "\..\wim-text.ico"
g_icon_cursor := % A_LineFile . "\..\wim-cursor.ico"

; モード
g_cursor := 0

set_mode(0)

; --------------------------------------------------------------------
; }}}

; アクティブウィンドウ切り替わりのイベント検出 {{{1
; --------------------------------------------------------------------

; - Windowsのイベントを拾う - hoge
; - https://sites.google.com/site/agkh6mze/howto/winevent

;#Persistent

myFunc := RegisterCallback("WinActivateHandler")

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

OnClipboardChange("ClipChanged")

ClipChanged(Type) {
    if (Type = 1) {
        ; long text
        maxLength := 100
        StringLen, length, Clipboard
        if (length > maxLength) {
            str := SubStr(Clipboard, 1, maxLength)
            ToolTip テキストをコピーしました`n%str%...`n(%length% 文字)
        } else {
            ; short text
            ToolTip テキストをコピーしました`n%Clipboard%
        }
    } else if (Type = 2) {
        ; non text
        ToolTip テキストでないものをコピーしました
    }
    SetTimer, RemoveToolTip, 1500
}

RemoveToolTip() {
    ; SetTimer, RemoveToolTip, Off
    ToolTip
}

; --------------------------------------------------------------------
; }}}

; Tray Icon / Menu {{{1
; --------------------------------------------------------------------

; wim-jus.ini
IniFile := % A_Linefile . "\..\wim-jus.ini"
Section := "wim-jus"

strWimVersion := "Wim JUS Version " . WimVersion
WimURL := "https://github.com/yoyuse/wim-jus"

EnableDateStamp := 1
strEnableDateStamp := "Date Stamp"
IniRead, EnableDateStamp, %IniFile%, %Section%, EnableDateStamp, %EnableDateStamp%

EnableNaturalScroll := 1
strEnableNaturalScroll := "Natural Scroll"
IniRead, EnableNaturalScroll, %IniFile%, %Section%, EnableNaturalScroll, %EnableNaturalScroll%

; 区切り線
Menu, Tray, Add
; バージョン情報
Menu, Tray, Add, %strWimVersion%, menuWimVersion
; 日付入力を使うか
Menu, Tray, Add, %strEnableDateStamp%, menuEnableDateStamp
if (EnableDateStamp == 1) {
    Menu, Tray, Check, %strEnableDateStamp%
}
; ナチュラルスクロールを使うか
Menu, Tray, Add, %strEnableNaturalScroll%, menuEnableNaturalScroll
if (EnableNaturalScroll == 1) {
    Menu, Tray, CHeck, %strEnableNaturalScroll%
}

; Auto-execute Section の終わり
Return

menuWimVersion:
    Run, %WimURL%
    Return

menuEnableDateStamp:
    If (EnableDateStamp == 1) {
        Menu, Tray, Uncheck, %strEnableDateStamp%
        EnableDateStamp := 0
    } else {
        Menu, Tray, Check, %strEnableDateStamp%
        EnableDateStamp := 1
    }
    IniWrite, %EnableDateStamp%, %IniFile%, %Section%, EnableDateStamp
    Return

menuEnableNaturalScroll:
    If (EnableNaturalScroll == 1) {
        Menu, Tray, Uncheck, %strEnableNaturalScroll%
        EnableNaturalScroll := 0
    } else {
        Menu, Tray, Check, %strEnableNaturalScroll%
        EnableNaturalScroll := 1
    }
    IniWrite, %EnableNaturalScroll%, %IniFile%, %Section%, EnableNaturalScroll
    Return

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
    icon :=
    if (g_cursor == 1) {
        icon := g_icon_cursor
    } else {
        icon := g_icon_text
    }
    if FileExist(icon) {
        Menu, Tray, Icon, %icon%
    }
}

; --------------------------------------------------------------------
; }}}

; モード表示 {{{1
; --------------------------------------------------------------------

set_mode(mode, show = 1) {
    global g_cursor
    g_cursor := mode
    if (show == 1) {
        show_mode()
    }
    set_icon()
    Return
}

show_mode() {
    global g_cursor
    s := g_cursor ? "◆ カーソル" : "◇ テキスト"
    ToolTip, %s%, A_CaretX, A_CaretY + 20, 2
    SetTimer, hide_mode, 4000
    Return
}

hide_mode:
    SetTimer, hide_mode, Off
    ToolTip, , , , 2
    Return

; --------------------------------------------------------------------
; }}}

; モード切り替え {{{1
; --------------------------------------------------------------------

~*RShift::show_mode()

#If

; 変換を修飾キーとして扱うための準備
; 変換を押し続けている限りリピートせず待機
$vk1C::
    startTime := A_TickCount
    KeyWait, vk1C
    keyPressDuration := A_TickCount - startTime
    ; 変換を押している間に他のホットキーが発動した場合は入力しない
    ; 変換を長押ししていた場合も入力しない
    If (A_ThisHotkey == "$vk1C" and keyPressDuration < 300) {
        set_mode(1)
    }
    Return

; 無変換を修飾キーとして扱うための準備
; 無変換を押し続けている限りリピートせず待機
$vk1D::
    startTime := A_TickCount
    KeyWait, vk1D
    keyPressDuration := A_TickCount - startTime
    ; 無変換を押している間に他のホットキーが発動した場合は入力しない
    ; 無変換を長押ししていた場合も入力しない
    If (A_ThisHotkey == "$vk1D" and keyPressDuration < 300) {
        set_mode(0)
    }
    Return

; --------------------------------------------------------------------
; }}}

; HenkanFN {{{1
; --------------------------------------------------------------------

~vk1C & Enter::
    Send,{Blind}{Enter}
    set_mode(0)
    Return

~vk1C & vkF3::Reload
~vk1C & vkF4::Reload
~vk1C & 1::Send,{Blind}{F1}
~vk1C & 2::Send,{Blind}{F2}
~vk1C & 3::Send,{Blind}{F3}
~vk1C & 4::Send,{Blind}{F4}
~vk1C & 5::Send,{Blind}{F5}
~vk1C & 6::Send,{Blind}{F6}
~vk1C & 7::Send,{Blind}{F7}
~vk1C & 8::Send,{Blind}{F8}
~vk1C & 9::Send,{Blind}{F9}
~vk1C & 0::Send,{Blind}{F10}
~vk1C & vkBD::Send,{Blind}{F11}
~vk1C & vkDE::Send,{Blind}{F12}
~vk1C & vkDC::Send,{Blind}{Ins}
~vk1C & BS::Send,{Blind}{Del}

~vk1C & q::Return
~vk1C & w::Return
~vk1C & e::Return
~vk1C & r::Return
~vk1C & t::Return
~vk1C & y::Send,{Blind}^y
~vk1C & u::Return
~vk1C & i::Return
~vk1C & o::Return
~vk1C & p::Return
~vk1C & vkC0::Send,{Blind}{PgUp}
~vk1C & vkDB::Send,{Blind}{PgDn}

~vk1C & a::Return
~vk1C & s::Return
~vk1C & d::Return
~vk1C & f::Return
~vk1C & g::Return
~vk1C & h::Send,{Blind}{Left}
~vk1C & j::Send,{Blind}{Down}
~vk1C & k::Send,{Blind}{Up}
~vk1C & l::Send,{Blind}{Right}
~vk1C & vkBB::Send,{Blind}{BS}
~vk1C & vkBA::Send,{Blind}{Del}
~vk1C & vkDD::Return

~vk1C & z::Send,{Blind}^z
~vk1C & x::Send,{Blind}^x
~vk1C & c::Send,{Blind}^c
~vk1C & v::Send,{Blind}^v
~vk1C & b::Return
~vk1C & n::Return
~vk1C & m::Return
~vk1C & vkBC::Send,{Blind}{Home}
~vk1C & vkBE::Send,{Blind}{End}
~vk1C & vkBF::Send,{Blind}{Enter}
~vk1C & vkE2::Return

; --------------------------------------------------------------------
; }}}

; MuhenkanFN {{{1
; --------------------------------------------------------------------

#If (g_cursor == 1)

~vk1D & vkF3::Send,{Blind}^{Esc}
~vk1D & vkF4::Send,{Blind}^{Esc}
~vk1D & 1::Send,{Blind}^{F1}
~vk1D & 2::Send,{Blind}^{F2}
~vk1D & 3::Send,{Blind}^{F3}
~vk1D & 4::Send,{Blind}^{F4}
~vk1D & 5::Send,{Blind}^{F5}
~vk1D & 6::Send,{Blind}^{F6}
~vk1D & 7::Send,{Blind}^{F7}
~vk1D & 8::Send,{Blind}^{F8}
~vk1D & 9::Send,{Blind}^{F9}
~vk1D & 0::Send,{Blind}^{F10}
~vk1D & vkBD::Send,{Blind}^{F11}
~vk1D & vkDE::Send,{Blind}^{F12}
~vk1D & vkDC::Send,{Blind}^{Ins}
~vk1D & BS::Send,{Blind}^{Del}

~vk1D & vkC0::Send,{Blind}^{PgUp}
~vk1D & vkDB::Send,{Blind}^{PgDn}

~vk1D & h::Send,{Blind}^{Left}
~vk1D & j::Send,{Blind}^{Down}
~vk1D & k::Send,{Blind}^{Up}
~vk1D & l::Send,{Blind}^{Right}
~vk1D & vkBB::Send,{Blind}^{BS}
~vk1D & vkBA::Send,{Blind}^{Del}

~vk1D & vkBC::Send,{Blind}^{Home}
~vk1D & vkBE::Send,{Blind}^{End}
~vk1D & vkBF::Send,{Blind}^{Enter}

#If

~vk1D & 1::Send,{Blind}^1
~vk1D & 2::Send,{Blind}^2
~vk1D & 3::Send,{Blind}^3
~vk1D & 4::Send,{Blind}^4
~vk1D & 5::Send,{Blind}^5
~vk1D & 6::Send,{Blind}^6
~vk1D & 7::Send,{Blind}^7
~vk1D & 8::Send,{Blind}^8
~vk1D & 9::Send,{Blind}^9
~vk1D & 0::Send,{Blind}^0
~vk1D & a::Send,{Blind}^a
~vk1D & b::Send,{Blind}^b
~vk1D & c::Send,{Blind}^c
~vk1D & d::Send,{Blind}^d
~vk1D & e::Send,{Blind}^e
~vk1D & f::Send,{Blind}^f
~vk1D & g::Send,{Blind}^g
~vk1D & h::Send,{Blind}^h
~vk1D & i::Send,{Blind}^i
~vk1D & j::Send,{Blind}^j
~vk1D & k::Send,{Blind}^k
~vk1D & l::Send,{Blind}^l
~vk1D & m::Send,{Blind}^m
~vk1D & n::Send,{Blind}^n
~vk1D & o::Send,{Blind}^o
~vk1D & p::Send,{Blind}^p
~vk1D & q::Send,{Blind}^q
~vk1D & r::Send,{Blind}^r
~vk1D & s::Send,{Blind}^s
~vk1D & t::Send,{Blind}^t
~vk1D & u::Send,{Blind}^u
~vk1D & v::Send,{Blind}^v
~vk1D & w::Send,{Blind}^w
~vk1D & x::Send,{Blind}^x
~vk1D & y::Send,{Blind}^y
~vk1D & z::Send,{Blind}^z
~vk1D & vkBA::Send,{Blind}^{vkBA}
~vk1D & vkBB::Send,{Blind}^{vkBB}
~vk1D & vkBC::Send,{Blind}^{vkBC}
~vk1D & vkBD::Send,{Blind}^{vkBD}
~vk1D & vkBE::Send,{Blind}^{vkBE}
~vk1D & vkBF::Send,{Blind}^{vkBF}
~VK1D & VKC0::Send,{Blind}^{VKC0}
~vk1D & vkDB::Send,{Blind}^{vkDB}
~vk1D & vkDC::Send,{Blind}^{vkDC}
~vk1D & vkDD::Send,{Blind}^{vkDD}
~vk1D & vkDE::Send,{Blind}^{vkDE}
~vk1D & vkE2::Send,{Blind}^{vkE2}
~vk1D & Space::Send,{Blind}^{Space}
~vk1D & Tab::Send,{Blind}^{Tab}
~vk1D & Enter::Send,{Blind}^{Enter}
~VK1D & BS::Send,{Blind}^{BS}
~vk1D & vkF3::Send,{Blind}^{vkF3}
~vk1D & vkF4::Send,{Blind}^{vkF4}
; ; ~vk1D & vk1C::Send,{Blind}^{vk1C}
; ; ~vk1D & vk1D::Send,{Blind}^{vk1D}
~vk1D & vkF2::Send,{Blind}^{vkF2}
~vk1D & vkF0::Send,{Blind}^{vkF0}
~vk1D & AppsKey::Send,{Blind}^{AppsKey}

; --------------------------------------------------------------------
; }}}

; カーソルモード {{{1
; --------------------------------------------------------------------

#If (g_cursor == 1)

~*Enter::set_mode(0)

*vkF3::Send,{Blind}{Esc}
*vkF4::Send,{Blind}{Esc}
1::Return
2::Return
3::Return
4::Return
5::Return
6::Return
7::Return
8::Return
9::Return
0::Return
*vkBD::Return
*vkDE::Return
*vkDC::Return
~*BS::Return

*q::Return
*w::Return
*e::Return
*r::Return
*t::Return
*y::Send,{Blind}^y
*u::Return
*i::
    if GetKeyState("Shift") {
        Send,{Home}
    }
    set_mode(0)
    Return
*o::
    SendMode,Event
    if GetKeyState("Shift") {
        Send,{End}
        Send,{Home}
        Send,{Enter}
        Send,{Up}
    } else {
        Send,{End}
        Send,{Enter}
    }
    set_mode(0)
    Return
*p::Return
*vkC0::Send,{Blind}{PgUp}
*vkDB::Send,{Blind}{PgDn}

*a::
    if GetKeyState("Shift") {
        Send,{End}
    }
    set_mode(0)
    Return
*s::
    if GetKeyState("Shift") {
        SendMode,Event
        Send,{End}
        Send,{Home}
        Send,{Home}
        Send,+{End}
        Send,+{Right}
        set_mode(1)
    } else {
        send,+{Right}
        set_mode(0)
    }
*d::Return
*f::Return
*g::Return
*h::Send,{Blind}{Left}
*j::Send,{Blind}{Down}
*k::Send,{Blind}{Up}
*l::Send,{Blind}{Right}
*vkBB::Send,{Blind}{BS}
*vkBA::Send,{Blind}{Del}
*vkDD::Return

*z::Send,{Blind}^z
*x::Send,{Blind}^x
*c::Send,{Blind}^c
*v::Send,{Blind}^v
*b::Return
*n::Return
*m::Return
*vkBC::Send,{Blind}{Home}
*vkBE::Send,{Blind}{End}
*vkBF::Send,{Blind}{Enter}
*vkE2::Return

; --------------------------------------------------------------------
; }}}

; テキストモード {{{1
; --------------------------------------------------------------------

#If (g_cursor == 0)

*vkF3::Send,{Blind}{Esc}
*vkF4::Send,{Blind}{Esc}

 +vk32::Send,{@}
 +vk36::Send,{^}
+*vk37::Send,{Blind}{&}
+*vk38::Send,{Blind}{*}
+*vk39::Send,{Blind}{(}
+*vk30::Send,{Blind}{)}
+*vkBD::Send,{Blind}{_}
+*vkDE::Send,{Blind}{+}
 *vkDE::Send,{Blind}{=}

*vkC0::Send,{Blind}{[}
*vkDB::Send,{Blind}{]}

 +vkBB::Send,{:}
+*vkBA::Send,{Blind}{"}
 *vkBA::Send,{Blind}{'}

 *vkDD::Send,{Blind}{\}
+*vkDD::Send,{Blind}{|}

+*vkE2::Send,{Blind}{~}
 *vkE2::Send,{Blind}{``}

; --------------------------------------------------------------------
; }}}

; Misc {{{1
; --------------------------------------------------------------------

#If

; disable S-無変換
+vk1D::Return

; disable W-無変換
#vk1D::Return

; disable 英数
vkF0::Return

; カタカナ ひらがな → 半角/全角
*vkF2::Send,{Blind}{vkF3}

#If

; 変換 と 無変換 の入力
vk1C & vk1D::Send,{vk1C}
vk1D & vk1C::Send,{vk1D}

#If (EnableDateStamp == 1)

; date stamp
+<^vkBB::Send,%A_YYYY%-%A_MM%-%A_DD%
+<^vkBA::
    FormatTime,DateStringShort,,yyMMdd
    Send,%DateStringShort%
    Return

#If (EnableNaturalScroll == 1)

; natural scroll
WheelUp::WheelDown
WheelDown::WheelUp
WheelLeft::WheelRight
WheelRight::WheelLeft

#If

; --------------------------------------------------------------------
; }}}
