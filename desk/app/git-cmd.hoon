/-  *git-cmd, *sole
/+  shoe, verb, default-agent, dbug, agentio
/+  *git, *git-cmd-parser
|%
+$  state-0
  $:  dir=@tas      :: repository
      head=ref      :: HEAD
  ==
+$  versioned-state
  $%  [%0 state-0]
  ==
+$  card  card:shoe
--
=|  state-0
=*  state  -
%-  agent:dbug
^-  agent:gall
%-  (agent:shoe cmd-and-opts)
::  XX A bug in |*?
::  Calling shoe:shoe with [command (list option)] 
::  does not compile.
::
^-  (shoe:shoe cmd-and-opts)
=<  :: helper core
|_  =bowl:gall
+*  this  .
    def  ~(. (default-agent this %|) bowl)
    des  ~(. (default:shoe this command (list option)) bowl)
    do   ~(. +> bowl)
++  on-init  on-init:def
++  on-save  !>(state)
++  on-load  on-load:def
++  on-poke  on-poke:def
++  on-watch  on-watch:def
++  on-leave  on-leave:def
++  on-peek  on-peek:def
++  on-agent  on-agent:def
++  on-arvo  on-arvo:def
++  on-fail  on-fail:def
::
++  command-parser
  |=  =sole-id
  ^+  |~(nail *(like [? command (list option)]))
  %+  cook  
    |=  [cmd=command opts=(list option)]
    [| cmd opts]
  ;~  pose
    parse-ls
    parse-cd
  ==
++  tab-list
  |=  =sole-id
  :~  ['ls' leaf+"list available repositories"]
      ['cd' leaf+"change to repository"]
      ['clone' leaf+"clone a repository"]
  ==
++  on-command
  |=  [=sole-id =command opts=(list option)]
  ^-  (quip card _this)
  ~&  on-command+command
  ~&  on-command+opts
  =^  cards  state
    ?+  -.command  !!
      %ls  (ls:do sole-id command ~)
      %cd  (cd:do sole-id command ~)
    ==
  [cards this]
++  can-connect
  |=  =sole-id
  ^-  ?
  =(our.bowl src.bowl)
++  on-connect
  |=  =sole-id
  ~&  connected+sole-id
  ^-  (quip card _this)
  =;  [to=(list _sole-id) fec=shoe-effect:shoe]
    [[%shoe to fec]~ this]
  :-  ~[sole-id]
  [%sole %pro & %$ ~[' / > ']]
++  on-disconnect  on-disconnect:des
--
|_  =bowl:gall
+*  io   ~(. agentio bowl)
++  ls
  ::  XX There is a bug in the manner how bucgar is implemented.
  ::  This should really, really get fixed.
  :: |=  [=sole-id cmd=$>(%ls command)]
  ::
  |=  [=sole-id ls=command opts=(list option)]
  ^-  (quip card _state)
  ?>  ?=(%ls -.ls)
  =/  repos  .^((set @ta) %gx (scry:io /git-store/noun))
  =;  [to=(list _sole-id) fec=shoe-effect:shoe]
    [[%shoe to fec]~ state]
  :-  ~[sole-id]
  [%sole %txt "{<repos>}"]
++  cd
  |=  [=sole-id cd=command opts=(list option)]
  ^-  (quip card _state)
  ?>  ?=(%cd -.cd)
  =/  repos  .^((set @ta) %gx (scry:io /git-store/noun))
  =;  [to=(list _sole-id) fec=shoe-effect:shoe]
    [[%shoe to fec]~ state(dir name.cd)]
  :-  ~[sole-id]
  ?.  |(=(%$ name.cd) (~(has in repos) name.cd))
    [%sole %txt "cd: no such repository: /{(trip name.cd)} "]
  [%sole %pro & %$ ~[(crip " /{(trip name.cd)} > ")]]
--
