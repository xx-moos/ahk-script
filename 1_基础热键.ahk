; ============================================
; 基础热键脚本 - 老王保证能跑的版本
; ============================================
#Requires AutoHotkey v2.0
#SingleInstance Force
SendMode "Input"
SetWorkingDir A_ScriptDir

; ============================================
; 基础热键示例
; ============================================

; Win+T: 打开终端（Windows Terminal）
#t::Run("wt")

; Ctrl+Alt+N: 打开记事本
^!n::Run("notepad")

; Ctrl+Alt+C: 打开计算器
^!c::Run("calc")

; ============================================
; 快速输入常用文本
; ============================================

; Ctrl+Alt+E: 输入邮箱
^!e::Send("your-email@example.com")

; Ctrl+Alt+P: 输入电话
^!p::Send("13800138000")

; Ctrl+Alt+D: 插入当前日期时间
^!d::Send(FormatTime(, "yyyy-MM-dd HH:mm:ss"))

; ============================================
; 媒体控制热键
; ============================================

; Ctrl+Alt+Space: 播放/暂停
^!Space::Send("{Media_Play_Pause}")

; Ctrl+Alt+Left: 上一曲
^!Left::Send("{Media_Prev}")

; Ctrl+Alt+Right: 下一曲
^!Right::Send("{Media_Next}")

; Ctrl+Alt+Up: 音量增加
^!Up::Send("{Volume_Up}")

; Ctrl+Alt+Down: 音量减少
^!Down::Send("{Volume_Down}")

; ============================================
; 窗口快捷操作
; ============================================

; Win+Q: 快速退出程序
#q::Send("!{F4}")

; Win+M: 最小化当前窗口
#m::WinMinimize("A")

; Win+Shift+M: 最大化当前窗口
#+m::WinMaximize("A")

; ============================================
; 文本编辑增强
; ============================================

; Ctrl+Shift+U: 转换为大写
^+u::{
    ; 保存剪贴板原内容
    clipSaved := ClipboardAll()
    A_Clipboard := ""
    
    ; 复制选中文本
    Send("^c")
    ClipWait(0.5)
    
    if (A_Clipboard != "") {
        ; 转换为大写并粘贴
        A_Clipboard := StrUpper(A_Clipboard)
        Send("^v")
    }
    
    ; 恢复剪贴板
    Sleep(100)
    A_Clipboard := clipSaved
}

; Ctrl+Shift+L: 转换为小写
^+l::{
    clipSaved := ClipboardAll()
    A_Clipboard := ""
    
    Send("^c")
    ClipWait(0.5)
    
    if (A_Clipboard != "") {
        A_Clipboard := StrLower(A_Clipboard)
        Send("^v")
    }
    
    Sleep(100)
    A_Clipboard := clipSaved
}

; ============================================
; 快速搜索
; ============================================

; Ctrl+Shift+G: Google搜索选中文本
^+g::{
    clipSaved := ClipboardAll()
    A_Clipboard := ""
    
    Send("^c")
    ClipWait(0.5)
    
    if (A_Clipboard != "") {
        Run("https://www.google.com/search?q=" . UrlEncode(A_Clipboard))
    }
    
    Sleep(100)
    A_Clipboard := clipSaved
}

; Ctrl+Shift+B: 百度搜索选中文本
^+b::{
    clipSaved := ClipboardAll()
    A_Clipboard := ""
    
    Send("^c")
    ClipWait(0.5)
    
    if (A_Clipboard != "") {
        Run("https://www.baidu.com/s?wd=" . UrlEncode(A_Clipboard))
    }
    
    Sleep(100)
    A_Clipboard := clipSaved
}

; ============================================
; 辅助函数
; ============================================

; URL编码函数
UrlEncode(str) {
    static hex := "0123456789ABCDEF"
    encoded := ""
    
    Loop Parse, str {
        if RegExMatch(A_LoopField, "[a-zA-Z0-9\-_.~]") {
            encoded .= A_LoopField
        } else {
            code := Ord(A_LoopField)
            encoded .= "%" . SubStr(hex, (code >> 4) + 1, 1) . SubStr(hex, (code & 0xF) + 1, 1)
        }
    }
    
    return encoded
}

; ============================================
; 状态提示
; ============================================
TrayTip("按Win+F1查看帮助", "基础热键脚本已启动", "Iconi")

; Win+F1: 显示帮助
#F1::{
    helpText := "
    (
    === 基础热键列表 ===
    
    【程序启动】
    Win+T: 打开终端
    Ctrl+Alt+N: 打开记事本
    Ctrl+Alt+C: 打开计算器
    
    【快速输入】
    Ctrl+Alt+E: 输入邮箱
    Ctrl+Alt+P: 输入电话
    Ctrl+Alt+D: 插入日期时间
    
    【媒体控制】
    Ctrl+Alt+Space: 播放/暂停
    Ctrl+Alt+Left/Right: 上一曲/下一曲
    Ctrl+Alt+Up/Down: 音量增/减
    
    【窗口操作】
    Win+Q: 关闭窗口
    Win+M: 最小化窗口
    Win+Shift+M: 最大化窗口
    
    【文本编辑】
    Ctrl+Shift+U: 转大写
    Ctrl+Shift+L: 转小写
    
    【快速搜索】
    Ctrl+Shift+G: Google搜索
    Ctrl+Shift+B: 百度搜索
    
    【其他】
    Win+F1: 显示此帮助
    Win+Esc: 退出脚本
    )"
    
    MsgBox(helpText, "热键帮助", "Icon?")
}

; Win+Esc: 退出脚本
#Esc::{
    result := MsgBox("确定要退出脚本吗？", "退出确认", "YesNo Icon?")
    if (result = "Yes") {
        ExitApp()
    }
}