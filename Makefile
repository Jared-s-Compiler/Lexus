COMPILER = flex

all: lexer

lexer: src/lexer.l
	$(COMPILER) -o src/lexer.cpp $<
clean:
	rm src/lexer.cpp
