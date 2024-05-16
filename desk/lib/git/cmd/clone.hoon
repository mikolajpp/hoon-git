::
::  git clone - Clone a repository into git store
::
/+  *git-cmd
|%
+$  args  [url=@t dir=(unit @tas)]
++  opt
  ;~  pose
    (flag-opt %quiet %q)
    (text-opt %origin %o)
    (flag-opt %quiet %q)
    (flag-opt %verbose %v)
    (text-opt %origin %o)
    (text-opt %branch %b)
    (flag-opt %no-tags %$)
    (flag-opt %single-branch %$)
  ==
++  parse
  %^  cmd  %clone
    opt
  ;~  plug
    ::  <url>
    url
    ::  [dir]
    (punt ;~(pfix gap urs))
  ==
    
--
