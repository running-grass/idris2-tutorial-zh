# [构造 Idris 项目](src/Appendices/Projects.md)

在本节中，我将展示如何组织、安装和依赖更大的Idris项目。我们将看看Idris包、模块系统、类型和函数的可见性、编写注释和文档字符串，以及使用pack来管理我们的库。

本节应该对已经编写了一些Idris代码的读者有用。我们在这里不会做任何花哨的类型级别魔法，但我会使用`failing`代码块来演示几个概念，你可能之前没有见过。这种新的语言特性允许我们编写在类型检查期间应该失败的代码。例如：

```repl
failing "Can't find an implementation for FromString Bits8."
  ohno : Bits8
  ohno = "Oh no!"
```

作为失败块的一部分，我们可以给编译器错误消息的子字符串，用于文档目的，并确保块失败时出现预期的错误。

## 模块

每个Idris源文件都定义了一个*模块*，通常以如下所示的模块头开始：

```idris
module Appendices.Projects
```

模块的名称由几个大写字母标识符组成，用点分隔，必须反映存储模块的`.idr`文件的路径。例如，这个模块存储在文件`Appendices/Projects.md`中，所以模块的名称是`Appendices.Projects`。

但是，等待！"，你可能会说，"`Appendices`的父文件夹呢？为什么那些不是模块名称的一部分？"为了理解这一点，我们必须谈谈*源目录*的概念。源目录是Idris寻找源文件的地方。它默认为运行Idris可执行文件的目录。例如，当在项目中的`src`文件夹中时，你可以像这样打开这个源文件：

```sh
idris2 Appendices/Projects.md
```

但是，如果你从项目根文件夹尝试同样的事情，这不会起作用：

```sh
$ idris2 src/Appendices/Projects.md
...
Error: Module name Appendices.Projects does not match file name "src/Appendices/Projects.md"
...
```

所以，哪些文件夹名称应该包含在模块名称中，取决于我们认为我们的源目录是哪个父文件夹。通常的做法是将源目录命名为`src`，尽管这不是强制性的（正如我之前所说，默认情况下，实际上是运行Idris的目录）。可以使用`--source-dir`命令行选项更改源目录。以下工作从项目根目录：

```sh
idris2 --source-dir src src/Appendices/Projects.md
```

并且以下也会从父文件夹工作（假设这个教程存储在文件夹`tutorial`中）：

```sh
idris2 --source-dir tutorial/src tutorial/src/Appendices/Projects.md
```

大多数时候，你会为你的项目指定一个`.ipkg`文件（稍后在本节中可以看到），并在那里定义源目录。之后，你可以使用pack（而不是`idris2`可执行文件）来启动REPL会话并加载你的源文件。

### 模块导入

当你编写Idris代码时，你经常需要从其他模块导入函数和数据类型。这可以通过`import`语句来完成。这里有一些例子，展示了这些可能是什么样子的：

```idris
import Data.String
import Data.List
import Text.CSV
import public Appendices.Neovim
import Data.Vect as V
import public Data.List1 as L
```

前两行从另一个*包*导入模块（我们将在下面学习包）：`Data.List`从*base*包中导入，它将作为Idris安装的一部分安装。

第二行从我们自己的源目录`src`中导入模块`Text.CSV`。总是可以导入与正在处理的文件位于相同源目录的模块。

第三行从我们自己的源目录导入模块`Appendices.Neovim`。请注意，这个`import`语句有一个额外的`public`关键字。这允许我们*重新导出*一个模块，因此它不仅在当前模块中可用，而且在其他模块中也可用：如果另一个模块导入`Appendices.Projects`，模块`Appendices.Neovim`也将被导入，而不需要额外的`import`语句。这在将一些复杂功能拆分到不同模块并希望通过单个全能模块导入所有功能时很有用。参见*base*中的模块`Control.Monad.State`作为示例。你可以在克隆[Idris2项目](https://github.com/idris-lang/Idris2)后在GitHub或本地查看Idris源代码。基础库可以在`libs/base`子文件夹中找到。

通常，为了使用来自某个模块`A`的函数，我们也需要来自另一个模块`B`的实用程序，所以`A`应该重新导出`B`。例如，*base*中的`Data.Vect`重新导出`Data.Fin`，因为后者在处理向量时经常需要。

第四行导入模块`Data.Vect`，给它一个新名称`V`，用作更短的前缀。如果你经常需要通过模块名称前缀来消除歧义，这可以帮助使你的代码更简洁：

```idris
vectSum : Nat
vectSum = sum $ V.fromList [1..10]
```

最后，在第五行，我们公开导入一个模块并给它一个新名称。这个名称将在我们通过`Appendices.Projects`间接导入`Data.List1`时被看到。要看到这一点，请启动一个REPL会话（在类型检查教程之后），而不从项目根文件夹加载源文件：

```sh
pack typecheck tutorial
pack repl
```

现在加载模块`Appendices.Projects`并检查`singleton`的类型：

```repl
Main> :module Appendices.Projects
Imported module Appendices.Projects
Main> :t singleton
Data.String.singleton : Char -> String
Data.List.singleton : a -> List a
L.singleton : a -> List1 a
```

正如你所看到的，`List1`版本的`singleton`现在以`L`而不是`Data.List1`为前缀。仍然可以使用"官方"前缀：

```repl
Main> List1.singleton 12
12 ::: []
Main> L.singleton 12
12 ::: []
```

### 模块和命名空间

有时，我们希望在单个模块中定义具有相同名称的几个函数或数据类型。Idris不允许这样做，因为每个名称在其*命名空间*中必须是唯一的，而模块的命名空间只是完全限定的模块名称。然而，通过使用`namespace`关键字，可以在模块中定义额外的命名空间。所有应该属于这个命名空间的功能必须缩进相同的空格量。

这是另一个例子：

```idris
data HList : List Type -> Type where
  Nil  : HList []
  (::) : (v : t) -> (vs : HList ts) -> HList (t :: ts)

head : HList (t :: ts) -> t
head (v :: _) = v

tail : HList (t :: ts) -> HList ts
tail (_ :: vs) = vs

namespace HVect
  public export
  data HVect : Vect n Type -> Type where
    Nil  : HVect []
    (::) : (v : t) -> (vs : HVect ts) -> HVect (t :: ts)

  public export
  head : HVect (t :: ts) -> t
  head (v :: _) = v

  public export
  tail : HVect (t :: ts) -> HVect ts
  tail (_ :: vs) = vs
```

函数名称`HVect.head`和`HVect.tail`以及构造函数`HVect.Nil`和`HVect.(::)`与外部命名空间（`Appendices.Projects`）中的同名函数和构造函数冲突，所以我们不得不将它们放在自己的命名空间中。为了能够从外部使用它们，它们需要被导出（参见下面的可见性部分）。如果我们需要区分这些名称，我们可以用它们的命名空间的前缀来区分它们。例如，以下由于作用域中有几个名为`head`的函数，所以会出现歧义错误，并且不清楚`head`的参数（一些支持列表语法的类型，其中再次有几个在作用域中），我们想要哪个版本：

```idris
failing "Ambiguous elaboration."
  whatHead : Nat
  whatHead = head [12,"foo"]
```

通过用命名空间的一部分前缀`head`，我们可以解决歧义。现在很明显，`[12,"foo"]`必须是一个`HVect`，因为那是`HVect.head`的参数的类型：

```idris
thisHead : Nat
thisHead = HVect.head [12,"foo"]
```

在接下来的子部分中，我将使用命名空间来演示可见性的原则。

### 可见性

为了在模块或命名空间之外使用函数和数据类型，我们需要改变它们的*可见性*。默认可见性是`private`：这样的函数或数据类型在模块或命名空间之外不可见：

```idris
namespace Foo
  foo : Nat
  foo = 12

failing "Name Appendices.Projects.Foo.foo is private."
  bar : Nat
  bar = 2 * foo
```

要使函数可见，请使用`export`关键字注释它：

```idris
namespace Square
  export
  square : Num a => a -> a
  square v = v * v
```

这将允许我们从其他模块或命名空间（在导入`Appendices.Projects`之后）调用函数`square`：

```idris
OneHundred : Bits8
OneHundred = square 10
```

然而，`square`的*实现*不会被导出，所以`square`在类型检查期间不会减少：

```idris
failing "Can't solve constraint between: 100 and square 10."
  checkOneHundred : OneHundred === 100
  checkOneHundred = Refl
```

为此，我们需要*公开导出*`square`：

```idris
namespace SquarePub
  public export
  squarePub : Num a => a -> a
  squarePub v = v * v

OneHundredAgain : Bits8
OneHundredAgain = squarePub 10

checkOneHundredAgain : OneHundredAgain === 100
checkOneHundredAgain = Refl
```

因此，如果你需要一个在类型检查期间减少的函数，请使用`public
export`而不是`export`。这在使用函数计算类型时特别重要。这样的函数*必须*在类型检查期间减少，否则它们是完全无用的：

```idris
namespace Stupid
  export
  0 NatOrString : Type
  NatOrString = Either String Nat

failing "Can't solve constraint between: Either String ?b and NatOrString."
  natOrString : NatOrString
  natOrString = Left "foo"
```

如果我们公开导出我们的类型别名，一切类型检查都很好：

```idris
namespace Better
  public export
  0 NatOrString : Type
  NatOrString = Either String Nat

natOrString : Better.NatOrString
natOrString = Left "bar"
```

### 数据类型的可见性

数据类型的可见性行为略有不同。如果设置为`private`（默认值），则*类型构造器*和*数据构造器*在定义它们的命名空间之外不可见。如果用`export`注释，则类型构造器被导出，但数据构造器不被导出：

```idris
namespace Export
  export
  data Foo : Type where
    Foo1 : String -> Export.Foo
    Foo2 : Nat -> Export.Foo

  export
  mkFoo1 : String -> Export.Foo
  mkFoo1 = Foo1

foo1 : Export.Foo
foo1 = mkFoo1 "foo"
```

正如你所看到的，我们可以在命名空间`Export`之外使用类型`Foo`以及函数`mkFoo1`。然而，我们不能直接使用`Foo1`构造函数来创建类型`Foo`的值：

```idris
failing "Export.Foo1 is private."
  foo : Export.Foo
  foo = Foo1 "foo"
```

当我们公开导出数据类型时，情况会发生变化：

```idris
namespace PublicExport
  public export
  data Foo : Type where
    Foo1 : String -> PublicExport.Foo
    Foo2 : Nat -> PublicExport.Foo

foo2 : PublicExport.Foo
foo2 = Foo2 12
```

同样适用于接口：如果它们被公开导出，则接口（一个类型构造器）及其所有函数都被导出，你可以在定义它们的命名空间之外编写实现：

```idris
namespace PEI
  public export
  interface Sized a where
    size : a -> Nat

Sized Nat where size = id

sumSizes : Foldable t => Sized a => t a -> Nat
sumSizes = foldl (\n,e => n + size e) 0
```

如果它们没有被公开导出，你将无法在定义它们的命名空间之外编写实现（但你仍然可以在你的代码中使用类型及其函数）：

```idris
namespace EI
  export
  interface Empty a where
    empty : a -> Bool

  export
  Empty (List a) where
    empty [] = True
    empty _  = False

failing
  Empty Nat where
    empty Z = True
    empty (S _) = False

nonEmpty : Empty a => a -> Bool
nonEmpty = not . empty
```

### 子命名空间

有时，在另一个模块或命名空间中访问私有函数是必要的。这在子命名空间中是可能的（出于更好的名称）：与父模块或命名空间共享父模块或命名空间前缀的模块和命名空间。例如：

```idris
namespace Inner
  testEmpty : Bool
  testEmpty = nonEmpty (the (List Nat) [12])
```

正如你所看到的，我们可以在命名空间`Appendices.Projects.Inner`中访问函数`nonEmpty`，尽管它是模块`Appendices.Projects`中的私有函数。这甚至适用于模块：如果我们编写一个模块`Data.List.Magic`，我们就可以访问*base*模块中定义的私有实用函数。实际上，我确实这样做了，并添加了模块`Data.List.Magic`来演示Idris模块系统的一个怪癖（去看看吧！）。一般来说，这是一种绕过可见性约束的相当hacky的方式，但有时可能会有用。

## 参数块（Parameter Blocks）

在本节中，我们将研究一个称为`parameters`块的语言结构，它允许我们在几个函数之间共享一组只读参数（参数），从而允许我们编写更简洁的函数签名。我将通过一个小示例程序来演示它们的实用性。

将一些外部信息提供给函数的最基本方法是将其作为附加参数传递。在面向对象编程中，这个原则有时被称为[依赖注入](https://en.wikipedia.org/wiki/Dependency_injection)，并且对此有很多讨论，整个库和框架都是围绕它构建的。

在函数式编程中，我们可以完全放松地处理所有这些问题：需要访问一些配置数据来运行你的应用程序？将其作为附加参数传递给你的函数。想要使用一些本地可变状态？将相应的`IORef`作为附加参数传递给你的函数。这既高效又简单。唯一的缺点是：它可能会使我们的函数签名膨胀。实际上，有一个抽象这个概念的monad，称为`Reader`
monad。它可以在*base*库中的模块`Control.Monad.Reader`中找到。

在Idris中，有一个更简单的方法：我们可以使用自动隐式参数的证明搜索来进行依赖注入。这里有一些示例代码：

```idris
data Error : Type where
  NoNat  : String -> Error
  NoBool : String -> Error

record Console where
  constructor MkConsole
  read : IO String
  put  : String -> IO ()

record ErrorHandler where
  constructor MkHandler
  handle : Error -> IO ()

getCount' : (h : ErrorHandler) => (c : Console) => IO Nat
getCount' = do
  str <- c.read
  case parsePositive str of
    Nothing => h.handle (NoNat str) $> 0
    Just n  => pure n

getText' : (h : ErrorHandler) => (c : Console) => (n : Nat) -> IO (Vect n String)
getText' n = sequence $ replicate n c.read

prog' : ErrorHandler => (c : Console) => IO ()
prog' = do
  c.put "Please enter the number of lines to read."
  n  <- getCount'
  c.put "Please enter \{show n} lines of text."
  ls <- getText' n
  c.put "Read \{show n} lines and \{show . sum $ map length ls} characters."
```

示例程序从一些`Console`类型读取输入并打印输出，其实现留给函数的调用者。这是一个典型的依赖注入示例：我们的`IO`操作对如何读取和写入文本行一无所知（例如，它们不会直接调用`putStrLn`或`getLine`），而是依赖于一个外部*对象*来为我们处理这些任务。这允许我们在测试期间使用一个简单的*模拟对象*，而在运行应用程序时使用例如两个文件句柄或数据库连接。这些是典型的技术，通常在面向对象编程中找到，事实上，这个示例模拟了典型的面向对象模式，在纯函数式编程语言中：一个像`Console`这样的类型可以被视为一个*类*，提供一些功能（*方法*`read`和`put`），而一个类型为`Console`的值可以被视为这个类的*对象*，我们可以调用这些方法。

同样适用于错误处理：我们的错误处理程序可以默默地忽略任何发生的错误，或者它可以将其打印到`stderr`并同时写入一个日志文件。无论它做什么，我们的函数都不需要关心。

请注意，即使在这样一个非常简单的示例中，我们引入了两个额外的函数参数，并且我们可以很容易地看到在现实世界的应用程序中我们可能需要更多这样的参数，并且这会迅速使我们的函数签名膨胀。幸运的是，Idris有一个非常干净和简单的解决方案：`parameter`块。这些允许我们指定一个*参数*列表（不变的函数参数），由块中列出的所有函数共享。这些参数现在不再需要与每个函数一起列出，从而使我们的函数签名更简洁。以下是上面示例中的参数块：

```idris
parameters {auto c : Console} {auto h : ErrorHandler}
  getCount : IO Nat
  getCount = do
    str <- c.read
    case parsePositive str of
      Nothing => h.handle (NoNat str) $> 0
      Just n  => pure n

  getText : (n : Nat) -> IO (Vect n String)
  getText n = sequence $ replicate n c.read

  prog : IO ()
  prog = do
    c.put "Please enter the number of lines to read."
    n  <- getCount
    c.put "Please enter \{show n} lines of text."
    ls <- getText n
    c.put "Read \{show n} lines and \{show . sum $ map length ls} characters."
```

我们可以将任意数量的参数（隐式、显式、自动隐式、命名和未命名）作为`parameters`块中的参数列出，但它最好与隐式和自动隐式参数一起使用。显式参数必须显式地传递给参数块中的函数，即使从具有相同显式参数的其他参数块调用它们也是如此。这可能会相当混乱。

为了完成这个示例，这里是一个运行程序的主函数。请注意，我们如何显式组装`Console`和`ErrorHandler`，以便在调用`prog`时使用。

```idris
main : IO ()
main =
  let cons := MkConsole (trim <$> getLine) putStrLn
      err  := MkHandler (const $ putStrLn "It didn't work")
   in prog
```

通过自动隐式参数的依赖注入只是参数块的一种可能应用。它们在一般情况下的有用性在于我们有许多重复的参数列表。

## 文档

文档是关键。无论是其他程序员使用我们编写的库，还是我们自己将来试图理解我们的代码，重要的是用注释来注释我们的代码，解释非平凡的实现细节和描述导出数据类型和函数的意图和功能。

### 注释

在Idris源文件中写注释就像在两个连字符后添加一些文本一样简单：

```idris
-- this is a truly boring comment
boring : Bits8 -> Bits8
boring a = a -- probably I should just use `id` from the Prelude
```

每当一行包含两个连字符，而这些连字符不是字符串文字的一部分时，Idris会将该行的其余部分解释为注释。

也可以使用分隔符`{-`和`-}`来编写多行注释：

```idris
{-
  This is a multiline comment. It can be used to comment
  out whole blocks of code, for instance if we get several
  type errors in a larger source file.
-}
```

### 文档字符串

虽然注释是针对阅读和试图理解我们源代码的程序员，但文档字符串提供了导出函数和数据类型的文档，解释它们的意图和行为给其他人。

这是一个文档化函数的例子：

```idris
||| Tries to extract the first two elements from the beginning
||| of a list.
|||
||| Returns a pair of values wrapped in a `Just` if the list has
||| two elements or more. Returns `Nothing` if the list has fewer
||| than two elements.
export
firstTwo : List a -> Maybe (a,a)
firstTwo (x :: y :: _) = Just (x,y)
firstTwo _             = Nothing
```

让我们在 REPL 上试一试：

```repl
Appendices.Projects> :doc firstTwo
Appendices.Projects.firstTwo : List a -> Maybe (a,a)
  Tries to extract the first two elements from the beginning
  of a list.

  Returns a pair of values wrapped in a `Just` if the list has
  two elements or more. Returns `Nothing` if the list has fewer
  than two elements.
  Visibility: export
```

我们也可以以类似的方式记录数据类型及其构造函数：

```idris
||| 一个按其持有的值数量索引的二叉树。
|||
||| @param `n` : 存储在`Tree`中的值的数量
||| @param `a` : 存储在`Tree`中的值的类型
public export
data Tree : (n : Nat) -> (a : Type) -> Type where
  ||| 存储在二叉树叶子中的单个值。
  Leaf   : (v : a) -> Tree 1 a

  ||| 连接两个子树的分支。
  Branch : Tree m a -> Tree n a -> Tree (m + n) a
```

像往常一样，我们应该看看 REPL 的结果：

记录我们的代码非常重要。当你试图理解其他人的代码，或者当你几个月前写了一段非平凡的源代码，然后一直没有再看它时，你会意识到这一点。如果它没有很好地记录，这可能是一种不愉快的体验。Idris为我们提供了必要的工具来记录和注释我们的代码，所以应该花时间去做。这是值得的。

## 包

Idris包允许我们将几个模块组装成一个逻辑单元，并通过*安装*包使它们对其他Idris项目可用。在本节中，我们将学习Idris包的结构以及如何在项目中依赖其他包。

### `.ipkg`文件

Idris包的核心是一个`.ipkg`文件，通常但不一定存储在项目根目录中。例如，对于这个Idris教程，有一个文件`tutorial.ipkg`在教程的根目录中。

一个`.ipkg`文件由几个键值对（大多数是可选的）组成，其中最重要的是我将在这里描述的。到目前为止，设置一个新的Idris项目最简单的方法是让pack或Idris本身为你做这件事。只需运行

```sh
pack new lib pkgname
```

创建一个新的库的骨架或

```sh
pack new bin appname
```

创建一个新的应用程序。除了创建一个新的目录和合适的`.ipkg`文件外，这些命令还将添加一个`pack.toml`文件，我们将在下面进一步讨论。

### 依赖

`.ipkg`文件最重要的方面之一是列出库依赖的包。这是来自[*hedgehog*包](https://github.com/stefan-hoeck/idris2-hedgehog)的一个例子，这是一个在Idris中编写属性测试的框架：

```ipkg
depends    = base         >= 0.5.1
           , contrib      >= 0.5.1
           , elab-util    >= 0.5.0
           , pretty-show  >= 0.5.0
           , sop          >= 0.5.0
```

正如你所看到的，*hedgehog*依赖于*base*和*contrib*，它们都是每个Idris安装的一部分，但也依赖于[*elab-util*](https://github.com/stefan-hoeck/idris2-elab-util)，一个用于编写推导器脚本的实用程序库（一种强大的技术，通过编写Idris代码创建Idris声明；如果你感兴趣，它还附带了一个冗长的教程），[*sop*](https://github.com/stefan-hoeck/idris2-sop)，一个通过*积和*表示法泛型派生接口实现的库（这是一个你可能想在某个时候检查的有用东西），以及[*pretty-show*](https://github.com/stefan-hoeck/idris2-pretty-show)，一个用于漂亮打印Idris值的库（*hedgehog*在这种情况下使用它，以防测试失败）。

因此，在你实际上可以使用*hedgehog*为你的项目编写一些属性测试之前，你需要先安装它依赖的包。由于这可能很繁琐，最好让一个包管理器（如pack）为你处理这个任务。

#### 依赖版本

你可能想要指定一个特定的版本（或范围）Idris应该用于你的依赖。这在你有几个版本的相同包安装并且它们都不兼容你的项目时可能很有用。以下是几个例子：

```ipkg
depends    = base         == 0.5.1
           , contrib      == 0.5.1
           , elab-util    >= 0.5.0
           , pretty-show
           , sop          >= 0.5.0 && < 0.6.0
```

这将查找版本完全符合给定版本的包*base*和*contrib*，包*elab-util*的版本大于或等于`0.5.0`，包*pretty-show*的任何版本，以及包*sop*的版本在给定范围内。在所有情况下，如果一个包的几个安装版本符合指定的范围，将使用最新版本。

为了在你的包中使用这个功能，每个`.ipkg`文件都应该给出包的名称和当前版本：

```ipkg
package tutorial

version    = 0.1.0
```

正如我将在下面展示的，当使用pack和它的精选包集合时，包版本扮演一个不那么重要的角色。但即使如此，你可能也想考虑限制你接受的包的版本，以确保你抓住任何上游引入的破坏性变化。

### 库模块

许多（如果不是大多数）在GitHub上可用的Idris包是编程*库*：它们实现一些功能并使其对所有依赖于给定包的项目可用。这与Idris*应用程序*不同，后者应该被编译为可执行文件，然后可以在你的计算机上运行。Idris项目本身提供了两者：Idris编译器应用程序，我们用它来类型检查和构建其他Idris库和应用程序，以及一些库，如*prelude*、*base*和*contrib*，它们提供在大多数Idris项目中有用的基本数据类型和函数。

为了类型检查和安装你在库中编写的模块，你必须在`.ipkg`文件的`modules`字段中列出它们。以下是*sop*包的一个摘录：

```ipkg
modules = Data.Lazy
        , Data.SOP
        , Data.SOP.Interfaces
        , Data.SOP.NP
        , Data.SOP.NS
        , Data.SOP.POP
        , Data.SOP.SOP
        , Data.SOP.Utils
```

此列表中缺少的模块将*不会*被安装，因此对依赖于sop库的其他包不可用。

### Pack 和它的精选包集合

当你的项目的依赖图变得庞大而复杂时，也就是说，当你的项目依赖于许多库，而这些库本身又依赖于其他库时，可能会发生两个包都依赖于第三个包的不同版本的情况。这种情况几乎不可能解决，并且在处理冲突库时会导致很多挫败感。

因此，pack项目的哲学是从一开始就避免这种情况，通过使用*精选包集合*。一个pack集合由Idris编译器的特定Git提交和一个包集组成，每个包再次在特定的Git提交中，所有这些包都经过测试，可以很好地协同工作，没有问题。你可以在这里看到pack可用的包列表[here](https://github.com/stefan-hoeck/idris2-pack-db/blob/main/STATUS.md)。

每当一个你正在工作的项目依赖于pack的包集合中列出的一个库时，pack会自动为你安装它和它的所有依赖。然而，你可能也想依赖一个尚未成为pack集合一部分的库。在这种情况下，你必须在你的`pack.toml`文件之一中指定该库的问题
-
在`$HOME/.pack/user/pack.toml`中找到的全局文件，或者一个本地到你的当前项目或其父目录之一（如果有的话）。在那里，你可以指定一个本地到你的系统的依赖或一个Git项目（本地或远程）。以下是每种情况的示例：

```toml
[custom.all.foo]
type = "local"
path = "/path/to/foo"
ipkg = "foo.ipkg"

[custom.all.bar]
type   = "github"
url    = "https://github.com/me/bar"
commit = "latest:main"
ipkg   = "bar.ipkg"
```

正如你所看到的，在两种情况下，你必须指定项目可以找到的位置以及`.ipkg`文件的名称和位置。在Git项目的情况下，你还需要告诉pack应该使用哪个提交。在上面的例子中，我们想要使用`main`分支的最新提交。我们可以使用`pack
fetch`来获取并存储当前的最新提交哈希。

像上面给出的条目足以添加对自定义库的支持到pack。你现在可以在你自己的项目中将这些库列为依赖，pack会自动为你安装它们。

## 结论

这结束了我们对Idris项目结构化的章节。我们已经学习了几种代码块 -
`failing`块用于显示一段代码无法推导，`namespace`用于在同一个源文件中重载名称，以及参数块用于在函数之间共享参数列表 -
以及如何将几个源文件组装成一个Idris库或应用程序。最后，我们学习了如何在Idris项目中包含外部库以及如何使用pack来帮助我们跟踪这些依赖。

<!-- vi: filetype=idris2:syntax=markdown
-->
