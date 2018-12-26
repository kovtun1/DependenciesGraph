type swift_token =
  | Type of string
  | Word of string
  | Protocol
  | Class
  | Extension
  | Enum
  | Struct
  | Colon
  | Comma
  | Dot
  | OpenCurlyBrace
  | CloseCurlyBrace

let string_of_swift_token token =
  match token with
  | Type name ->
    "TYPE(" ^ name ^ ")"
  | Word name ->
    "WORD(" ^ name ^ ")"
  | Protocol ->
    "PROTOCOL"
  | Class ->
    "CLASS"
  | Extension ->
    "EXTENSION"
  | Enum ->
    "ENUM"
  | Struct ->
    "STRUCT"
  | Colon ->
    "COLON"
  | Comma ->
    "COMMA"
  | Dot ->
    "DOT"
  | OpenCurlyBrace ->
    "OPEN_CURLY_BRACE\n"
  | CloseCurlyBrace ->
    "CLOSE_CURLY_BRACE\n"
