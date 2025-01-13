
### 文件结构

1. **Prologue（序言）：** 包含 Go 代码，通常是包声明、导入语句和全局变量等。

2. **Declarations（声明部分）：** 定义符号、类型和优先级等。

3. **Grammar Rules（语法规则）：** 定义语言的语法规则及其对应的动作。

4. **Epilogue（结尾部分）：** 包含词法分析器和其他辅助代码。

整体格式如下：
```
%{
Prologue
%}
Declarations

%%

Grammar Rules

%%

Epilogue
```

#### 1.Prologue（序言）
```
%{
package main

import (
    "fmt"
    "os"
)

func main() {
    // 从标准输入读取数据
    scanner := bufio.NewScanner(os.Stdin)
    fmt.Println("Please enter an expression:")
    if scanner.Scan() {
        input := scanner.Text()
        lexer := NewLexer(input) // 将输入字符串传递给词法分析器
        yyParse(lexer)
    }
}
%}
```
**%{** 和 **%}** ：这对符号用于包裹 Go 代码。goyacc 会将这些代码原封不动地复制到生成的解析器文件中。

**main 函数** ： 程序的入口点。调用 yyParse 函数启动解析过程，并传入一个词法分析器实例

#### 2. Declarations（声明部分）

```
%union {
    value int
}

%token <value> NUMBER
%type <value> expr
%type <value> term
```
**%union**：定义符号值的类型。这里定义了一个名为 value 的字段，类型为 int。%union 用于表示符号可以携带的数据类型。

**%token**：定义终结符（token）。这里定义了一个名为 NUMBER 的终结符，它的值类型是 %union 中的 value 字段（即 int）。

**%type**：定义非终结符的类型。这里定义了一个名为 expr 的非终结符，它的值类型也是 %union 中的 value 字段。

#### 3. Grammar Rules（语法规则）

```
%%

input:
    expr { fmt.Println($1) }
    ;

expr:
    expr '+' term { $$ = $1 + $3 }
    | term { $$ = $1 }
    ;

term:
    NUMBER { $$ = $1 }
    ;

%%
```

%%：分隔符，表示语法规则部分的开始和结束。

语法规则：

每条规则的形式是：非终结符: 产生式 { 动作 }。

\$\$ 表示当前规则的结果值。


\$1, \$2, \$3 等表示产生式中第 1、2、3 个符号的值。