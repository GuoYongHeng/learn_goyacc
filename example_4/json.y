%{
package main

import (
    "fmt"
    "os"
    "bufio"
    "strconv"
    "unicode"
)

// 定义 JSON 数据结构
type JSONValue interface{}

var result JSONValue

func main() {
    // 从标准输入读取数据
    scanner := bufio.NewScanner(os.Stdin)
    fmt.Println("Please enter a JSON string:")
    if scanner.Scan() {
        input := scanner.Text()
        lexer := NewLexer(input) // 将输入字符串传递给词法分析器
        yyParse(lexer)
        fmt.Println("Parsed JSON:", result)
    }
}
%}

%union {
    val JSONValue // 定义符号值的类型为 JSONValue
    str string    // 用于存储字符串
    num float64   // 用于存储数字
}

%token <str> STRING
%token <num> NUMBER
%token TRUE FALSE NULL
%token LBRACE RBRACE LBRACKET RBRACKET COLON COMMA

%type <val> json object array pair pairs elements value

%%

json:
    value { result = $1 } // 将解析结果存储在全局变量中
    ;

value:
    STRING      { $$ = $1 } // 字符串
    | NUMBER    { $$ = $1 } // 数字
    | object    { $$ = $1 } // 对象
    | array     { $$ = $1 } // 数组
    | TRUE      { $$ = true } // 布尔值 true
    | FALSE     { $$ = false } // 布尔值 false
    | NULL      { $$ = nil } // null
    ;

object:
    LBRACE pairs RBRACE { $$ = $2 } // 对象
    | LBRACE RBRACE     { $$ = make(map[string]interface{}) } // 空对象
    ;

pairs:
    pair                { $$ = $1 } // 单个键值对
    | pairs COMMA pair  {
        m := $1.(map[string]interface{})
        for k, v := range $3.(map[string]interface{}) {
            m[k] = v
        }
        $$ = m
    }
    ;

pair:
    STRING COLON value { $$ = map[string]interface{}{$1: $3} } // 键值对
    ;

array:
    LBRACKET elements RBRACKET { $$ = $2 } // 数组
    | LBRACKET RBRACKET        { $$ = []interface{}{} } // 空数组
    ;

elements:
    value                { $$ = []interface{}{$1} } // 单个元素
    | elements COMMA value { $$ = append($1.([]interface{}), $3) } // 多个元素
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

    // 识别字符串
    if c := l.input[l.pos]; c == '"' {
        l.pos++
        start := l.pos
        for l.pos < len(l.input) && l.input[l.pos] != '"' {
            l.pos++
        }
        if l.pos >= len(l.input) {
            fmt.Println("Error: Unterminated string")
            return 0
        }
        lval.str = l.input[start:l.pos]
        l.pos++
        return STRING
    }

    // 识别数字
    if c := l.input[l.pos]; c >= '0' && c <= '9' || c == '-' {
        start := l.pos
        if l.input[l.pos] == '-' {
            l.pos++
        }
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

    // 识别关键字（true, false, null）
    if l.pos+4 <= len(l.input) && l.input[l.pos:l.pos+4] == "true" {
        l.pos += 4
        return TRUE
    }
    if l.pos+5 <= len(l.input) && l.input[l.pos:l.pos+5] == "false" {
        l.pos += 5
        return FALSE
    }
    if l.pos+4 <= len(l.input) && l.input[l.pos:l.pos+4] == "null" {
        l.pos += 4
        return NULL
    }

    // 识别符号
    switch c := l.input[l.pos]; c {
    case '{':
        l.pos++
        return LBRACE
    case '}':
        l.pos++
        return RBRACE
    case '[':
        l.pos++
        return LBRACKET
    case ']':
        l.pos++
        return RBRACKET
    case ':':
        l.pos++
        return COLON
    case ',':
        l.pos++
        return COMMA
    default:
        fmt.Printf("Unknown character: %c\n", c)
        l.pos++
        return 0
    }
}

func (l *Lexer) Error(s string) {
    fmt.Println("Error:", s)
}