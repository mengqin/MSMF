%{
    #define YYSTYPE double
    #define YYERROR_VERBOSE 1
    #include<math.h>
    #include<stdio.h>
    int yylex(void);
    void yyerror(const char*);
%}

%token NUM 
%left '-' '+' 
%left '*' '/' 
%left NEG 
%right '^' 

%%
input:  /*empty*/
        | input line
        ;
line:   '\n'
        | exp '\n'  {printf("value=%f\n",$1);}
        | error '\n'    {yyerrok;}
        ;
exp:    NUM {$$=$1;}
        |exp '+' exp        {printf("%f + %f\n",$1,$3);$$=$1+$3;}
        |exp '-' exp        {$$=$1-$3;}
        |exp '*' exp        {$$=$1*$3;}
        |exp '/' exp        {$$=$1/$3;}
        |'-' exp %prec NEG  {$$=-$2;}
        |exp '^' exp        {$$=pow($1,$3);}
        |'(' exp ')'        {$$=$2;}
        ;
%%
int main(void)
{
    return yyparse();
}
void yyerror(char const *s) 
{
    fprintf(stderr,"%s\n",s);
}
