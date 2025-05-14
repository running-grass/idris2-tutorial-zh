# 介绍

欢迎来到我的 Idris 2 教程。在这里，我会尽量涵盖 Idris 2 编程语言的各个方面。
本教程中的所有 `.md` 文件都是 literate Idris 文件：它们由 Markdown 组成（因此以 `.md` 结尾），
GitHub 会对其进行美观的排版，并且其中的 Idris 代码块可以被 Idris 编译器类型检查和构建（后文会详细介绍）。
需要注意的是，常规的 Idris 源文件使用 `.idr` 作为后缀，除非你像我现在这样写的文字比代码还多，否则建议使用 `.idr` 文件。
在本教程的后续部分，你需要完成一些练习，参考答案可以在 `src/Solutions` 子文件夹中找到。在那里，我使用的是常规的 `.idr` 文件。

在开始之前，请确保你已经在系统上安装了 Idris 编译器。
本教程假设你已经按照[这里](../Appendices/Install.md)的说明安装了 *pack* 包管理器并创建了一个骨架包。
当然，你也可以只安装 Idris 编译器来学习本教程，但在启动 REPL 会话或构建可执行文件时，可能需要做一些调整。

每个 Idris 源文件通常应该以模块名称和一些必要的导入开头，本文档也不例外。

```idris
module Tutorial.Intro
```

模块名称由以点分隔的标识符列表组成，并且必须反映文件夹结构加上模块文件的名称。

## 关于 Idris 编程语言

Idris 是一种具有*依赖类型*的、*完全*的*纯函数式*编程语言。我将在本节中快速解释这些形容词。

### 函数式编程

在函数式编程语言中，函数是一等公民，这意味着它们可以被赋值给变量、作为参数传递给其他函数，也可以作为函数的返回值。
与面向对象编程语言不同，在函数式编程中，函数是主要的抽象手段。
这意味着每当我们在项目的多个部分发现相同或类似的代码时，我们会尝试进行抽象，从而只需编写一次相应的代码。
我们通过引入一个或多个实现该行为的新函数来实现这一点。
这样做时，我们通常会尽量让函数通用，以便在更多场景下复用。

函数式编程语言关注函数的求值，不像经典的命令式语言关注语句的执行。

### 纯函数式编程

纯函数式编程语言有一个额外的重要保证：函数不会产生像写入文件或改变全局状态这样的副作用。
它们只能通过调用其他纯函数、给定参数来获取计算结果，*而没有其它的途径*。
因此，给定相同的输入，它们将*总是*生成相同的输出。此属性称为 [引用透明](https://en.wikipedia.org/wiki/Referential_transparency)。

纯函数有几个优点：

* 它们可以通过指定（可能是随机生成的）输入参数集以及预期结果来轻松测试。
* 它们是线程安全的，因为不会修改全局状态，因此可以在多个并发计算中自由使用。

当然，也有一些缺点：

* 仅使用纯函数很难高效地实现某些算法。
* 编写实际上*做*某些事情（具有一些可观察到的效果）的程序有点棘手，但肯定是可能的。

### 依赖类型

Idris 是一种强类型、静态类型的编程语言。这意味着每个 Idris 表达式都有一个*类型*（例如：整数、字符串列表、布尔值、从整数到布尔的函数等），并且类型会在编译时被检查，以避免常见的编程错误。

例如，如果一个函数需要 `String` 类型的参数（Unicode 字符序列，例如 "Hello123"），使用 `Integer` 类型的参数调用此函数是*类型错误*的，Idris 编译器将拒绝从此类错误类型的程序生成可执行文件。

所谓*静态类型*，就是 Idris 编译器会在*编译时*捕获类型错误，也就是在生成可执行程序之前。
与之相对的是*动态类型*语言，比如 Python，它们会在*运行时*检查类型错误，也就是程序执行时。
静态类型语言的理念是，在程序运行前尽可能多地捕获类型错误。

更重要的是，Idris 具有*依赖类型*，这是它在编程语言领域中最具特色的属性之一。
在 Idris 中，类型是一等公民：类型可以作为参数传递给函数，函数也可以返回类型作为结果。
更进一步，类型可以*依赖于*其他*值*。这意味着什么，以及为什么这非常有用，我们将在适当的时候进行探索。

### 全函数

*完全*函数是指对于所有可能的输入，都能在有限的计算步骤内返回期望类型的值的纯函数。
完全函数不会抛出异常或陷入无限循环，尽管它们可能需要很长时间才能计算出结果。

Idris 内置了一个完全性检查器，它使我们能够验证我们编写的函数是否是可证明的完全性。
Idris 中的完全性是可选的，因为一般来说，检查任意计算机程序的完全性是无法确定的（另请参见 [停机问题](https://en.wikipedia.org/wiki/Halting_problem)）。
但是，如果我们使用 `total` 关键字注释函数，如果 Idris 的完全性检查器无法验证所讨论的函数确实是完全的，则 Idris 将失败并出现类型错误。

## 使用 REPL

Idris 附带了一个有用的 REPL（*Read Evaluate Print Loop* 的首字母缩写词），我们将使用它来修补小想法，并快速试验我们刚刚编写的代码。要启动 REPL 会话，请在终端中运行以下命令：

```repl
pack repl
```

Idris 现在应该准备好接受你的命令了：

```repl
     ____    __     _         ___
    /  _/___/ /____(_)____   |__ \
    / // __  / ___/ / ___/   __/ /     Version 0.5.1-3c532ea35
  _/ // /_/ / /  / (__  )   / __/      https://www.idris-lang.org
 /___/\__,_/_/  /_/____/   /____/      Type :? for help

Welcome to Idris 2.  Enjoy yourself!
Main>
```

我们可以继续输入一些简单的算术表达式。 Idris 将进行*求值*并打印结果：

```repl
Main> 2 * 4
8
Main> 3 * (7 + 100)
321
```

由于 Idris 中的每个表达式都有一个关联的*类型*，我们可能还想检查这些：

```repl
Main> :t 2
2 : Integer
```

这里的 `:t` 是 Idris REPL 的命令（它不是 Idris 编程语言的一部分），它用于检查表达式的类型。

```repl
Main> :t 2 * 4
2 * 4 : Integer
```

每当我们使用整数字面量执行计算而没有明确说明我们想要使用的类型时，Idris 将使用 `Integer` 作为默认值。 `Integer` 是任意精度的有符号整数类型。它是语言中内置的*原语类型*之一。其他原语包括固定精度有符号和无符号整数类型（`Bits8`、`Bits16`、`Bits32` `Bits64`、`Int8`、 `Int16`、`Int32` 和 `Int64`）、双精度（64 位）浮点数（`Double`）、Unicode 字符（`Char`) 和 Unicode 字符串 (`String`)。我们将在适当的时候会使用到大多数。

## 第一个 Idris 程序

我们经常会启动一个 REPL 来修补 Idris 语言的一小部分，阅读一些文档，或检查 Idris 模块的内容，但现在我们将编写一个最小的 Idris 程序来开始使用该语言。这是强制性的 *Hello World*：

```idris
main : IO ()
main = putStrLn "Hello World!"
```

稍后我们将详细检查上面的代码，但首先我们要编译并运行它。在此项目的根目录中，运行以下命令：
```sh
pack -o hello exec src/Tutorial/Intro.md
```

这将在目录 `build/exec` 中创建可执行文件 `hello`，可以像这样从命令行调用它（没有美元前缀；这里用来区分终端命令和它的输出）：

```sh
$ build/exec/hello
Hello World!
```

pack 程序要求当前目录或其父目录下有 `.ipkg` 文件，以便获取其他设置，比如要使用的源代码目录（在本项目中为 `src`）。可选的 `-o` 选项用于指定生成的可执行文件名。如果没有指定，pack 会自动生成一个名字。输入 `pack help` 可以查看所有可用的命令行选项和命令，输入 `pack help <cmd>` 可以获取某个具体命令的帮助。

作为替代方案，你还可以在 REPL 会话中加载此源文件并从那里调用函数 `main`：

```sh
pack repl src/Tutorial/Intro.md
```

```repl
Tutorial.Intro> :exec main
Hello World!
```

请在你的系统上尝试这两种构建和运行 `main` 函数的方法！

## 如何声明一个 Idris 定义

现在我们执行了第一个 Idris 程序，接下来我们将更多地讨论我们如何编写代码来定义它。

Idris 中一个典型的顶级函数由三部分组成：函数的名称（在我们的例子中是 `main`），它的类型（`IO ()`）加上它的实现（`putStrLn "Hello World!"`）。用几个简单的例子来解释这些事情会更容易。下面，我们为最大的无符号八位整数定义一个顶级常量：

```idris
maxBits8 : Bits8
maxBits8 = 255
```

第一行可以理解为："我们想要声明一个（零元）函数 `maxBits8`，它的类型是 `Bits8`。" 这被称为*函数声明*：我们声明将有一个给定名称和类型的函数。第二行的意思是："调用 `maxBits8` 的结果应该是 `255`。"（如你所见，我们可以为除 `Integer` 以外的其他整数类型使用整数字面量。）这被称为*函数定义*：函数 `maxBits8` 在被求值时应表现为这里描述的行为。

我们可以在 REPL 进行检查。将此源文件加载到 Idris REPL 中（如上所述），然后运行以下测试。

```repl
Tutorial.Intro> maxBits8
255
Tutorial.Intro> :t maxBits8
Tutorial.Intro.maxBits8 : Bits8
```

我们也可以使用 `maxBits8` 作为另一个表达式的一部分：

```repl
Tutorial.Intro> maxBits8 - 100
155
```

我将 `maxBits8` 称为*零元函数*，它其实就是*常量*的一个花哨说法。让我们编写并测试我们的第一个*真正*的函数：

```idris
distanceToMax : Bits8 -> Bits8
distanceToMax n = maxBits8 - n
```

这引入了一些新语法和一种新类型：函数类型。`distanceToMax : Bits8 -> Bits8` 可以这样读："`distanceToMax` 是一个参数类型为 `Bits8` 的函数，返回类型也是 `Bits8`。" 在实现中，参数被赋予本地标识符 `n`，然后在右侧进行计算。再次在 REPL 中尝试该函数：

```repl
Tutorial.Intro> distanceToMax 12
243
Tutorial.Intro> :t distanceToMax
Tutorial.Intro.distanceToMax : Bits8 -> Bits8
Tutorial.Intro> :t distanceToMax 12
distanceToMax 12 : Bits8
```

最后一个例子，让我们实现一个计算整数平方的函数：

```idris
square : Integer -> Integer
square n = n * n
```

我们现在学习 Idris 编程的一个非常重要的方面：Idris 是一种*静态类型*的编程语言。我们不允许随意混合类型。这样做会导致类型检查器（Idris 编译过程的一部分）报错。例如，如果我们在 REPL 中尝试以下操作，将会收到类型错误：

```repl
Tutorial.Intro> square maxBits8
Error: ...
```

原因：`square` 需要 `Integer` 类型的参数，但 `maxBits8` 的类型是 `Bits8`。许多原语类型可以使用函数 `cast` 相互转换（有时会有精度损失的风险，稍后会详细介绍）：

```repl
Tutorial.Intro> square (cast maxBits8)
65025
```

请注意，在上面的示例中，结果比 `maxBits8` 大得多。原因是，首先将 `maxBits8` 转换为相同值的 `Integer`，然后对其进行平方。另一方面，如果我们直接将 `maxBits8` 平方，结果将被截断以适应 `Bits8` 的有效范围：

```repl
Tutorial.Intro> maxBits8 * maxBits8
1
```

## 在哪里可以获得帮助

有多种在线资源和印刷资源，你可以在其中找到有关 Idris 编程语言的帮助和文档。以下是它们的非全面列表：

* [使用 Idris 进行类型驱动开发](https://www.manning.com/books/type-driven-development-with-idris)

  *专门*讲 Idris 的书！这本书详细介绍了如何使用 Idris 及其依赖类型来编写健壮且简洁的代码。书中使用的是 Idris 1，因此在使用 Idris 2 时部分内容需要稍作调整，具体可参考[所需更新列表](https://idris2.readthedocs.io/en/latest/typedd/typedd.html)。

* [Idris 2 速成课程](https://idris2.readthedocs.io/en/latest/tutorial/index.html)

  Idris 2 官方教程。全面而精炼地解释了 Idris 2 的所有特性。我发现它作为参考资料非常有用，因此也很容易查阅。不过，它并不是函数式编程或类型驱动开发的入门介绍。

* [Idris 2 GitHub 仓库](https://github.com/idris-lang/Idris2)

  这里有详细的安装说明和一些入门材料。还有一个[wiki](https://github.com/idris-lang/Idris2/wiki)，你可以在这里找到[编辑器插件列表](https://github.com/idris-lang/Idris2/wiki/The-Idris-editor-experience)、[社区库列表](https://github.com/idris-lang/Idris2/wiki/Libraries)、[外部后端列表](https://github.com/idris-lang/Idris2/wiki/External-backends)以及其他有用信息。

* [Idris 2 Discord 频道](https://discord.gg/UX68fDs2jc)

  如果你在代码上遇到困难，想要询问某些晦涩的语言特性，想推广你的新库，或者只是想和其他 Idris 程序员交流，这里是个不错的去处。Discord 频道非常活跃，对新手*非常*友好。

* Idris REPL

  最后，Idris 本身也能提供很多有用的信息。我在编写 Idris 代码时通常会至少打开一个 REPL 会话。我的编辑器（neovim）配置了 [Idris 2 的语言服务器](https://github.com/idris-community/idris2-lsp)，这非常有用。在 REPL 中：

  * 使用 `:t` 检查表达式或元变量（孔）的类型，例如 `:t foldl`；
  * 使用 `:ti` 检查包含隐式参数的函数类型，例如 `:ti foldl`；
  * 使用 `:m` 列出作用域内的所有元变量（孔）；
  * 使用 `:doc` 查看顶级函数（如 `:doc the`）、数据类型及其所有构造函数和可用提示（如 `:doc Bool`）、语言特性（如 `:doc case`、`:doc let`、`:doc interface`、`:doc record`，甚至 `:doc ?`），或接口（如 `:doc Uninhabited`）的文档；
  * 使用 `:module` 从可用包之一导入模块，例如 `:module Data.Vect`；
  * 使用 `:browse` 列出已加载模块导出的所有函数的名称和类型，例如 `:browse Data.Vect`；
  * 使用 `:help` 获取其他命令的列表及其简要说明。

## 概括

在本介绍中，我们了解了 Idris 编程语言的最基本功能。我们使用 REPL 来修改我们的想法并检查代码中事物的类型，我们使用 Idris 编译器将 Idris 源文件编译为可执行文件。

我们还了解了 Idris 中顶级定义的基本形式，它始终由标识符（其名称）、类型和实现组成。

### 下一步是什么？

在[下一章](Functions1.md)中，我们开始在 Idris 中进行真正的编程。我们学习如何编写我们自己的纯函数，函数如何组合，以及我们如何像对待其他值一样对待函数并将它们作为参数传递给其他函数。

<!-- vi: filetype=idris2:syntax=markdown -->
