# BrewSession Built-in Commands TODO

更新时间：2026-05-23

范围：`brew commands` 中的 **Built-in commands**（不含 Built-in developer commands）

约定：

- `[x]` 表示该命令形态在 BrewSession 中已可调用
- `[ ]` 表示该命令形态在 BrewSession 中仍待补齐

## --cache

说明：获取 Homebrew 缓存路径

- [x] `brew --cache`：输出 Homebrew 全局缓存目录路径。
- [x] `brew --cache <formula|cask>`：输出指定 formula/cask 的缓存文件路径。

## --caskroom

说明：获取 Cask 安装根目录

- [x] `brew --caskroom`：输出 Caskroom 根目录路径。

## --cellar

说明：获取 Cellar 根目录

- [x] `brew --cellar`：输出 Cellar 根目录路径。
- [x] `brew --cellar <formula>`：输出指定 formula 在 Cellar 下的安装路径。

## --env

说明：输出 brew 运行环境

- [x] `brew --env`：输出 Homebrew 运行时环境信息。
- [ ] `brew --env --shell=<shell>`：按指定 shell 形式输出环境信息。
- [ ] `brew --env --plain`：输出更精简的环境信息文本。

## --prefix

说明：获取 Homebrew 前缀目录

- [x] `brew --prefix`：输出 Homebrew 前缀路径。
- [x] `brew --prefix <formula>`：输出指定 formula 的安装前缀路径。

## --repository

说明：获取仓库目录

- [x] `brew --repository`：输出 Homebrew 主仓库路径。
- [x] `brew --repository <tap>`：输出指定 tap 的仓库路径。

## --taps

说明：输出已 tap 的仓库名

- [x] `brew --taps`：列出当前已添加的 tap 名称。

## --version

说明：查看 Homebrew 版本

- [x] `brew --version`：输出 Homebrew 版本及相关版本信息。

## alias

说明：管理命令别名

- [x] `brew alias`：列出当前命令别名。
- [ ] `brew alias --edit`：编辑别名配置。

## analytics

说明：管理匿名统计开关

- [x] `brew analytics`：查看 analytics 状态和说明。
- [ ] `brew analytics state`：仅查看当前 analytics 开关状态。
- [ ] `brew analytics on`：开启 analytics。
- [ ] `brew analytics off`：关闭 analytics。

## autoremove

说明：移除不再需要的依赖

- [x] `brew autoremove`：自动移除无反向依赖的包。
- [ ] `brew autoremove --dry-run`：预览将被移除的包但不执行删除。

## bundle

说明：执行 Brewfile 相关操作

- [x] `brew bundle <subcommand>`：执行 bundle 子命令（如 install/dump/cleanup）。
- [ ] `brew bundle install`：按 Brewfile 安装依赖集合。
- [ ] `brew bundle dump`：将当前环境导出为 Brewfile。

## casks

说明：列出可用 cask

- [x] `brew casks`：列出可用的 cask token。

## cleanup

说明：清理旧版本和缓存

- [x] `brew cleanup`：删除旧版本 keg 与过期缓存。
- [ ] `brew cleanup --dry-run`：预览清理结果。
- [ ] `brew cleanup --prune=<days>`：按天数阈值清理缓存。

## command-not-found-init

说明：输出 command-not-found 初始化脚本

- [x] `brew command-not-found-init`：输出 shell 初始化代码以支持命令缺失提示。

## command

说明：定位某个 brew 子命令脚本

- [x] `brew command <cmd>`：输出指定 brew 子命令对应脚本路径。

## commands

说明：列出命令清单

- [x] `brew commands`：列出内置命令和开发者命令。
- [ ] `brew commands --quiet`：仅输出命令名。
- [ ] `brew commands --include-aliases`：输出时包含别名。

## completions

说明：管理 shell 自动补全

- [x] `brew completions <subcommand>`：管理补全脚本（link/unlink/state）。
- [ ] `brew completions state`：查看补全状态。
- [ ] `brew completions link`：安装补全链接。

## config

说明：查看 Homebrew 配置

- [x] `brew config`：输出当前系统与 Homebrew 配置信息。

## deps

说明：查看依赖关系

- [x] `brew deps <formula>`：列出指定 formula 的依赖。
- [ ] `brew deps --tree <formula>`：以树形显示依赖关系。
- [ ] `brew deps --direct <formula>`：仅显示直接依赖。

## desc

说明：查看包描述

- [x] `brew desc <formula|cask>`：输出包的简要描述。
- [ ] `brew desc --search <text>`：按关键字搜索描述。

## developer

说明：管理开发者模式

- [x] `brew developer`：查看开发者模式说明。
- [ ] `brew developer on`：开启开发者模式。
- [ ] `brew developer off`：关闭开发者模式。

## docs

说明：打开文档入口

- [x] `brew docs`：打开 Homebrew 文档主页。

## doctor

说明：系统健康检查

- [x] `brew doctor`：检查系统环境与 Homebrew 常见问题。

## exec

说明：在 brew 环境中执行外部命令

- [x] `brew exec <command ...>`：带 Homebrew 环境变量执行指定命令。

## fetch

说明：下载源码或瓶子

- [x] `brew fetch <formula|cask>`：下载包资源但不安装。
- [ ] `brew fetch --force <formula|cask>`：强制重新下载。

## formulae

说明：列出可用 formula

- [x] `brew formulae`：列出可用 formula 名称。

## gist-logs

说明：上传日志到 GitHub Gist

- [x] `brew gist-logs <formula|cask>`：收集并上传相关日志，返回 gist 信息。

## help

说明：查看帮助

- [x] `brew help`：查看总体帮助。
- [ ] `brew help <command>`：查看指定命令帮助。

## home

说明：打开项目主页

- [x] `brew home <formula|cask>`：打开包主页链接。

## info

说明：查看包详细信息

- [x] `brew info --json=v2 <formula|cask>`：输出结构化详情（含版本、依赖、安装信息等）。
- [ ] `brew info --json=v2 --installed`：仅输出已安装条目详情。

## install

说明：安装 formula 或 cask

- [x] `brew install <formula|cask>`：安装指定包。
- [ ] `brew install --formula <formula>`：显式按 formula 方式安装。
- [ ] `brew install --cask <cask>`：显式按 cask 方式安装。
- [ ] `brew install --HEAD <formula>`：安装 HEAD 版本。

## leaves

说明：列出叶子包

- [x] `brew leaves`：列出未被其他包依赖的已安装 formula。

## link

说明：链接已安装 formula 到前缀目录

- [x] `brew link <formula>`：创建符号链接使可执行文件可用。
- [ ] `brew link --overwrite <formula>`：覆盖冲突文件后链接。
- [ ] `brew link --dry-run <formula>`：预览链接操作。

## list

说明：列出已安装内容

- [x] `brew list`：列出已安装 formula 与 cask。
- [x] `brew list --formula --versions`：列出已安装 formula 及版本。
- [x] `brew list --cask`：列出已安装 cask。
- [ ] `brew list <formula|cask>`：列出指定包安装的文件。

## log

说明：查看 Git 日志

- [x] `brew log <formula>`：查看 formula 变更日志。
- [ ] `brew log --oneline <formula>`：单行格式输出日志。

## mcp-server

说明：启动 Homebrew MCP 服务

- [x] `brew mcp-server`：启动 Homebrew MCP server。

## migrate

说明：迁移已重命名包

- [x] `brew migrate <formula>`：将已安装包迁移到新名称。

## missing

说明：检查缺失依赖

- [x] `brew missing`：检查已安装包是否存在缺失依赖。

## nodenv-sync

说明：同步 nodenv

- [x] `brew nodenv-sync`：同步 nodenv 与 Homebrew 安装的版本。

## options

说明：查看包可选安装参数

- [x] `brew options <formula>`：显示公式可选参数。
- [ ] `brew options --compact <formula>`：紧凑格式输出选项。

## outdated

说明：列出可升级包

- [x] `brew outdated --json=v2`：结构化输出可升级包列表。
- [ ] `brew outdated --greedy`：包含更多 cask 升级候选。
- [ ] `brew outdated --greedy-auto-updates`：包含自动更新 cask。

## pin

说明：固定包版本

- [x] `brew pin <formula>`：固定公式，避免 upgrade 自动升级。

## postinstall

说明：执行 postinstall 步骤

- [x] `brew postinstall <formula>`：重新运行 formula 的 postinstall 脚本。

## pyenv-sync

说明：同步 pyenv

- [x] `brew pyenv-sync`：同步 pyenv 与 Homebrew 安装的 Python 版本。

## rbenv-sync

说明：同步 rbenv

- [x] `brew rbenv-sync`：同步 rbenv 与 Homebrew 安装的 Ruby 版本。

## readall

说明：批量读取并检查定义文件

- [x] `brew readall`：读取并校验 formula/cask 定义文件。
- [ ] `brew readall --eval-all`：评估更多定义内容并校验。

## reinstall

说明：重新安装包

- [x] `brew reinstall <formula|cask>`：重新安装指定包。

## search

说明：搜索包

- [x] `brew search --formula <query>`：搜索 formula。
- [x] `brew search --cask <query>`：搜索 cask。
- [x] `brew search <query>`：同时搜索 formula 与 cask。

## services

说明：管理后台服务

- [x] `brew services <subcommand>`：执行服务管理子命令。
- [ ] `brew services list`：查看服务状态列表。
- [ ] `brew services start <service>`：启动服务。
- [ ] `brew services stop <service>`：停止服务。

## setup-ruby

说明：设置 Homebrew Ruby 环境

- [x] `brew setup-ruby`：初始化/配置 Homebrew Ruby 开发环境。

## shellenv

说明：输出 shell 环境导出脚本

- [x] `brew shellenv`：输出当前 shell 可执行的环境变量导出片段。

## source

说明：显示包定义源码

- [x] `brew source <formula|cask>`：输出或打开对应包定义源码位置。

## tab

说明：修改安装元数据

- [x] `brew tab <formula|cask>`：操作 tab 元数据。
- [ ] `brew tab --installed-on-request <formula>`：标记为按需安装。
- [ ] `brew tab --no-installed-on-request <formula>`：取消按需安装标记。

## tap-info

说明：查看 tap 信息

- [x] `brew tap-info <tap>`：查看 tap 的基础信息。
- [ ] `brew tap-info --json <tap>`：输出结构化 tap 信息。

## tap

说明：添加 tap 仓库

- [x] `brew tap <user/repo>`：添加一个 tap 仓库。
- [ ] `brew tap <user/repo> <url>`：从自定义 URL 添加 tap。

## unalias

说明：移除别名

- [x] `brew unalias <alias>`：删除指定 brew 命令别名。

## uninstall

说明：卸载包

- [x] `brew uninstall <formula|cask>`：卸载指定包。
- [ ] `brew uninstall --zap <cask>`：卸载 cask 并清理更多残留文件。
- [ ] `brew uninstall --force <formula|cask>`：强制卸载。

## unlink

说明：取消链接 formula

- [x] `brew unlink <formula>`：移除公式的符号链接。

## unpin

说明：取消固定版本

- [x] `brew unpin <formula>`：取消 formula 的 pin 状态。

## untap

说明：移除 tap 仓库

- [x] `brew untap <user/repo>`：移除指定 tap 仓库。

## update-if-needed

说明：按需更新 Homebrew 元数据

- [x] `brew update-if-needed`：仅在必要时执行更新流程。

## update-reset

说明：重置仓库状态

- [x] `brew update-reset`：重置 Homebrew 仓库到干净状态。

## update

说明：更新 Homebrew

- [x] `brew update`：更新 Homebrew 元数据与 tap 仓库。
- [ ] `brew update --force`：强制更新。

## upgrade

说明：升级包

- [x] `brew upgrade <formula|cask>`：升级指定包。
- [ ] `brew upgrade`：升级所有可升级包。
- [ ] `brew upgrade --greedy`：更激进地升级 cask。

## uses

说明：查询反向依赖

- [x] `brew uses <formula>`：查询哪些 formula 依赖该 formula。
- [ ] `brew uses --recursive <formula>`：递归查询反向依赖。
- [ ] `brew uses --installed <formula>`：仅显示本机已安装项。

## version-install

说明：安装指定版本定义

- [x] `brew version-install <version>`：按版本安装/处理版本化定义。

## which-formula

说明：根据命令定位对应 formula

- [x] `brew which-formula <command>`：查找提供该命令的 formula。
- [ ] `brew which-formula --explain <command>`：输出定位过程说明。
