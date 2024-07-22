/+  *git, stream
|%
+$  pack-object-type  $?  object-type
                          %ofs-delta
                          %ref-delta
                      ==
+$  pack-object-header  [type=pack-object-type size=@ud]
+$  pack-object  $%  raw-object
                     [%ofs-delta pos=@ud base-offset=@ud =octs]
                     [%ref-delta pos=@ud =hash =octs]
                 ==
+$  pack-delta-object  $>(?(%ofs-delta %ref-delta) pack-object)

+$  pack-header  [version=%2 count=@ud]
::  XX different comparison functions
::  do not throw error!
::  Is it possible to extract comparison
::  function from pack-index?
::
+$  pack-index   ((mop hash @ud) lth)
++  pack-on  ((on hash @ud) lth)
+$  pack  [=hash-type count=@ud index=pack-index end-pos=@ud data=stream:libstream]
--
