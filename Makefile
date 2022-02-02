COMPILER = clang++
CFLAGS   =   -stdlib=libc++ -Weverything        \
			-Wno-comma                         \
			-Wno-unused-template               \
			-Wno-sign-conversion               \
			-Wno-exit-time-destructors         \
			-Wno-global-constructors           \
			-Wno-missing-prototypes            \
			-Wno-weak-vtables                  \
			-Wno-padded                        \
			-Wno-double-promotion              \
			-Wno-c++98-compat-pedantic         \
			-Wno-c++11-compat-pedantic         \
			-Wno-c++14-compat-pedantic         \
			-Wno-c++17-compat-pedantic         \
			-fdiagnostics-show-category=name   \
											   \
			-Wno-zero-as-null-pointer-constant \
			-Wno-ctad-maybe-unsupported        

all: lexer

lexer: src/lexer.l
	flex -o src/lexer.cpp $<
	$(COMPILER) $(CFLAGS) -c src/lexer.cpp -o lexer.o

#clean: 
	#rm $(OUTPUT) $(OBJS) src/scanner.cpp src/parser.cpp src/parser.hpp src/*.hh
