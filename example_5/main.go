package main

import (
	"fmt"
)

func main() {
	input := "10 + 3 * (5 - 4) + 2.3"

	// 初始化词法分析器
	lexer := NewLexer(input)

	// 调用 goyacc 生成的解析器
	yyParse(lexer)

	// 输出 AST
	fmt.Println("AST:", root.String())
	fmt.Println("Result:", root.Eval())
}
