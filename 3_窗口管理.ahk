; ============================================
; 窗口管理脚本 - 让窗口听话的神器
; ============================================
#Requires AutoHotkey v2.0
#SingleInstance Force
SendMode "Input"
SetWorkingDir A_ScriptDir
CoordMode "Mouse", "Screen"

; ============================================
; 全局变量
; ============================================
global g_SavedWindows := Map()
global g_WindowGroups := Map()

; ============================================
; 窗口分屏快捷键
; ============================================

; Win+Left: 窗口贴左半屏
#Left::{
    hwnd := WinGetID("A")
    if (!hwnd)
        return
    
    ; 获取显示器工作区域
    MonitorGetWorkArea(, &left, &top, &right, &bottom)
    width := (right - left) // 2
    height := bottom - top
    
    WinMove(left, top, width, height, hwnd)
}

; Win+Right: 窗口贴右半屏
#Right::{
    hwnd := WinGetID("A")
    if (!hwnd)
        return
    
    MonitorGetWorkArea(, &left, &top, &right, &bottom)
    width := (right - left) // 2
    height := bottom - top
    
    WinMove(left + width, top, width, height, hwnd)
}

; Win+Up: 窗口贴上半屏
#Up::{
    hwnd := WinGetID("A")
    if (!hwnd)
        return
    
    MonitorGetWorkArea(, &left, &top, &right, &bottom)
    width := right - left
    height := (bottom - top) // 2
    
    WinMove(left, top, width, height, hwnd)
}

; Win+Down: 窗口贴下半屏
#Down::{
    hwnd := WinGetID("A")
    if (!hwnd)
        return
    
    MonitorGetWorkArea(, &left, &top, &right, &bottom)
    width := right - left
    height := (bottom - top) // 2
    
    WinMove(left, top + height, width, height, hwnd)
}

; ============================================
; 四分屏快捷键
; ============================================

; Win+Numpad7: 左上角
#Numpad7::{
    MoveWindowToQuarter("LeftTop")
}

; Win+Numpad9: 右上角
#Numpad9::{
    MoveWindowToQuarter("RightTop")
}

; Win+Numpad1: 左下角
#Numpad1::{
    MoveWindowToQuarter("LeftBottom")
}

; Win+Numpad3: 右下角
#Numpad3::{
    MoveWindowToQuarter("RightBottom")
}

; Win+Numpad5: 居中显示
#Numpad5::{
    CenterWindow()
}

; ============================================
; 窗口位置和大小保存/恢复
; ============================================

; Ctrl+Win+S: 保存当前窗口位置
^#s::{
    hwnd := WinGetID("A")
    if (!hwnd)
        return
    
    WinGetPos(&x, &y, &width, &height, hwnd)
    title := WinGetTitle(hwnd)
    
    g_SavedWindows[hwnd] := {
        x: x,
        y: y,
        width: width,
        height: height,
        title: title
    }
    
    TrayTip(title, "窗口位置已保存", "Iconi")
}

; Ctrl+Win+R: 恢复窗口位置
^#r::{
    hwnd := WinGetID("A")
    if (!hwnd)
        return
    
    if (g_SavedWindows.Has(hwnd)) {
        saved := g_SavedWindows[hwnd]
        WinMove(saved.x, saved.y, saved.width, saved.height, hwnd)
        TrayTip(saved.title, "窗口位置已恢复", "Iconi")
    } else {
        TrayTip("请先按Ctrl+Win+S保存", "未找到保存的位置", "Icon!")
    }
}

; ============================================
; 窗口透明度控制
; ============================================

; Ctrl+Win+WheelUp: 增加透明度
^#WheelUp::{
    MouseGetPos(,, &hwnd)
    transparency := WinGetTransparent(hwnd)
    
    if (transparency = "")
        transparency := 255
    
    transparency := Min(255, transparency + 25)
    WinSetTransparent(transparency, hwnd)
}

; Ctrl+Win+WheelDown: 减少透明度
^#WheelDown::{
    MouseGetPos(,, &hwnd)
    transparency := WinGetTransparent(hwnd)
    
    if (transparency = "")
        transparency := 255
    
    transparency := Max(50, transparency - 25)
    WinSetTransparent(transparency, hwnd)
}

; Ctrl+Win+T: 重置透明度
^#t::{
    hwnd := WinGetID("A")
    WinSetTransparent("Off", hwnd)
    TrayTip("", "透明度已重置", "Iconi")
}

; ============================================
; 窗口置顶控制
; ============================================

; Ctrl+Win+Space: 切换窗口置顶
^#Space::{
    hwnd := WinGetID("A")
    if (!hwnd)
        return
    
    ; 获取当前置顶状态
    exStyle := WinGetExStyle(hwnd)
    isAlwaysOnTop := (exStyle & 0x8) != 0  ; WS_EX_TOPMOST = 0x8
    
    if (isAlwaysOnTop) {
        WinSetAlwaysOnTop(false, hwnd)
        TrayTip(WinGetTitle(hwnd), "窗口置顶已取消", "Iconi")
    } else {
        WinSetAlwaysOnTop(true, hwnd)
        TrayTip(WinGetTitle(hwnd), "窗口已置顶", "Iconi")
    }
}

; ============================================
; 虚拟桌面切换（Windows 10/11）
; ============================================

; Ctrl+Win+Left: 切换到左边虚拟桌面
^#Left::{
    Send("^#{Left}")
}

; Ctrl+Win+Right: 切换到右边虚拟桌面
^#Right::{
    Send("^#{Right}")
}

; ============================================
; 窗口组管理
; ============================================

; Ctrl+Win+G: 将当前窗口加入组
^#g::{
    InputBox := InputBox("请输入组名（如：work, game, dev）", "添加到窗口组", "w300 h100")
    
    if (InputBox.Result = "OK" && InputBox.Value != "") {
        groupName := InputBox.Value
        hwnd := WinGetID("A")
        title := WinGetTitle(hwnd)
        
        if (!g_WindowGroups.Has(groupName)) {
            g_WindowGroups[groupName] := []
        }
        
        g_WindowGroups[groupName].Push({
            hwnd: hwnd,
            title: title
        })
        
        TrayTip(title . " → " . groupName, "已添加到组", "Iconi")
    }
}

; Ctrl+Win+H: 隐藏组内所有窗口
^#h::{
    InputBox := InputBox("请输入要隐藏的组名", "隐藏窗口组", "w300 h100")
    
    if (InputBox.Result = "OK" && InputBox.Value != "") {
        groupName := InputBox.Value
        
        if (g_WindowGroups.Has(groupName)) {
            for window in g_WindowGroups[groupName] {
                try {
                    WinMinimize(window.hwnd)
                }
            }
            TrayTip(groupName, "窗口组已隐藏", "Iconi")
        } else {
            TrayTip(groupName, "组不存在", "Icon!")
        }
    }
}

; Ctrl+Win+U: 显示组内所有窗口
^#u::{
    InputBox := InputBox("请输入要显示的组名", "显示窗口组", "w300 h100")
    
    if (InputBox.Result = "OK" && InputBox.Value != "") {
        groupName := InputBox.Value
        
        if (g_WindowGroups.Has(groupName)) {
            for window in g_WindowGroups[groupName] {
                try {
                    WinRestore(window.hwnd)
                    WinActivate(window.hwnd)
                }
            }
            TrayTip(groupName, "窗口组已显示", "Iconi")
        } else {
            TrayTip(groupName, "组不存在", "Icon!")
        }
    }
}

; ============================================
; 快速切换常用程序
; ============================================

; Alt+1: 切换到浏览器
!1::{
    if WinExist("ahk_class Chrome_WidgetWin_1") || WinExist("ahk_class MozillaWindowClass") {
        WinActivate()
    } else {
        Run("chrome.exe")
    }
}

; Alt+2: 切换到VS Code
!2::{
    if WinExist("ahk_exe Code.exe") {
        WinActivate()
    } else {
        Run("code")
    }
}

; Alt+3: 切换到文件管理器
!3::{
    if WinExist("ahk_class CabinetWClass") {
        WinActivate()
    } else {
        Run("explorer")
    }
}

; ============================================
; 辅助函数
; ============================================

; 移动窗口到四分之一屏幕
MoveWindowToQuarter(position) {
    hwnd := WinGetID("A")
    if (!hwnd)
        return
    
    MonitorGetWorkArea(, &left, &top, &right, &bottom)
    width := (right - left) // 2
    height := (bottom - top) // 2
    
    switch position {
        case "LeftTop":
            WinMove(left, top, width, height, hwnd)
        case "RightTop":
            WinMove(left + width, top, width, height, hwnd)
        case "LeftBottom":
            WinMove(left, top + height, width, height, hwnd)
        case "RightBottom":
            WinMove(left + width, top + height, width, height, hwnd)
    }
}

; 居中显示窗口
CenterWindow() {
    hwnd := WinGetID("A")
    if (!hwnd)
        return
    
    ; 获取窗口大小
    WinGetPos(,, &winWidth, &winHeight, hwnd)
    
    ; 获取显示器工作区域
    MonitorGetWorkArea(, &left, &top, &right, &bottom)
    monWidth := right - left
    monHeight := bottom - top
    
    ; 计算居中位置
    x := left + (monWidth - winWidth) // 2
    y := top + (monHeight - winHeight) // 2
    
    WinMove(x, y,,, hwnd)
}

; ============================================
; 启动提示
; ============================================

TrayTip("按Win+F2查看帮助", "窗口管理脚本已启动", "Iconi")

; Win+F2: 显示帮助
#F2::{
    helpText := "
    (
    === 窗口管理快捷键 ===
    
    【分屏布局】
    Win+左/右箭头: 左/右半屏
    Win+上/下箭头: 上/下半屏
    Win+数字键7/9/1/3: 四分屏
    Win+数字键5: 居中显示
    
    【窗口控制】
    Ctrl+Win+Space: 窗口置顶
    Ctrl+Win+T: 重置透明度
    Ctrl+Win+鼠标滚轮: 调整透明度
    
    【位置管理】
    Ctrl+Win+S: 保存窗口位置
    Ctrl+Win+R: 恢复窗口位置
    
    【窗口组】
    Ctrl+Win+G: 添加到组
    Ctrl+Win+H: 隐藏组
    Ctrl+Win+U: 显示组
    
    【快速切换】
    Alt+1: 浏览器
    Alt+2: VS Code
    Alt+3: 文件管理器
    
    【虚拟桌面】
    Ctrl+Win+左/右: 切换虚拟桌面
    )"
    
    MsgBox(helpText, "窗口管理帮助", "Icon?")
}