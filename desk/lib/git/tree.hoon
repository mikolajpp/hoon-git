::
::::  git tree utils
  ::
/+  git=git-repository, *git-object
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
--
