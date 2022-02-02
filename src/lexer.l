/*
 * The MIT License (MIT)
 * 
 * Copyright (c) 2014 Krzysztof Narkiewicz <krzysztof.narkiewicz@ezaquarii.com>
 * 
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 * 
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 * 
 */

%{
	#include <cstdlib>
	#include <iostream>

	#include "../include/interpreter.h"
	/*#include "location.hh"*/
	#include "lexer.cpp"
	#include "scanner.h"

	/*
	* Original yyterminate() macro returns int. 
	* Since we're using Bison 3 variants as tokens, 
	* we must redeinfe it to change the type from `int` to `Parser::semantic_type`
	*/

	#define yyterminate() Synthetic::Parser::make_END(Synthetic::location());

	// This will track current scanner location.
	// Action is called when length of the token is known.
	#define YY_USER_ACTION m_driver.increaseLocation(yyleng);
	
	// !!!WARNING!!!
	// Location API is used, but the location is not initialized, 'cause I'm lazy. When making
	// a token with make_{something} method you can pass detailed token location. Current location
	// is accessible with m_driver.location() method. All puzzle elements are there - just
	// pass location value in every action code block below. I'm going to waste more time writing
	// this excuse than putting this boilerplate below...
	//
	// Location class can be found in location.hh and posistion.hh files. It's just a bit too much
	// boilerplate for this small example. Bummer.

%}

%option nodefault
%option noyywrap
%option c++

%option yyclass="Scanner"
%option prefix="Synthetic_"

%%

input|output { return Synthetic::Parser::make_KEYWORD(yytext, Synthetic::location()); }

int|float|bool { return Synthetic::Parser::make_PRIMITIVE_TYPE(yytext, Synthetic::location()); }

true|false {
		uint8_t value = strcmp(yytext, "true") == 0 ? 1 : 0;
		return Synthetic::Parser::make_BOOLEAN(value, Synthetic::location());
}

if { return Synthetic::Parser::make_IF(yytext, Synthetic::location()); }

else { return Synthetic::Parser::make_ELSE(yytext, Synthetic::location()); }

then { return Synthetic::Parser::make_THEN(yytext, Synthetic::location()); }

endif { return Synthetic::Parser::make_ENDIF(yytext, Synthetic::location()); }

for { return Synthetic::Parser::make_FOR(yytext, Synthetic::location()); }

forend { return Synthetic::Parser::make_FOREND(yytext, Synthetic::location()); }

while { return Synthetic::Parser::make_WHILE(yytext, Synthetic::location()); }

whileend { return Synthetic::Parser::make_WHILEEND(yytext, Synthetic::location()); }

do { return Synthetic::Parser::make_DO(yytext, Synthetic::location()); }

doend { return Synthetic::Parser::make_DOEND(yytext, Synthetic::location()); }

[a-z|A-Z][a-zA-Z0-9]*  { return Synthetic::Parser::make_ID(yytext, Synthetic::location()); }

[\+]{2} { return Synthetic::Parser::make_ID_INC(yytext, Synthetic::location()); }

[\-]{2} { return Synthetic::Parser::make_ID_DEC(yytext, Synthetic::location()); }

\!.*\! { return Synthetic::Parser::make_COMMENT(yytext, Synthetic::location()); }


\( { return Synthetic::Parser::make_LEFTPAR(Synthetic::location()); }
            
\) { return Synthetic::Parser::make_RIGHTPAR(Synthetic::location()); }

\{ { return Synthetic::Parser::make_LEFT_CURLY(Synthetic::location()); }
            
\} { return Synthetic::Parser::make_RIGHT_CURLY(Synthetic::location()); }

, { return Synthetic::Parser::make_COMMA(Synthetic::location()); }

; { return Synthetic::Parser::make_SEMICOLON(Synthetic::location()); }

[\+|\-|\*|\/]{1}   { return Synthetic::Parser::make_BINARY_OP(yytext, Synthetic::location()); }

\<|\>|\>\=|\<\=|and|or|not { return Synthetic::Parser::make_RELATIONAL_OP(yytext, Synthetic::location()); }

\= { return Synthetic::Parser::make_ASSIGN(Synthetic::location());}

[\n\t\s]+ { /* Whitespace */ }


[-+]?[0-9]+ {
		size_t number = strtoll(yytext, 0, 10);
		return Synthetic::Parser::make_NUMBER(number, Synthetic::location());
}

[-+]?[0-9]+[\.]?[0-9]+ {
		std::string::size_type sz;
		float number = std::stof(yytext, &sz); 
		return Synthetic::Parser::make_FLOAT(number, Synthetic::location());
}

. { std::cerr << "Scanner: unknown character [" << yytext << "]" << std::endl;  }
            
<<EOF>> { return yyterminate(); }

%%
