%{
package main

// 定义 goyacc 的 union（对应 AST 节点）
var root Expr
%}

%union {
	number float64   // 存储数值
	expr   Expr      // 存储表达式节点
}

%token <number> NUMBER
%token ADD SUB MUL DIV
%token LPAREN RPAREN

%type<expr> expr

%left ADD SUB
%left MUL DIV

%%

input:
	expr { root = $1 }  // 将最终表达式存入 Lexer.result
;

expr:
	NUMBER          { $$ = NumberExpr{Val: $1} }  // 数值节点
	| expr ADD expr { $$ = BinOpExpr{Op: "+", Left: $1, Right: $3} }
	| expr SUB expr { $$ = BinOpExpr{Op: "-", Left: $1, Right: $3} }
	| expr MUL expr { $$ = BinOpExpr{Op: "*", Left: $1, Right: $3} }
	| expr DIV expr { $$ = BinOpExpr{Op: "/", Left: $1, Right: $3} }
	| LPAREN expr RPAREN { $$ = $2 }  // 括号优先级
;

%%