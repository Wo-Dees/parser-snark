%{
    #include "driver.hh"
    #include "parser.hh"
%}

%option noyywrap nounput noinput
%option batch debug
%option c++

%option yyclass="Scanner"

%{
  void Scanner::UpdateLocation() {
      if (driver.location_debug) {
          std::cerr << "Action called " << driver.location << std::endl;
      }
      driver.location.columns(yyleng);
  }
  #define YY_USER_ACTION UpdateLocation();
%}

file_name_md [a-zA-Z][a-zA-Z_0-9.]*.md
file_name_json [a-zA-Z][a-zA-Z_0-9.]*.json
variable [a-zA-Z][a-zA-Z_0-9./\_]*
blank [ |\t|\r|\n]

%%

%{
  yy::location& loc = driver.location;
  if (driver.location_debug) {
      std::cerr << "BEFORE " << loc << std::endl;
  }
%}

{blank}   {
               if (driver.location_debug) {
                   std::cerr << "Blank matched" << std::endl;
               }
               driver.offset_ += 1;
           }

"\""            return yy::parser::make_DOT(loc);
"@"             return yy::parser::make_DOG(loc);
"include"       return yy::parser::make_INCLUDE(loc);
"import"        return yy::parser::make_IMPORT(loc);
"from"          return yy::parser::make_FROM(loc);
"="             return yy::parser::make_EUQ(loc);
"let"           return yy::parser::make_LET(loc);
")"             return yy::parser::make_RPAREN(loc);
"("             return yy::parser::make_LPAREN(loc);

{file_name_json} {
                    if (driver.location_debug) {
                        std::cerr << "ID found " << yytext << std::endl;
                    }
                    return yy::parser::make_IDENTIFIER_FILE_JSON(yytext, loc);
                 }

{file_name_md}  {
                    if (driver.location_debug) {
                        std::cerr << "ID found " << yytext << std::endl;
                    }
                    return yy::parser::make_IDENTIFIER_FILE_MD(yytext, loc);
                }

{variable}      {
                    if (driver.location_debug) {
                        std::cerr << "ID found " << yytext << std::endl;
                    }
                    return yy::parser::make_IDENTIFIER_VARIABLE(yytext, loc);
                }

<<EOF>>    return yy::parser::make_END (loc);


%{
  if (driver.location_debug) {
      std::cerr << "AFTER " <<  loc << std::endl;
  }
%}

%%