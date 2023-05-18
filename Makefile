TESTS_DIR := Tests
TESTS := $(wildcard $(TESTS_DIR)/*.c)

all: miniC

miniC: lex.yy.c y.tab.c 
	gcc lex.yy.c y.tab.c memory.c table_symbole.c -o miniC

lex.yy.c: ANSI-C.l
	lex ANSI-C.l

y.tab.c: miniC.y
	yacc -d miniC.y

test: miniC
	@for testfile in $(TESTS); do \
		echo "Running test: $$testfile"; \
		if ./miniC < $$testfile; then \
			echo -e "\033[0;32mTest : $$testfile OK\n\033[0m"; \
		else \
			echo -e "\033[31;1mTest : $$testfile failed\n\033[0m"; \
		fi \
	done
start: miniC
	./miniC < Tests/switch.c
	dot -Tpdf ex.dot -o ex.pdf

clean:
	rm -f lex.yy.c y.tab.c y.tab.h miniC
	clear