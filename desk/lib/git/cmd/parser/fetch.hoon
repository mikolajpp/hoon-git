::
::  git fetch - Download objects and refs from another repository
::
::
/+  *git-cmd-parser, *git-refs, *git-refspec
|%
+$  args  [remote=(unit @t) raw-refspecs=(list raw-refspec)]
+$  opts  $:  all=_|
              atomic=_|
              force=_|
              tags=_|
              no-tags=_|
              prefetch=_|
              set-upstream=_|
              quiet=_|
              verbose=_|
          ==
++  opt
  ;~  pose
    (flag-opt %all %$)
    (flag-opt %atomic %$)
    (flag-opt %force %f)
    (flag-opt %tags %t)
    (flag-opt %no-tags %n)
    (flag-opt %prefetch %$)
    (flag-opt %set-upstream %$)
    (flag-opt %quiet %q)
    (flag-opt %verbose %v)
  ==
++  parse
  %^  parse-cmd-with-pfix  %fetch
    opt
  ::  XX How to handle options following
  ::  an argument?
  ::  Currently 'fetch origin --verbose' will
  ::  take --verbose to be the second argument.
  ::  This should only be the case if we signalled
  ::  end of options with `--`. It seems in +cmd
  ::  parser, before scanning for arguments, we should first
  ::  extract the argument region with ending with first -.
  ::
  ::  XX this seems unnecessary
  :-  (easy ~)
  ::
  ::  XX This parser could be simplified if
  ::  parse-cmd had access to the args type and
  ::  could get its bunt:
  ::  %^  parse-cmd-default %fetch opt args
  ::  would allow args to assume their default value if
  ::  no arguments were supplied.
  ::
  ;~  pose
    ;~  pfix
      parse-gap
      ;~  plug
        ::  [<remote: name or URL>]
        ::
        (punt parse-raw-url)
        ::  [<refspec>...]
        ::
        ;~  pose
          ;~  pfix  parse-gap
            (most parse-gap ;~(simu prn parse-raw-refspec))
          ==
          (cold ~ (star ace))
        ==
      ==
    ==
    (easy *args)
  ==
++  get-opts
  |=  =opts-map
  ^-  opts
  =|  =opts
  =+  opt=(~(get by opts-map) %all)
  =?  all.opts  ?=(^ opt)
    &
  =+  opt=(~(get by opts-map) %atomic)
  =?  atomic.opts  ?=(^ opt)
    &
  =+  opt=(~(get by opts-map) %force)
  =?  force.opts  ?=(^ opt)
    &
  =+  opt=(~(get by opts-map) %tags)
  =?  tags.opts  ?=(^ opt)
    &
  =+  opt=(~(get by opts-map) %no-tags)
  =?  no-tags.opts  ?=(^ opt)
    &
  =+  opt=(~(get by opts-map) %prefetch)
  =?  prefetch.opts  ?=(^ opt)
    &
  =+  opt=(~(get by opts-map) %set-upstream)
  =?  set-upstream.opts  ?=(^ opt)
    &
  =+  opt=(~(get by opts-map) %quiet)
  =?  quiet.opts  ?=(^ opt)
    &
  =+  opt=(~(get by opts-map) %verbose)
  =?  verbose.opts  ?=(^ opt)
    &
  opts
--
