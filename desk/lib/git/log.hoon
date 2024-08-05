::
::::  git tree utilities
  ::
/+  git=git-repository, *git-object, t=git-tree, r=git-revision
|%
::    +tree-path-last-modified: find the most recent commit
::    which modified the .path, starting at revision .tip
::
++  tree-path-last-modified
  |=  [repo=repository:git tip=hash =path]
  ^-  (unit [hash commit])
  ::  XX cached repo:
  ::  take a $-(repo .. -> x) and transform
  ::  into $-(repo .. -> [x repo]) which utilizes 
  ::  cache for resolving objects
  ::
  =/  commit  (got-commit:~(store git repo) tip)
  =/  tree-hash  (tree-path-hash:t repo tree.commit path)
  ?~  tree-hash  ~
  =/  =rev-walk:r  (walk:r repo ~[tip] ~)
  |-
  =^  step  rev-walk  ~(step r rev-walk)
  ?~  step
    (some [tip commit])
  =/  step-tree-hash  (tree-path-hash:t repo tree.commit.u.step path)
  ?~  step-tree-hash
    step
  ?:  !=(tree-hash step-tree-hash)
    (some [tip commit])
  $(tip hash.u.step, commit commit.u.step)

--
