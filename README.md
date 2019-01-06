# DependenciesGraph
Generates dependency graph for a folder containing .swift files.

# Libraries used
[Menhir](http://gallium.inria.fr/~fpottier/menhir/)  
[vis.js](http://visjs.org)  

# How to use
Download the [release](https://github.com/kovtun1/DependenciesGraph/releases)  
`cd <PATH_TO_Dependencies Graph v1>`  
`./main.native <PATH_TO_SWIFT_FILES_FOLDER>`  
Open index.html  
Select graph (Inheritance or Usage)  

You can specify types that shouldn't be added to the graph in `types_to_ignore.txt`. One type per line.

# How to compile
`ocamlbuild -package unix -package str -use-menhir -menhir "menhir --external-tokens Lexer" main.native`

# Examples
[Alamofire](https://github.com/Alamofire/Alamofire)
![](https://i.imgur.com/a87SPe8.png)

[Nuke](https://github.com/kean/Nuke)
![](https://i.imgur.com/9QEf26G.png)
