/-  *sole
/+  shoe, verb, default-agent, dbug, agentio
/+  *git, *git-cmd
::  XX Find a way to import commands in bulk
::  Commands
::
/+  git-cmd-ls
/+  git-cmd-cd
/+  git-cmd-cat
/+  git-cmd-clone
::
|%
+$  state-0
  $:  dir=@tas      :: repository
      head=ref      :: revision
  ==
+$  versioned-state
  $%  [%0 state-0]
  ==
+$  card  card:shoe
+$  command  $+  git-command
  $%  [%ls args:git-cmd-ls]
      [%cd args:git-cmd-cd]
      [%cat args:git-cmd-cat]
      [%lock %~]
      ::
      [%clone args:git-cmd-clone]
      [%diff diff-args]
      [%fetch fetch-args]
      [%log log-args]
      [%merge merge-args]
      [%pull pull-args]
  ==
+$  cat-file-args  ~
+$  diff-args  ~
+$  fetch-args  ~
+$  log-args  ~
+$  merge-args  ~
+$  pull-args  ~
--
=|  state-0
=*  state  -
%-  agent:dbug
^-  agent:gall
%-  (agent:shoe ,[command (list option)])
^-  (shoe:shoe [command (list option)])
=<
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
  ::  XX A weird bug: putting clone first results in 
  ::  -find.p.roq error
  ::
  ;~  pose
    parse:git-cmd-ls
    parse:git-cmd-cd
    parse:git-cmd-cat
    ::
    parse:git-cmd-clone
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
  ~&  cmd+command
  ~&  opts+opts
  =^  cards  state
    ?+  -.command
      :_   state
      [%shoe ~[sole-id] %sole %txt "Unknown command: {(trip -.command)}"]~
      ::
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
  [%sole %pro & %$ ~[' /> ']]
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
  [%sole %tan ~[rose+[[" " " " " "] ~(tap in repos)]]]
++  cd
  |=  [=sole-id cd=command opts=(list option)]
  ^-  (quip card _state)
  ?>  ?=(%cd -.cd)
  =/  repos  .^((set @ta) %gx (scry:io /git-store/noun))
  =;  [to=(list _sole-id) fec=shoe-effect:shoe]
    [[%shoe to fec]~ state(dir name.cd)]
  :-  ~[sole-id]
  ?.  |(=(%$ name.cd) (~(has in repos) name.cd))
    [%sole %txt "cd: no such repository: /{(trip name.cd)}"]
  [%sole %pro & %$ ~[(crip " /{(trip name.cd)}> ")]]
--
