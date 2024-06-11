/+  *git-refs, stream
|%
+$  raw-refspec
  [opt=(unit @tD) src=@t dst=(unit @t)]
+$  refspec
  $:  force=_|
      negative=_|
      pattern=_|
      matching=_|
      hash=_|
      src=$~([%ref ~] $@(hash [%ref ref=refname]))
      dst=(unit refname)
  ==
--
|%
++  sane-refspec
  |=  [=refspec fetch=_|]
  &
::  Map refname using refspec
::  XX handle partial name globs
++  map-refname
  |=  [=refspec ref=refname]
  ^-  (unit refname)
  ?.  pattern.refspec  ~
  ?@  src.refspec  ~
  =+  src=(pattern-to-prefix ref.src.refspec)
  ::
  ::  XX Do we really need to differentiate refnames such as
  ::  /refs/heads and /refs/heads/ in pattern matching?
  ::  Is there any practical difference in git when it comes to 
  ::  /refs/heads* and /refs/heads/*?
  ::
  ::  With the pattern flag, /refs/heads unambigously means
  ::  /refs/heads/*, while /refs/heads/test unambigously means
  ::  /refs/heads/test*
  ::  This also means we needn't store the pattern star
  ::  as part of refspec. The flag is enough
  ::
  :: /refs/heads [%refs %heads ~]
  :: /refs/heads/ [%refs %heads %$ ~]
  :: src:/refs/heads/*
  :: dst:/refs/remotes/origin/*
  :: /refs/heads/main
  ::
  =/  sub=(unit refname)
    |-
    ::  XX ?= with null should really be fixed
    ::  XX handle partial patterns
    ?~  src  `ref
    ?~  ref  `ref
    ?.  =(i.src i.ref)  ~
    $(src t.src, ref t.ref)
  ?~  sub  sub
  %-  some
  (weld (pattern-to-prefix (need dst.refspec)) u.sub)
::  Generate a list of prefix refnames from .refspec
::
++  ref-prefixes
  |=  [=refspec fetch=_|]
  ^-  (list refname)
  =,  refspec
  ::  Select base prefix based on refspec
  ::
  =/  base=(unit refname)
    ?:  |(hash negative)
      ~
    ?:  fetch
      `+.src
    ::  push
    ::
    ?:  ?=(^ dst)
      dst
    ?:  !hash
      `+.src
    ~
  ?~  base  ~
  ?:  pattern
    ~[(pattern-to-prefix u.base)]
  ::  Expand
  ::  XX different expansion for fetch and push
  ::
  :~  u.base
      (weld /refs u.base)
      (weld /refs/heads u.base)
      (weld /refs/tags u.base)
  ==
    
++  parse-refspec  refspec:parse
++  parse-raw-refspec  raw-refspec:parse
::  Convert .raw to $refspec
::
++  raw-to-refspec
  |=  [raw=raw-refspec fetch=?]
  ^-  (unit refspec)
  =+  src=(scan (trip src.raw) refspec-src:parse)
  =/  dst=(unit refname)
    ?~  dst.raw  ~
    %-  some
    (scan (trip u.dst.raw) refspec-dst:parse)
  :: ::
  (to-refspec opt.raw src dst fetch)
::  Parsed to $refspec
::
++  to-refspec
  |=  $:  opt=(unit @t)
          src=$@(hash [%ref refname])
          dst=(unit refname)
          fetch=?
      ==
  ^-  (unit refspec)
  =/  force=?
    ?&(?=(^ opt) =('+' u.opt))
  =/  negative=?
    ?&(?=(^ opt) =('^' u.opt))
  ::
  =|  =refspec
  ?:  &(negative ?=(^ dst))
    ~|  "Invalid negative refspec"  ~
  ::  Special case ':' or '+:' for pushing matching refs
  ::
  ?:  ?&  !fetch 
          ?=([%ref %$] src)
          ?=([~ %$] dst)
      ==
    `refspec(matching &)
  ::  Verify pattern consistency
  ::
  =|  dst-glob=_|
  =?  dst-glob  ?=(^ dst)
    (has-pattern u.dst)
  =/  src-glob=?
    ?@  src  |
    (has-pattern src)
  ?:  ?:  src-glob
        ?|  &(?=(^ dst) !dst-glob)
            &(?=(~ dst) !negative fetch)
        ==
      ?&  ?=(^ dst)
        dst-glob
      ==
    ~|  "Invalid wildcard refspec"  ~
  =/  pattern  |(src-glob dst-glob)
  =/  flags
    (con refname-one-level ?.(pattern 0 refname-pattern))
  =/  sane-src=?
    ?@  src  &
    (sane-refname +.src flags)
  ::  Negative refspecs
  ::
  ::  1. src must not be empty
  ::  2. src must not be a hash
  ::  3. src must be a valid refspec
  ::
  ?:  ?&  negative
          ?|  ?=(~ src)
              ?=(hash src)
              !sane-src
          ==
      ==
    ~|  "Invalid negative refspec"  ~
  ?:  ?&  fetch
        ::  Fetch refspecs
        ::
        ::  1. if src is non-empty, it must be valid
        ::  2. if dst is non-empty, it must be valid
        ?|  &(!?=(~ src) !sane-src)
            &(?=(^ dst) !?=(~ u.dst) !(sane-refname u.dst flags))
        ==
      ==
      ~|  "Invalid fetch refspec"  ~
  ?:  ?&  !fetch
        ::  Push refspecs
        ::
        ::  1. when wildcarded, src must be valid
        ::  2. otherwise, src must be existing sha-1, 
        ::  but this can't be verified
        ::  3. if dst is missing, src must be valid
        ::  4. dst must not be empty and must be valid
        ?|  &(pattern !sane-src)
            ?~  dst  
              !sane-src
            !(sane-refname u.dst flags)
        ==
      ==
    ~|  "Invalid push refspec"  ~
  ::
  %-  some
  %=  refspec
    force  force
    negative  negative
    pattern  pattern
    hash  ?=(@ src)
    src  src
    dst  dst
  ==
++  parse
  |%
  ::  force '+' or negative '^'
  ::
  ++  refspec-opt
    (punt ;~(pose lus ket))
  ::  source: hash or refname
  ::
  ++  refspec-src
    ;~  pose
      ::  XX use generic hash parser
      ::
      parse-sha-1
      (stag %ref (cold ['HEAD' ~] pat))
      (stag %ref parse-refname)
    ==
  ::  target: refname
  ::
  ++  refspec-dst  parse-refname
  ++  refspec
    |*  fetch=?
    ::  XX Eh, no function composition rune?
    ::  ;.(need to-refspec)
    %+  cook
      ::  XX This should work
      :: (corl need (curr to-refspec &))
      |=  $:  opt=(unit @t)
              src=$@(hash [%ref refname])
              dst=(unit refname)
          ==
      (need (to-refspec opt src dst fetch))
    ;~  plug
      refspec-opt
      refspec-src
      (punt ;~(pfix col refspec-dst))
    ==
  ++  raw-refspec
    ;~  plug
      (punt ;~(pose lus ket))
      ;~  pose
        pat  ::  HEAD
        parse-raw-pattern-refname 
      ==
      (punt ;~(pfix col parse-raw-pattern-refname))
    ==
  --
--
