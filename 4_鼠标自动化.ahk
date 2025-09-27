; ============================================
; 鼠标自动化脚本 - 让鼠标自己动起来
; ============================================
#Requires AutoHotkey v2.0
#SingleInstance Force
SendMode "Input"
SetWorkingDir A_ScriptDir
CoordMode "Mouse", "Screen"

; ============================================
; 全局变量
; ============================================
global g_MousePositions := []
global g_RecordMode := false
global g_AutoClickEnabled := false
global g_MouseSpeed := 10

; ============================================
; 鼠标手势功能
; ============================================

; 右键+滚轮上: 增加音量
~RButton & WheelUp::{
    Send("{Volume_Up}")
    ShowVolumeTip("音量+")
}

; 右键+滚轮下: 减少音量
~RButton & WheelDown::{
    Send("{Volume_Down}")
    ShowVolumeTip("音量-")
}

; 右键+中键: 静音切换
~RButton & MButton::{
    Send("{Volume_Mute}")
    ShowVolumeTip("静音切换")
}

; ============================================
; 鼠标增强功能
; ============================================

; 中键: 关闭标签页（在浏览器中）
#HotIf WinActive("ahk_class Chrome_WidgetWin_1") || WinActive("ahk_class MozillaWindowClass")
MButton::Send("^w")
#HotIf

; Ctrl+鼠标左键: 快速双击
^LButton::{
    Click(2)
}

; Ctrl+鼠标右键: 快速三击（选中整行）
^RButton::{
    Click(3)
}

; ============================================
; 鼠标位置记录和回放
; ============================================

; F9: 开始/停止记录鼠标位置
F9::{
    global g_RecordMode
    
    if (!g_RecordMode) {
        g_RecordMode := true
        g_MousePositions := []
        TrayTip("按F10记录位置，F9停止记录", "开始记录", "Iconi")
    } else {
        g_RecordMode := false
        count := g_MousePositions.Length
        TrayTip("共记录了 " . count . " 个位置", "记录完成", "Iconi")
    }
}

; F10: 记录当前鼠标位置
F10::{
    global g_RecordMode, g_MousePositions
    
    if (!g_RecordMode) {
        TrayTip("请先按F9开始记录", "未在记录模式", "Icon!")
        return
    }
    
    MouseGetPos(&x, &y)
    g_MousePositions.Push({x: x, y: y})
    
    TrayTip("位置 #" . g_MousePositions.Length . ": " . x . ", " . y, "位置已记录", "Iconi")
}

; F11: 回放记录的鼠标位置
F11::{
    global g_MousePositions
    
    if (g_MousePositions.Length = 0) {
        TrayTip("请先记录鼠标位置", "无记录", "Icon!")
        return
    }
    
    TrayTip("按Esc可中断", "开始回放", "Iconi")
    
    for pos in g_MousePositions {
        ; 检查是否按下Esc
        if (GetKeyState("Escape", "P")) {
            TrayTip("", "回放中断", "Iconi")
            break
        }
        
        ; 平滑移动到位置
        SmoothMouseMove(pos.x, pos.y, g_MouseSpeed)
        Sleep(500)  ; 每个位置停留0.5秒
        Click()
    }
    
    TrayTip("", "回放完成", "Iconi")
}

; ============================================
; 自动点击功能
; ============================================

; F7: 启动/停止自动点击
F7::{
    global g_AutoClickEnabled
    g_AutoClickEnabled := !g_AutoClickEnabled
    
    if (g_AutoClickEnabled) {
        SetTimer(AutoClick, 1000)  ; 每秒点击一次
        TrayTip("每秒点击一次，F7停止", "自动点击已启动", "Iconi")
    } else {
        SetTimer(AutoClick, 0)
        TrayTip("", "自动点击已停止", "Iconi")
    }
}

; 自动点击函数
AutoClick() {
    Click()
}

; ============================================
; 鼠标跟随功能
; ============================================

; Ctrl+Win+F: 鼠标跟随活动窗口
^#f::{
    hwnd := WinGetID("A")
    if (!hwnd)
        return
    
    WinGetPos(&x, &y, &width, &height, hwnd)
    MouseMove(x + width/2, y + height/2, 0)
    
    TrayTip(WinGetTitle(hwnd), "鼠标已居中", "Iconi")
}

; ============================================
; 鼠标速度控制
; ============================================

; Ctrl+Shift+Plus: 增加鼠标移动速度
^+NumpadAdd::{
    global g_MouseSpeed
    g_MouseSpeed := Max(1, g_MouseSpeed - 2)
    TrayTip("速度: " . (11 - g_MouseSpeed), "鼠标速度", "Iconi")
}

; Ctrl+Shift+Minus: 减少鼠标移动速度
^+NumpadSub::{
    global g_MouseSpeed
    g_MouseSpeed := Min(20, g_MouseSpeed + 2)
    TrayTip("速度: " . (11 - g_MouseSpeed), "鼠标速度", "Iconi")
}

; ============================================
; 鼠标坐标显示
; ============================================

; Ctrl+Shift+M: 显示当前鼠标坐标
^+m::{
    MouseGetPos(&x, &y, &hwnd)
    winTitle := WinGetTitle(hwnd)
    className := WinGetClass(hwnd)
    
    info := "鼠标坐标: " . x . ", " . y . "`n"
          . "窗口标题: " . winTitle . "`n"
          . "窗口类名: " . className
    
    MsgBox(info, "鼠标信息", "Icon!")
}

; ============================================
; 鼠标穿透点击
; ============================================

; Ctrl+Win+Click: 穿透点击（点击下层窗口）
^#LButton::{
    ; 保存当前鼠标位置
    MouseGetPos(&x, &y, &topWindow)
    
    ; 暂时隐藏顶层窗口
    WinSetTransparent(1, topWindow)
    
    ; 点击下层
    Click()
    
    ; 恢复顶层窗口
    Sleep(50)
    WinSetTransparent("Off", topWindow)
}

; ============================================
; 画圆和画线功能
; ============================================

; Ctrl+Shift+C: 用鼠标画圆
^+c::{
    MouseGetPos(&centerX, &centerY)
    radius := 100
    steps := 36  ; 圆的平滑度
    
    TrayTip("以当前位置为中心画圆", "画圆", "Iconi")
    
    Loop steps {
        angle := (A_Index - 1) * 2 * 3.14159 / steps
        x := centerX + radius * Cos(angle)
        y := centerY + radius * Sin(angle)
        MouseMove(x, y, 2)
        Sleep(10)
    }
    
    ; 回到中心
    MouseMove(centerX, centerY, 5)
}

; Ctrl+Shift+L: 画直线（从当前位置到点击位置）
^+l::{
    ; 获取起始位置
    MouseGetPos(&startX, &startY)
    
    TrayTip("点击目标位置画线", "画线模式", "Iconi")
    
    ; 等待用户点击
    KeyWait("LButton", "D")
    MouseGetPos(&endX, &endY)
    
    ; 画线
    steps := 20
    Loop steps {
        x := startX + (endX - startX) * A_Index / steps
        y := startY + (endY - startY) * A_Index / steps
        MouseMove(x, y, 0)
        Sleep(10)
    }
}

; ============================================
; 鼠标区域限制
; ============================================
global g_MouseLocked := false
global g_LockRegion := {x1: 0, y1: 0, x2: 0, y2: 0}

; Ctrl+Shift+R: 设置鼠标活动区域
^+r::{
    TrayTip("点击左上角", "设置区域", "Iconi")
    KeyWait("LButton", "D")
    MouseGetPos(&x1, &y1)
    
    TrayTip("点击右下角", "设置区域", "Iconi")
    KeyWait("LButton", "D")
    MouseGetPos(&x2, &y2)
    
    global g_LockRegion
    g_LockRegion.x1 := x1
    g_LockRegion.y1 := y1
    g_LockRegion.x2 := x2
    g_LockRegion.y2 := y2
    
    TrayTip("按Ctrl+Shift+X锁定鼠标", "区域已设置", "Iconi")
}

; Ctrl+Shift+X: 锁定/解锁鼠标区域
^+x::{
    global g_MouseLocked
    g_MouseLocked := !g_MouseLocked
    
    if (g_MouseLocked) {
        SetTimer(EnforceMouseRegion, 10)
        TrayTip("限制在指定区域内", "鼠标已锁定", "Iconi")
    } else {
        SetTimer(EnforceMouseRegion, 0)
        TrayTip("可自由移动", "鼠标已解锁", "Iconi")
    }
}

; 强制鼠标在区域内
EnforceMouseRegion() {
    global g_LockRegion
    MouseGetPos(&x, &y)
    
    newX := x
    newY := y
    
    if (x < g_LockRegion.x1)
        newX := g_LockRegion.x1
    if (x > g_LockRegion.x2)
        newX := g_LockRegion.x2
    if (y < g_LockRegion.y1)
        newY := g_LockRegion.y1
    if (y > g_LockRegion.y2)
        newY := g_LockRegion.y2
    
    if (newX != x || newY != y)
        MouseMove(newX, newY, 0)
}

; ============================================
; 辅助函数
; ============================================

; 平滑移动鼠标
SmoothMouseMove(targetX, targetY, speed := 10) {
    MouseGetPos(&currentX, &currentY)
    
    distance := Sqrt((targetX - currentX)**2 + (targetY - currentY)**2)
    steps := Max(1, distance / speed)
    
    Loop Round(steps) {
        progress := A_Index / steps
        x := currentX + (targetX - currentX) * progress
        y := currentY + (targetY - currentY) * progress
        MouseMove(x, y, 0)
        Sleep(5)
    }
}

; 显示音量提示
ShowVolumeTip(text) {
    ToolTip(text)
    SetTimer(() => ToolTip(), -1000)
}

; ============================================
; 启动和帮助
; ============================================

TrayTip("按Win+F3查看帮助", "鼠标自动化脚本已启动", "Iconi")

; Win+F3: 显示帮助
#F3::{
    helpText := "
    (
    === 鼠标自动化快捷键 ===
    
    【鼠标手势】
    右键+滚轮上/下: 音量控制
    右键+中键: 静音切换
    
    【快速操作】
    Ctrl+左键: 双击
    Ctrl+右键: 三击选中行
    中键: 关闭标签页(浏览器)
    
    【位置记录】
    F9: 开始/停止记录
    F10: 记录当前位置
    F11: 回放记录
    
    【自动化】
    F7: 自动点击开关
    Ctrl+Win+F: 鼠标居中到窗口
    
    【绘图功能】
    Ctrl+Shift+C: 画圆
    Ctrl+Shift+L: 画线
    
    【区域限制】
    Ctrl+Shift+R: 设置限制区域
    Ctrl+Shift+X: 锁定/解锁区域
    
    【其他】
    Ctrl+Shift+M: 显示坐标信息
    Ctrl+Win+Click: 穿透点击
    Ctrl+Shift+加/减: 调整速度
    )"
    
    MsgBox(helpText, "鼠标自动化帮助", "Icon?")
}