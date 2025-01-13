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
    fmt.Println("Please enter an expression:")
    if scanner.Scan() {
        input := scanner.Text()
        lexer := NewLexer(input) // 将输入字符串传递给词法分析器
        yyParse(lexer)
    }
}
%}

%union {
    value int
}

%token <value> NUMBER
%type <value> expr
%type <value> term

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