::
::  git merge - Fast-forward merge
::
/+  *git-cmd-parser, *git-refs
|%
+$  args  raw-refname=@t
+$  opts  ~
++  parse
  %+  parse-cmd-solo  %merge
  ;~(pfix parse-gap ;~(simu prn parse-urp))
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
  :: =+  opt=(~(get by opts-map) %number)
  :: =?  number.opts  ?=(^ opt)
  ::   ?>  ?=($>(%ud opt-value) u.opt)
  ::   p.u.opt
  opts
--
