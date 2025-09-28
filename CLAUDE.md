# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

这是一个AutoHotkey v2脚本集合项目，目前包含2个实用工具脚本。老王出品，保证能跑不报错。

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

; 帮助系统和调试功能
```

### 核心设计原则
1. **统一错误处理**：使用try-catch包装所有可能出错的操作
2. **配置持久化**：重要配置保存到.ini文件中
3. **用户友好提示**：所有操作都有TrayTip反馈
4. **无注释代码**：除非明确要求，否则不添加注释

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

## 项目文件结构

### 核心脚本文件（在script目录下）
- `ugit_快捷提交.ahk` - UGit Git客户端自动化脚本，支持智能按钮检测
- `文本扩展.ahk` - 文本自动替换和扩展工具

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

### DllCall调用的正确语法 (重要！)
```autohotkey
; ✅ 正确的DllCall字符串输出处理 (v2标准)
className := Buffer(256)
DllCall("GetClassName", "Ptr", hwnd, "Ptr", className, "Int", 256)
classNameStr := StrGet(className, "UTF-8")

; ✅ 正确的WindowFromPoint调用
hwnd := DllCall("WindowFromPoint", "Int", Round(x), "Int", Round(y), "Ptr")

; ✅ 正确的GetWindowText调用
textLength := DllCall("GetWindowTextLength", "Ptr", hwnd) + 1
buttonText := Buffer(textLength * 2)
DllCall("GetWindowText", "Ptr", hwnd, "Ptr", buttonText, "Int", textLength)
buttonTextStr := StrGet(buttonText, "UTF-8")

; ❌ 错误的v1风格写法
className := ""
DllCall("GetClassName", "Ptr", hwnd, "Str", className, "Int", 256)  ; 错误！
```

### 全局变量正确使用方式
```autohotkey
; ✅ 正确的全局变量重新赋值
^!r::{
    global g_CommitButtonFound, g_SuccessCount
    g_CommitButtonFound := false
    g_SuccessCount := Map()
}

; ❌ 错误的语法
^!r::{
    global g_CommitButtonFound := false  ; 错误！不能在global声明时赋值
    global g_SuccessCount := Map()       ; 错误！
}
```

## UGit自动化脚本架构详解

### 智能检测层级系统
`ugit_快捷提交.ahk` 实现了六层检测系统，按成功率排序：

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

### 核心快捷键
- `Ctrl+Enter`: 智能提交按钮检测和点击
- `Ctrl+Alt+C`: 手动定位提交按钮位置
- `Ctrl+Alt+反引号`: 切换调试模式

## 文本扩展脚本功能

### 文本替换类型
- **开发工具缩写**: `brs`, `nrd`, `prb` 等自动展开为构建命令
- **时间日期**: `/date`, `/time`, `/now` 生成各种格式时间
- **UUID生成**: `/uuid` 生成标准UUID
- **代码片段**: 常用代码模板快速插入

### 扩展语法
```autohotkey
; 基础替换（输入后空格触发）
::缩写::展开内容

; 函数式替换（即时触发）
::/command::{
    result := ProcessFunction()
    Send(result)
}
```

## 开发注意事项

### 代码风格要求
- **函数命名**：使用PascalCase，如 `GetWindowInfo()`
- **变量命名**：全局变量使用 `g_` 前缀，如 `g_WindowList`
- **错误处理**：所有可能失败的操作都要用try-catch包装
- **配置管理**：使用INI文件保存用户配置

### 热键冲突避免
```autohotkey
; 使用条件热键避免冲突
#HotIf WinActive("ahk_exe ugit.exe")
^Enter::SmartCommit()
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
2. **DllCall报错** - 检查字符串输出是否使用Buffer+StrGet组合
3. **热键冲突** - 使用#HotIf条件限制热键作用范围
4. **权限不足** - 以管理员身份运行脚本
5. **按钮检测失败** - 使用手动定位功能重新配置
6. **全局变量错误** - 检查是否在global声明时赋值

### DllCall常见错误和解决方案
- **字符串输出错误**: 必须使用Buffer+StrGet，不能直接传递字符串变量
- **API参数类型错误**: WindowFromPoint需要两个Int参数，不是Int64
- **内存分配不足**: 字符串Buffer要乘以2（Unicode字符）
- **变量名混用**: 确保使用StrGet后的字符串变量名

### 调试技巧
- UGit脚本：启用调试模式查看检测过程
- 文本扩展：检查替换规则是否正确触发
- 查看配置文件确认设置是否保存成功
- DllCall调试：使用OutputDebug输出API调用结果