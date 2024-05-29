/-  *git-cmd
|%
::
++  parse-cmd-solo  cmd-solo:parse
++  parse-cmd  cmd:parse
++  parse-cmd-with-pfix  cmd-with-pfix:parse
::
++  parse-gap  gap:parse
++  parse-hym  hym:parse
++  parse-urs  urs:parse
++  parse-urp  urp:parse
::
++  parse-url  auri:de-purl:html
++  parse-raw-url  url:parse
::
++  flag-opt  flag-opt:parse
++  text-opt  text-opt:parse
++  num-opt  num-opt:parse
::
++  parse
  |%
  :: Like sym, but includes uppercase
  ++  hym
    %+  cook
      |=(a=tape (rap 3 ^-((list @) a)))
    ;~(plug ;~(pose low hig) (star ;~(pose nud low hig hep)))
  ::  renovated @ta
  ++  urs  %+  cook
             |=(a=tape ^-(@ta (rap 3 a)))
           (star ;~(pose nud hig low hep dot sig cab))
  ::  urs path
  ::
  ++  urp  %+  cook
             |=(a=tape ^-(@ta (rap 3 a)))
           (star ;~(pose nud hig low hep dot sig cab fas))
  ::  XX Add valid +url to cord parser
  ::
  ++  url
    %+  cook
      |=(a=tape ^-(@t (rap 3 ^-((list @) a))))
    (plus ;~(pose nud low hig hep dot sig cab col fas))
  ++  gap  (plus ace)
  ++  val-f  (easy ~)
  ++  val-ud  dem:ag
  ++  val-t
    ;~  pose
      ::  'cord'
      (ifix [soq soq] (boss 256 (star qit)))
      ::  unescaped cord
      (boss 256 (star ;~(less ace qit)))
    ==
  ++  value
    |=  kind=opt-kind
    ^-  $-(nail (like opt-value))
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
      |*(cmd=* [cmd ~])
    (stag cmd ;~(pfix (jest cmd) args))
  ++  any-short-opt
    ;~(plug hep ;~(pose low dit))
  ++  any-long-opt
    ;~(plug hep hep ;~(pose low dit))
  ++  any-opt
    ;~(pose any-short-opt any-long-opt)
  ++  cmd
    |*  [cmd=@tas opt=rule args=rule]
    (cmd-with-pfix cmd opt gap args)
  ::  Generic command parser
  ::
  ::  .cmd: command name
  ::  .opt: option
  ::  .pix: arguments prefix
  ::  .args: arguments
  ::
  ++  cmd-with-pfix
    |*  [cmd=@tas opt=rule pix=rule args=rule]
    |=  tub=nail
    ^-  (like [[_cmd _(wonk *args)] (list option)])
    ::  Parse front options, command arguments
    ::
    ::  XX using , somehow changes output of
    ::  compiler error.
    ::
    =/  vex=(like [(list option) (unit *) command=[_cmd _(wonk *args)]])
      %.  tub
      ;~  pfix  (jest cmd)
        ;~  plug
          (star ;~(pfix gap opt))
          (punt ;~(plug gap hep hep))
          ;~(pfix pix (stag cmd args))
        ==
      ==
    :: ~&  vex
    ?~  q.vex  vex
    =/  [front=(list option) opt-end=(unit *) command=[_cmd _(wonk *args)]]
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
    [p.vex `[[command (weld front back)] q.u.q.vex]]
  --
--
