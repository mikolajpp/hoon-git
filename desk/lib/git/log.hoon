::
::::  git log utilities
  ::
/+  git=git-repository, *git-object, t=git-tree, rw=git-rev-walk
|%
::    +tree-path-last-modified: find the most recent commit
::    which modified the .path, starting at revision .tip
::
++  tree-path-last-modified
  |=  [repo=repository:git tip=hash =path]
  ^-  (unit [hash commit])
  ::  XX cache transformation gate:
  ::  take a $(repo .. -> x) and transform
  ::  into $(repo ... -> [x repo]) which utilizes 
  ::  cache for resolved objects
  ::
  =/  commit  (got-commit:~(store git repo) tip)
  =/  tree-hash  (tree-path-hash:t repo tree.commit path)
  ?~  tree-hash  ~
  =/  =rev-walk:rw  (walk:rw repo ~[tip] ~)
  |-
  =^  step  rev-walk  ~(step rw rev-walk)
  ~&  step+hash
  ?~  step
    (some [tip commit])
  =/  step-tree-hash  (tree-path-hash:t repo tree.commit.u.step path)
  ?~  step-tree-hash
    step
  ?:  !=(tree-hash step-tree-hash)
    step
  $(tip hash.u.step, commit commit.u.step)

--
