{
  open Lexing

  type token =
    | TYPE of string
    | WORD of string
    | PROTOCOL
    | CLASS
    | EXTENSION
    | ENUM
    | STRUCT
    | COLON
    | COMMA
    | DOT
    | OPEN_CURLY_BRACE
    | CLOSE_CURLY_BRACE
    | EOF
}

let word = ['a'-'z' 'A'-'Z'] ['a'-'z' 'A'-'Z' '0'-'9' '_']*

rule lex = parse
  | [' ' '\t' '\n'] { lex lexbuf }
  | "protocol"      { PROTOCOL }
  | "class"         { CLASS }
  | "extension"     { EXTENSION }
  | "enum"          { ENUM }
  | "struct"        { STRUCT }
  | ":"             { COLON }
  | ","             { COMMA }
  | "."             { DOT }
  | "{"             { OPEN_CURLY_BRACE }
  | "}"             { CLOSE_CURLY_BRACE }
  | "//"            { skip_line lexbuf
                    ; lex lexbuf
                    }
  | "/*"            { skip_block_comment 0 lexbuf
                    ; lex lexbuf
                    }
  | "\""            { skip_string false lexbuf
                    ; lex lexbuf
                    }
  | "\".*\""        { lex lexbuf }
  | "import"        { skip_line lexbuf
                    ; lex lexbuf
                    }
  | eof             { EOF }
  | word as s       { if String.capitalize_ascii s = s then
                        TYPE(s)
                      else
                        WORD(s) }
  | _               { lex lexbuf }
and skip_line = parse
| ('\n' | eof) { () }
| _            { skip_line lexbuf }
and skip_block_comment level = parse
| "*/" { if level = 0 then
           ()
         else
           skip_block_comment (level - 1) lexbuf }
| "/*" { skip_block_comment (level + 1) lexbuf }
| eof  { () }
| _    { skip_block_comment level lexbuf }
and skip_string prev_char_is_backslash = parse
| ("\"" | eof) { if prev_char_is_backslash then
                   skip_string false lexbuf
                 else
                   ()
               }
| "\\"         { skip_string true lexbuf }
| "\\\\"       { skip_string false lexbuf }
| _            { skip_string false lexbuf }
