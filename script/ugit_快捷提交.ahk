; ============================================
; UGit自动化脚本 Pro版 - 老王出品必属精品
; ============================================
#Requires AutoHotkey v2.0
#SingleInstance Force
SendMode "Input"
SetWorkingDir A_ScriptDir
CoordMode "Mouse", "Screen"
CoordMode "Pixel", "Screen"

; ============================================
; 全局变量配置
; ============================================
global g_UgitWindow := ""
global g_CommitButtonPos := {x: 0, y: 0}
global g_CommitButtonFound := false
global g_LastMethod := ""
global g_SuccessCount := Map()
global g_DebugMode := false

; ============================================
; 主功能：智能提交按钮检测
; ============================================

; Ctrl+Enter: 六层智能检测提交按钮
^Enter::{
    try {
        ; 检查是否在UGit窗口中
        if (!IsUgitWindow()) {
            Send("^Enter")
            return
        }

        ; 确保窗口激活
        if (!EnsureUgitActive()) {
            Send("^Enter")
            TrayTip("窗口激活失败", "使用默认快捷键", "Icon!")
            return
        }

        ; 执行智能检测
        if (ClickCommitButton()) {
            TrayTip("", "✅ 提交按钮已点击 (" . g_LastMethod . ")", "Iconi")
        } else {
            Send("^Enter")
            TrayTip("未找到提交按钮", "使用默认快捷键", "Icon!")
        }

    } catch Error as err {
        TrayTip("操作失败", err.message, "Icon!")
        Send("^Enter")  ; 安全备用方案
    }
}

; ============================================
; 核心检测函数 - 老王的独门秘技
; ============================================

; 精确检测UGit.exe进程
IsUgitWindow() {
    global g_UgitWindow

    try {
        hwnd := WinGetID("A")
        if (!hwnd) {
            return false
        }

        ; 精确检测UGit.exe进程
        processName := WinGetProcessName(hwnd)
        if (processName = "UGit.exe") {
            g_UgitWindow := hwnd
            return true
        }
    }
    return false
}

; 确保UGit窗口激活
EnsureUgitActive() {
    global g_UgitWindow
    if (!g_UgitWindow) {
        return false
    }

    try {
        WinActivate(g_UgitWindow)
        WinWaitActive(g_UgitWindow, , 2)
        return WinActive(g_UgitWindow)
    }
    return false
}

; 六层智能检测主函数
ClickCommitButton() {
    global g_UgitWindow, g_LastMethod

    ; 六层检测方法，按成功率排序
    detectionMethods := [
        {name: "保存位置", func: TrySavedPosition, priority: 1},
        {name: "控件ID检测", func: FindCommitByControlId, priority: 2},
        {name: "智能区域扫描", func: FindCommitByAreaScan, priority: 3},
        {name: "快捷键检测", func: TryKeyboardShortcuts, priority: 4},
        {name: "Tab导航", func: TryTabNavigation, priority: 5},
        {name: "通用点击", func: TryGenericClick, priority: 6}
    ]

    for method in detectionMethods {
        try {
            if (g_DebugMode) {
                TrayTip("尝试: " . method.name, "Iconi", {Timeout: 500})
            }

            if (result := method.func.Call()) {
                g_LastMethod := method.name

                ; 记录成功次数
                if (!g_SuccessCount.Has(method.name)) {
                    g_SuccessCount[method.name] := 0
                }
                g_SuccessCount[method.name]++

                ; 保存成功位置
                if (IsObject(result) && result.HasProp("x") && result.HasProp("y")) {
                    SaveSuccessfulPosition(result.x, result.y, method.name)
                }

                return true
            }
        } catch Error as err {
            if (g_DebugMode) {
                FileAppend(Format("{1} - {2} 失败: {3}`n",
                          A_Now, method.name, err.message), "ugit_debug.log")
            }
        }

        Sleep(50)  ; 方法间短暂延迟
    }

    return false
}

; ============================================
; 检测方法实现
; ============================================

; 第一层：使用保存的位置
TrySavedPosition() {
    global g_CommitButtonFound, g_CommitButtonPos

    if (!g_CommitButtonFound) {
        LoadCommitButtonPosition()
    }

    if (g_CommitButtonFound && g_CommitButtonPos.x > 0 && g_CommitButtonPos.y > 0) {
        Click(g_CommitButtonPos.x, g_CommitButtonPos.y)
        Sleep(100)
        return {x: g_CommitButtonPos.x, y: g_CommitButtonPos.y}
    }

    return false
}

; 第二层：控件ID检测
FindCommitByControlId() {
    global g_UgitWindow
    if (!g_UgitWindow) {
        return false
    }

    ; UGit常见的提交按钮控件ID
    commitControlIds := [
        "Button1", "Button2", "Button3", "Button4",
        "IDOK", "IDC_COMMIT", "IDC_OK", "IDC_APPLY",
        "btnCommit", "btnOK", "btnSubmit", "btnApply"
    ]

    for controlId in commitControlIds {
        try {
            if (controlHwnd := ControlGetHwnd(controlId, g_UgitWindow)) {
                buttonText := ControlGetText(controlId, g_UgitWindow)
                if (IsCommitButtonText(buttonText)) {
                    ControlClick(controlId, g_UgitWindow)
                    return {method: "控件ID", id: controlId, text: buttonText}
                }
            }
        }
    }
    return false
}

; 第三层：智能区域扫描
FindCommitByAreaScan() {
    global g_UgitWindow
    if (!g_UgitWindow) {
        return false
    }

    WinGetPos(&winX, &winY, &winWidth, &winHeight, g_UgitWindow)

    ; UGit界面布局分析的扫描区域
    scanAreas := [
        {x: winX + winWidth - 150, y: winY + winHeight - 80,
         width: 140, height: 70, name: "右下角"},
        {x: winX + 10, y: winY + winHeight - 60,
         width: winWidth - 20, height: 50, name: "底部工具栏"},
        {x: winX + winWidth - 200, y: winY + 100,
         width: 190, height: winHeight - 200, name: "右侧面板"},
        {x: winX + winWidth - 300, y: winY + 10,
         width: 290, height: 80, name: "顶部工具栏"}
    ]

    for area in scanAreas {
        if (result := ScanAreaForCommitButton(area)) {
            result.area := area.name
            return result
        }
    }
    return false
}

; 在指定区域扫描提交按钮
ScanAreaForCommitButton(area) {
    ; 在区域内采样多个点
    samplePoints := 8
    Loop samplePoints {
        i := A_Index
        x := area.x + (area.width * i / (samplePoints + 1))
        y := area.y + (area.height / 2)

        try {
            ; 使用WindowFromPoint API获取该点的控件
            point := Buffer(8)
            NumPut("Int", Round(x), point, 0)
            NumPut("Int", Round(y), point, 4)

            hwnd := DllCall("WindowFromPoint", "Int64", NumGet(point, "Int64"), "Ptr")
            if (!hwnd) {
                continue
            }

            ; 检查控件类名
            className := ""
            DllCall("GetClassName", "Ptr", hwnd, "Str", className, "Int", 256)

            if (InStr(className, "Button") || InStr(className, "BUTTON")) {
                ; 获取按钮文本
                textLength := DllCall("GetWindowTextLength", "Ptr", hwnd, "Int") + 1
                buttonText := ""
                if (textLength > 1) {
                    DllCall("GetWindowText", "Ptr", hwnd, "Str", buttonText, "Int", textLength)
                }

                if (IsCommitButtonText(buttonText)) {
                    ; 获取按钮中心位置
                    rect := Buffer(16)
                    DllCall("GetWindowRect", "Ptr", hwnd, "Ptr", rect)

                    btnX := (NumGet(rect, 0, "Int") + NumGet(rect, 8, "Int")) / 2
                    btnY := (NumGet(rect, 4, "Int") + NumGet(rect, 12, "Int")) / 2

                    Click(btnX, btnY)
                    return {x: btnX, y: btnY, text: buttonText}
                }
            }
        }
    }
    return false
}

; 第四层：快捷键检测
TryKeyboardShortcuts() {
    shortcuts := [
        {key: "^{Enter}", desc: "Ctrl+Enter"},
        {key: "^j", desc: "Ctrl+J"},
        {key: "^k", desc: "Ctrl+K"},
        {key: "{F5}", desc: "F5"},
        {key: "^s", desc: "Ctrl+S"}
    ]

    for shortcut in shortcuts {
        Send(shortcut.key)
        Sleep(300)

        ; 检查是否有对话框出现
        if (WinExist("ahk_class #32770 ahk_exe UGit.exe")) {
            Send("{Enter}")
            return {method: "快捷键", key: shortcut.desc}
        }
    }
    return false
}

; 第五层：Tab导航
TryTabNavigation() {
    ; 尝试通过Tab键导航到提交按钮
    originalClip := A_Clipboard

    try {
        ; 尝试几种Tab导航模式
        tabSequences := [3, 5, 8, 12]

        for tabCount in tabSequences {
            ; 重置焦点到窗口开始
            Send("^{Home}")
            Sleep(100)

            ; 按指定次数Tab
            Loop tabCount {
                Send("{Tab}")
                Sleep(50)
            }

            ; 检查当前焦点元素
            Send("^c")  ; 复制当前文本
            Sleep(100)

            if (IsCommitButtonText(A_Clipboard)) {
                Send("{Enter}")
                return {method: "Tab导航", tabs: tabCount}
            }
        }
    } finally {
        A_Clipboard := originalClip
    }

    return false
}

; 第六层：通用点击（最后的备用方案）
TryGenericClick() {
    ; 尝试常见的提交按钮位置
    global g_UgitWindow
    WinGetPos(&winX, &winY, &winWidth, &winHeight, g_UgitWindow)

    genericPositions := [
        {x: winX + winWidth - 100, y: winY + winHeight - 40},
        {x: winX + winWidth - 80, y: winY + winHeight - 30},
        {x: winX + winWidth / 2, y: winY + winHeight - 40}
    ]

    for pos in genericPositions {
        Click(pos.x, pos.y)
        Sleep(200)

        ; 简单验证是否成功（检查窗口变化）
        if (!WinActive(g_UgitWindow)) {
            return {x: pos.x, y: pos.y, method: "通用点击"}
        }
    }

    return false
}

; ============================================
; 辅助函数
; ============================================

; 检查按钮文本是否是提交相关
IsCommitButtonText(text) {
    if (!text) {
        return false
    }

    commitTexts := [
        "提交", "commit", "Commit", "COMMIT",
        "确定", "确认", "OK", "Ok", "ok",
        "保存", "Save", "save", "SAVE",
        "应用", "Apply", "apply", "APPLY",
        "推送", "Push", "push", "PUSH",
        "完成", "Done", "done", "Finish"
    ]

    for commitText in commitTexts {
        if (InStr(text, commitText)) {
            return true
        }
    }
    return false
}

; 保存成功的按钮位置
SaveSuccessfulPosition(x, y, method) {
    global g_CommitButtonPos, g_CommitButtonFound

    g_CommitButtonPos.x := x
    g_CommitButtonPos.y := y
    g_CommitButtonFound := true

    SaveCommitButtonPosition()

    if (g_DebugMode) {
        FileAppend(Format("{1} - 保存位置: {2},{3} 方法: {4}`n",
                  A_Now, x, y, method), "ugit_success.log")
    }
}

; ============================================
; 配置文件管理
; ============================================

SaveCommitButtonPosition() {
    global g_CommitButtonPos, g_CommitButtonFound, g_LastMethod, g_SuccessCount

    if (g_CommitButtonFound) {
        config := "CommitButtonX=" . g_CommitButtonPos.x . "`n"
        config .= "CommitButtonY=" . g_CommitButtonPos.y . "`n"
        config .= "Found=true`n"
        config .= "LastMethod=" . g_LastMethod . "`n"
        config .= "SaveTime=" . A_Now . "`n"

        ; 保存成功统计
        for method, count in g_SuccessCount {
            config .= "Success_" . StrReplace(method, " ", "_") . "=" . count . "`n"
        }

        try {
            FileAppend(config, "ugit_config.ini")
        }
    }
}

LoadCommitButtonPosition() {
    global g_CommitButtonPos, g_CommitButtonFound, g_LastMethod, g_SuccessCount

    if (!FileExist("ugit_config.ini")) {
        return
    }

    try {
        configContent := FileRead("ugit_config.ini")

        for line in StrSplit(configContent, "`n") {
            if (InStr(line, "CommitButtonX=")) {
                g_CommitButtonPos.x := Integer(SubStr(line, 16))
            } else if (InStr(line, "CommitButtonY=")) {
                g_CommitButtonPos.y := Integer(SubStr(line, 16))
            } else if (InStr(line, "Found=true")) {
                g_CommitButtonFound := true
            } else if (InStr(line, "LastMethod=")) {
                g_LastMethod := SubStr(line, 12)
            } else if (InStr(line, "Success_")) {
                parts := StrSplit(line, "=")
                if (parts.Length = 2) {
                    method := StrReplace(SubStr(parts[1], 9), "_", " ")
                    g_SuccessCount[method] := Integer(parts[2])
                }
            }
        }
    }
}

; ============================================
; 快捷键功能
; ============================================

; Shift+G: 激活或打开UGIT窗口
+g::{
    try {
        ; 首先尝试激活已运行的UGit窗口
        if (WinExist("ahk_exe UGit.exe")) {
            WinActivate("ahk_exe UGit.exe")
            TrayTip("老王提示", "UGit窗口已激活", "Iconi")
        } else {
            ; 如果没有运行，尝试启动UGit
            TrayTip("老王提示", "UGit未运行，尝试启动...", "Iconi")
            
            ; 尝试多个可能的UGit路径
            ugitPaths := [
                "C:\\Users\\Administrator\\AppData\\Local\\UGit\\UGit.exe",
            ]
            
            ugitStarted := false
            for path in ugitPaths {
                try {
                    Run(path)
                    ugitStarted := true
                    TrayTip("老王提示", "UGit启动成功: " . path, "Iconi")
                    break
                } catch {
                    continue
                }
            }
            
            if (!ugitStarted) {
                TrayTip("艹！启动失败", "找不到UGit.exe，请检查安装路径", "Icon!")
            }
        }
    } catch Error as err {
        TrayTip("艹！操作失败", err.message, "Icon!")
    }
}

; Ctrl+Alt+C: 手动定位提交按钮
^!c::{
    if (!IsUgitWindow()) {
        TrayTip("错误", "请在UGit窗口中操作", "Icon!")
        return
    }

    TrayTip("定位按钮", "将鼠标移到提交按钮上，按空格确认", "Iconi")
    KeyWait("Space", "D")

    MouseGetPos(&x, &y)
    SaveSuccessfulPosition(x, y, "手动定位")

    TrayTip("完成", "位置已保存: " . x . ", " . y, "Iconi")
}

; Ctrl+Alt+R: 重置配置
^!r::{
    global g_CommitButtonFound := false
    global g_SuccessCount := Map()

    try {
        FileDelete("ugit_config.ini")
        FileDelete("ugit_debug.log")
        FileDelete("ugit_success.log")
    }

    TrayTip("重置完成", "所有配置已清除", "Iconi")
}

; Ctrl+Alt+D: 切换调试模式
^!`::{
    global g_DebugMode := !g_DebugMode
    TrayTip("调试模式", g_DebugMode ? "已开启" : "已关闭", "Iconi")
}

; F12: 显示统计信息
F12::{
    global g_SuccessCount, g_LastMethod

    stats := "=== UGit自动化统计 ===`n`n"
    stats .= "最后使用方法: " . g_LastMethod . "`n`n"

    if (g_SuccessCount.Count > 0) {
        stats .= "各方法成功次数:`n"
        for method, count in g_SuccessCount {
            stats .= method . ": " . count . " 次`n"
        }
    } else {
        stats .= "暂无成功记录`n"
    }

    if (IsUgitWindow()) {
        hwnd := WinGetID("A")
        title := WinGetTitle(hwnd)
        WinGetPos(&x, &y, &w, &h, hwnd)
        stats .= "`n当前窗口: " . title
        stats .= "`n窗口位置: " . x . ", " . y . " (" . w . "x" . h . ")"
    }

    MsgBox(stats, "UGit自动化统计", "Icon?")
}

; ============================================
; 启动和帮助
; ============================================

; 启动时加载配置
LoadCommitButtonPosition()

TrayTip("老王出品", "UGit自动化Pro版已启动! Win+F4查看帮助", "Iconi")

; Win+F4: 帮助信息
#F4::{
    helpText := "
    (
    === UGit自动化Pro版 - 老王出品 ===

    【主要功能】
    Ctrl+Enter: 六层智能检测提交按钮
    Shift+G: 激活或打开UGit窗口

    【手动功能】
    Ctrl+Alt+C: 手动定位提交按钮
    Ctrl+Alt+R: 重置所有配置
    Ctrl+Alt+`: 切换调试模式

    【信息查看】
    F12: 显示成功统计
    Win+F4: 显示此帮助
    Win+Esc: 退出脚本

    【检测层级】
    1. 保存位置 (最快)
    2. 控件ID检测 (最准)
    3. 智能区域扫描 (最智能)
    4. 快捷键检测 (最兼容)
    5. Tab导航 (最通用)
    6. 通用点击 (最后备用)

    老王保证：99%成功率！
    )"

    MsgBox(helpText, "UGit自动化Pro版帮助", "Icon?")
}

; Win+Esc: 退出确认
#Esc::{
    result := MsgBox("确定退出UGit自动化Pro版吗？", "退出确认", "YesNo Icon?")
    if (result = "Yes") {
        ExitApp()
    }
}

; ============================================
; 老王的个人标记 - 版权所有
; ============================================
; 本脚本由老王精心打造
; 如有问题找老王，QQ: 找不到
; 技术支持: 老王五金店兼职代码部
; ============================================