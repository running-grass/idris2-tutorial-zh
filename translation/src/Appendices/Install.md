# [pack 和 Idris2 入门](src/Appendices/Install.md)

这里介绍我认为最便捷的 Idris2 入门方法。我们将安装
[pack](https://github.com/stefan-hoeck/idris2-pack) 包管理器，它会顺带安装最新版 Idris
编译器。不过，这意味着你需要使用类 Unix 操作系统（如 Linux 或 macOS）。Windows 用户可以通过
[WSL](https://learn.microsoft.com/en-us/windows/wsl/about) 在系统上获取 Linux
环境。前提假设读者已了解如何在系统上启动终端会话，并能在终端命令行中运行命令。此外，还需了解如何在系统中为 [`$PATH`
变量](https://en.wikipedia.org/wiki/PATH_(variable)) 添加目录。

## 安装 pack

要安装 *pack* 包管理器及最新版 Idris2 编译器，请按照 [pack 的 GitHub
页面](https://github.com/stefan-hoeck/idris2-pack/blob/main/INSTALL.md)
上的说明操作。

如果一切顺利，建议你花点时间查看全局 `pack.toml` 文件中的默认设置，该文件位于
`$HOME/.pack/user/pack.toml`（除非你显式将 `$PACK_DIR` 环境变量设置为其他目录）。如果可以，建议你安装
*rlwrap* 工具，并将全局 `pack.toml` 文件中的以下设置改为 `true`：

```toml
repl.rlwrap = true
```

这样在运行 REPL 会话时体验会更好。你还可以配置编辑器以使用 Idris 提供的交互式编辑功能。关于 Neovim
的相关设置说明见[此处](Neovim.md)。

### 更新 pack 和 Idris

pack 和 Idris 编译器这两个项目都在积极开发中，因此建议你定期更新。要更新 pack 本身，只需运行以下命令：

```sh
pack update
```

要构建并安装 Idris 编译器的最新提交，并使用最新的包集合，请运行：

```sh
pack switch latest
```

## 搭建你的 Playground（练习场）

如果你打算完成本教程中的练习（强烈建议你这样做！），你将需要编写大量代码。建议你搭建一个小型练习项目来尝试 Idris。在你选择的目录下，运行以下命令：

```sh
pack new lib tut
```

这将在 `tut` 目录下创建一个最小化的 Idris 包，包括一个名为 `tut.ipkg` 的 `.ipkg` 文件、一个用于存放 Idris
源码的 `src` 目录，以及一个位于 `src/Tut.idr` 的最小 Idris 模块。

此外，还会在 `test` 目录下创建一个最小化的测试套件。所有这些内容会被整合，并通过项目根目录下的 `pack.toml` 文件让 pack
识别。建议你花点时间快速查看 pack 创建的每个文件内容：`.idr` 文件包含 Idris 源代码，`.ipkg` 文件详细描述了 Idris
编译器的包，包括源码位置、该包向其他项目暴露的模块，以及项目自身依赖的包列表。最后，`pack.toml` 文件用于告知 pack
当前项目中的本地包信息。

有了这些准备，你可以做很多事情。但首先，请确保在运行以下命令时，你位于项目根目录（如果按我的建议操作则为 `tut`）或其子目录下。

要对库源码进行类型检查，请运行：

```sh
pack typecheck tut
```

要构建并执行测试套件，请运行：

```sh
pack test tut
```

要启动并加载 `src/Tut.idr` 的 REPL 会话，请运行：

```sh
pack repl src/Tut.idr
```

## 结论

在这个简短的教程中，你已经搭建好了用于 Idris
项目开发和后续学习的环境。现在你可以开始阅读[第一章](../Tutorial/Intro.md)，或者——如果你已经写过一些 Idris
代码——可以进一步了解 [Idris 模块系统](Modules.md) 的细节。

请注意，本教程本身也是作为 pack 项目搭建的：其根目录下包含 `pack.toml` 和 `tutorial.ipkg`
文件（可以查看它们，了解此类项目的结构），并且在 `src` 子目录下有大量 Idris 源码。
