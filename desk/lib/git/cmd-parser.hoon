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
::  XX move this to hoon.hoon
::  This should be |*
++  fail  |=(tub=nail ^-(edge [p=p.tub q=~]))
++  cmd
  |*  [cmd=@tas args=rule opt-rule=rule]
  |=  tub=nail
  ^-  (like [command (list option)])
  ::  Parse front options, command arguments
  ::
  ::  XX using , somehow changes output of 
  ::  compiler error. 
  ::
  =/  vex=(like [(list option) (unit [@t @t]) command])
    %.  tub
    ;~  plug
      (star opt-rule)
      (punt ;~(plug hep hep))
      (stag cmd ;~(pfix (jest cmd) args))
    ==
  ?~  q.vex  vex
  =/  [front=(list option) opt-end=(unit *) =command]
    p.u.q.vex
  :: ?~  opt-end
  [p.vex `[[command front] q.u.q.vex]]
  :: =/  vex
  ::   ((star opt-rule) q.u.q.vex)
  :: ?~  q.vex  q.vex
  :: =+  back=p.u.q.vex
  :: [p.vex `[[command (weld front back)] q.u.q.vex]]
++  parse-ls
  (stag %ls ;~(pfix (jest %ls) (easy %~)))
  :: %^  cmd  %ls  (easy %~)
  ::   fail
++  parse-cd
  =/  opt
   ;~  pose
    (opt %depth %d %ud)
    (opt %quiet %q %f)
   ==
  %^  cmd  %cd
    ;~(pfix (punt ;~(plug ace fas)) urs)
  opt
--
