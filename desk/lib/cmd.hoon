/-  *git-cmd
|%
::  XX Given an options mold, and an options map,
::  return a filled options noun. Should run compiled.
::
++  get-opts  !!
++  cmd-parse  cmd:parse
++  parse
  |%
  ::  Renovated @ta to include uppercase
  ::
  ++  urs  %+  cook
             |=(a=tape (rap 3 ^-((list @) a)))
           (star ;~(pose nud hig low hep dot sig cab))
  ++  gap  (plus ace)
  ++  val-f  (easy ~)  :: option is present
  ::  XX Allow non-Hoon integers
  ++  val-ud  dem:ag
  ++  val-t
    ;~  pose
      ::  'cord'
      (ifix [soq soq] (boss 256 (star qit)))
      ::  unescaped cord
      (boss 256 (star ;~(less ace qit)))
    ==
  ++  value
    |*  kind=opt-kind
    ?-  kind
      %f  (stag %f val-f)
      %t  (stag %t val-t)
      %ud  (stag %ud val-ud)
    ==
  ::  -o
  ++  short
    |=(o=char ;~(plug hep (just o)))
  ::  --opt
  ++  long
    |=  opt=@tas
    ;~(plug hep hep (jest opt))
  ::  -o val, -oval
  ++  short-value
    |=  [o=char kind=opt-kind]
    ?:  ?=(%f kind)
      ;~(pfix (short o) (value kind))
    ;~(pfix (short o) ;~(pfix (star ace) (value kind)))
  ::  --opt val, --opt=val
  ++  long-value
    |=  [opt=@tas kind=opt-kind]
    ::  XX a bug in the parser:
    ::  ?=(kind %f) parser to something wrong
    ::
    ?:  ?=(%f kind)
      ;~(pfix (long opt) (value kind))
    ;~  pfix
      (long opt)
      ;~  pose
        ;~(pfix tis (value kind))
        ;~(pfix gap (value kind))
      ==
    ==
  ++  short-or-long-value
    |=  [o=@t opt=@tas kind=opt-kind]
    ;~  pose
      (short-value o kind)
      (long-value opt kind)
    ==
  ++  opt
    |=  [opt=@tas o=@tas kind=opt-kind]
    %+  stag  opt
    ?:  =(%$ o)
      (long-value opt kind)
    (short-or-long-value o opt kind)
  ++  flag-opt
    |=  [opt=@tas o=@tas]
    (^opt opt o %f)
  ++  text-opt
    |=  [opt=@tas o=@tas]
    (^opt opt o %t)
  ++  num-opt
    |=  [opt=@tas o=@tas]
    (^opt opt o %ud)
  ++  cmd-solo
    |*  [cmd=@tas args=rule]
    %+  cook
      |=(cmd=* [cmd ~])
    (stag cmd ;~(pfix (jest cmd) args))
  ++  any-short-opt
    ;~(plug hep ;~(pose low dit))
  ++  any-long-opt
    ;~(plug hep hep ;~(pose low dit))
  ++  any-opt
    ;~(pose any-short-opt any-long-opt)
  ++  cmd
    |*  [cmd=@tas opt=rule args=rule]
    |=  tub=nail
    ^-  (like [* (list option)])
    ::  Parse front options, command arguments
    ::
    ::  XX using , somehow changes output of
    ::  compiler error.
    ::
    =/  vex=(like [(list option) (unit *) *])
      %.  tub
      ;~  pfix  (jest cmd)
        ;~  plug
          (ifix [gap (star ace)] (more gap opt))
          (punt ;~(plug hep hep gap))
          (stag cmd args)
        ==
      ==
    ?~  q.vex  vex
    =/  [front=(list option) opt-end=(unit *) command=*]
      ~&  parse-cmd+[front command]
      p.u.q.vex
    ?:  ?|(?=(^ opt-end) =("" q.q.u.q.vex))
      [p.vex `[[command front] q.u.q.vex]]
    =/  vex=(like (list option))
      %.  q.u.q.vex
      ;~  sfix
        ;~(pfix gap (more gap opt))
        (star ace)
      ==
    ?~  q.vex  vex
    =+  back=p.u.q.vex
    :: ~&  parse-cmd+[command front back]
    [p.vex `[[command (weld front back)] q.u.q.vex]]
  --
--
