
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

 **语法规则** ：

* 每条规则的形式是：非终结符: 产生式 { 动作 }。

* \$\$ 表示当前规则的结果值。

* \$1, \$2, \$3 等表示产生式中第 1、2、3 个符号的值。

##### 规则详解

1. input规则

```
input:
    expr { fmt.Println($1) }
    ;
```
* 表示整个输入是一个 expr（表达式）。

* 动作 { fmt.Println(\$1) }：解析完成后，打印表达式的值（ \$1 是 expr 的值）。

2. expr规则

```
expr:
    expr '+' term { $$ = $1 + $3 }
    | term { $$ = $1 }
    ;
```

* 表示一个表达式可以是一个表达式加上一个项（expr '+' term），或者直接是一个项（term）。

* 动作 { \$\$ = \$1 + \$3 }：如果是 expr '+' term，则将 expr 的值（$1）和 term 的值（\$3）相加，结果赋给 \$\$。

* 动作 { \$\$ = \$1 }：如果是 term，则直接将 term 的值赋给 $$。

3. term规则

```
term:
    NUMBER { $$ = $1 }
    ;
```

* 表示一个项可以是一个数字（NUMBER）。

* 动作 { \$\$ = \$1 }：将 NUMBER 的值赋给 \$\$。

#### 4. Epilogue（结尾部分）

```
// 词法分析器
type Lexer struct {
    input string
    pos   int
}

func NewLexer(input string) *Lexer {
    return &Lexer{input: input}
}

func (l *Lexer) Lex(lval *yySymType) int {
    for l.pos < len(l.input) {
        switch c := l.input[l.pos]; {
        case c >= '0' && c <= '9':
            lval.value = 0
            for l.pos < len(l.input) && l.input[l.pos] >= '0' && l.input[l.pos] <= '9' {
                lval.value = lval.value*10 + int(l.input[l.pos]-'0')
                l.pos++
            }
            return NUMBER
        case c == '+':
            l.pos++
            return '+'
        case c == ' ' || c == '\t':
            l.pos++
            continue
        default:
            fmt.Printf("Unknown character: %c\n", c)
            l.pos++
        }
    }
    return 0
}

func (l *Lexer) Error(s string) {
    fmt.Println("Error:", s)
}
```

* yySymType 是 goyacc 生成解析器时自动定义的一个结构体类型，用于表示符号（token 或非终结符）的值类型。它是解析器中符号值的载体，通常与 %union 定义的类型相关联。


* 词法分析器：goyacc 生成的解析器需要一个词法分析器来提供符号（tokens）。这里实现了一个简单的词法分析器。

    * Lexer 结构体：包含输入字符串和当前位置。

    * NewLexer 函数：初始化词法分析器。

    * Lex 方法：实现词法分析逻辑。

        * 读取输入字符串，识别数字（NUMBER）和加号（'+'）。

        * 将数字转换为整数值并存储在 lval.value 中。

        * 返回符号的类型（NUMBER 或 '+'）。

    * Error 方法：用于报告解析错误。

 