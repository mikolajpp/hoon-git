/+  *git-hash, stream
|%
+$  refname  $+(refname (list @t))
::  XX rename refname to symref
+$  ref  $@(hash [%symref =refname])
::  XX Can you use an axal with ref-path instead
::  of path from the aura typesystem
::  point of view?
::
+$  refs  $+(git-refs (axal ref))
--
|%
::  Refs namespace
::
++  refspace
  |%
  ++  head  ['HEAD' ~]
  ::  XX rename to branch and tag
  ++  branches  /refs/heads
  ++  tags  /refs/tags
  ++  remote  /refs/remotes
  ++  prefetch  /refs/prefetch
  --
++  has-pattern
  |=  =refname
  ^-  ?
  |-
  ?~  refname  |
  ?^  (find-byte:stream '*' 0+(as-octs:stream i.refname))
    &
  $(refname t.refname)
::  Transform pattern refname to ls-refs prefix
::
::  /a/b/*  -> /a/b
::  /a/b/c* -> /a/b/c
::  /a/b*/c -> /a/b
::
++  pattern-to-prefix
  |=  pat=refname
  ^-  refname
  =|  pix=refname
  |-
  ?~  pat  (flop pix)
  ?:  =('*' i.pat)
    (flop pix)
  =+  glob=(find-byte:stream '*' 0+(as-octs:stream i.pat))
  ?~  glob
    $(pat t.pat, pix [i.pat pix])
  (flop [(cut 3 [0 u.glob] i.pat) pix])
++  expand-ref-prefix
  |=  pix=refname
  ^-  (list refname)
  :~  pix
      (weld /refs pix)
      (weld /refs/tags pix)
      (weld /refs/heads pix)
      (weld /refs/remotes pix)
      :(weld /refs/remotes pix ['HEAD' ~])
  ==
++  print-ref
  |=  =ref
  ^-  tape
  ::  XX parametrize on hash algo
  ?@  ref
    (print-hash-sha-1 ref)
  "symref: {<refname.ref>}"
++  print-refname
  |=  =refname
  ^-  @t
  ?~  refname  %$
  =+  pri=i.refname
  ::  XX why does =. not work here?
  =+  refname=t.refname
  |-
  ?~  refname  pri
  ?:  =(%$ i.refname)
    $(pri (cat 3 pri '/'), refname t.refname)
  %=  $
    refname  t.refname
    pri  :((cury cat 3) pri '/' i.refname)
  ==
++  parse-refname  refname:parse
++  parse-raw-refname  raw-refname:parse
++  parse-raw-pattern-refname  raw-pattern-refname:parse
++  parse-refname-ext  refname-ext:parse
::
++  parse
  |%
  ::  Invalid characters
  ::  ':', '?', '[', '\', '^', '~', ' ', '/'
  ::
  ++  except
    ;~  pose
      col  wut
      sel  bas
      ket  sig
      ace  fas
    ==
  ++  char
    ;~  less
      except
      ;~(plug dot dot)  :: disallow ".."
      ;~(plug pat kel)  :: disallow "@{"
      prn
    ==
  ++  segment
    %+  cook  crip
    ;~  plug
      :: disallow initial '.'
      ;~(less dot char)
      (star char)
    ==
  ++  refname
    ;~  less
      pat
      (more fas segment)
    ==
  ::  refname with optional trailing '/'
  ::
  ++  refname-ext  ;~(sfix refname (punt fas))
  ++  raw-refname
    %+  cook
      |=(a=tape ^-(@t (rap 3 a)))
    :: @ta with '/'
    (star ;~(pose nud hig low hep dot sig cab fas))
  ++  raw-pattern-refname
    %+  cook
      |=(a=tape ^-(@t (rap 3 a)))
    :: @ta with '/' and '*'
    (star ;~(pose nud hig low hep dot sig cab fas tar))
  --
::  Sane flags
::  XX is there a better Hoon pattern?
::
++  refname-one-level  0x1
++  refname-pattern    0x2
::
++  has-flag
  |=  [lag=@uxD flags=@uxD]
  ^-  ?
  !=(0 (dis lag flags))
++  sane-refname
  |=  [=refname flags=@uxD]
  ^-  ?
  ?~  refname  |
  ::  XX Allow only single pattern
  ::
  ::  Disallow trailing dot
  ::
  =+  rear=(rear refname)
  =+  last=(cut 3 [(dec (met 3 rear)) 1] rear)
  ?:  =('.' last)
    |
  ?:  ?&  !(has-flag refname-one-level flags)
          (lth (lent refname) 2)
      ==
    |
  &
--
