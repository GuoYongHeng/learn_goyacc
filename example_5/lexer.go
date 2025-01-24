package main

import (
	"errors"
	"fmt"
	"strconv"
	"unicode"
)

type Lexer struct {
	input   string // 输入字符串
	pos     int    // 当前字符位置
	current rune   // 当前字符
}

// 初始化词法分析器
func NewLexer(input string) *Lexer {
	l := &Lexer{input: input}
	l.readChar() // 初始化第一个字符
	return l
}

// 读取下一个字符
func (l *Lexer) readChar() {
	if l.pos >= len(l.input) {
		l.current = 0 // EOF
	} else {
		l.current = rune(l.input[l.pos])
	}
	l.pos++
}

// 跳过空白字符
func (l *Lexer) skipWhitespace() {
	for l.current == ' ' || l.current == '\t' {
		l.readChar()
	}
}

// 读取数字（整数或浮点数）
func (l *Lexer) readNumber() (float64, error) {
	startPos := l.pos - 1 // 当前字符已经是数字的第一个字符
	hasDot := false

	for {
		if unicode.IsDigit(l.current) || l.current == '.' {
			if l.current == '.' {
				if hasDot {
					return 0, errors.New("数字包含多个小数点")
				}
				hasDot = true
			}
			l.readChar()
		} else {
			break
		}
	}

	// 提取数字字符串并转换
	numStr := l.input[startPos : l.pos-1]
	value, err := strconv.ParseFloat(numStr, 64)
	if err != nil {
		return 0, fmt.Errorf("无效数字格式: %s", numStr)
	}
	return value, nil
}

// 实现 goyacc 的 Lex 接口
func (l *Lexer) Lex(lval *yySymType) int {
	l.skipWhitespace()

	switch l.current {
	case '+':
		l.readChar()
		return ADD
	case '-':
		l.readChar()
		return SUB
	case '*':
		l.readChar()
		return MUL
	case '/':
		l.readChar()
		return DIV
	case '(':
		l.readChar()
		return LPAREN
	case ')':
		l.readChar()
		return RPAREN
	case 0: // EOF
		return 0
	}

	// 处理数字
	if unicode.IsDigit(l.current) || l.current == '.' {
		value, err := l.readNumber()
		if err != nil {
			panic(err)
		}
		lval.number = value
		return NUMBER
	}

	panic(fmt.Sprintf("无法识别的字符: %c", l.current))
}

// 错误处理（保持原接口）
func (l *Lexer) Error(e string) {
	panic(fmt.Sprintf("位置 %d: %s", l.pos, e))
}
