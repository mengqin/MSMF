%option noyywrap 
%{
    #include "test_yacc.y.h"
    int trace = 0 ; 
%}

%%
[0-9]   {if(trace)ECHO;
            yylval=atof(yytext);
            printf("yylval=%d\n",yylval);
            return NUM;
        }   
"+"     {if(trace)ECHO;return '+';}
"-"     {if(trace)ECHO;return '-';}
"*"     {if(trace)ECHO;return '*';}
"/"     {if(trace)ECHO;return '/';}
"^"     {if(trace)ECHO;return '^';}
"n"     {if(trace)ECHO;return 'n';}
"("     {if(trace)ECHO;return '(';}
")"     {if(trace)ECHO;return ')';}
"\n"    {if(trace)ECHO;return '\n';}
.       {if(trace)ECHO;}

%%
