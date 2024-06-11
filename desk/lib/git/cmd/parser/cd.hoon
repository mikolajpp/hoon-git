::
::  git cd - Navigation
::
::  > cd [/repo][:master]
::
/+  *git-cmd-parser, *git-refs
|%
+$  args  [repo=@ta branch=@t]
::
++  parse-repo  
  parse-urs
++  parse-branch
  ;~  pose
    ;~(simu prn parse-raw-refname)
    (easy '') 
  ==
++  parse
  %+  parse-cmd-solo  %cd
  ;~  pose
    ;~  pfix  parse-gap
      ;~  plug
        ::  /[repo]
        ;~(pfix fas parse-repo)
        ::  [:branch]
        ;~  pose
          ;~(pfix col parse-branch)
          (easy '')
        ==
      ==
    ==
    (easy ~. '')
  ==
--
