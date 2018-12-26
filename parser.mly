%token <string> TYPE
%token <string> WORD
%token PROTOCOL
%token CLASS
%token EXTENSION
%token ENUM
%token STRUCT
%token COLON
%token COMMA
%token DOT
%token OPEN_CURLY_BRACE
%token CLOSE_CURLY_BRACE
%token EOF

%{
  open Lexer
  open Swift
%}

%start <Swift.swift_token list> main

%%

main:
  | expressions=list(expr) EOF { expressions }
expr:
  | t=TYPE            { Type(t) }
  | w=WORD            { Word(w) }
  | PROTOCOL          { Protocol }
  | CLASS             { Class }
  | EXTENSION         { Extension }
  | ENUM              { Enum }
  | STRUCT            { Struct }
  | COLON             { Colon }
  | COMMA             { Comma }
  | DOT               { Dot }
  | OPEN_CURLY_BRACE  { OpenCurlyBrace }
  | CLOSE_CURLY_BRACE { CloseCurlyBrace }
