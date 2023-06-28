package main

import (
	"bufio"
	"fmt"
	"os"
	"unicode"
)

type Op int

const (
	Add Op = iota
	Sub
	Mul
	Div
)

type Monkey struct {
	Known bool
	Value int
	src1  string
	src2  string
	op    Op
}

func ValueMonkey(value int) Monkey {
	return Monkey{
		Known: true,
		Value: value,
	}
}

func OpMonkey(src1 string, op byte, src2 string) Monkey {
	return Monkey{
		Known: false,
		src1:  src1,
		op:    opValue(op),
		src2:  src2,
	}
}

func opValue(c byte) Op {
	if c == '+' {
		return Add
	} else if c == '-' {
		return Sub
	} else if c == '*' {
		return Mul
	} else if c == '/' {
		return Div
	}
	fmt.Fprintf(os.Stderr, "invalid op: %c\n", c)
	os.Exit(1)
	panic("bad")
}

func (o Op) Eval(v1 int, v2 int) int {
	if o == Add {
		return v1 + v2
	} else if o == Sub {
		return v1 - v2
	} else if o == Mul {
		return v1 * v2
	} else if o == Div {
		return v1 / v2
	}
	fmt.Fprintf(os.Stderr, "invalid op: %d\n", o)
	os.Exit(1)
	panic("bad")
}

func (m Monkey) Eval(dictionary map[string]Monkey) int {
	if !m.Known {
		v1 := dictionary[m.src1].Eval(dictionary)
		v2 := dictionary[m.src2].Eval(dictionary)
		m.Value = m.op.Eval(v1, v2)
		m.Known = true
	}
	return m.Value
}

func main() {
	monkey := make(map[string]Monkey)

	scanner := bufio.NewScanner(os.Stdin)
	for scanner.Scan() {
		line := scanner.Text()
		var name string
		if unicode.IsDigit(rune(line[6])) {
			var value int
			fmt.Sscanf(line, "%s %d", &name, &value)
			name = name[:4]
			monkey[name] = ValueMonkey(value)
		} else {
			var src1 string
			var op byte
			var src2 string
			fmt.Sscanf(line, "%s %s %c %s", &name, &src1, &op, &src2)
			name = name[:4]
			monkey[name] = OpMonkey(src1, op, src2)
		}
	}

	fmt.Println(monkey["root"].Eval(monkey))
}
