/+  default-agent, dbug
/+  agentio
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
    cmd  ~(. +> bowl)
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
  =^  cards  state
    (handle-cmd !<(command:git vase))
  [cards this]

  ++  handle-cmd
    |=  com=command:git
    ^-  (quip card _state)
    ?-  -.com
      %init    (init:cmd +.com)
      %clone   (clone:cmd +.com)
      %list    list:cmd
      %delete  (delete:cmd +.com)
    ==
  --
::
++  on-watch   on-watch:def
++  on-leave   on-leave:def
++  on-peek    on-peek:def
++  on-agent   on-agent:def
++  on-arvo
  |=  [=wire sign=sign-arvo]
  ^-  (quip card _this)
  ?>  ?=([%clone %pack @tas ~] wire)
  =+  name=i.t.t.wire
  ?:  (~(has by repos.state.this) name)
    ~|  "Repository {<name>} already exists"  !!
  ?>  ?=([%khan %arow *] sign)
  ?:  ?=(%| -.p.sign)
    ((slog leaf+<p.p.sign> ~) `this)
  =+  pack=!<(pack:git q.p.p.sign)
  ~&  "Successfully cloned new repository {<name>}"
  =|  repo=repository:git
  =.  repo  repo(archive [pack ~])
  =+  repos=(~(put by repos.state) [name repo])
  `this(repos.state repos)
++  on-fail    on-fail:def
--
|_  =bowl:gall
+*  aio  ~(. agentio bowl)
::
++  init
  |=  name=@tas
  ^-  (quip card _state)
  ?:  (~(has by repos) name)
    ~&  "Reinitialized existing Git repository {<name>}"
    `state
  ~&  "Initialized empty Git repository {<name>}"
  `state(repos (~(put by repos) name *repository:git))
++  clone
  |=  [name=@tas url=@t]
  ^-  (quip card _state)
  =+  ted=[%fard q.byk.bowl %git-clone %noun !>(`url)]
  :_  state
  [%pass [%clone %pack name ~] %arvo %k ted]~
::
++  delete
  |=  name=@tas
  ^-  (quip card _state)
  ?:  (~(has by repos) name)
    ~&  "Deleted Git repository {<name>}"
    `state(repos (~(del by repos) name))
  `state
::
++  list 
  |-
  ^-  (quip card _state)
  ~&  ~(key by repos)
  `state
::
::  XX should accept octs
::
:: ++  cmd-hash-object
::   |=  [repository=(unit @tas) type=object-type:git data=@]
::   ^-  (quip card _state)
::   ?~  repository
::     =/  hax  (make-hash-raw:obj:git %sha-1 [type [(met 3 data) data]])
::       ~&  +.hax
::     `state
::   =/  repo  (~(got by repos) u.repository)
::   =.  repo  (~(put go:git repo) [%blob [(met 3 data) data]])
::   `state(repos (~(put by repos) u.repository repo))
::
:: ++  cmd-cat-file
::   |=  [repository=@tas hash=@ta]
::   ^-  (quip card _state)
::   ?:  (lth (met 3 hash) 4)
::     ~|  "Not a valid object name {<hash>}"  !!
::   =/  repo  (~(got by repos) repository)
::   =/  keys  (~(find-key go:git repo) hash)
::   ?~  keys
::     ~|  "Not a valid object name {<hash>}"  !!
::   ?:  (gth (lent keys) 1)
::     ~|  "Short object ID {<hash>} is ambigous"
::     ~|  "{<keys>}"
::     !!
::   ~&  (~(got go:git repo) [%sha-1 i.keys])
::   `state
--
