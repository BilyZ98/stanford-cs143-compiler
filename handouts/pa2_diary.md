

# Why wrote this ?

So this is the notes about the pa2 that implements a
lexical analyzer in time span.


so this will record my learning and my questions in this 
lexical assignment.


1. What does lexical analyzer even mean?


2. And how do we wrote cool.flex file ?

3. Now I know that I should wrote a bunch of regular expression
to extract the token out of the source file, what is relative order
each regular expression ? 


4. use start condition to match different chars in the string matching process , %s or %x ?.
   I learn that from the [lex intro doc](http://dinosaur.compilertools.net/lex/index.html) that I could use start condition in lex to execute different code with different chars matched when we start matching the string or the comments in the cool programming language.

   Strange thing is, when I write the following code as my start
   condition in the cool.flex file, the lexer does not work as I expected.
   ```
   %s IN_STRING IN_COMMENT
   ```
  
  the test results show that it does not matched the end of the string quotes \".

  The lexer results  is below.
  ```
  string begin
  got newline
  string begin
  #18 ERROR "Unterminated string constant"
  ```
  
  As we can see, there is no "string end" message showing
  and it shows another "string begin" message, which is weird, 
  since our IN_STRING condition is begun and it should not 
  match the other non IN_STRING start condition regular 
  expression,
  so I just check the another lex document again, 
  this time I solve the problem by replacing the "%s IN_STRING"
  with "%x IN_STRING".

  [lex start condition doc](http://westes.github.io/flex/manual/Start-Conditions.html#Start-Conditions)
  The difference between "%s" and "%x" is that 
  "%s" start condition is inclusive, which means other regular expression
  will also be used to matched the remaining string even if you
  call the start condition. 

  So this is why we have two "string begin" message in the lexer results.

  And the "%x" is exclusive start condition which means other regular 
  expression that is not in current start condition will not used 
  to matched the incoming stream of text.

  So this time, my lexer results shows as expected.

  ```
  string begin
  got newline
  string end
  #17 STR_CONST "concat"
  ```

5. order between regular expressions.

  I am writing the cool.flex file and try to matched the false and true boolean keywords, but the flex gives the warning that the true and false rule cannot be matched, then I googled it, the stackoverflow answers mention that this situation happens when you have rule earlier in the flex file that is the superset of your current regular expression, so  your regular expression will not be matched.
  
  The problematic code is below 
  ```

  {TYPE_IDENTIFIER} { 
  /* printf("find typeid:%s\n", yytext); */
  cool_yylval.symbol = stringtable.add_string(yytext);
  return (TYPEID); 
  }; 



{OBJECT_IDENTIFIER} {
    cool_yylval.symbol = stringtable.add_string(yytext);
    return (OBJECTID);
}

  {bool_const_false} {
      ....
    }


  {bool_const_true} {
      ....
    }

  ```


  The TYPE_IDENTIFIER regular expression contains the true and false keyword, so the true and  false keyword will be not matched and will be return as objectid or typeid.

  The solution is move the false and true keyword before the TYPE_IDENTIFIER and OBJECT_IDENTIFIER.

6. Use yytext and yymore in string constant matching process.

  At first  I use string_buf[1024] from the cool.flex file to store the final string literal. 

  The code is like below.
  
  ```
    %{ 
    char string_buf[1024];
    int cur_str_len = 0;
    %x IN_STRING 
    %}

    %%

    

    \"  {
      cur_str_len = 0;
      BEGIN IN_STRING;

      }

    <IN_STRING>\\t  {
      string_buf[cur_str_len++] = '\t';
    }


    <IN_STRING>\"    {
        
        if(cur_str_len > MAX_LEN) {
            return ERROR;
        }

    }
  ```


  As you can see from the code, it's prone to the long string error, I need to add test code at every <IN_STRING> rule 
 to avoid the buffer overflow and out-of-bound string access fault, which is not an appropriate way to deal with such error.


 So I decided to use yymore and process the \ translation symbol at the end of string.

 The code is like this.

  ```
    %{
      char string_buf[1024];
      %x IN_STRING
    %} 

    %%
    
    \"    {
        BEGIN IN_STRING;
        yymore();
      }


    <IN_STRING>\"  {


      for(int i=0; i < yyleng; i++) {
          if(i >= MAX_LEN) {
            return ERROR;     
          }

          // normal case
          *string_buf_ptr  = yytext[i];
          string_buf_ptr++;
      }
    }


    <IN_STRING>\\\n   {
        cur_lineno++;
        yymore();
      }

    <IN_STRING>\\[^\n] {
      yymore();

    }

    %%
  ```

  And this implementation of string matching will only do 
  string length check at the end of the string, which will
  prevent the out-of-bound array access and save us from 
  duplicate length checking code.


