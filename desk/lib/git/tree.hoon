::
::::  git tree utils
  ::
/+  git=git-repository, *git-object, *git-refs
|%
++  tree-entry-find-hash
  |=  [dir=tree-dir name=@ta]
  ^-  (unit hash)
  |-  ?~  dir  ~
  ?:  =(name.i.dir name)
    (some hash.i.dir)
  $(dir t.dir)
::    +tree-path-hash: find object hash at path in 
::    the tree object .tree-hash.
::
++  tree-path-hash
  |=  [repo=repository:git tree-hash=hash =path]
  ^-  (unit hash)
  ?~  path  (some tree-hash)
  =/  tree  (got-tree:~(store git repo) tree-hash)
  =/  entry-hash  (tree-entry-find-hash tree i.path)
  ?~  entry-hash  ~
  $(tree-hash u.entry-hash, path t.path)
::  +pit-of: like +fit:of, but also return
::  the matching prefix path. 
::
++  pit-of
  |*  [fat=(axal) pax=path]
  ^+  [pax pax fil.fat]
  =|  =refname
  |-
  ?~  pax
    [(flop refname) ~ fil.fat]
  =/  kid  (~(get by dir.fat) i.pax)
  ?~  kid
    [(flop refname) pax fil.fat]
  $(refname [i.pax refname], pax t.pax, fat u.kid)
--
