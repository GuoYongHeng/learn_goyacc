## 字符串连接程序

相比example_1，example_2只是把int换成了string，其余的并没有改变。

但是example_2中多了个%left，这里说一下

在 goyacc 中，%left 和 %right 是用于定义运算符结合性和优先级的指令

%left 表示左结合，如下所示

* a - b - c 被解析为 (a - b) - c 

%right 表示右结合，如下所示

* a ^ b ^ c 被解析为 a ^ (b ^ c)

