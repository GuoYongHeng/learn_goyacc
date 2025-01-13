%{
package main

import (
    "fmt"
    "os"
    "bufio"
    "strconv"
    "unicode"
)

func main() {
    // 从标准输入读取数据
    scanner := bufio.NewScanner(os.Stdin)
    fmt.Println("Please enter an expression (e.g., '1 + 2 * (3 - 4)'):")
    if scanner.Scan() {
        input := scanner.Text()
        lexer := NewLexer(input) // 将输入字符串传递给词法分析器
        yyParse(lexer)
    }
}
%}

%union {
    num float64 // 定义符号值的类型为浮点数
}

%token <num> NUMBER
%type <num> expr

// 定义运算符的优先级和结合性
%left '+' '-'
%left '*' '/'
%right UMINUS // 单目负号

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

// 词法分析器
type Lexer struct {
    input string
    pos   int
}

func NewLexer(input string) *Lexer {
    return &Lexer{input: input}
}

func (l *Lexer) Lex(lval *yySymType) int {
    // 跳过空白字符
    for l.pos < len(l.input) && unicode.IsSpace(rune(l.input[l.pos])) {
        l.pos++
    }

    if l.pos >= len(l.input) {
        return 0 // 结束输入
    }

    // 识别数字（整数或浮点数）
    if c := l.input[l.pos]; c >= '0' && c <= '9' || c == '.' {
        start := l.pos
        for l.pos < len(l.input) && (unicode.IsDigit(rune(l.input[l.pos])) || l.input[l.pos] == '.') {
            l.pos++
        }
        num, err := strconv.ParseFloat(l.input[start:l.pos], 64)
        if err != nil {
            fmt.Printf("Error parsing number: %v\n", err)
            return 0
        }
        lval.num = num
        return NUMBER
    }

    // 识别运算符和括号
    switch c := l.input[l.pos]; c {
    case '+', '-', '*', '/', '(', ')':
        l.pos++
        return int(c)
    default:
        fmt.Printf("Unknown character: %c\n", c)
        l.pos++
        return 0
    }
}

func (l *Lexer) Error(s string) {
    fmt.Println("Error:", s)
}