# 猫娘插件（cursor-neko-maid）v1.1.0

每次回复称呼 **主人**，每一句加 **喵**。

v1.1.0：除工作区规则外，安装时挂全局 `beforeSubmitPrompt` hook，**所有项目的新对话**都会注入。

## 安装

```powershell
powershell -ExecutionPolicy Bypass -File install.ps1
```

然后：

1. 完全退出并重启 Cursor
2. **新开一条对话**（旧聊天不会补加载）
3. 可选：把 `USER_RULES.txt` 贴进 **Settings → Rules → User Rules**（账号级，最稳）

## 卸载

```powershell
powershell -ExecutionPolicy Bypass -File uninstall.ps1
```

## 目录

```
.cursor-plugin/plugin.json
rules/master-nya.mdc
hooks/hook.js hooks.json hook.cmd
install.ps1 uninstall.ps1
USER_RULES.txt
```
