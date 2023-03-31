%skeleton "lalr1.cc"
%require "3.5"

%defines
%define api.token.constructor
%define api.value.type variant
%define parse.assert
%define parse.trace
%define parse.error verbose
%define api.token.prefix {TOK_}

%lex-param { Scanner &scanner }

%parse-param { Scanner &scanner }
%parse-param { Driver &driver }

%locations

%code requires {
    #include <string>

    class Scanner;
    class Driver;
}

%code {
    #include "driver.hh"
    #include "location.hh"

    static yy::parser::symbol_type yylex(Scanner &scanner) {
        return scanner.ScanToken();
    }
}

%token
    END 0 "end of file"
    DOT "\""
    DOG "@"
    INCLUDE "include"
    IMPORT "import"
    FROM "from"
    EUQ "="
    LET "let"
    LPAREN "("
    RPAREN ")"
;

%token <std::string> IDENTIFIER_FILE_MD "file_name_md"
%token <std::string> IDENTIFIER_FILE_JSON "file_name_json"
%token <std::string> IDENTIFIER_VARIABLE "variable"

%nterm <std::string> assignment
%nterm <std::string> assignments
%nterm <std::string> unit

%%

%start unit;

%right "import";
%right "include";
%right "let";

unit:
	assignments {
	};

assignments:
	%empty {
	}
    	| assignment assignments {
    	};

assignment:
    "@" "include" "(" "file_name_md" ")"  {
    	driver.offset_ += (10 + $4.size());
        driver.include_.insert($4);
    }
    | "@" "include" "(" "file_name_json" ")"  {
        driver.offset_ += (10 + $4.size());
        driver.include_.insert($4);
    }
    | "@" "let" "variable" "=" "\"" "variable" "\"" {
    	driver.offset_ += (7 + $3.size() + $6.size());
	driver.let_.insert({$3, $6});
    }
    | "@" "import" "variable" "from" "file_name_md" {
    	driver.offset_ += (11 + $3.size() + $5.size());
	driver.import_.insert({$3, $5});
    }
    | "@" "import" "variable" "from" "file_name_json" {
      	driver.offset_ += (11 + $3.size() + $5.size());
    	driver.import_.insert({$3, $5});
    }
    | "@" "variable" {
    	driver.offset_ += 1;
	driver.reference_.insert({$2, driver.offset_});
	driver.offset_ += ($2.size());
    };
%%

void yy::parser::error(const location_type& l, const std::string& m) {
    std::cerr << l << ": " << m << '\n';
}
