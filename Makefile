TESTS_DIR := Tests
TESTS := $(wildcard $(TESTS_DIR)/*.c)

all: miniC

create_directories:
	@if [ ! -d "pdf/Tests" ]; then \
		mkdir -p pdf/Tests; \
	fi
	@if [ ! -d "dot/Tests" ]; then \
		mkdir -p dot/Tests; \
	fi

miniC: lex.yy.c y.tab.c 
	gcc lex.yy.c y.tab.c memory.c table_symbole.c -o miniC -ll

lex.yy.c: ANSI-C.l
	lex ANSI-C.l

y.tab.c: miniC.y
	yacc -d miniC.y 

test: create_directories miniC
	@for testfile in $(TESTS); do \
		echo "Running test: $$testfile"; \
		if ./miniC < $$testfile; then \
			echo -e "\033[0;32mTest : $$testfile OK\n\033[0m"; \
			dot -Tpdf ex.dot -o pdf/$$testfile.pdf; \
			mv ex.dot dot/$$testfile.dot; \
			echo -e "\033[0;32mPDF generated: $$testfile.pdf\n\033[0m"; \
		else \
			echo -e "\033[31;1mTest : $$testfile failed\n\033[0m"; \
		fi \
	done

start: miniC
	./miniC < $(file)
	dot -Tpdf ex.dot -o ex.pdf
	mv ex.dot dot/ex.dot
	mv ex.pdf pdf/ex.pdf
clean:
	rm -f lex.yy.c y.tab.c y.tab.h miniC 
	rm -f dot/Tests/*.dot pdf/Tests/*.pdf
	clear