package main

import "strconv"

// 表达式接口
type Expr interface {
	String() string // 用于打印 AST
	Eval() float64  // 用于计算表达式的值
}

// 数值节点（整数或浮点数）
type NumberExpr struct {
	Val float64
}

func (n NumberExpr) String() string {
	return strconv.FormatFloat(n.Val, 'f', -1, 64)
}

func (n NumberExpr) Eval() float64 {
	return n.Val
}

// 二元操作节点
type BinOpExpr struct {
	Op    string
	Left  Expr
	Right Expr
}

func (b BinOpExpr) String() string {
	return "(" + b.Left.String() + " " + b.Op + " " + b.Right.String() + ")"
}

func (b BinOpExpr) Eval() float64 {
	// 递归计算左右子树的值
	leftVal := b.Left.Eval()
	rightVal := b.Right.Eval()

	switch b.Op {
	case "+":
		return leftVal + rightVal
	case "-":
		return leftVal - rightVal
	case "*":
		return leftVal * rightVal
	case "/":
		if rightVal == 0 {
			panic("除零错误")
		}
		return leftVal / rightVal
	default:
		panic("未知操作符: " + b.Op)
	}
}
