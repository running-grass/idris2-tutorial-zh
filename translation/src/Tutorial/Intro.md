# 引言

欢迎来到我的 Idris 2 教程。我会尽量全面地介绍 Idris 2 编程语言的各个方面。这里的所有 `.md` 文件都是文学化 Idris
文件：它们由 Markdown 组成（因此以 `.md` 结尾），GitHub 会将其与 Idris 代码块一起美观地渲染，这些代码块可以被 Idris
编译器类型检查和构建（稍后会详细介绍）。需要注意的是，常规 Idris 源文件使用 `.idr`
作为后缀，除非你像我现在这样写了大量说明性文字，否则建议使用 `.idr` 文件类型。在本教程后续，你需要完成一些练习，答案可以在
`src/Solutions` 子目录中找到，那里我使用的是常规的 `.idr` 文件。

在开始之前，请确保你已经在系统上安装了 Idris 编译器。本教程假定你已安装 *pack*
包管理器，并按照[这里](../Appendices/Install.md)的说明配置了一个基础包。当然，仅通过其他方式安装 Idris
编译器也可以学习本教程，但在启动 REPL 会话或构建可执行文件时，可能需要做一些调整。

每个 Idris 源文件通常都以模块名和一些必要的导入语句开头，本教程也不例外：

```idris
module Tutorial.Intro
```

模块名由用点分隔的标识符组成，必须与文件夹结构及模块文件名相对应。

## 关于 Idris 编程语言

Idris 是一种*纯粹*、*依值类型*、*全定义*的*函数式*编程语言。本节将简要解释这些术语的含义。

### 函数式编程

在函数式编程语言中，函数是一等公民，这意味着它们可以赋值给变量、作为参数传递给其他函数，也可以作为函数的返回值。与面向对象编程语言不同，函数式编程中，函数是主要的抽象手段。这意味着当我们在项目的多个部分发现相同或类似的代码时，会通过抽象出一个或多个新函数来实现复用，从而只需编写一次相关代码。通常我们会尽量让函数设计得通用，以便在更多场景下复用。

函数式编程语言关注的是函数的求值，而传统命令式语言关注的是语句的执行。

### 纯函数式编程

纯函数式编程语言还提供了一个重要保证：函数不会产生诸如写文件或修改全局状态等副作用。它们只能通过参数（以及可能调用其他纯函数）来计算结果，*除此之外别无他法*。因此，给定相同的输入，它们*总是*产生相同的输出。这一特性被称为[引用透明](https://en.wikipedia.org/wiki/Referential_transparency)。

纯函数有诸多优点：

* 可以通过指定（甚至随机生成）输入参数及期望结果，轻松对其进行测试。

* 由于不会修改全局状态，纯函数是线程安全的，因此可以在多个并发计算中自由使用。

当然，纯函数也有一些局限：

* 有些算法仅用纯函数难以高效实现。

* 要编写真正*产生效果*（即有可观察副作用）的程序会更复杂一些，但绝对可行。

### 依值类型

Idris 是一种强类型、静态类型的编程语言。这意味着每个 Idris
表达式都有一个*类型*（如：整数、字符串列表、布尔值、从整数到布尔值的函数等），并且类型会在编译时被检查，以避免常见的编程错误。

例如，如果某个函数需要 `String` 类型的参数（即 Unicode 字符序列，如 `"Hello123"`），而你用 `Integer`
类型的参数调用它，这就是*类型错误*，Idris 编译器会拒绝为这种类型错误的程序生成可执行文件。

*静态类型*意味着 Idris 编译器会在*编译时*捕获类型错误，也就是说，在生成可执行程序之前就能发现错误。与之相对的是*动态类型*语言（如
Python），它们会在*运行时*（即程序执行时）检查类型错误。静态类型语言的理念是在程序运行前尽可能多地发现类型错误。

此外，Idris 还支持*依值类型*，这是其在编程语言领域最具代表性的特性之一。在 Idris
中，类型是一等公民：类型可以作为参数传递给函数，函数也可以返回类型作为结果。更进一步，类型还可以*依赖于*其他*值*。这些特性意味着什么，以及它们为何如此强大，我们会在后续详细探讨。

### 全函数

*全*函数是一类纯函数，它保证对每一个可能的输入，都能在有限的计算步骤内返回一个符合预期类型的值。全函数不会因异常而失败，也不会陷入无限循环（尽管计算时间可能很长）。

Idris 内置了完全性检查器，可以帮助我们验证所写函数是否真正"全"。在 Idris
中，完全性检查是可选的，因为一般来说，判断任意程序是否完全是不可判定的（参见[停机问题](https://en.wikipedia.org/wiki/Halting_problem)）。但如果你用
`total` 关键字标注某个函数，而 Idris 检查器无法证明其完全性，则会报类型错误。

## 使用 REPL

Idris 自带了一个非常实用的 REPL（即 *Read Evaluate Print
Loop*，读-求值-打印-循环），我们可以用它来尝试小想法，或快速测试刚写的代码。要启动 REPL 会话，请在终端输入：

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

我们可以输入一些简单的算术表达式，Idris 会*求值*并输出结果：

```repl
Main> 2 * 4
8
Main> 3 * (7 + 100)
321
```

由于 Idris 中每个表达式都有对应的*类型*，我们也可以查看它们的类型信息：

```repl
Main> :t 2
2 : Integer
```

这里的 `:t` 是 Idris REPL 的命令（不是 Idris 语言本身的一部分），用于查看表达式的类型。

```repl
Main> :t 2 * 4
2 * 4 : Integer
```

当我们用整数字面量进行计算而未明确指定类型时，Idris 默认使用 `Integer` 类型。`Integer`
是一种任意精度的有符号整数，是语言内置的*原语类型*之一。其他原语类型还包括定长有符号和无符号整数（如
`Bits8`、`Bits16`、`Bits32`、`Bits64`、`Int8`、`Int16`、`Int32`、`Int64`）、双精度（64
位）浮点数（`Double`）、Unicode 字符（`Char`）和 Unicode 字符串（`String`）等。后续我们会用到其中许多类型。

## 第一个 Idris 程序

我们经常会启动一个 REPL 来修补 Idris 语言的一小部分，阅读一些文档，或检查 Idris 模块的内容，但现在我们将编写一个最小的 Idris
程序来开始使用该语言。这是强制性的 *Hello World*：

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

`--find-ipkg` 选项将在当前目录或其父目录之一中查找 `.ipkg` 文件，从中获取其他设置，如要使用的源码目录（在我们的例子中是 `src`）。`-o` 选项给出要生成的可执行文件的名称。输入 `idris2 --help` 以获取可用命令行选项和环境变量的列表。

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

Idris 中一个典型的顶级函数由三部分组成：函数的名称（在我们的例子中是 `main`），它的类型（`IO ()`）加上它的实现（`putStrLn
"Hello World"`）。用几个简单的例子来解释这些事情会更容易。下面，我们为最大的无符号八位整数定义一个顶级常量：

```idris
maxBits8 : Bits8
maxBits8 = 255
```

第一行可以读作："我们想声明（零元）函数 `maxBits8`。它的类型是
`Bits8`"。这称为*函数声明*：我们声明，应该有一个给定名称和类型的函数。第二行读作："调用 `maxBits8` 的结果应该是
`255`。"（如您所见，我们可以将整数字面量用于其他整数类型，而不仅仅是 `Integer`。）第二行称为*函数定义*：此处应该描述函数
`maxBits8` 在求值时的表现。

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

这引入了一些新语法和一种新类型：函数类型。 `distanceToMax : Bits8 -> Bits8` 可以这样读："`distanceToMax` 是具有一个 `Bits8` 类型参数的函数，它返回 `Bits8` 类型的结果"。在实现中，参数给定一个局部标识符 `n`，然后在右侧计算。再次在 REPL 中尝试函数：

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

我们现在要学习 Idris 编程的一个非常重要的方面：Idris 是*静态类型*编程语言，不能随意混用不同类型。否则会收到类型检查器的报错（类型检查是
Idris 编译过程的一部分）。例如，在 REPL 中尝试如下操作时会报类型错误：

```repl
Tutorial.Intro> square maxBits8
Error: ...
```

原因是：`square` 需要 `Integer` 类型的参数，而 `maxBits8` 的类型是 `Bits8`。许多原语类型之间可以用 `cast`
函数进行转换（有时可能会丢失精度，后面会详细介绍）：

```repl
Tutorial.Intro> square (cast maxBits8)
65025
```

请注意，上例的结果远大于 `maxBits8`。这是因为 `maxBits8` 先被转换为同值的 `Integer`，再进行平方。如果直接对
`maxBits8` 求平方，结果会被截断以适应 `Bits8` 的取值范围：

```repl
Tutorial.Intro> maxBits8 * maxBits8
1
```

## 在哪里可以获得帮助

有许多线上和纸质资源可以查阅 Idris 编程语言的帮助和文档，下面列出部分常用参考：

* [使用 Idris
  进行类型驱动开发](https://www.manning.com/books/type-driven-development-with-idris)

*专门*讲 Idris 的书！这描述得很详细。使用 Idris 和依值类型的核心概念编写健壮和简洁的代码。它使用 Idris 1 实现书中的例子，所以使用 Idris 2 时它的一部分必须稍微调整，有一个[所需更新列表](https://idris2.readthedocs.io/en/latest/typedd/typedd.html)。

* [Idris 2
  速成课程](https://idris2.readthedocs.io/en/latest/tutorial/index.html)

Idris 2 官方教程，对 Idris 2 的所有特性做了全面而深入的讲解，适合作为参考手册。但它并不是函数式编程或类型驱动开发的入门读物。

* [Idris 2 GitHub 存储库](https://github.com/idris-lang/Idris2)

  在这里查看详细的安装说明和一些介绍材料。还有一个[wiki](https://github.com/idris-lang/Idris2/wiki)，
  在这里你可以找到[编辑器插件列表](https://github.com/idris-lang/Idris2/wiki/The-Idris-editor-experience)，
  [社区库列表](https://github.com/idris-lang/Idris2/wiki/Libraries),
  [外部后端列表](https://github.com/idris-lang/Idris2/wiki/External-backends),
  和其他有用的信息。

* [Idris 2 Discord 频道](https://discord.gg/UX68fDs2jc)

  如果你被一段代码卡住了，想问一些晦涩的语言功能，想推广你的新库，或者想和其他 Idris 程序员一起出去玩，可以来这个地方。  Discord 频道非常活跃且对新人*非常*友好。

* Idris REPL

  最后，Idris 本身可以提供很多有用的信息。在 Idris 编程的时间我倾向于至少打开一个 REPL 会话。我的编辑器（neovim）已设置使用 [Idris 2 的语言服务器](https://github.com/idris-community/idris2-lsp)，在 REPL 中这非常有用。

  * 使用 `:t` 检查表达式或元变量（孔）的类型：`:t foldl`,
  * 使用 `:ti` 检查包含隐式参数的函数类型：`:ti foldl`,
  * 使用 `:m` 列出作用域内的所有元变量（孔），
  * 使用 `:doc` 访问顶级函数 (`:doc the`) 的文档，一种数据类型及其所有构造函数和可用提示 (`:doc Bool`
    )，语言特性（`:doc case`, `:doc let`, `:doc interface`, `:doc record`，甚至是
    `:doc ?`)，或者一个接口（`:doc Uninhabited`），
  * 使用 `:module` 从可用包之一导入模块：`:module Data.Vect`,
  * 使用 `:browse` 列出加载模块导出的所有函数的名称和类型： `:browse Data.Vect`,
  * 使用 `:help` 获取其他命令的列表以及每个命令的简短描述。

## 概括

在本介绍中，我们了解了 Idris 编程语言的最基本功能。我们使用 REPL 来修改我们的想法并检查代码中事物的类型，我们使用 Idris 编译器将
Idris 源文件编译为可执行文件。

我们还了解了 Idris 中顶级定义的基本形式，它始终由标识符（其名称）、类型和实现组成。

### 接下来做什么？

在[下一章](Functions1.md)中，我们开始在 Idris
中进行真正的编程。我们学习如何编写我们自己的纯函数，函数如何组合，以及我们如何像对待其他值一样对待函数并将它们作为参数传递给其他函数。

<!-- vi: filetype=idris2:syntax=markdown
-->
