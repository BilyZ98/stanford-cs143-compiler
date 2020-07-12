%option noyywrap

/*
 *  The scanner definition for COOL.
 */

/*
 *  Stuff enclosed in %{ %} in the first section is copied verbatim to the
 *  output, so headers and global definitions are placed here to be visible
 * to the code in the file.  Don't remove anything that was here initially
 */
%{
#include <cool-parse.h>
#include <stringtab.h>
#include <utilities.h>
#include <string>

/* The compiler assumes these identifiers. */
#define yylval cool_yylval
#define yylex  cool_yylex


/* Max size of string constants */
#define MAX_STR_CONST 1025
#define YY_NO_UNPUT   /* keep g++ happy */

extern FILE *fin; /* we read from this file */

/* define YY_INPUT so we read from the FILE fin:
 * This change makes it possible to use this scanner in
 * the Cool compiler.
 */
#undef YY_INPUT
#define YY_INPUT(buf,result,max_size) \
	if ( (result = fread( (char*)buf, sizeof(char), max_size, fin)) < 0) \
		YY_FATAL_ERROR( "read() in flex scanner failed");

char string_buf[MAX_STR_CONST]; /* to assemble string constants */
char *string_buf_ptr;

extern int curr_lineno;
extern int verbose_flag;

extern YYSTYPE cool_yylval;

int comment_layer = 0;
/*
 *  Add Your own definitions here
 */
#define CheckStringLonger(buf, buf_ptr) (buf_ptr - buf) > MAX_STR_CONST ? 1 : 0;

/*
void set_error_msg(const char *msg) {
  yylex = ERROR;
  yylval.error_msg = msg;

}
*/
%}

/*
 * Define names for regular expressions here.
 */

%Start STRING
%Start COMMENT
%Start INLINE_COMMENT

DARROW          =>
DIGIT  [0-9]
LETTER [a-zA-Z]
INTEGER {DIGIT}+
TYPE_IDENTIFIER [A-Z][a-zA-Z0-9_]* 
OBJECT_IDENTIFIER [a-z][a-zA-Z0-9_]* 
WHITESPACE [ \t\f\r\v]+
IDENTIFIER TYPE_IDENTIFIER|OBJECT_IDENTIFIER
KEYWORDS class|else|fi|if|in|inherits|isvoid|let|loop|pool|then|while|case|esac|new|of|not|t(r|R)(u|U)(e|E)|f(a|A)(l|L)(s|S)(e|E)
program  [class]+
class class TYPE [inherits TYPE] {[feature]*}
feature IDENTIFIER([formal(formal)*])  



/*
  # define YYTOKENTYPE
    Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  
   enum yytokentype {
     CLASS = 258,
     ELSE = 259,
     FI = 260,
     IF = 261,
     IN = 262,
     INHERITS = 263,
     LET = 264,
     LOOP = 265,
     POOL = 266,
     THEN = 267,
     WHILE = 268,
     CASE = 269,
     ESAC = 270,
     OF = 271,
     DARROW = 272,
     NEW = 273,
     ISVOID = 274,
     STR_CONST = 275,
     INT_CONST = 276,
     BOOL_CONST = 277,
     TYPEID = 278,
     OBJECTID = 279,
     ASSIGN = 280,
     NOT = 281,
     LE = 282,
     ERROR = 283,
     LET_STMT = 285
   };
*/

%%



 /*
  *  Nested comments
  */

<INITIAL,COMMENT,INLINE_COMMENT>"(*" {
  comment_layer++;
  BEGIN COMMENT;
}

<COMMENT>"*)" {
  comment_layer--;
  if(comment_layer == 0){
    BEGIN 0;
  }
}

<COMMENT>[^\n(*]* {

}

<COMMENT>[()*] {

}
<INITIAL>"--" {
  BEGIN(INLINE_COMMENT);
}

<INLINE_COMMENT>[^\n]* {

}

<INLINE_COMMENT>\n {
  curr_lineno++;
  BEGIN 0;
}

<COMMENT><<EOF>> {
  yylval.error_msg = "EOF in comment";
  BEGIN 0;
  return ERROR;
}

"*)" {
  yylval.error_msg = "Unmatched *)";
  return ERROR;
}

 /*
  *  The multiple-character operators.
  */
{DARROW}		{ return (DARROW); }

 /*
  * Keywords are case-insensitive except for the values true and false,
  * which must begin with a lower-case letter.
  */


 /*
  *  String constants (C syntax)
  *  Escape sequence \c is accepted for all characters c. Except for 
  *  \n \t \b \f, the result is c.
  *
  */
<INITIAL>(\")  {
  BEGIN(STRING);
  yymore();
}

<STRING>(\")  { 
  std::string input(yytext, yyleng);
  input = input.substr(1, input.length()-2); 

  if(input.find_first_of('\0') != std::string::npos){
    yylval.error_msg = "String contains null character";
    BEGIN 0;
    return ERROR;
  }
  string_buf_ptr = string_buf;
  for(int i=0; i < input.length(); i++) {
    if(input[i] == '\\'){
      switch (input[i+1]){
        case 't':
          *string_buf_ptr++ = '\t';
          break;
        case 'b':
          *string_buf_ptr++ = '\b';
          break;

        case 'n':
          *string_buf_ptr++ = '\n';
          break;

        case 'f':
          *string_buf_ptr++ = '\f';
          break;

        default:
          *string_buf_ptr++ = input[i+1];
          break;
      }
      i++;

    } 
    else {
      *string_buf_ptr++ = input[i];
    }

  }

  if(string_buf_ptr - string_buf > MAX_STR_CONST){
    yylval.error_msg = "String constant too long";
    BEGIN 0;
    return ERROR;
  }

  yylval.symbol = stringtable.add_string(string_buf);
  BEGIN 0;
  return STR_CONST;

}


<STRING>\\0 {
  yylval.error_msg = "String contains null character";
  return ERROR;
}

<STRING>\n {
  yylval.error_msg = "error unterminated string constant";
  return ERROR;
}


<STRING><<EOF>> {
  yylval.error_msg = "unterminated string";
  BEGIN 0;
  yyrestart(yyin);
  return ERROR;
}

<STRING>\\n {yymore();}
<STRING>\\b {yymore();}
<STRING>\\t {yymore();}
<STRING>\\f {yymore();}

<STRING>[^\\\n\"]* {
  yymore();  
}

<STRING>\\[^\n] {
  yymore();
}

<STRING>\\\n {
  curr_lineno++;
  yymore();
}


(?i:class) {
   return CLASS;
 }

(?i:else) {
  return ELSE;
}



(?i:fi) {
   return FI;
}

(?i:if) {
  return IF;
}

(?i:in) {
  return IN;
}

(?i:inherits) {
  return INHERITS;
}

(?:isvoid) {
  return ISVOID;
}


(?i:let) {
  return LET;
}

(?i:loop) {
  return  LOOP;
}

(?i:pool) {
  return POOL;
}

(?i:then) {
  return THEN;
}

(?i:while) {
  return WHILE;
}


(?i:case) {
  return CASE;
}

(?i:esac) {
  return ESAC;
}


(?i:new) {
  return NEW;
}

(?i:of) {
  return OF;
}

(?i:not) {
  return NOT;
}

f(?i:alse) {
  yylval.boolean = 0;
  return BOOL_CONST;
}

t(?i:rue) {
  yylval.boolean = 1;
  return BOOL_CONST;
}


{INTEGER} {
  yylval.symbol = inttable.add_string(yytext);
  return INT_CONST;
}


{TYPE_IDENTIFIER} {
  yylval.symbol = idtable.add_string(yytext);
  return TYPEID;
}

{OBJECT_IDENTIFIER} {
  yylval.symbol = idtable.add_string(yytext);
  return OBJECTID;
}

{WHITESPACE} {
  
}

"\n" {
  curr_lineno++;
}

"<-" { return ASSIGN; }

 /* LE */
"<=" { return LE; }

 /* DARROW */
"=>" { return DARROW; }

"+" { return int('+'); }

"-" { return int('-'); }

"*" { return int('*'); }

"/" { return int('/'); }

"<" { return int('<'); }

"=" { return int('='); }

"." { return int('.'); }

";" { return int(';'); }

"~" { return int('~'); }

"{" { return int('{'); }

"}" { return int('}'); }

"(" { return int('('); }

")" { return int(')'); }

":" { return int(':'); }

"@" { return int('@'); }

"," { return int(','); }

 /* =====
  * error
  * =====
  */

[^\n] {
  yylval.error_msg = yytext;
  return ERROR;
}

%%
