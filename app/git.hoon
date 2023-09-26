/+  default-agent, dbug
/+  git
|%
+$  versioned-state  
  $%  state-0
  ==
+$  repositories  (map @tas repository:git)
+$  state-0  [%0 repos=repositories]
+$  card  card:agent:gall
--
%-  agent:dbug
=|  state-0
=*  state  -
^-  agent:gall
=<
|_  =bowl:gall
+*  this  .
    def  ~(. (default-agent this %.n) bowl)
    do  ~(. +> bowl)
++  on-init
  ^-  (quip card _this)
  `this(state [%0 ~])
++  on-save    
  ^-  vase
  !>(state)
++  on-load  
  |=  old-state=vase
  ^-  (quip card _this)
  =/  state  !<(state-0 old-state)
  `this(state state)
::
++  on-poke    
  |=  [=mark =vase]
  ^-  (quip card _this)
  |^
  ?.  ?=(%noun mark)
    !!
  =^  cards  state
    (handle-cmd !<(command:git vase))
  [cards this]

  ++  handle-cmd
    |=  cmd=command:git
    ^-  (quip card _state)
    ?-  -.cmd
      %init         (cmd-init:do +:cmd)
      %ls           (cmd-ls:do)
      %hash-object  (cmd-hash-object:do +:cmd)
      %cat-file     (cmd-cat-file:do +:cmd)
    ==
  --
::
++  on-watch   on-watch:def
++  on-leave   on-leave:def
++  on-peek    on-peek:def
++  on-agent   on-agent:def
++  on-arvo    on-arvo:def
++  on-fail    on-fail:def
--
|_  =bowl:gall
::
++  cmd-init
  |=  name=@tas
  ^-  (quip card _state)
  ?:  (~(has by repos) name)
    ~&  "Reinitialized existing Git repository {<name>}"
    `state
  ~&  "Initialized empty Git repository {<name>}"
  `state(repos (~(put by repos) name *repository:git))
::
++  cmd-ls
  |.
  ^-  (quip card _state)
  ~&  ~(key by repos)
  `state
::
++  cmd-hash-object
  |=  [repository=(unit @tas) type=object-type:git data=@]
  ^-  (quip card _state)
  ?~  repository 
    =/  hax  (make-hash-raw:obj:git %sha-1 [type data])
      ~&  +.hax
    `state
  =/  repo  (~(got by repos) u.repository)
  =.  repo  (~(put go:git repo) [%blob data])
  `state(repos (~(put by repos) u.repository repo))
::
++  cmd-cat-file
  |=  [repository=@tas hash=@ta]
  ^-  (quip card _state)
  ?:  (lth (met 3 hash) 4) 
    ~|  "Not a valid object name {<hash>}"  !!
  =/  repo  (~(got by repos) repository)
  =/  keys  (~(find-key go:git repo) hash)
  ?~  keys
    ~|  "Not a valid object name {<hash>}"  !!
  ?:  (gth (lent keys) 1)
    ~|  "Short object ID {<hash>} is ambigous"
    ~|  "{<keys>}"
    !!
  ~&  (~(got go:git repo) [%sha-1 i.keys])
  `state
--
