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
	Equals
)

type Monkey struct {
	Known          bool
	Value          int
	IsHuman        bool
	HasHumanInTree bool
	src1           string
	src2           string
	op             Op
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
	} else if c == '=' {
		return Equals
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
	} else if o == Equals {
		if v1 == v2 {
			return 1
		} else {
			return 0
		}
	}
	fmt.Fprintf(os.Stderr, "invalid op: %d\n", o)
	os.Exit(1)
	panic("bad")
}

func (o Op) InverseLeft(a int, v int) int {
	if o == Add {
		return v - a
	} else if o == Sub {
		return v + a
	} else if o == Mul {
		return v / a
	} else if o == Div {
		return v * a
	} else if o == Equals {
		return a
	}
	fmt.Fprintf(os.Stderr, "invalid op for InverseLeft: %d\n", o)
	os.Exit(1)
	panic("bad")
}

func (o Op) InverseRight(a int, v int) int {
	if o == Add {
		return v - a
	} else if o == Sub {
		return a - v
	} else if o == Mul {
		return v / a
	} else if o == Div {
		return a / v
	} else if o == Equals {
		return a
	}
	fmt.Fprintf(os.Stderr, "invalid op for InverseLeft: %d\n", o)
	os.Exit(1)
	panic("bad")
}

func (m *Monkey) Eval(dictionary map[string]*Monkey) int {
	if m.IsHuman {
		fmt.Println("eval human")
	}
	if !m.Known {
		v1 := dictionary[m.src1].Eval(dictionary)
		v2 := dictionary[m.src2].Eval(dictionary)
		m.Value = m.op.Eval(v1, v2)
	}
	return m.Value
}

func (m *Monkey) dfsHumanTree(dictionary map[string]*Monkey) bool {
	if m.IsHuman {
		m.HasHumanInTree = true
	} else if m.Known {
		m.HasHumanInTree = false
	} else {
		a := dictionary[m.src1].dfsHumanTree(dictionary)
		b := dictionary[m.src2].dfsHumanTree(dictionary)
		m.HasHumanInTree = a || b
	}
	return m.HasHumanInTree
}

func (m *Monkey) MakeEqual(dictionary map[string]*Monkey, val int) {
	if m.IsHuman {
		fmt.Println(val)
		os.Exit(0)
	} else if m.Known {
		if m.HasHumanInTree {
			fmt.Fprintln(os.Stderr, "Known but HasHumanInTree")
		}
		fmt.Fprintf(os.Stderr, "trying to set monkey to %d, but known value of %d\n", val, m.Value)
		os.Exit(1)
	} else {
		if !m.HasHumanInTree {
			fmt.Fprintf(os.Stderr, "trying to make equal to %d, but no human in tree\n", val)
		}
		left := dictionary[m.src1]
		right := dictionary[m.src2]
		if left.HasHumanInTree {
			left.MakeEqual(dictionary, m.op.InverseLeft(right.Eval(dictionary), val))
		} else if right.HasHumanInTree {
			right.MakeEqual(dictionary, m.op.InverseRight(left.Eval(dictionary), val))
		} else {
			fmt.Fprintf(os.Stderr, "trying to make equal to %d, but no child has human in tree\n", val)
		}
	}
}

func main() {
	monkey := make(map[string]*Monkey)

	scanner := bufio.NewScanner(os.Stdin)
	for scanner.Scan() {
		line := scanner.Text()
		var name string
		if unicode.IsDigit(rune(line[6])) {
			var value int
			fmt.Sscanf(line, "%s %d", &name, &value)
			name = name[:4]
			m := ValueMonkey(value)
			if name == "humn" {
				m.IsHuman = true
			}
			monkey[name] = &m
		} else {
			var src1 string
			var op byte
			var src2 string
			fmt.Sscanf(line, "%s %s %c %s", &name, &src1, &op, &src2)
			name = name[:4]
			if name == "root" {
				op = '='
			}
			m := OpMonkey(src1, op, src2)
			monkey[name] = &m
		}
	}

	monkey["root"].dfsHumanTree(monkey)
	monkey["root"].MakeEqual(monkey, 1)
}
