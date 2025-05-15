# 函数第 1 部分

Idris 是一种*函数式*编程语言。这意味着函数是其主要的抽象方式（与 Java 等面向对象语言不同，后者以 *对象* 和 *类*
作为主要抽象）。这也意味着我们期望 Idris 能够让我们非常方便地组合和复用函数来构建新函数。实际上，在 Idris
中，函数是*一等公民*：函数既可以接收其他函数作为参数，也可以返回函数作为结果。

我们已经在[介绍](Intro.md)中了解了 Idris 顶层函数声明的基本形式，接下来我们将基于之前的内容继续学习。

```idris
module Tutorial.Functions1
```

## 多参函数

让我们来实现一个函数，用于判断其三个 `Integer`
参数是否构成一个[勾股三元组](https://en.wikipedia.org/wiki/Pythagorean_triple)。为此我们将用到一个新的运算符：`==`（相等运算符）。

```idris
isTriple : Integer -> Integer -> Integer -> Bool
isTriple x y z = x * x + y * y == z * z
```

在讨论类型之前，先在 REPL 里试用一下这个函数：

```repl
Tutorial.Functions1> isTriple 1 2 3
False
Tutorial.Functions1> isTriple 3 4 5
True
```

从这个例子可以看出，多参函数的类型就是一串参数类型（也称为*输入类型*），通过函数箭头（`->`）连接，最后以输出类型（本例为 `Bool`）结尾。

这个实现看起来有点像数学等式：我们在 `=`
左侧列出参数，在右侧描述对这些参数的计算过程。函数式编程语言中的函数实现通常更具数学风格，而命令式语言则更侧重于描述*如何*计算（即通过一系列命令式语句描述算法），而不是*要计算什么*。稍后我们会看到
Idris 也支持命令式风格，但通常我们更推荐声明式风格。

从 REPL 示例可以看出，调用函数时只需用空格分隔各参数，无需括号，除非某个参数表达式本身包含空格。这个特性在部分应用函数时非常方便（详见本章后文）。

需要注意的是，与 `Integer` 或 `Bits8` 不同，`Bool` 并不是 Idris
语言内置的原始数据类型，而是一个你完全可以自己定义的自定义数据类型。关于如何声明新数据类型，我们将在下一章详细介绍。

## 函数组合

函数可以有多种组合方式，最直接的就是使用点运算符（.）：

```idris
square : Integer -> Integer
square n = n * n

times2 : Integer -> Integer
times2 n = 2 * n

squareTimes2 : Integer -> Integer
squareTimes2 = times2 . square
```

你可以在 REPL 里试试这个例子，看看结果是否如你所料？

其实不用点运算符也能实现 `squareTimes2`，比如这样：

```idris
squareTimes2' : Integer -> Integer
squareTimes2' n = times2 (square n)
```

需要注意，点运算符（.）连接的函数是从右往左依次调用的：`times2 . square` 实际等价于 `\n => times2 (square n)`，而不是 `\n => square (times2 n)`。

我们可以很方便地用点运算符将多个函数串联起来，编写更复杂的函数：

```idris
dotChain : Integer -> String
dotChain = reverse . show . square . square . times2 . times2
```

这个函数会先将参数乘以四，然后连续平方两次，接着转为字符串（`show`），最后将结果字符串反转（`show` 和 `reverse` 都是 Idris
*Prelude* 的一部分，在所有 Idris 程序中都可用）。

## 高阶函数

函数可以接收其他函数作为参数。这是一个非常强大的概念，稍不留神就会写出很"疯狂"的代码。为了循序渐进，我们先从简单的例子开始：

```idris
isEven : Integer -> Bool
isEven n = mod n 2 == 0

testSquare : (Integer -> Bool) -> Integer -> Bool
testSquare fun n = fun (square n)
```

`isEven` 首先用 `mod` 函数判断一个整数能否被 2 整除。但更有意思的是 `testSquare`，它有两个参数：第一个参数是
*`Integer` 到 `Bool` 的函数*，第二个参数是 `Integer`。第二个参数会先平方，再传给第一个参数。你可以在 REPL 里试试：

```repl
Tutorial.Functions1> testSquare isEven 12
True
```

请仔细体会这里发生了什么：我们把 `isEven` 作为参数传给 `testSquare`，第二个参数是整数，会先平方再传给
`isEven`。虽然这个例子本身不复杂，但你会发现将函数作为参数传递有很多实际用途。

我在上面说过，我们很容易"发疯"。例如，考虑以下示例：  

```idris
twice : (Integer -> Integer) -> Integer -> Integer
twice f n = f (f n)
```

在 REPL 里试一下：

```repl
Tutorial.Functions1> twice square 2
16
Tutorial.Functions1> (twice . twice) square 2
65536
Tutorial.Functions1> (twice . twice . twice . twice) square 2
*** huge number ***
```

你可能会对这种行为感到惊讶，我们来拆解一下。下面两个表达式的行为完全一致：

```idris
expr1 : Integer -> Integer
expr1 = (twice . twice . twice . twice) square

expr2 : Integer -> Integer
expr2 = twice (twice (twice (twice square)))
```

所以，`square` 是二次方，`twice square` 是四次方（连续调用两次 `square`），`twice (twice square)`
是十六次方（连续两次 `twice square`），以此类推，直到 `twice (twice (twice (twice square)))` 变成
65536 次方，结果会非常巨大。

## 柯里化

一旦我们开始使用高阶函数，偏应用函数的概念（在数学家和逻辑学家 Haskell Curry 之后也称为 *柯里化*）变得非常重要。

在 REPL 会话中加载此文件并尝试以下操作：

```repl
Tutorial.Functions1> :t testSquare isEven
testSquare isEven : Integer -> Bool
Tutorial.Functions1> :t isTriple 1
isTriple 1 : Integer -> Integer -> Bool
Tutorial.Functions1> :t isTriple 1 2
isTriple 1 2 : Integer -> Bool
```

请注意，在 Idris 中我们可以对多参函数进行部分应用，结果会得到一个新函数。例如，`isTriple 1` 实际上是把参数 `1` 应用到 `isTriple` 上，返回一个类型为 `Integer -> Integer -> Bool` 的新函数。我们甚至可以将这种部分应用的结果用于新的顶层定义：

```idris
partialExample : Integer -> Bool
partialExample = isTriple 3 4
```

在 REPL 里试一下：

```repl
Tutorial.Functions1> partialExample 5
True
```

在上面的 `twice` 示例中，我们已经用偏应用函数的方式，仅用极少的代码就实现了令人印象深刻的效果。

## 匿名函数

有时我们希望把一个小的自定义函数传递给高阶函数，但又不想专门写一个顶层定义。例如，下面的 `someTest`
函数非常具体，通常用处不大，但我们依然可以把它传给高阶函数 `testSquare`：

```idris
someTest : Integer -> Bool
someTest n = n >= 3 || n <= 10
```

下面演示如何将其传递给 `testSquare`：

```repl
Tutorial.Functions1> testSquare someTest 100
True
```

我们也可以直接用匿名函数，无需定义 `someTest`：

```repl
Tutorial.Functions1> testSquare (\n => n >= 3 || n <= 10) 100
True
```

匿名函数有时也叫 *lambda*（源自[λ演算](https://en.wikipedia.org/wiki/Lambda_calculus)），之所以用反斜杠，是因为它形似希腊字母 λ。`\n =>` 语法表示一个参数为 `n` 的匿名函数，具体实现写在箭头右侧。和顶层函数一样，lambda 也可以有多个参数，用逗号分隔：`\x,y => x * x + y`。当我们把 lambda 作为参数传递给高阶函数时，通常需要用括号包裹，或者用美元符号 `($)` 分隔（详见下一节）。

注意，lambda 的参数没有类型标注，Idris 会根据上下文自动推断类型。

## 运算符

在 Idris 中，像 `.`、`*`、`+` 这样的中缀运算符其实并不是内建的，而是普通的 Idris
函数，只是语法上支持中缀写法。如果不用中缀写法，必须用括号括起来。

举个例子，让我们为类型为 `Bits8 -> Bits8` 的函数自定义运算符：

```idris
infixr 4 >>>

(>>>) : (Bits8 -> Bits8) -> (Bits8 -> Bits8) -> Bits8 -> Bits8
f1 >>> f2 = f2 . f1

foo : Bits8 -> Bits8
foo n = 2 * n + 3

test : Bits8 -> Bits8
test = foo >>> foo >>> foo >>> foo
```

除了声明和定义运算符本身，我们还必须指定它的结合性：`infixr 4 >>>` 表示，`(>>>)` 关联到右边（意味着 `f >>> g >>> h` 将被解释为 `f >>> (g >>> h)`)优先级为 `4`。你也可以在 REPL 中 看看 *Prelude* 导出的运算符的结合性：

```repl
Tutorial.Functions1> :doc (.)
Prelude.. : (b -> c) -> (a -> b) -> a -> c
  Function composition.
  Totality: total
  Fixity Declaration: infixr operator, level 9
```

当您在表达式中混合使用中缀运算符时，具有较高优先级的运算符绑定得更紧密。例如，`(+)` 的优先级为 8，而 `(*)` 的优先级为 9。因此，`a *
b + c ` 与 `(a * b) + c` 相同，而不是 `a * (b + c)`。

### 运算符块

运算符可以像常规函数一样被部分应用。在这种情况下，整个表达式必须用括号括起来，称为 *运算符块*。这里有两个例子：

```repl
Tutorial.Functions1> testSquare (< 10) 5
False
Tutorial.Functions1> testSquare (10 <) 5
True
```

可以看到，`(< 10)` 和 `(10 <)` 是有区别的。前者判断参数是否小于 10，后者判断 10 是否小于参数。

有一个例外，*减号*运算符 `(-)` 不能用运算符块。下面这个例子可以说明：

```idris
applyToTen : (Integer -> Integer) -> Integer
applyToTen f = f 10
```

这只是一个高阶函数，把 10 作为参数传给另一个函数。如下例所示，这种写法完全没问题：

```repl
Tutorial.Functions1> applyToTen (* 2)
20
```

但如果我们想让 10 减去 5，下面的写法就会失败：

```repl
Tutorial.Functions1> applyToTen (- 5)
Error: Can't find an implementation for Num (Integer -> Integer).

(Interactive):1:12--1:17
 1 | applyToTen (- 5)
```

问题在于，Idris 会把 `- 5` 解析为一个负数字面量，而不是运算符块。在这种情况下，我们只能用匿名函数来实现：

```repl
Tutorial.Functions1> applyToTen (\x => x - 5)
5
```

### 非运算符的中缀表示法

在 Idris 中，普通的二元函数也可以用反引号包裹后采用中缀写法。你甚至可以为它们定义优先级（结合性），像普通运算符一样用在运算符块中：

```idris
infixl 8 `plus`

infixl 9 `mult`

plus : Integer -> Integer -> Integer
plus = (+)

mult : Integer -> Integer -> Integer
mult = (*)

arithTest : Integer
arithTest = 5 `plus` 10 `mult` 12

arithTest' : Integer
arithTest' = 5 + 10 * 12
```

### *Prelude* 导出的运算符

下面列出 *Prelude*
导出的常用运算符。大多数运算符是*有约束*的，也就是说它们只适用于实现了某些*接口*的类型。现在不用担心接口的细节，后面会专门讲解。你可以放心地理解为：加法、乘法适用于所有数值类型，比较运算符适用于
*Prelude* 里几乎所有类型（除了函数类型）。

* `(.)`：函数组合
* `(+)`：加法
* `(*)`：乘法
* `(-)`：减法
* `(/)`：除法
* `(==)` ：判断两个值是否相等
* `(/=)` ：判断两个值是否不相等
* `(<=)`、`(>=)`、`(<)` 和 `(>)` ：比较运算符
* `($)`：函数应用

上面最特殊的是最后一个。它的优先级为
0，所有其他运算符都比它结合得更紧。此外，函数应用本身的结合性也很高，因此可以用它来减少括号。例如，`isTriple 3 4 (2 + 3 * 1)`
可以写成 `isTriple 3 4 $ 2 + 3 * 1`，效果完全一样。有时这样更易读，有时未必。需要记住的是：`fun $ x y` 就等价于
`fun (x y)`。

## 练习

1. 用点运算符重写 `testSquare` 和 `twice`，去掉第二个参数（可以参考 `squareTimes2`
   的写法）。这种高度简洁的写法有时被称为 *无参风格*（point-free style），通常是编写小工具函数的首选方式。

2. 用上面的 `isEven` 和 Idris *Prelude* 里的 `not` 组合声明并实现 `isOdd`，要求用无参风格。

3. 声明并实现函数 `isSquareOf`，判断第一个 `Integer` 参数是否是第二个参数的平方。

4. 声明并实现函数 `isSmall`，判断其 `Integer` 参数是否小于等于 100。实现时用 `<=` 或 `>=` 运算符。

5. 声明并实现函数 `absIsSmall`，判断其 `Integer` 参数的绝对值是否小于等于 100。实现时用 `isSmall` 和
   `abs`（来自 Idris *Prelude*），建议用无参风格。

6. 在这个稍微扩展的练习中，我们将实现一些实用程序来处理 `Integer` 谓词（从 `Integer` 到 `Bool`
   的函数）。实现以下高阶函数（在您的实现中使用布尔运算符 `&&`、`||` 和函数 `not`）：

   ```idris
   -- return true, if and only if both predicates hold
   and : (Integer -> Bool) -> (Integer -> Bool) -> Integer -> Bool

   -- return true, if and only if at least one predicate holds
   or : (Integer -> Bool) -> (Integer -> Bool) -> Integer -> Bool

   -- return true, if the predicate does not hold
   negate : (Integer -> Bool) -> Integer -> Bool
   ```

   完成这个练习后，在 REPL 中试一试。在下面的例子中，我们通过用反引号包裹来使用双参函数 `and` 的中缀表示法的。这只是一种语法糖，使某些功能应用程序更具可读性：

   ```repl
   Tutorial.Functions1> negate (isSmall `and` isOdd) 73
   False
   ```

7. 如上所述，Idris 允许我们定义自己的中缀运算符。更好的是，Idris 支持函数名的
   *重载*，即两个函数或运算符可以有相同的名称，但类型和实现不同。 Idris 将使用类型来区分同名的运算符和函数。

   这允许我们重新实现函数 `and`、`or` 和 `negate`，在练习 6 中，使用布尔代数中现有的运算符和函数：

   ```idris
   -- return true, if and only if both predicates hold
   (&&) : (Integer -> Bool) -> (Integer -> Bool) -> Integer -> Bool
   x && y = and x y

   -- return true, if and only if at least one predicate holds
   (||) : (Integer -> Bool) -> (Integer -> Bool) -> Integer -> Bool

   -- return true, if the predicate does not hold
   not : (Integer -> Bool) -> Integer -> Bool
   ```

   实现另外两个函数，并在 REPL 里测试：

   ```repl
   Tutorial.Functions1> not (isSmall && isOdd) 73
   False
   ```

## 结论

本章小结：

* Idris 中的函数可以接受任意数量的参数，由函数类型中的 `->` 分隔。

* 函数可以依次使用点运算符进行组合，这会产生高度简洁的代码。

* 可以通过传递更少的函数来偏应用函数，参数少于函数的预期。结果是一个新的函数，预期传入剩下的参数。这种技术被称为 *柯里化*。

* 函数可以作为参数传递给其他函数，允许我们轻松组合小型程序单元来创建更复杂的行为。

* 如果编写相应的顶层函数太繁琐，我们可以将匿名函数 (*lambdas*) 传递给高阶函数。

* Idris 允许我们定义自己的中缀运算符。这些必须写在括号中，除非它们被声明为中缀表示法。

* 也可以部分应用中缀运算符。这些 *运算符块* 必须用括号括起来，并且用作运算符的第一个或第二个参数被确定。

* Idris 支持名称重载：函数可以具有相同的名称，但拥有不同的实现。Idris 将根据所涉及的类型决定使用哪个函数。

注意：同一个模块里的函数和运算符名必须唯一。如果要定义同名函数，必须放在不同模块。如果 Idris 无法自动区分，可以用 *命名空间* 前缀来指定：

```repl
Tutorial.Functions1> :t Prelude.not
Prelude.not : Bool -> Bool
Tutorial.Functions1> :t Functions1.not
Tutorial.Functions1.not : (Integer -> Bool) -> (Integer -> Bool) -> Integer -> Bool
```

### 下一步是什么

在[下一章](DataTypes.md)中，我们将学习如何自定义数据类型，以及如何构造和解构这些新类型的值，还会介绍泛型类型和泛型函数。

<!-- vi: filetype=idris2:syntax=markdown
-->
