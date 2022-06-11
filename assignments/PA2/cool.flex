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


bool string_has_null = false;

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
ID_STRING_CHAR         [a-zA-Z0-9_]
STRING_CHAR             [^\0]
/* STRING              {STRING_CHAR}+ */
TYPE_IDENTIFIER     [A-Z]{ID_STRING_CHAR}*
OBJECT_IDENTIFIER   [a-z]{ID_STRING_CHAR}*
COOL_IDENTIFIER     self|SELF_TYPE

/* we need to consider new line char in the string situration
  see action below
*/
STRING_CONST             \"[^"nbtf]* 

COMMENTS            (--[^\n(--)]*)|(\(\*[^\*\)]*)  

/* KEYWORDS            {f}{i}|{i}{f}|{i}{n}|{i}{n}{h}{e}{r}{i}{t}{s}|{i}{s}{v}{o}{i}{d}|{l}{e}{t}|{l}{o}{o}{p}|{p}{o}{o}{l}|{t}{h}{e}{n}|{w}{h}{i}{l}{e}|{c}{a}{s}{e}|{e}{s}{a}{c}|{n}{e}{w}|{o}{f} */

IF_KEYWORD          {i}{f}
FI_KEYWORD          {f}{i}
BOOL_CONST_TRUE     t{r}{u}{e}
BOOL_CONST_FALSE    f{a}{l}{s}{e}
CLASS_KEYWORD       {c}{l}{a}{s}{s}
ELSE_KEYWORD        {e}{l}{s}{e}
IN_KEYWORD          {i}{n} 
INHERITS_KEYWORD    {i}{n}{h}{e}{r}{i}{t}{s}
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

%x              IN_STRING IN_COMMENT IN_INLINE_COMMENT

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

{NOT_KEYWORD}  { return (NOT);}


\"              {
    BEGIN IN_STRING;
    string_has_null = false;
    yymore();
}

<IN_STRING>\"    {
   // end processing 


    BEGIN 0;
   if(string_has_null) {
    yylval.error_msg = "String contains null character";
    return ERROR;
   }
    
    string_buf_ptr = string_buf;
   for(int i=1; i < yyleng-1; i++) {
     int cur_len = string_buf_ptr - string_buf;
     if(cur_len > MAX_STR_CONST) {
         yylval.error_msg = "String constant too long";
         return ERROR;
     }

      if(yytext[i] == '\\') {
        char next_char = yytext[i+1];

        switch (next_char){
            case 't':
              *string_buf_ptr = '\t';
              break;

            case 'b':
              *string_buf_ptr = '\b';
              break;

            case 'n':
              *string_buf_ptr = '\n';
              break;

            case 'f':
              *string_buf_ptr = '\f';
              break;

            default:
              *string_buf_ptr = next_char;
          }
          i++;
      } else {
          *string_buf_ptr = yytext[i];
      }

      string_buf_ptr++;
   }
  
    *string_buf_ptr = '\0';
    string_buf_ptr++;
   int str_len = string_buf_ptr - string_buf;
   if(str_len > MAX_STR_CONST)  {
       yylval.error_msg = "String constant too long";
       return ERROR;
     }
    yylval.symbol = stringtable.add_string(string_buf);

   return STR_CONST;
}

<IN_STRING>\n   {
  yylval.error_msg =  "Unterminated string constant";
  BEGIN 0;
  return ERROR;
}


<IN_STRING>\\\n  {
    curr_lineno++; 
    yymore();
}

<IN_STRING>(\0)|(\\\0) { 

  string_has_null = true;
  yymore();
}


<IN_STRING><<EOF>>  {
  yylval.error_msg = "EOF in string constant";
  BEGIN 0;
  yyrestart(yyin);
  return ERROR;
}

<IN_STRING>\\[^\n]  {
    // this will match \<EOF> and \(\0)
    // this will also accept the \"
    yymore();
}


<IN_STRING>[^\\\n\0\"]*  {
  // what if we have a NULL and following characters ? 
  // will this regular expression executed or the previous one ?

  // I should do some test to find out .
  // In my option NULL will be matched to this 
  // expression instead of the previous one.
  // I tested it, it will match the null character,
  // so I add \0 in the exclued set.
  yymore();
}



--        {
    BEGIN IN_INLINE_COMMENT;
}



<IN_INLINE_COMMENT>\n {
    curr_lineno++;
    BEGIN 0;
}

<IN_INLINE_COMMENT><<EOF>> {
  BEGIN 0;
}

<IN_INLINE_COMMENT>[^\n]+ {

}

\(\*           {
    comment_level += 1; 
    BEGIN IN_COMMENT;
}


\*\)          {
    yylval.error_msg = "Unmatched *)";
    return ERROR;
}

<IN_COMMENT>\(\*  {
    comment_level += 1;
  }

<IN_COMMENT>\*\) {
    comment_level -= 1;

    if(comment_level == 0) {
        BEGIN 0;
    }
}


<IN_COMMENT>\n  {
    curr_lineno++;
}

<IN_COMMENT><<EOF>>   {
    yylval.error_msg = "EOF in comment";
    BEGIN 0;
    return ERROR;
}

<IN_COMMENT>[^\n(*]*  {
  // do not match the "(*" since the lex will
  // try to match as long as possible and 
  // (* is the start of comment 
}

<IN_COMMENT>[(*] {
  // match (  or * independently.
  // this is shorter compared to previous reg expresison.
}


{BOOL_CONST_TRUE}  {
  yylval.boolean = 1;
  return BOOL_CONST;
  }

{BOOL_CONST_FALSE} {
    yylval.boolean = 0;
    return BOOL_CONST;
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

  cool_yylval.symbol = inttable.add_string(yytext);
  return (INT_CONST); 
}


{LE_KEYWORD}      {
    return (LE);
}


{ASSIGN_KEYWORD}   {
    return (ASSIGN);
}





"+"  { return  int('+');}  

"-"  { return int('-'); }

"*"  { return int('*');}

"/"  { return int('/');}

";"  { return int(';');}

"."  { return int('.');}

"="  { return int('=');}

","  { return int(',');}

":"  { return int(':');}

"("  { return int('(');}

")"  { return int(')');}

"@"  { return int('@');}

"~"  { return int('~');}

"<"  { return int('<');}


"{"  { return int('{');}

"}"  { return int('}');}

\0   {
  yylval.error_msg = "null symbol";
  return ERROR;
}

\n          {
  curr_lineno++;
}

[\t\r\v\f ]  {
}

[^\t\r\v\f ]      {
  yylval.error_msg = strdup(yytext); 
  return ERROR;
}



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
