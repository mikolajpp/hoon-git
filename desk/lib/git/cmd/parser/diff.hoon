::
::  git merge - Fast-forward merge
::
/+  *git-cmd-parser, *git-refs
|%
+$  args  $:  src=$@(@ta [%ref ref=@ta])
              dst=$@(@ta [%ref ref=@ta])
          ==
+$  opts  ~
++  hex
  ;~(pose (shim '0' '9') (shim 'a' 'f'))
++  parse-short-raw-hash
  (cook crip (stun [4 40] hex))
++  parse
  %+  parse-cmd-solo  %diff
  ;~  pfix  parse-gap
    ::  XX native way to support nested parsers
    %+  cook
      |=  [src=tape dst=tape]
      ^-  args
      =/  src
        %+  scan  src
        ;~(pose parse-short-raw-hash (stag %ref parse-raw-refname))
      =/  dst
        %+  scan  dst
        ;~(pose parse-short-raw-hash (stag %ref parse-raw-refname))
      [src dst]
    ;~  plug
      ::  XX parse-raw-refname should not 
      ::  parse empty strings
      ::
      (plus ;~(less dot dot prn))
      ;~(pfix dot dot (plus prn))
    ==
  ==
++  get-opts
  |=  =opts-map
  ^-  opts
  =|  =opts
  opts
--
