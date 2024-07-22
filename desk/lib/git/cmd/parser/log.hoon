::
::  git log - Show commit logs
::
/+  *git-cmd-parser, *git-refs
|%
+$  args  raw-refname=@t
+$  opts  $:  number=_1
          ==
::  XX Git supports option of the form
::  -@ud. Extend the command parser
::  to accomodate this.
++  opt
  ;~  pose
    (num-opt %number %n)
  ==
++  parse
  %^  parse-cmd-with-pfix  %log
    opt
  :-  (easy ~)
  ;~  pose
    ;~(pfix parse-gap parse-urp)
    (easy '')
  ==
++  get-opts
  |=  =opts-map
  ^-  opts
  =|  =opts
  ::  XX This should be auto generated
  ::
  :: =+  opt=(~(get by opts-map) %single-branch)
  :: =?  single-branch.opts  ?=(^ opt)
  ::   &
  :: =+  opt=(~(get by opts-map) %no-single-branch)
  :: =?  single-branch.opts  ?=(^ opt)
  ::   &
  =+  opt=(~(get by opts-map) %number)
  =?  number.opts  ?=(^ opt)
    ?>  ?=($>(%ud opt-value) u.opt)
    p.u.opt
  opts
--
