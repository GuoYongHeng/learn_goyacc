%{
package main

import (
    "fmt"
    "os"
    "bufio"
)

func main() {
    // 从标准输入读取数据
    scanner := bufio.NewScanner(os.Stdin)
    fmt.Println("Please enter strings to concatenate (e.g., 'hello + world'):")
    if scanner.Scan() {
        input := scanner.Text()
        lexer := NewLexer(input) // 将输入字符串传递给词法分析器
        yyParse(lexer)
    }
}
%}

%union {
    str string // 定义符号值的类型为字符串
}

%token <str> STRING
%type <str> expr term

%left '+' // 定义加号为左结合

%%

input:
    expr { fmt.Println("Result:", $1) } // 打印连接后的字符串
    ;

expr:
    expr '+' term { $$ = $1 + $3 } // 字符串连接
    | term        { $$ = $1 }      // 单个字符串
    ;

term:
    STRING { $$ = $1 } // 字符串
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
    for l.pos < len(l.input) {
        switch c := l.input[l.pos]; {
        case c == '"': // 识别字符串
            l.pos++
            start := l.pos
            for l.pos < len(l.input) && l.input[l.pos] != '"' {
                l.pos++
            }
            if l.pos >= len(l.input) {
                fmt.Println("Error: Unterminated string")
                return 0
            }
            lval.str = l.input[start:l.pos] // 提取字符串内容
            l.pos++
            return STRING
        case c == '+': // 识别加号
            l.pos++
            return '+'
        case c == ' ' || c == '\t': // 跳过空白字符
            l.pos++
            continue
        default:
            fmt.Printf("Unknown character: %c\n", c)
            l.pos++
        }
    }
    return 0 // 结束输入
}

func (l *Lexer) Error(s string) {
    fmt.Println("Error:", s)
}