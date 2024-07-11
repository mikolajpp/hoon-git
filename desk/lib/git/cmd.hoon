/+  *git-refs, *git-object
/+  git=git-repository
|%
::  Find refname
::
::  Matches against refs in /refs/heads,
::  /refs/tags and other standard locations
::
++  find-refname
  |=  [repo=repository:git branch=refname]
  ^-  (unit refname)
  =/  refs=(list refname)
    (expand-ref-prefix branch)
  |-
  ?~  refs  ~
  ?:  (has:~(refs git repo) i.refs)
    (some i.refs)
  $(refs t.refs)
::
::  Find matching hashes given a short key
::
++  find-by-key
  |=  [repo=repository:git key=@ta]
  ^-  (list hash)
  ~
::  Diff two trees
::  
::  Return a list of [path left=hash right=hash]
:: 
++  diff-tree
  |=  $:  repo=repository:git
          a=tree-dir
          b=tree-dir
          p=path
      ==
  ^-  (list (trel path hash hash))
  =/  sa=tree-dir
    %+  sort  a
    |=  [rya=tree-entry ryb=tree-entry]
    (lth name.rya name.ryb)
  =/  sb=tree-dir
    %+  sort  b
    |=  [rya=tree-entry ryb=tree-entry]
    (lth name.rya name.ryb)
  :: ~&  sa+sa
  :: ~&  sb+sb
  =|  diff=(list (trel path hash hash))
  |-
  :: ~&  diff-at+p
  ::  left exhausted - append right
  ?~  sa
    %-  flop
    %+  weld
      %+  turn  sb
      |=(ent=tree-entry [[name.ent p] 0x0 hash.ent])
    diff
  ::  right exhausted - append left
  ?~  sb
    %-  flop
    %+  weld
      %+  turn  sa
      |=(ent=tree-entry [[name.ent p] hash.ent 0x0])
    diff
  ::  No change
  ::
  ?:  ?&  =(name.i.sa name.i.sb)
          =(hash.i.sa hash.i.sb)
      ==
    $(sa t.sa, sb t.sb)
  ::  a,b,c  x
  ::  a,b,c  f
  ::
  ::  Names are different, append both
  ::
  ?:  !=(name.i.sa name.i.sb)
    =/  diff-a=(trel path hash hash)
      [[name.i.sa p] hash.i.sa 0x0]
    =/  diff-b=(trel path hash hash)
      [[name.i.sb p] hash.i.sb 0x0]
    %=  $
      diff  [diff-a diff-b diff]
      sa  t.sb
      sb  t.sb
    ==
  ::  Diff
  ::  XX use mode
  =/  left-obj
    (got:~(store git repo) hash.i.sa)
  =/  right-obj
    (got:~(store git repo) hash.i.sb)
  ::  Advance
  ::
  ::  Three cases
  ::
  ::  blob and blob - perform txt diff
  ::  blob and tree - show whole text file
  ::  tree and tree - recurse
  ::
  ?:  &(?=(%blob -.left-obj) ?=(%blob -.right-obj))
    :: ~&  diff-blob+p
    %=  $
      diff  :_  diff  [[name.i.sa p] hash.i.sa hash.i.sb]
      sa  t.sa
      sb  t.sb
    ==
  ::  XX handle commit and tag objects
  ?:  &(?=(%tree -.left-obj) ?=(%tree -.right-obj))
    :: ~&  diff-tree+p
    %=  $
      ::  XX terrible complexity, use nested lists
      ::
      diff  %+  weld
              (diff-tree repo tree.left-obj tree.right-obj [name.i.sa p])
            diff
      sa  t.sa
      sb  t.sb
    ==
  ::  Tree against the blob
  ::  Diff blob and whole tree contents
  ?:  |(?=(%tree -.left-obj) ?=(%tree -.right-obj))
    :: ~&  diff-tree-blob+p
    %=  $
      diff
        ?:  ?=(%tree -.left-obj)
          :-  [[name.i.sb p] 0x0 hash.i.sb]
          %+  weld
            (tree-all-diff repo tree.left-obj p &)
          diff
        :-  [[name.i.sa p] hash.i.sa 0x0]
        ?>  ?=(%tree -.right-obj)
        %+  weld
          (tree-all-diff repo tree.right-obj p |)
        diff
      sa  t.sa
      sb  t.sb
    ==
  :: ~&  "Unhandled obj diff: {<-.left-obj>}:{<-.right-obj>}"  !!
  ::  Submodule
  $(sa t.sa, sb t.sb)
    
  ++  tree-all-diff
    |=  [repo=repository:git tree=tree-dir p=path side=?]
    ^-  (list (trel path hash hash))
    =|   diff=(list (trel path hash hash))
    |-
    ^-  _diff
    ?~  tree  diff
    ::  XX only get hash
    =/  obj
      (got:~(store git repo) hash.i.tree)
    ?:  ?=(%blob -.obj)
      :_  diff
      :-  [name.i.tree p]
      ?:  side  
        [hash.i.tree 0x0]
      [0x0 hash.i.tree]
    ?.  ?=(%tree -.obj)
      $(tree t.tree)
    (tree-all-diff repo tree.obj [name.i.tree p] side)
--
