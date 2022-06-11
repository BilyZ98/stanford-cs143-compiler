

# Why lexical ? 


# What materials you must read the finish this assignment ?
  First of all, the [assignment doc of course](https://courses.edx.org/assets/courseware/v1/00e29b916fa002225f3ab7590307d69c/asset-v1:StanfordOnline+SOE.YCSCS1+3T2020+type@asset+block/PA1.pdf), 
  in this doc, you will know which file you should modify and what your task is, implementing a lexical analyzer ,
  this doc also tell you what error msg you should return under different error,
  each section matters

  second, [flex basic introduction](http://dinosaur.compilertools.net/lex/index.html).
  This doc is critical if don't know what flex is and how you can use it.
  So the flex is lexical analyzer generator. Let me explain what this means, basically it
  means that you write a bunch of regular expression and the corresponding code in a file, and feed these to flex, the flex will generate cpp code that will recognize the pattern of your regular expression given a text file.
  
  You can run the command 
  ```
  make lexer && ./lexer test.cl
  ```
  in the assignment folder to get a sense of what I mean.

  And you should also learn how to write basic regular expression to match string pattern.

  And, you should learn how to use start condition to match different patterns after your lexer enter into a start condition, this is called left contxt sensitivity in the section 10 of the doc.
  You will need to use this to handle string matching in your cool.flex file.

  third, [the cool manual](https://courses.edx.org/assets/courseware/v1/27e1a38f1161e61d91c25a4b1805489b/asset-v1:StanfordOnline+SOE.YCSCS1+3T2020+type@asset+block/cool_manual.pdf), as told in the assignment web page, this manual gives you complete token set in the cool language , so you don't miss any valid or invalid token to match. 
  And it tells you what char is valid for the identifiers.

  fourth, [cool support code tour](https://courses.edx.org/assets/courseware/v1/115f9c1f48cffa3192f23dc37c3a4eee/asset-v1:StanfordOnline+SOE.YCSCS1+3T2020+type@asset+block/cool-tour.pdf), as been told in the course website, you should read the third section "String Tables" in this doc specifically, you'll need to use this in the string rule in your cool.flex file.
  You need to call the code like this 
  ```
  <STRING> {

  yylval.symbol = stringtable.add_string(yytext);
  return STR_CONST;
  }

  ```
  stringtable variable is defined in the file 
  ```
    PA2/stringtab.cc
  ```
  And also, you'll need to use inttable and idtable to store integer and identifier.

  fifth,  [start condition in  flex](http://westes.github.io/flex/manual/Start-Conditions.html#Start-Conditions).
  I met the start condition problem when I was writing the string matching rules, so you need to understand inclusive start condition and exclusive start condition in flex..

  sixth, 
  ```
  /assignment/PA2/README
  ```
  this will help your get a sense of what each file in the PA2 folder does and it tells you that you could use strdup() function in your coo.flex file, I use it in my code to handle the invalid char error.

# How do we implement a lexical analyzer?  

We write rules which is regular expression string 
that match the input stream from the code file.  We will explain these at the Lex file structure section.



# Lex file structure 

So why are we illustrating the file strucutre of the Lex file,
because I want to remember it and tell what each part does.
You need to know what each part does to write a working lexer.

```
%{
Declaration
%}
Definitions
%%
Rules
%%
User subroutines

```

The Definitions section help us reduce some time by 
define some regular expression first say for example,

```
%{

%}
BLANK [ \t]
```
So now the blank includes the white space and the tab key.

## Rules
So the rules section is the most important section.
This Rules section will specifies the rules and tells the 
lexer how to match the input program texts.

And mainly the one rule is made up by two part.
1. regular expression 
2. action for the regular expression.

The regular expression is a string and the flex will generate code according
to this regular expression that finds all the match string in the input 
code file, or we could text file.

The action for the regular expression is some piece of codes to be executed 
when string in the source code file is matched against the regular expression. 

The following code is an example that tell what is 
regular expression and what is action for the regular expression.
```

%%
[0-9]+      { printf("found an integer\n");};
```
So the 
```
[0-9]+ 
```
represents the regular expression that matches all the integers,
like 0, 11, 38776, etc.

and 
```
{ printf("found an integer\n");};

```
is the code piece that will be matched each time a integer is found in
the source code file.

You could test the above piece code by append the code to file test.flex
like this 
```
// file name is test.flex

%{

%}

%%
[0-9]+      { printf("found an integer\n");};
```

and then compile the cool.flex into test-lex.cc by enter the following 
command at terminal
```
$ flex -d -otest-lex.cc test.flex
```


Now you get a c programming language file that could recognize the integer 
string in all text file.

So why these two part ?  


## key words in the lex 
- yytext
  the yytext variable records the current match string, its type is 
  array of char, so you can access the last character in the current
  matched string with yytext[yyleng -1]  

- yymore()
  match the chars following the current match string to expand the current matched one with the current regular expression.

- yyless()
  move the matched cursor back 

- REJECT
  use following regular expressions down below the current 
  regular expression to see if there is another regular expression also matches the current string.

- ECHO 
  print the current matched string.

- %s, or %x start condition 
  
Some special examples for regular expression.

1. Matched the double quotes in the string .









