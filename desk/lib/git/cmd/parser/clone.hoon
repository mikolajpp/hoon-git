::
::  git clone - Clone a repository into %git-store
::
/+  *git-cmd-parser, *git-refs
|%
+$  args  [url=@t dir=(unit @ta)]
+$  opts  $:  quiet=_|
              verbose=_|
              :: XX What is allowed origin name?
              origin=_~.origin
              branch=refname
              no-tags=_|
              single-branch=refname
          ==
++  opt
  ;~  pose
    (flag-opt %quiet %q)
    (flag-opt %verbose %v)
    (text-opt %origin %o)
    (text-opt %branch %b)
    (flag-opt %no-tags %$)
    :: (flag-opt %single-branch %$)
    :: (flag-opt %no-single-branch %$)
  ==
++  parse
  %^  parse-cmd  %clone
    opt
  ::  Inside parse-cmd args type is not accessible
  ;~  plug
    ::  <url>
    ::
    parse-raw-url
    ::  [dir] to store in %git-store
    ::  XX solve the problem of args parsing
    ::  empty strings - parse-txt?
    (punt ;~(pfix parse-gap ;~(less hep ;~(simu prn parse-urs))))
  ==
++  get-opts
  |=  =opts-map
  ^-  opts
  =|  =opts
  ::  XX This should be auto generated
  ::
  =+  opt=(~(get by opts-map) %quiet)
  =?  quiet.opts  ?=(^ opt)
    &
  =+  opt=(~(get by opts-map) %verbose)
  =?  verbose.opts  ?=(^ opt)
    &
  =+  opt=(~(get by opts-map) %origin)
  =?  origin.opts  ?=(^ opt)
    :: XX Another typesystem bug?
    ::
    :: ?>  ?=([~ u=[%t p=@t]] opt)
    ?>  ?=($>(%t opt-value) u.opt)
    p.u.opt
  =+  opt=(~(get by opts-map) %branch)
  =?  branch.opts  ?=(^ opt)
    ?>  ?=($>(%t opt-value) u.opt)
    (scan (trip p.u.opt) parse-refname)
  =+  opt=(~(get by opts-map) %no-tags)
  =?  no-tags.opts  ?=(^ opt)
    &
  :: =+  opt=(~(get by opts-map) %single-branch)
  :: =?  single-branch.opts  ?=(^ opt)
  ::   &
  :: =+  opt=(~(get by opts-map) %no-single-branch)
  :: =?  single-branch.opts  ?=(^ opt)
  ::   &
  :: =+  opt=(~(get by opts-map) %dir)
  :: =?  dir.opts  ?=(^ opt)
  ::   ?>  ?=($>(%t opt-value) u.opt)
  ::   (scan (trip p.u.opt) parse-refname)
  opts
--
