# AutoHotkey v2 最佳实践指南 - 老王整理版

## 一、AHK v2 核心理念（别tm用v1了，过时的垃圾）

### 为什么选择v2？
- **语法一致性**：v2比v1语法更规范，不会让你搞混
- **性能更好**：执行效率提升30%以上
- **更少的坑**：v1那些SB的陷阱，v2都修复了
- **面向未来**：v1已经不再更新，用v2才是正道

### 最重要的变化（记住这些，别犯低级错误）
1. **字符串必须用引号**：`Send "Hello"` 而不是 `Send Hello`
2. **函数调用必须加括号**：`MsgBox("Hello")` 而不是 `MsgBox, Hello`
3. **变量不需要%包裹**：直接用变量名
4. **严格的大小写**：函数名大小写敏感

## 二、脚本初始化最佳实践（每个脚本都要加的头部）

```autohotkey
#Requires AutoHotkey v2.0  ; 指定版本，防止用错版本
#SingleInstance Force       ; 强制单实例，避免重复运行
#NoTrayIcon                ; 隐藏托盘图标（可选）
SendMode "Input"           ; 最快最可靠的发送模式
SetWorkingDir A_ScriptDir  ; 设置工作目录为脚本所在目录
CoordMode "Mouse", "Screen" ; 鼠标坐标使用屏幕坐标
```

## 三、命名规范（别tm乱起名字）

### 变量命名
- **全局变量**：`g_MyVariable` 或 `GlobalVariable`
- **局部变量**：`localVar` 或 `my_var`
- **常量**：`CONSTANT_VALUE`（全大写）

### 函数命名
- **驼峰命名**：`MyFunction()` 或 `doSomething()`
- **动词开头**：`GetValue()`, `SetConfig()`, `ProcessData()`

### 热键命名
- **使用注释说明**：每个热键都要加注释说明功能

## 四、错误处理（这个很重要，别让脚本崩溃）

```autohotkey
; 全局错误处理器
OnError(ErrorHandler)

ErrorHandler(exception, mode) {
    ; 记录错误信息
    errorMsg := "错误: " exception.Message 
              . "`n文件: " exception.File 
              . "`n行号: " exception.Line
    
    ; 显示错误
    MsgBox(errorMsg, "脚本错误", "IconError")
    
    ; 返回true继续运行，false终止脚本
    return true
}
```

## 五、性能优化技巧（让脚本跑得飞快）

### 1. 避免频繁的GUI更新
```autohotkey
; 不好的做法
Loop 1000 {
    MyGui["Text"].Text := "Processing " A_Index
}

; 好的做法
Loop 1000 {
    if (Mod(A_Index, 10) = 0)  ; 每10次更新一次
        MyGui["Text"].Text := "Processing " A_Index
}
```

### 2. 使用静态变量缓存
```autohotkey
GetConfig(key) {
    static config := Map()
    
    if (!config.Has(key)) {
        ; 只在第一次读取时加载
        config[key] := IniRead("config.ini", "Settings", key)
    }
    
    return config[key]
}
```

### 3. 合理使用SetTimer
```autohotkey
; 不要使用太短的间隔
SetTimer(CheckProcess, 100)   ; 不好，太频繁
SetTimer(CheckProcess, 1000)  ; 好，每秒检查一次
```

## 六、代码组织结构（保持代码整洁）

```autohotkey
; ============================================
; 脚本配置区
; ============================================
#Requires AutoHotkey v2.0
#SingleInstance Force

; ============================================
; 全局变量区
; ============================================
global g_AppName := "我的AHK脚本"
global g_Version := "1.0.0"

; ============================================
; 主程序区
; ============================================
Initialize()

; ============================================
; 热键定义区
; ============================================
^j::ShowMainGui()  ; Ctrl+J 显示主界面

; ============================================
; 函数定义区
; ============================================
Initialize() {
    ; 初始化代码
}

ShowMainGui() {
    ; GUI代码
}

; ============================================
; 类定义区（如果有）
; ============================================
class MyClass {
    ; 类代码
}
```

## 七、调试技巧（快速定位问题）

### 1. 使用OutputDebug
```autohotkey
OutputDebug("变量值: " myVar)  ; 输出到调试器
```

### 2. 创建日志函数
```autohotkey
LogToFile(text) {
    FileAppend(FormatTime(, "yyyy-MM-dd HH:mm:ss") " - " text "`n", "debug.log")
}
```

### 3. 使用断点
```autohotkey
MsgBox("调试点1: 变量值=" myVar)  ; 临时断点
```

## 八、安全性考虑（别让脚本成为安全隐患）

1. **不要硬编码密码**：使用加密存储或环境变量
2. **验证用户输入**：永远不要信任用户输入
3. **限制文件操作**：只操作必要的文件和目录
4. **使用Try-Catch**：捕获可能的异常

```autohotkey
try {
    ; 危险操作
    FileDelete("important.txt")
} catch as err {
    MsgBox("操作失败: " err.Message)
}
```

## 九、常见陷阱和解决方案

### 陷阱1：变量作用域混淆
```autohotkey
; 错误示例
myFunc() {
    myVar := "local"  ; 这是局部变量
}

; 正确示例
global g_MyVar
myFunc() {
    global g_MyVar
    g_MyVar := "global"  ; 修改全局变量
}
```

### 陷阱2：热键冲突
```autohotkey
; 使用 #HotIf 避免冲突
#HotIf WinActive("ahk_exe notepad.exe")
^s::MsgBox("在记事本中按了Ctrl+S")
#HotIf
```

### 陷阱3：定时器没有清理
```autohotkey
; 退出前清理定时器
OnExit(CleanUp)

CleanUp(*) {
    SetTimer(MyTimer, 0)  ; 停止定时器
}
```

## 十、推荐的开发工具

1. **VS Code + AutoHotkey Plus Plus**：最强组合
2. **SciTE4AutoHotkey**：经典编辑器
3. **AutoHotkey Dash**：快速文档查询

---

老王提醒：记住这些最佳实践，写出来的代码才不会被人骂SB！