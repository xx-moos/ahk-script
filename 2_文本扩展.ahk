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
::btw::by the way
::asap::as soon as possible
::fyi::for your information
::imo::in my opinion
::afaik::as far as I know
::tbd::to be determined
::eta::estimated time of arrival
::brb::bun run build

; 中文快速输入
::nh::你好
::zj::再见
::xbb::不好意思
::xx::谢谢
::bk::不客气
::hhh::哈哈哈
::wg::我感觉
::wjj::我觉得
::wt::问题
::jj::解决

; ============================================
; 智能日期时间插入
; ============================================

; /td - 今天日期
::/td::{
    Send(FormatTime(, "yyyy-MM-dd"))
}

; /tm - 明天日期
::/tm::{
    tomorrow := DateAdd(A_Now, 1, "Days")
    Send(FormatTime(tomorrow, "yyyy-MM-dd"))
}

; /yt - 昨天日期
::/yt::{
    yesterday := DateAdd(A_Now, -1, "Days")
    Send(FormatTime(yesterday, "yyyy-MM-dd"))
}

; /now - 当前时间
::/now::{
    Send(FormatTime(, "yyyy-MM-dd HH:mm:ss"))
}

; /time - 当前时间（仅时分秒）
::/time::{
    Send(FormatTime(, "HH:mm:ss"))
}

; /week - 当前星期
::/week::{
    weekDays := ["星期日", "星期一", "星期二", "星期三", "星期四", "星期五", "星期六"]
    Send(weekDays[A_WDay])
}

; ============================================
; 邮件模板
; ============================================

; /sig - 邮件签名
::/sig::{
    signature := "
    (
Best regards,
张三
软件工程师
邮箱: zhangsan@example.com
电话: 138-0013-8000
    )"
    Send(signature)
}

; /thank - 感谢邮件
::/thank::{
    thankYou := "
    (
您好，

感谢您的邮件。我已经收到并会尽快处理。

如有紧急事项，请直接联系我。
    )"
    Send(thankYou)
}

; /meeting - 会议邀请
::/meeting::{
    meeting := "
    (
您好，

诚邀您参加以下会议：

时间：[请填写时间]
地点：[请填写地点]
议题：[请填写议题]

请确认是否能够参加，谢谢！
    )"
    Send(meeting)
}

; ============================================
; 代码片段快速输入
; ============================================

; /py - Python主函数模板
::/py::{
    pythonTemplate := '
    (
def main():
    """主函数"""
    pass

if __name__ == "__main__":
    main()
    )'
    Send(pythonTemplate)
}

; /js - JavaScript函数模板
::/js::{
    jsTemplate := "
    (
function functionName(params) {
    // TODO: 实现功能
    return null;
}
    )"
    Send(jsTemplate)
}

; /html - HTML5模板
::/html::{
    htmlTemplate := '
    (
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document</title>
</head>
<body>
    
</body>
</html>
    )'
    Send(htmlTemplate)
}

; /css - CSS类模板
::/css::{
    cssTemplate := "
    (
.className {
    /* 样式属性 */
    margin: 0;
    padding: 0;
}
    )"
    Send(cssTemplate)
}

; ============================================
; 特殊字符快速输入
; ============================================

; 数学符号
::!=::≠
::<=::≤
::>=::≥
::+-::±
::inf::∞
::sqrt::√
::pi::π
::sum::∑
::delta::Δ

; 箭头符号
::->>::→
::<->::←
::^>::↑
::v>::↓
::<->>::↔

; 表情符号
:::)::😊
:::(::😔
:::D::😃
:::P::😛
:::o::😮
:::|::😐
::-_-::😑
::^_^::😄

; ============================================
; 动态文本扩展
; ============================================

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

; /lorem - Lorem Ipsum占位文本
::/lorem::{
    lorem := "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
    Send(lorem)
}

; ============================================
; 网址快速输入
; ============================================

; 常用网站
::/gh::https://github.com/
::/gg::https://www.google.com/
::/bd::https://www.baidu.com/
::/so::https://stackoverflow.com/
::/yt::https://www.youtube.com/
::/bili::https://www.bilibili.com/

; ============================================
; 特殊功能热字符串
; ============================================

; 自动纠正常见拼写错误
::teh::the
::recieve::receive
::occured::occurred
::seperate::separate
::definately::definitely
::accomodate::accommodate
::untill::until
::wich::which
::alot::a lot

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

; ============================================
; 配置和帮助
; ============================================

; 设置热字符串选项
#Hotstring EndChars `t`n.,;!?  ; 设置触发字符
#Hotstring O  ; 删除触发字符（Omit ending character）

; Ctrl+Alt+H: 显示帮助
^!h::{
    helpText := "
    (
    === 文本扩展快捷键 ===
    
    【常用缩写】
    btw → by the way
    asap → as soon as possible
    fyi → for your information
    
    【中文快输】
    nh → 你好
    zj → 再见
    xx → 谢谢
    
    【日期时间】
    /td → 今天日期
    /tm → 明天日期
    /yt → 昨天日期
    /now → 当前时间
    /week → 星期几
    
    【邮件模板】
    /sig → 邮件签名
    /thank → 感谢邮件
    /meeting → 会议邀请
    
    【代码模板】
    /py → Python模板
    /js → JavaScript模板
    /html → HTML5模板
    /css → CSS模板
    
    【特殊字符】
    != → ≠
    <= → ≤
    >= → ≥
    -> → →
    
    【其他功能】
    /uuid → 生成UUID
    /random → 随机数
    /lorem → 占位文本
    
    提示：输入缩写后按空格触发替换
    )"
    
    MsgBox(helpText, "文本扩展帮助", "Icon?")
}

; 启动提示
TrayTip("按Ctrl+Alt+H查看帮助", "文本扩展脚本已启动", "Iconi")