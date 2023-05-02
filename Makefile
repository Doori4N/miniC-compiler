TESTS_DIR := Tests
TESTS := $(wildcard $(TESTS_DIR)/*.c)

all: miniC

miniC: lex.yy.c y.tab.c
	gcc lex.yy.c y.tab.c -o miniC

lex.yy.c: ANSI-C.l
	lex ANSI-C.l

y.tab.c: miniC.y
	yacc -d miniC.y

test: miniC
	@for testfile in $(TESTS); do \
		echo "Running test: $$testfile"; \
		./miniC < $$testfile; \
	done

clean:
	rm -f lex.yy.c y.tab.c y.tab.h miniC
	clear
