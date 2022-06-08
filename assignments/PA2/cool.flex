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

/*
 *  Add Your own definitions here
 */

bool in_comment = false, in_string = false;
int comment_level = 0;
int cur_str_len = 0;

%}

/*
 * Define names for regular expressions here.
 */

a                   [aA]
b                   [bB]
c                   [cC]
d                   [dD]
e                   [eE]
f                   [fF]
g                   [gG]
h                   [hH]
i                   [iI]
j                   [jJ]
k                   [kK]
l                   [lL]
m                   [mM]
n                   [nN]
o                   [oO]
p                   [pP]
q                   [qQ]
r                   [rR]
s                   [sS]
t                   [tT]
u                   [uU]
v                   [vV]
w                   [wW]
x                   [xX]
y                   [yY]
z                   [zZ]


DARROW              =>
DIGIT               [0-9]
INTEGER             {DIGIT}+
STRING_CHAR         [a-zA-Z0-9_]
/* STRING              {STRING_CHAR}+ */
TYPE_IDENTIFIER     [A-Z]{STRING_CHAR}*
OBJECT_IDENTIFIER   [a-z]{STRING_CHAR}*
COOL_IDENTIFIER     self|SELF_TYPE

/* we need to consider new line char in the string situration
  see action below
*/
STRING_CONST             \"[^"nbtf]* 

COMMENTS            (--[^\n(--)]*)|(\(\*[^\*\)]*)  

/* KEYWORDS            {f}{i}|{i}{f}|{i}{n}|{i}{n}{h}{e}{r}{i}{t}{s}|{i}{s}{v}{o}{i}{d}|{l}{e}{t}|{l}{o}{o}{p}|{p}{o}{o}{l}|{t}{h}{e}{n}|{w}{h}{i}{l}{e}|{c}{a}{s}{e}|{e}{s}{a}{c}|{n}{e}{w}|{o}{f} */

IF_KEYWORD          {i}{f}
FI_KEYWORD          {f}{i}
BOOL_CONST          f{a}{l}{s}{e}|t{r}{u}{e}
CLASS_KEYWORD       {c}{l}{a}{s}{s}
ELSE_KEYWORD        {e}{l}{s}{e}
IN_KEYWORD          {i}{n} 
INHERITS_KEYWORD    {i}{n}{h}{i}{t}{s}
LET_KEYWORD         {l}{e}{t}
LOOP_KEYWORD        {l}{o}{o}{p}
POOL_KEYWORD        {p}{o}{o}{l}
THEN_KEYWORD        {t}{h}{e}{n}
WHILE_KEYWORD       {w}{h}{i}{l}{e}
CASE_KEYWORD        {c}{a}{s}{e}
ESAC_KEYWORD        {e}{s}{a}{c}
OF_KEYWORD          {o}{f}
NEW_KEYWORD         {n}{e}{w}
ISVOID_KEYWORD      {i}{s}{v}{o}{i}{d}
NOT_KEYWORD         {n}{o}{t}

/* what is le and what is assign */
/* assignment has the lowest precedence.*/
ASSIGN_KEYWORD      <-
LE_KEYWORD          <=

LET_STMT_KEYWORD    {l}{e}{t}

WHITESPACE          [ \n\f\r\t\v]+

OPERATOR            \.|@|~|\*|/|\+|-|<|=

%x              IN_STRING IN_COMMENT

%%

 /*
  *  Nested comments
  */
{CLASS_KEYWORD} { return (CLASS);}

{ELSE_KEYWORD} {return (ELSE);}

{FI_KEYWORD} {return (FI);}


{IF_KEYWORD} {return (IF);}

{IN_KEYWORD} { return (IN);}

{INHERITS_KEYWORD} {
    return (INHERITS);
}

{LET_KEYWORD} {return (LET);}


{LOOP_KEYWORD} { return (LOOP);}

{POOL_KEYWORD} {return (POOL);}

{THEN_KEYWORD} {return (THEN);}

{WHILE_KEYWORD} {return (WHILE);}

{CASE_KEYWORD} {return (CASE);}

{ESAC_KEYWORD} {return (ESAC);}

{OF_KEYWORD} { return (OF);}

{DARROW}		{ return (DARROW); }

{NEW_KEYWORD} { return (NEW);}

{ISVOID_KEYWORD} { return (ISVOID);}


\"              {
    printf("string begin\n");
    cur_str_len = 0;
    string_buf_ptr = string_buf;
    BEGIN IN_STRING;
}

<IN_STRING>\"  {
  BEGIN(INITIAL);
  if (cur_str_len > MAX_STR_CONST)  {
      cool_yylval.error_msg = "String constant too long";
      return ERROR;
    }
  printf("string end\n");
  return (STR_CONST);
}

<IN_STRING>\\(\n) {
  string_buf[cur_str_len++] = '\n';
}

<IN_STRING>\n   {
        cool_yylval.error_msg= "Unterminated string constant";
        BEGIN 0;
        curr_lineno++;
        return ERROR;

}



    

<IN_STRING>\0     {
    cool_yylval.error_msg = "String contains null character";
    BEGIN 0;
    return ERROR;
  }

<IN_STRING>\\b  {
  string_buf[cur_str_len++] = '\b'; 
}

<IN_STRING>\\t  {
    string_buf[cur_str_len++] = '\t';
}

<IN_STRING>\\n {
    printf("got newline \n");
    string_buf[cur_str_len++] = '\n';
  }

<IN_STRING>\\f {
    string_buf[cur_str_len++] = '\f';
}

<IN_STRING>\\{STRING_CHAR} {
    string_buf[cur_str_len++] = yytext[0]; 
}

<IN_STRING>{STRING_CHAR}+ {
  memcpy(string_buf+cur_str_len, yytext, yyleng);    

  cur_str_len += yyleng;
}



{TYPE_IDENTIFIER} { 
  /* printf("find typeid:%s\n", yytext); */
  cool_yylval.symbol = stringtable.add_string(yytext);
  return (TYPEID); 
  }; 



{OBJECT_IDENTIFIER} {
    cool_yylval.symbol = stringtable.add_string(yytext);
    return (OBJECTID);
}

 /*
  *  The multiple-character operators.
  */

{INTEGER}   { 

  printf("found a integer, %s\n", yytext); 
}

[^\n]      { printf("");}

\n          {
  printf("");
  curr_lineno++;
  }

.             ;

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


%%
