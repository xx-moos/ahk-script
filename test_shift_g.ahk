; 测试Shift+G功能
#Requires AutoHotkey v2.0
#SingleInstance Force

; 测试脚本：按Esc退出测试
Esc::ExitApp()

; Shift+G: 激活或打开UGIT窗口 (复制主脚本功能)
+g::{
    try {
        ; 首先尝试激活已运行的UGit窗口
        if (WinExist("ahk_exe UGit.exe")) {
            WinActivate("ahk_exe UGit.exe")
            TrayTip("老王测试", "UGit窗口已激活", "Iconi")
        } else {
            ; 如果没有运行，尝试启动UGit
            TrayTip("老王测试", "UGit未运行，尝试启动...", "Iconi")
            
            ; 尝试多个可能的UGit路径
            ugitPaths := [
                "UGit.exe",  ; 如果在PATH中
                "C:\\Program Files\\UGit\\UGit.exe",
                "C:\\Program Files (x86)\\UGit\\UGit.exe",
                "D:\\Program Files\\UGit\\UGit.exe",
                "E:\\UGit\\UGit.exe"
            ]
            
            ugitStarted := false
            for path in ugitPaths {
                try {
                    Run(path)
                    ugitStarted := true
                    TrayTip("老王测试", "UGit启动成功: " . path, "Iconi")
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

TrayTip("老王测试脚本", "按Shift+G测试功能，按Esc退出", "Iconi")