::
::  git cd - Navigation
::
::  > cd [/repo][:master]/dir
::
/+  *git-cmd
|%
+$  args  name=@ta
::
++  parse
  %+  parse-cmd-solo  %cd
  ;~  pose
    ;~(pfix parse-gap ;~(pfix fas parse-urs))
    (easy %$)
  ==
--
