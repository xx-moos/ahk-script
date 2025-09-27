; ============================================
; ugit自动化脚本 - 让Git提交更高效
; ============================================
#Requires AutoHotkey v2.0
#SingleInstance Force
SendMode "Input"
SetWorkingDir A_ScriptDir
CoordMode "Mouse", "Screen"
CoordMode "Pixel", "Screen"

; ============================================
; 全局变量
; ============================================
global g_UgitWindow := ""
global g_CommitButtonPos := {x: 0, y: 0}
global g_CommitButtonFound := false

; ============================================
; 主要功能：Ctrl+Enter 点击ugit提交按钮
; ============================================

; Ctrl+Enter: 在ugit中自动点击提交按钮
^Enter::{
    ; 检查是否在ugit窗口中
    if (!IsUgitWindow()) {
        ; 如果不在ugit中，发送普通的Ctrl+Enter
        Send("^Enter")
        return
    }
    
    ; 在ugit中，尝试点击提交按钮
    if (ClickCommitButton()) {
        TrayTip("", "提交按钮已点击", "Iconi")
    } else {
        ; 如果找不到提交按钮，发送普通的Ctrl+Enter
        Send("^Enter")
        TrayTip("未找到提交按钮", "使用默认快捷键", "Icon!")
    }
}

; ============================================
; 辅助功能：手动定位和设置提交按钮
; ============================================

; Ctrl+Alt+C: 手动定位ugit提交按钮位置
^!c::{
    if (!IsUgitWindow()) {
        TrayTip("请在ugit窗口中操作", "窗口检测", "Icon!")
        return
    }
    
    TrayTip("请将鼠标移动到提交按钮上，然后按空格键", "定位提交按钮", "Iconi")
    
    ; 等待用户按空格键
    KeyWait("Space", "D")
    
    ; 获取鼠标位置
    MouseGetPos(&x, &y)
    global g_CommitButtonPos
    g_CommitButtonPos.x := x
    g_CommitButtonPos.y := y
    g_CommitButtonFound := true
    
    ; 保存到配置文件
    SaveCommitButtonPosition()
    
    TrayTip("提交按钮位置已保存: " . x . ", " . y, "定位完成", "Iconi")
}

; Ctrl+Alt+R: 重新检测提交按钮
^!r::{
    global g_CommitButtonFound := false
    TrayTip("", "提交按钮位置已重置", "Iconi")
    
    ; 删除配置文件
    try {
        FileDelete("ugit_config.ini")
    }
}

; ============================================
; 智能提交按钮检测功能
; ============================================

; 检测是否在ugit窗口中
IsUgitWindow() {
    global g_UgitWindow
    
    ; 获取当前活动窗口
    hwnd := WinGetID("A")
    if (!hwnd)
        return false
    
    ; 获取窗口标题和类名
    title := WinGetTitle(hwnd)
    class := WinGetClass(hwnd)
    
    ; 检查是否是ugit窗口（常见的ugit窗口标识）
    isUgit := InStr(title, "ugit") || 
              InStr(title, "Git") || 
              InStr(class, "ugit") ||
              InStr(class, "Git")
    
    if (isUgit) {
        g_UgitWindow := hwnd
        return true
    }
    
    return false
}

; 点击提交按钮
ClickCommitButton() {
    ; 首先尝试使用保存的位置
    if (TrySavedPosition()) {
        return true
    }
    
    ; 如果保存的位置不可用，尝试智能检测
    if (TrySmartDetection()) {
        return true
    }
    
    ; 最后尝试通用方法
    return TryGenericMethod()
}

; 尝试使用保存的位置
TrySavedPosition() {
    global g_CommitButtonFound, g_CommitButtonPos
    
    if (!g_CommitButtonFound) {
        ; 尝试从配置文件加载
        LoadCommitButtonPosition()
    }
    
    if (g_CommitButtonFound && g_CommitButtonPos.x > 0 && g_CommitButtonPos.y > 0) {
        ; 点击保存的位置
        Click(g_CommitButtonPos.x, g_CommitButtonPos.y)
        Sleep(100)
        return true
    }
    
    return false
}

; 智能检测提交按钮
TrySmartDetection() {
    ; 获取ugit窗口信息
    hwnd := g_UgitWindow
    if (!hwnd)
        return false
    
    WinGetPos(&winX, &winY, &winWidth, &winHeight, hwnd)
    
    ; 常见的提交按钮位置模式
    buttonPatterns := [
        ; 右下角区域（最常见）
        {x: winX + winWidth - 120, y: winY + winHeight - 60, width: 80, height: 30},
        {x: winX + winWidth - 100, y: winY + winHeight - 50, width: 70, height: 25},
        
        ; 底部中央区域
        {x: winX + winWidth//2 - 40, y: winY + winHeight - 60, width: 80, height: 30},
        
        ; 右上角区域
        {x: winX + winWidth - 150, y: winY + 50, width: 80, height: 30},
        
        ; 顶部工具栏区域
        {x: winX + winWidth - 200, y: winY + 20, width: 100, height: 40}
    ]
    
    ; 尝试每个位置
    for pattern in buttonPatterns {
        if (IsButtonAtPosition(pattern)) {
            Click(pattern.x + pattern.width//2, pattern.y + pattern.height//2)
            Sleep(100)
            
            ; 保存成功的位置
            global g_CommitButtonPos
            g_CommitButtonPos.x := pattern.x + pattern.width//2
            g_CommitButtonPos.y := pattern.y + pattern.height//2
            g_CommitButtonFound := true
            SaveCommitButtonPosition()
            
            return true
        }
    }
    
    return false
}

; 检测指定位置是否有按钮
IsButtonAtPosition(pattern) {
    ; 简单的颜色检测（按钮通常是较深的颜色）
    x := pattern.x + pattern.width//2
    y := pattern.y + pattern.height//2
    
    ; 获取像素颜色
    pixelColor := PixelGetColor(x, y)
    
    ; 转换为RGB值
    r := (pixelColor & 0xFF0000) >> 16
    g := (pixelColor & 0x00FF00) >> 8
    b := (pixelColor & 0x0000FF)
    
    ; 按钮通常是较深的颜色（RGB值较小）
    isDark := (r + g + b) < 400
    
    return isDark
}

; 通用方法：尝试发送Tab键导航到提交按钮
TryGenericMethod() {
    ; 尝试按Tab键导航到提交按钮
    Send("{Tab}")
    Sleep(200)
    Send("{Tab}")
    Sleep(200)
    Send("{Tab}")
    Sleep(200)
    
    ; 尝试按Enter键
    Send("{Enter}")
    Sleep(100)
    
    return true
}

; ============================================
; 配置文件管理
; ============================================

; 保存提交按钮位置到配置文件
SaveCommitButtonPosition() {
    global g_CommitButtonPos, g_CommitButtonFound
    
    if (g_CommitButtonFound) {
        configContent := "CommitButtonX=" . g_CommitButtonPos.x . "`n"
        configContent .= "CommitButtonY=" . g_CommitButtonPos.y . "`n"
        configContent .= "Found=true`n"
        
        try {
            FileWrite(configContent, "ugit_config.ini")
        }
    }
}

; 从配置文件加载提交按钮位置
LoadCommitButtonPosition() {
    global g_CommitButtonPos, g_CommitButtonFound
    
    if (!FileExist("ugit_config.ini")) {
        return
    }
    
    try {
        configContent := FileRead("ugit_config.ini")
        
        ; 解析配置文件
        for line in StrSplit(configContent, "`n") {
            if (InStr(line, "CommitButtonX=")) {
                g_CommitButtonPos.x := Integer(SubStr(line, 16))
            } else if (InStr(line, "CommitButtonY=")) {
                g_CommitButtonPos.y := Integer(SubStr(line, 16))
            } else if (InStr(line, "Found=true")) {
                g_CommitButtonFound := true
            }
        }
    }
}

; ============================================
; 增强功能：ugit快捷键
; ============================================

; Ctrl+Alt+S: 在ugit中快速暂存所有更改
^!s::{
    if (IsUgitWindow()) {
        Send("^a")  ; 全选所有文件
        Sleep(100)
        Send("{Space}")  ; 空格键暂存
        TrayTip("", "所有更改已暂存", "Iconi")
    } else {
        Send("^!s")  ; 发送原始快捷键
    }
}

; Ctrl+Alt+U: 在ugit中取消暂存
^!u::{
    if (IsUgitWindow()) {
        Send("{Space}")  ; 空格键取消暂存
        TrayTip("", "暂存已取消", "Iconi")
    } else {
        Send("^!u")  ; 发送原始快捷键
    }
}

; Ctrl+Alt+D: 在ugit中显示差异
^!d::{
    if (IsUgitWindow()) {
        Send("d")  ; 按d键显示差异
        TrayTip("", "显示文件差异", "Iconi")
    } else {
        Send("^!d")  ; 发送原始快捷键
    }
}

; ============================================
; 调试和测试功能
; ============================================

; F12: 调试模式 - 显示当前窗口信息
F12::{
    hwnd := WinGetID("A")
    if (!hwnd) {
        TrayTip("", "无法获取窗口信息", "Icon!")
        return
    }
    
    title := WinGetTitle(hwnd)
    class := WinGetClass(hwnd)
    WinGetPos(&x, &y, &width, &height, hwnd)
    MouseGetPos(&mouseX, &mouseY)
    
    info := "窗口标题: " . title . "`n"
          . "窗口类名: " . class . "`n"
          . "窗口位置: " . x . ", " . y . "`n"
          . "窗口大小: " . width . " x " . height . "`n"
          . "鼠标位置: " . mouseX . ", " . mouseY . "`n"
          . "是否ugit窗口: " . (IsUgitWindow() ? "是" : "否")
    
    MsgBox(info, "窗口调试信息", "Icon?")
}

; ============================================
; 启动和帮助
; ============================================

; 启动时加载配置
LoadCommitButtonPosition()

TrayTip("按Win+F4查看帮助", "ugit自动化脚本已启动", "Iconi")

; Win+F4: 显示帮助
#F4::{
    helpText := "
    (
    === ugit自动化快捷键 ===
    
    【主要功能】
    Ctrl+Enter: 点击ugit提交按钮
    
    【按钮定位】
    Ctrl+Alt+C: 手动定位提交按钮
    Ctrl+Alt+R: 重置按钮位置
    
    【ugit增强】
    Ctrl+Alt+S: 暂存所有更改
    Ctrl+Alt+U: 取消暂存
    Ctrl+Alt+D: 显示文件差异
    
    【调试功能】
    F12: 显示窗口调试信息
    
    【帮助】
    Win+F4: 显示此帮助
    Win+Esc: 退出脚本
    
    注意：首次使用请按Ctrl+Alt+C定位提交按钮
    )"
    
    MsgBox(helpText, "ugit自动化帮助", "Icon?")
}

; Win+Esc: 退出脚本
#Esc::{
    result := MsgBox("确定要退出ugit自动化脚本吗？", "退出确认", "YesNo Icon?")
    if (result = "Yes") {
        ExitApp()
    }
}
