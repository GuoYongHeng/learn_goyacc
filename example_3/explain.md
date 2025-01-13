## 计算器

一个简单的计算器，支持加减乘除和括号，并且可以处理整数和浮点数。这个例子会展示如何定义优先级、结合性以及处理多种数据类型。

### Declarations（声明部分）

```
%union {
    num float64 // 定义符号值的类型为浮点数
}

%token <num> NUMBER
%type <num> expr

// 定义运算符的优先级和结合性
%left '+' '-'
%left '*' '/'
%right UMINUS // 单目负号
```
* %union：定义符号值的类型。这里定义了一个名为 num 的字段，类型为 float64，用于存储整数和浮点数。

* %token：定义终结符（token）。这里定义了一个名为 NUMBER 的终结符，它的值类型是 %union 中的 num 字段。

* %type：定义非终结符的类型。这里定义了一个名为 expr 的非终结符，它的值类型也是 %union 中的 num 字段。

* 优先级和结合性：

    * %left 定义左结合的运算符（加减法的优先级低于乘除法，靠后定义的运算符优先级更高）。

    * %right 定义右结合的运算符（单目负号 UMINUS）。

### Grammar Rules（语法规则）
```
%%

input:
    expr { fmt.Printf("Result: %v\n", $1) } // 打印计算结果
    ;

expr:
    expr '+' expr { $$ = $1 + $3 } // 加法
    | expr '-' expr { $$ = $1 - $3 } // 减法
    | expr '*' expr { $$ = $1 * $3 } // 乘法
    | expr '/' expr { $$ = $1 / $3 } // 除法
    | '-' expr %prec UMINUS { $$ = -$2 } // 单目负号
    | '(' expr ')' { $$ = $2 } // 括号
    | NUMBER { $$ = $1 } // 数字
    ;

%%
```

%prec UMINUS：指定单目负号的优先级。

### %prec讲解

%prec 是一个用于显式指定语法规则优先级的指令。它的作用是覆盖默认的优先级规则，允许你为某条语法规则指定一个特定的优先级。

#### 为什么需要 %prec？
在某些情况下，语法规则的默认优先级可能不符合预期。例如：

* 某些规则可能没有明显的运算符，但仍然需要优先级。

* 某些规则可能需要临时改变优先级。

%prec 允许你显式地为某条规则指定优先级，从而解决这些问题。

#### %prec 的语法

```
rule: rule_body %prec token
```

* rule 是语法规则的左侧非终结符。

* rule_body 是语法规则的右侧符号。

* token 是一个终结符，它的优先级和结合性会被应用到这条规则上。

#### %prec 的作用

%prec 的作用是将指定终结符的优先级和结合性应用到当前规则上。例如：

```
expr: expr ADD expr
    | expr SUB expr
    | MINUS expr %prec MUL
```
在这个例子中：

* MINUS expr 规则没有明显的运算符，因此它的默认优先级可能不符合预期。

* 使用 %prec MUL 将 MUL（乘法）的优先级和结合性应用到 MINUS expr 规则上。