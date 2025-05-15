# Idris 2 中的函数式编程

[中文翻译](https://github.com/running-grass/idris2-tutorial-zh/blob/main/translation/README.md),
[日本語訳](https://github.com/gemmaro/idris2-tutorial/blob/ja/translation/ja/README.md)

本项目旨在成为 Idris 编程语言的较为全面的指南，并为函数式编程新手提供丰富的入门材料。

内容分为若干部分，其中核心语言特性部分是 Idris 函数式编程的主要指南。每部分包含多个章节，深入讲解 Idris
编程语言及其核心库的某一方面。大多数章节配有练习，解答见目录 `src/Solutions`。

目前，核心语言特性部分尚未完成，仍在积极开发中，并已在我的部分学生中试用，其中一些学生完全没有函数式编程经验。

## 目录

### 第 1 部分：核心语言特性

本部分旨在系统介绍 Idris 编程语言。如果您是函数式编程新手，请按顺序学习这些章节并*完成所有练习*。

如果您已使用过其他纯函数式编程语言（如 Haskell），则可快速浏览入门内容（函数第 1 部分、代数数据类型和接口），因为大部分内容您已熟悉。

1. [介绍](src/Tutorial/Intro.md)
   1. [关于 Idris 编程语言](src/Tutorial/Intro.md#关于-Idris-编程语言)
   2. [使用 REPL](src/Tutorial/Intro.md#使用-REPL)
   3. [第一个 Idris 程序](src/Tutorial/Intro.md#第一个-Idris-程序)
   4. [Idris 定义的结构](src/Tutorial/Intro.md#Idris-定义的结构)
   5. [如何获取帮助](src/Tutorial/Intro.md#如何获取帮助)
2. [函数第 1 部分](src/Tutorial/Functions1.md)
   1. [多参数函数](src/Tutorial/Functions1.md#多参数函数)
   2. [函数组合](src/Tutorial/Functions1.md#函数组合)
   3. [高阶函数](src/Tutorial/Functions1.md#高阶函数)
   4. [柯里化](src/Tutorial/Functions1.md#柯里化)
   5. [匿名函数](src/Tutorial/Functions1.md#匿名函数)
   6. [运算符](src/Tutorial/Functions1.md#运算符)
3. [代数数据类型](src/Tutorial/DataTypes.md)
   1. [枚举](src/Tutorial/DataTypes.md#枚举)
   2. [和类型](src/Tutorial/DataTypes.md#和类型)
   3. [记录](src/Tutorial/DataTypes.md#记录)
   4. [泛型数据类型](src/Tutorial/DataTypes.md#泛型数据类型)
   5. [数据定义的替代语法](src/Tutorial/DataTypes.md#数据定义的替代语法)
4. [接口](src/Tutorial/Interfaces.md)
   1. [接口基础](src/Tutorial/Interfaces.md#接口基础)
   2. [接口进阶](src/Tutorial/Interfaces.md#接口进阶)
   3. [Prelude 中的接口](src/Tutorial/Interfaces.md#Prelude-中的接口)
5. [函数第 2 部分](src/Tutorial/Functions2.md)
   1. [let 绑定与局部定义](src/Tutorial/Functions2.md#let-绑定与局部定义)
   2. [函数参数详解](src/Tutorial/Functions2.md#函数参数详解)
   3. [孔编程](src/Tutorial/Functions2.md#孔编程)
6. [依值类型](src/Tutorial/Dependent.md)
   1. [长度索引列表](src/Tutorial/Dependent.md#长度索引列表)
   2. [Fin：向量安全索引](src/Tutorial/Dependent.md#Fin-向量安全索引)
   3. [编译期计算](src/Tutorial/Dependent.md#编译期计算)
7. [IO：副作用编程](src/Tutorial/IO.md)
   1. [纯副作用？](src/Tutorial/IO.md#纯副作用)
   2. [Do 块脱糖](src/Tutorial/IO.md#Do-块脱糖)
   3. [文件操作](src/Tutorial/IO.md#文件操作)
   4. [IO 实现原理](src/Tutorial/IO.md#IO-实现原理)
8. [函子及其相关](src/Tutorial/Functor.md)
   1. [函子](src/Tutorial/Functor.md#函子)
   2. [应用函子](src/Tutorial/Functor.md#应用函子)
   3. [单子](src/Tutorial/Functor.md#单子)
   4. [背景与延伸阅读](src/Tutorial/Functor.md#背景与延伸阅读)
9. [递归与折叠](src/Tutorial/Folds.md)
   1. [递归](src/Tutorial/Folds.md#递归)
   2. [关于完全性检查的说明](src/Tutorial/Folds.md#关于完全性检查的说明)
   3. [可折叠（Foldable）接口](src/Tutorial/Folds.md#Foldable-接口)
10. [带副作用的遍历](src/Tutorial/Traverse.md)
    1. [阅读 CSV 表格](src/Tutorial/Traverse.md#阅读-CSV-表格)
    2. [使用状态编程](src/Tutorial/Traverse.md#使用状态编程)
    3. [组合的力量](src/Tutorial/Traverse.md#组合的力量)
11. [Sigma 类型](src/Tutorial/DPair.md)
    1. [依值对](src/Tutorial/DPair.md#依赖对)
    2. [用例：核酸](src/Tutorial/DPair.md#用例：核酸)
    3. [用例：带有模式的 CSV 文件](src/Tutorial/DPair.md#用例：带有模式的-CSV-文件)
12. [命题等式 Equality](src/Tutorial/Eq.md)
    1. [相等作为类型](src/Tutorial/Eq.md#相等作为类型)
    2. [程序作为证明](src/Tutorial/Eq.md#程序作为证明)
    3. [遁入虚无](src/Tutorial/Eq.md#遁入虚无)
    4. [重写规则](src/Tutorial/Eq.md#重写规则)
13. [谓词和证明搜索](src/Tutorial/Predicates.md)
    1. [前置条件](src/Tutorial/Predicates.md#前置条件)
    2. [值之间的契约](src/Tutorial/Predicates.md#值之间的契约)
    3. [用例：灵活的错误处理](src/Tutorial/Predicates.md#用例：灵活的错误处理)
    4. [接口的真相](src/Tutorial/Predicates.md#接口的真相)
14. [原语](src/Tutorial/Prim.md)
    1. [原语的实现](src/Tutorial/Prim.md#原语的实现)
    2. [使用字符串](src/Tutorial/Prim.md#使用字符串)
    3. [整数](src/Tutorial/Prim.md#整数)
    4. [细化原语](src/Tutorial/Prim.md#细化原语)

### 第 2 部分：附录

附录可用作手头主题的参考。我计划最终对 Idris 语法、典型错误消息、模块系统、交互式编辑以及可能的其他内容有一个简明的参考。

1. [pack 和 Idris2 入门](src/Appendices/Install.md)
2. [Neovim 中的交互式编辑](src/Appendices/Neovim.md)
3. [构造 Idris 项目](src/Appendices/Projects.md)
4. [深入量化类型理论](src/Appendices/QTT.md)

## 前置条件

目前，该项目正在针对 Idris 2 存储库的主要分支进行积极开发和演进。它每晚在 GitHub 上进行测试，并针对
[pack包集合](https://github.com/stefan-hoeck/idris2-pack-db) 中的最新版本进行构建。

为了更好地跟随本教程，强烈建议按照[这里](src/Appendices/Install.md)的说明，通过 pack 包管理器安装 Idris。
