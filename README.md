# DependenciesGraph
Generates dependency graph for a .swift file.  
Example input:
```
class A {
  let b: B
  let c: C
}

class B {
  let c: C
  let d: D
}

class C {
  
}

class D {
  unowned let d: D
}

class E {
  func craeteB() -> B {
    return B()
  }
}

class F {
  func createA() -> A {
    return A()
  }
}
```
Example output:  
![](http://i.imgur.com/S7AJQE8.png)
