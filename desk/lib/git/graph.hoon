::
::  Commit graph utilities
::
/+  *git, git=git-repository
|_  repo=repository:git
::  Can every commit in @from 
::  reach at least one commit in @have
::  
::  XX optimize using generation number
++  can-all-reach-from
  |=  [from=(list hash) have=(set hash) oldest-have=@ud]
  ^-  ?
  ::  XX Why does ?=(~ have)
  ::  cause downstream type errors?
  ::
  ?:  =(~ have)
    |
  |-
  ?~  from
    &
  =+  hash=i.from
  ::  Depth-first search for anything 
  ::  in the set @have
  ::
  =/  reach=?
    |-
    ?:  (~(has in have) hash)
      &
    ::  XX introduce object caching 
    ::  =^  obj  repo  (got:~(store git repo))
    ::  would cache an object from the archive 
    ::  in the loose map
    ::
    =+  obj=(got:~(store git repo) hash)
    ::  Not a commit object, do not worry about reachability
    ::
    ?.  ?=(%commit -.obj)
      &
    ::  XX Such accessess are too long. Move
    ::  commit stuff into /lib/git/commit/hoon 
    ::  and provide compile-time accessors
    ::
    ?:  (lth -.date.committer.commit.obj oldest-have)
      |
    %+  roll  parents.commit.obj
      |=  [=^hash reach=?]
      ^-  ?
      ?:  ?|(reach (~(has in have) hash))
        &
      ^$(hash hash)
  ::
  ?:  !reach
    |
  $(from t.from)
--
