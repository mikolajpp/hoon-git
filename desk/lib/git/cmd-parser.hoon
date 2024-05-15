/-  *git-cmd
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
  ;~(pfix (short o) ;~(pfix (punt gap) (value kind)))
::  --opt val, --opt=val
++  long-value
  |=  [opt=@tas kind=opt-kind]
  ;~  pfix
    (long opt)
    ;~  pose
      ;~(pfix tis (value kind))
      ;~(pfix gap (value kind))
    ==
  ==
++  long-or-short-value
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
  (long-or-short-value o opt kind)
::  XX Handle options terminator '--'
::
++  fin  ;~(plug hep hep)
::  XX move this to hoon.hoon
++  fail  |=(tub=nail ^-(edge [p=p.tub q=~]))
++  cmd
  |=  $:  name=@tas 
          rule=_|~(nail *(like command))
          opt=_|~(nail *(like option))
      ==
  |=  tub=nail
  ::  XX this parser could definitely 
  ::  be written with combinators
  ::
  ^-  (like [command (list option)])
  ::  Parse front options
  ::
  =/  vex=edge
    ((star opt) tub)
  :: [hair (unit p=nail q=*)]
  ?~  q.vex  vex
  =+  front=q.u.q.vex
  ::  Check for options terminator
  ::
  =/  fex
    (fin p.u.q.vex)
  ::  Parse program command and arguments
  ::
  =/  vex
    %-  (stag name ;~(pfix name rule))
    ?~(fex p.u.q.vex p.u.q.fex)
  ?~  vex  vex
  =+  cmd=q.u.q.vex
  ?~  fex
    [p.vex `[p.u.vex cmd front]]
  ::  If no separator was found, parse remaining options
  ::
  =/  vex
    ((star opt) p.u.q.vex)
  ?~  vex  vex
  =+  back=q.u.q.vex
  [p.vex `[p.u.vex cmd (weld front back)]]
++  parse-ls
  %^  cmd  %ls  (easy ~)
    fail
  :: %+  cmd  %ls
  :: (easy ~)
++  parse-cd
  =/  opt
   ;~  pose
    (opt %depth %d %ud)
    (opt %quiet %q %f)
   ==
  %^  cmd  %cd 
    ;~(pfix (punt ;~(plug ace fas)) urs)
  `opt
--
