# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

这是一个AutoHotkey v2脚本集合项目，包含5个功能模块脚本和一个升级版的UGit自动化工具。老王出品，保证能跑不报错。

## 核心架构

### 脚本架构模式
所有脚本都遵循统一的架构模式：
```autohotkey
; 头部：版本要求和配置
#Requires AutoHotkey v2.0
#SingleInstance Force
SendMode "Input"
SetWorkingDir A_ScriptDir

; 全局变量区（如需要）
global g_VariableName := value

; 热键定义区
^!key::FunctionName()

; 函数定义区
FunctionName() {
    ; 实现
}

; 帮助系统
#F[N]::ShowHelp()
```

### 核心设计原则
1. **统一错误处理**：使用try-catch包装所有可能出错的操作
2. **配置持久化**：重要配置保存到.ini文件中
3. **用户友好提示**：所有操作都有TrayTip反馈
4. **帮助系统**：每个脚本都有Win+F[N]快捷键显示帮助

## 常用开发命令

### 脚本运行
```bash
# 运行单个脚本
双击 .ahk 文件

# 编译脚本为exe
"C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe" /in script.ahk /out script.exe
```

### 调试命令
```autohotkey
; 调试输出
OutputDebug("调试信息: " . variable)

; 临时消息
TrayTip("标题", "内容", "Iconi")

; 断点调试
MsgBox("调试点: " . A_LineNumber)
```

## 文件结构

### 核心脚本文件
- `1_基础热键.ahk` - 基础热键和快速启动功能
- `2_文本扩展.ahk` - 文本替换和模板系统
- `3_窗口管理.ahk` - 窗口布局和管理功能
- `4_鼠标自动化.ahk` - 鼠标增强和自动化
- `5_ugit自动化.ahk` - UGit基础自动化功能
- `ugit_pro_upgrade.ahk` - UGit Pro版（六层智能检测系统）

### 配置和文档
- `AHK_最佳实践指南.md` - 完整的AHK v2开发规范和最佳实践
- `README.md` - 用户使用手册
- `ugit_config.ini` - UGit自动化配置文件（运行时生成）

## AutoHotkey v2 关键语法要点

### 必须遵循的语法规则
```autohotkey
; ✅ 正确语法 (v2)
Send("Hello World")           ; 字符串必须用引号
MsgBox("内容", "标题", "选项")   ; 函数必须用括号
myVar := "value"              ; 变量赋值用 :=
WinActivate(hwnd)             ; 变量不需要%包裹

; ❌ 错误语法 (v1风格)
Send Hello World              ; 缺少引号
MsgBox, Hello, Title          ; 缺少括号
myVar = value                 ; 错误的赋值符号
WinActivate, %hwnd%           ; 多余的%符号
```

### TrayTip函数正确用法
```autohotkey
; v2正确语法：TrayTip(Text, Title, Options)
TrayTip("消息内容", "标题", "Iconi")    ; 信息图标
TrayTip("警告内容", "标题", "Icon!")    ; 警告图标
TrayTip("错误内容", "标题", "Iconx")    ; 错误图标
```

### 常见错误处理模式
```autohotkey
try {
    ; 可能出错的操作
    result := SomeFunction()
} catch Error as err {
    TrayTip("操作失败", err.message, "Icon!")
    return false
}
```

## UGit自动化特殊架构

### 智能检测层级系统
`ugit_pro_upgrade.ahk` 实现了六层检测系统，按成功率排序：

1. **保存位置** - 使用历史成功位置
2. **控件ID检测** - 通过控件ID和文本识别
3. **智能区域扫描** - 在UI关键区域扫描按钮
4. **快捷键检测** - 尝试标准快捷键组合
5. **Tab导航** - 通过Tab键导航到按钮
6. **通用点击** - 最后的备用方案

### 配置文件格式
```ini
CommitButtonX=1234
CommitButtonY=567
Found=true
LastMethod=保存位置
SaveTime=20240127143022
Success_保存位置=15
Success_控件ID检测=8
```

## 开发注意事项

### 代码风格要求
- **无注释原则**：除非用户明确要求，否则不添加代码注释
- **函数命名**：使用PascalCase，如 `GetWindowInfo()`
- **变量命名**：全局变量使用 `g_` 前缀，如 `g_WindowList`
- **错误处理**：所有可能失败的操作都要用try-catch包装

### 热键冲突避免
```autohotkey
; 使用条件热键避免冲突
#HotIf WinActive("ahk_exe notepad.exe")
^s::Send("自定义保存操作")
#HotIf

; 检查窗口类型再执行
^Enter::{
    if (IsTargetWindow()) {
        CustomAction()
    } else {
        Send("^Enter")  ; 发送原始快捷键
    }
}
```

### 测试和验证
- 所有热键操作都要有备用方案（发送原始按键）
- UI检测要有多层fallback机制
- 配置文件读写要有异常处理
- 用户反馈要及时（TrayTip提示）

## 性能优化要点

- 使用`CoordMode "Mouse", "Screen"`统一坐标系
- 智能检测中加入适当的Sleep延迟
- 配置文件使用缓存机制避免频繁读写
- UI检测优先使用成功率高的方法

## 故障排除

### 常见问题
1. **语法错误** - 检查是否使用了v1语法
2. **热键冲突** - 使用#HotIf条件限制
3. **权限不足** - 以管理员身份运行
4. **按钮检测失败** - 使用手动定位功能(Ctrl+Alt+C)

### 调试技巧
- 启用调试模式：`Ctrl+Alt+`` (backtick)
- 查看日志文件：`ugit_debug.log`, `ugit_success.log`
- 使用F12查看窗口信息和统计数据