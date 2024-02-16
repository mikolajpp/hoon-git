/+  default-agent, dbug
/+  agentio
/+  git
|%
+$  versioned-state
  $%  state-0
  ==
+$  repo-store  (map @tas repository:git)
+$  state-0  [%0 =repo-store]
+$  card  card:agent:gall
+$  command
  $%  [%put name=@tas =repository:git]
      [%update name=@tas =repository:git]
      [%delete name=@tas]
  ==
--
%-  agent:dbug
=|  state-0
=*  state  -
^-  agent:gall
=<
|_  =bowl:gall
+*  this  .
    def  ~(. (default-agent this %.n) bowl)
    do   ~(. +> bowl)
++  on-init
  ^-  (quip card _this)
  `this(state [%0 ~])
++  on-save
  ^-  vase
  !>(state)
++  on-load
  |=  old-state=vase
  ^-  (quip card _this)
  =+  state=!<(state-0 old-state)
  `this(state state)
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  |^
  ?.  ?=(%noun mark)
    !!
  =+  cmd=!<(command:git vase)
  =^  cards  state
    ?-  -.cmd
      %put    (put:do +.cmd)
      %update (update:do +.cmd)
      %delete (delete:do +.cmd)
    ==
::
++  on-watch   on-watch:def
++  on-leave   on-leave:def
++  on-peek    on-peek:def
++  on-agent   on-agent:def
++  on-arvo
  |=  [=wire sign=sign-arvo]
  ^-  (quip card _this)
  `this
::
++  on-fail    on-fail:def
--
|_  =bowl:gall
++  put
  |=  [name=@tas repo=repository:git]
  ^-  (quip card _state)
  ?:  (~(has by repos) name)
    ~|  "Repository {<name>} already exists"  !!
  `state(repo-store (~(put by repo-store) name repo))
++  update 
  |=  [name=@tas repo=repository:git]
  ^-  (quip card _state)
  ?.  (~(has by repos) name)
    ~|  "Repository {<name>} does not exist"  !!
  `state(repo-store (~(put by repo-store) name repo))
++  delete
  |=  name=@tas
  ~&  delete-repo+name
  ^-  (quip card _state)
  ?:  (~(has by repos) name)
    ~&  "Deleted Git repository {<name>}"
    `state(repos (~(del by repos) name))
  `state
--
