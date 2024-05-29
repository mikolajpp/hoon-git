::
::  git rm - Delete repository
::
::  > rm /repo
::
/+  *git-cmd
|%
+$  args  name=@ta
::
++  parse
  %+  parse-cmd-solo  %rm
  ;~  pose
    ;~(pfix parse-gap ;~(pfix fas parse-urs))
    (easy %$)
  ==
--
