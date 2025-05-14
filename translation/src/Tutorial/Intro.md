# 介绍

Welcome to my Idris 2 tutorial. I'll try and treat as many aspects
of the Idris 2 programming language as possible here.
All `.md` files in here are literate Idris files: They consist of
Markdown (hence the `.md` ending), which is being pretty printed
by GitHub together with Idris code blocks, which can be
type checked and built by the Idris compiler (more on this later).
Note, however, that regular Idris source files use an `.idr` ending,
and that you go with that file type unless you end up writing
much more prose than code as I do at the moment. Later in this
tutorial, you'll have to solve some exercises, the solutions of
which can be found in the `src/Solutions` subfolder. There, I
use regular `.idr` files.

Before we begin, make sure to install the Idris compiler on your system.
Throughout this tutorial, I assume you installed the *pack* package
manager and setup a skeleton package as described
[here](../Appendices/Install.md). It is
certainly possible to follow along with just the Idris compiler installed
by other means, but some adjustments will be necessary
when starting REPL sessions or building executables.

每个 Idris 源文件通常应该以模块名称和一些必要的导入开头，本文档也不例外。

```idris
module Tutorial.Intro
```

模块名称由以点分隔的标识符列表组成，并且必须反映文件夹结构加上模块文件的名称。

## 关于 Idris 编程语言

Idris 是一种具有*依赖类型*的、*完全*的*纯**函数式*编程语言。我将在本节中快速解释这些形容词。

### 函数式编程

In functional programming languages, functions are first-class
constructs, meaning that they can be assigned to variables,
passed as arguments to other functions, and returned as results
from functions. Unlike for instance in
object-oriented programming languages, in functional programming,
functions are the main form of abstraction. This means that whenever
we find a common pattern or (almost) identical code in several
parts of a project, we try to abstract over this in order to
have to write the corresponding code only once.
We do this by introducing one or more new functions
implementing this behavior. Doing so, we often try to be as general
as possible to make our functions as versatile to use as possible.

函数式编程语言关注函数的求值，不像经典的命令式语言关注语句的执行。

### 纯函数式编程

纯函数式编程语言有一个额外的重要保证：函数不会产生像写入文件或改变全局状态这样的副作用。他们只能通过调用其他纯函数，给定参数来获取计算结果，*而没有其它的途径*。因此，给定相同的输入，它们将*总是*生成相同的输出。此属性称为 [引用透明](https://en.wikipedia.org/wiki/Referential_transparency)。

纯函数有几个优点：

* 它们可以通过指定（可能是随机生成的）输入参数集以及预期结果来轻松测试。


* They are thread-safe, since they don't mutate global state, and
  as such can be freely used in several computations running
  in parallel.


当然，也有一些缺点：

* 仅使用纯函数很难有效地实现某些算法。


* 编写实际上*做*某些事情（具有一些可观察到的效果）的程序有点棘手，但肯定是可能的。


### 依赖类型

Idris is a strongly, statically typed programming language. This
means that every Idris expression is given a *type* (for instance:
integer, list of strings, boolean, function from integer to boolean, etc.)
and types are verified at compile time to rule out certain
common programming errors.

例如，如果一个函数需要 `String` 类型的参数（Unicode 字符序列，例如 `"Hello123"`），使用 `Integer` 类型的参数调用此函数是*类型错误*的，Idris 编译器将拒绝从此类错误类型的程序生成可执行文件。

Being *statically typed* means that the Idris compiler will catch
type errors at *compile time*, that is, before it generates an executable
program that can be run. The opposite to this are *dynamically typed*
languages such as Python, which check for type errors at *runtime*, that is,
when a program is being executed. It is the philosophy of statically typed
languages to catch as many type errors as possible before there even is
a program that can be run.

更重要的是，Idris 具有*依赖类型*，这是它在编程语言领域中最具特色的属性之一。在 Idris 中，类型是*一等*的：类型可以作为参数传递给函数，函数可以返回类型作为结果。更重要的是，类型可以*依赖于*其他*值*。这意味着什么，以及为什么这非常有用，我们将在适当的时候进行探索。

### 全函数

A *total* function is a pure function, that is guaranteed to return
a value of the expected return type for every possible input in
a finite number of computational steps. A total function will never fail with an
exception or loop infinitely, although it can still take arbitrarily
long to compute its result

Idris 内置了一个完全性检查器，它使我们能够验证我们编写的函数是否是可证明的完全性。 Idris 中的完全性是可选的，因为一般来说，检查任意计算机程序的完全性是无法确定的（另请参见 [停机问题](https://en.wikipedia.org/wiki/Halting_problem)）。但是，如果我们使用 `total` 关键字注释函数，如果 Idris 的完全性检查器无法验证所讨论的函数确实是完全的，则 Idris 将失败并出现类型错误。

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

The pack program requires an `.ipkg` to be in scope (in the current
directory or one of its parent directories) from which
it will get other settings like the source directory to use
(`src` in our case). The optional `-o` option gives the name of the
executable to be generated. Pack comes up with a name of its own
it this is missing. Type `pack help` for a list
of available command-line options and commands, and `pack help <cmd>`
for getting help for a specific command.

作为替代方案，您还可以在 REPL 会话中加载此源文件并从那里调用函数 `main`：

```sh
pack repl src/Tutorial/Intro.md
```

```repl
Tutorial.Intro> :exec main
Hello World!
```

继续尝试在您的系统上构建和运行函数 `main` 的两种方法！

## 如何声明一个 Idris 定义

现在我们执行了第一个 Idris 程序，接下来我们将更多地讨论我们如何编写代码来定义它。

Idris 中一个典型的顶级函数由三部分组成：函数的名称（在我们的例子中是 `main`），它的类型（`IO ()`）加上它的实现（`putStrLn "你好世界”`）。用几个简单的例子来解释这些事情会更容易。下面，我们为最大的无符号八位整数定义一个顶级常量：

```idris
maxBits8 : Bits8
maxBits8 = 255
```

The first line can be read as: "We'd like to declare  (nullary)
function `maxBits8`. It is of type `Bits8`". This is
called the *function declaration*: we declare that there
shall be a function of the given name and type. The second line
reads: "The result of invoking `maxBits8` should be `255`."
(As you can see, we can use integer literals for other integral
types than just `Integer`.) This is called the *function definition*:
Function `maxBits8` should behave as described here when being
evaluated.

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

我将 `maxBits8` 称为*零元函数*，它只是*常量*的一个花哨的同义词。让我们编写并测试我们的第一个*真实*的函数：

```idris
distanceToMax : Bits8 -> Bits8
distanceToMax n = maxBits8 - n
```

这引入了一些新语法和一种新类型：函数类型。 `distanceToMax : Bits8 -> Bits8` 可以这样读：“`distanceToMax` 是具有一个 `Bits8` 类型参数的函数，它返回 `Bits8` 类型的结果”。在实现中，参数给定一个本地标识符 `n`，然后在右侧计算。再次在 REPL 中尝试函数：

```repl
Tutorial.Intro> distanceToMax 12
243
Tutorial.Intro> :t distanceToMax
Tutorial.Intro.distanceToMax : Bits8 -> Bits8
Tutorial.Intro> :t distanceToMax 12
distanceToMax 12 : Bits8
```

作为最后一个例子，让我们实现一个计算整数平方的函数：

```idris
square : Integer -> Integer
square n = n * n
```

我们现在学习 Idris 编程的一个非常重要的方面：Idris 是一种*静态类型*的编程语言。我们不允许随意混合类型。这样做会导致来自类型检查器的错误消息（这是 Idris 编译过程的一部分）。例如，如果我们在 REPL 中尝试以下操作，我们将收到类型错误：

```repl
Tutorial.Intro> square maxBits8
Error: ...
```

原因：`square` 需要 `Integer` 类型的参数，但 `maxBits8` 的类型是 `Bits8`。许多原语类型可以使用函数 `cast` 相互转换（有时会有精度损失的风险）（稍后会详细介绍）：

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

有多种在线资源和印刷资源，您可以在其中找到有关 Idris 编程语言的帮助和文档。以下是它们的非全面列表：

* [使用 Idris 进行类型驱动开发](https://www.manning.com/books/type-driven-development-with-idris)


  *专门*讲 Idris 的书！这描述得很详细。使用 Idris 和依赖类型的核心概念编写健壮和简洁的代码。它使用 Idris 1 实现书中的例子，所以使用 Idris 2 时它的一部分必须稍微调整，有一个[所需更新列表](https://idris2.readthedocs.io/en/latest/typedd/typedd.html)。

* [Idris 2 速成课程](https://idris2.readthedocs.io/en/latest/tutorial/index.html)


  Idris 2 官方教程。全面而密集的解释 Idris 2 的所有功能。我发现这作为参考很有用，因此它是高度可访问的。但是，它不是函数式编程或类型驱动开发的入门介绍

* [Idris 2 GitHub 存储库](https://github.com/idris-lang/Idris2)


  在这里查看详细的安装说明和一些介绍材料。还有一个[wiki](https://github.com/idris-lang/Idris2/wiki)，
  在这里你可以找到[编辑器插件列表](https://github.com/idris-lang/Idris2/wiki/The-Idris-editor-experience)，
  [社区库列表](https://github.com/idris-lang/Idris2/wiki/Libraries),
  [外部后端列表](https://github.com/idris-lang/Idris2/wiki/External-backends),
和其他有用的信息。

* [Idris 2 Discord 频道](https://discord.gg/UX68fDs2jc)


  如果你被一段代码卡住了，想问一些晦涩的语言功能，想推广你的新库，或者想和其他 Idris 程序员一起出去玩，可以来这个地方。Discord 频道非常活跃且对新人*非常*友好。

* Idris REPL


  最后，Idris 本身可以提供很多有用的信息。在 Idris 编程的时间我倾向于至少打开一个 REPL 会话。我的编辑器（neovim）已设置使用 [Idris 2 的语言服务器](https://github.com/idris-community/idris2-lsp)，在 REPL 中这非常有用。

  * 使用 `:t` 检查表达式或元变量（孔）的类型：`:t foldl`,

  * 使用 `:ti` 检查包含隐式参数的函数类型：`:ti foldl`,

  * 使用 `:m` 列出作用域内的所有元变量（孔），

  * 使用 `:doc` 访问顶级函数 (`:doc the`) 的文档，一种数据类型及其所有构造函数和可用提示 (`:doc Bool` )，语言特性（`:doc case`, `:doc let`, `:doc interface`, `:doc record`，甚至是 `:doc ?`)，或者一个接口（`:doc Uninhabited`），

  * 使用 `:module` 从可用包之一导入模块：`:module Data.Vect`,

  * 使用 `:browse` 列出加载模块导出的所有函数的名称和类型： `:browse Data.Vect`,

  * 使用 `:help` 获取其他命令的列表以及每个命令的简短描述。


## 概括

在本介绍中，我们了解了 Idris 编程语言的最基本功能。我们使用 REPL 来修改我们的想法并检查代码中事物的类型，我们使用 Idris 编译器将 Idris 源文件编译为可执行文件。

我们还了解了 Idris 中顶级定义的基本形式，它始终由标识符（其名称）、类型和实现组成。

### 下一步是什么？

在[下一章](Functions1.md)中，我们开始在 Idris 中进行真正的编程。我们学习如何编写我们自己的纯函数，函数如何组合，以及我们如何像对待其他值一样对待函数并将它们作为参数传递给其他函数。

<!-- vi: filetype=idris2:syntax=markdown
-->
