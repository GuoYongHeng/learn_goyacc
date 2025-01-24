package main

import (
	"fmt"
	"testing"
)

func TestLexer(t *testing.T) {
	input := "31 + 5.2 * (14 - 2)"

	lexer := NewLexer(input)

outerloop:
	for {
		val := &yySymType{}
		tpe := lexer.Lex(val)
		switch tpe {
		case ADD:
			fmt.Println("+")
		case SUB:
			fmt.Println("-")
		case MUL:
			fmt.Println("*")
		case DIV:
			fmt.Println("/")
		case LPAREN:
			fmt.Println("(")
		case RPAREN:
			fmt.Println(")")
		case NUMBER:
			fmt.Println(val.number)
		case 0:
			break outerloop
		default:
			panic("unknown token")
		}
	}
}
