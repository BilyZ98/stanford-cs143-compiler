

# Why lexical ? 



# How do we implement a lexical analyzer?  

We write rules which is regular expression string 
that match the input stream from the code file.



# Lex file structure 
So why are we illustrating the file strucutre of the Lex file,
because I want to remember it and tell what each part does.
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

- yyless()

- REJECT

- ECHO 

Some special examples for regular expression.

1. Matched the double quotes in the string .









