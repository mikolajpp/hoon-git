::
::  git fetch - Download objects and refs from another repository
::
::
/+  *git-cmd, *git-refs, *git-refspec
|%
::  
::  Modify refspecs to place all refs under prefetch:refspace
::
++  filter-prefetch-refspec
  |=  =refspec
  ^-  (unit _refspec)
  ::  XX =, refspec breaks type inference on units
  ::  and lists
  ::
  =*  dst  dst.refspec
  =*  src  src.refspec
  ?:  negative.refspec  ~
  ::  XX  =, breaks type inference
  ::
  ?:  ?&  ?=(^ src)
          ?=([@ta @ta *] ref.src)
          ?=(~ dst)
          =(tags:refspace /[i.ref.src]/[i.t.ref.src])
      ==
    ~
  =/  new-dst=refname
    ::  XX why is welp needed here instead of weld?
    %+  welp
      prefetch:refspace
    ::  XX Why can't we test inside & for unit?
    ?~  dst  ~
    ?:  &(?=([@ta *] u.dst) =(%refs i.u.dst))
      t.u.dst
    u.dst
  %-  some
  %=  refspec
    dst  `new-dst
    force  &
  ==
--
