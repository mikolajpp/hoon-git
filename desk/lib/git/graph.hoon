::
::  Commit graph utilities
::
/+  *git
|_  repo=repository
::  Can every commit in @from 
::  reach at least one commit in @have
::
++  can-all-reach-from
  |=  [from=(list hash) have=(set hash)]
  ^-  ?
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
    ?>  ?=(%commit -.obj)
    %+  roll  parents.header.obj
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
