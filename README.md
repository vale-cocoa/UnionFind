# UnionFind

A data structure for modelling dynamic connectivity. 

Dynamic connectivity can be defined by two operations on  a set of *n* distinctive elments:
- **Union Command**: connect two objects
- **Find/Connected Query**: is there a path connecting two elements?
Assuming *"is connected to"* is an equivalence relation between elements which is:
  - **Reflexive**: *p* is connected to *p*.
  - **Symmetric**: if *p* is connected to *q*, then *q* is also connected to *p*.
  - **Transitive**: if *p* is connected to *q* and *q* is connected to *r*, then *p* is also connected to *r*.
Where *p*, *q*, *r* are distinct nodes from the set.
