; ============================================
; 文本扩展和自动替换脚本 - 打字神器
; ============================================
#Requires AutoHotkey v2.0
#SingleInstance Force
SendMode "Input"
SetWorkingDir A_ScriptDir

; ============================================
; 基础文本替换（输入后空格触发）
; ============================================

; 常用缩写
::brs::bun run start
::brd::bun run dev
::brb::bun run build

::nrs::npm run start
::nrd::npm run dev
::nrb::npm run build

::prs::pnpm run start
::prd::pnpm run dev
::prb::pnpm run build


; /uuid - 生成UUID
::/uuid::{
    uuid := GenerateUUID()
    Send(uuid)
}

; /random - 生成随机数
::/random::{
    random := Random(100000, 999999)
    Send(String(random))
}



; ============================================
; 辅助函数
; ============================================

; 生成UUID
GenerateUUID() {
    uuid := ""
    Loop 32 {
        if (A_Index = 9 || A_Index = 14 || A_Index = 19 || A_Index = 24) {
            uuid .= "-"
        }
        uuid .= Format("{:x}", Random(0, 15))
    }
    return uuid
}

; Ctrl+Alt+H: 显示帮助
^!h::{
    helpText := "
    (
    文本扩展帮助
    brd -> bun run dev
    brb -> bun run build
    brs -> bun run start

    nrs -> npm run start
    nrd -> npm run dev
    nrb -> npm run build
    
    prs -> pnpm run start
    prd -> pnpm run dev
    prb -> pnpm run build
    
    /uuid -> 生成UUID
    /random -> 生成随机数
    )"
    
    MsgBox(helpText, "文本扩展帮助", "Icon?")
}

; 启动提示
TrayTip("按Ctrl+Alt+H查看帮助", "文本扩展脚本已启动", "Iconi")