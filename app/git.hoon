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
      %init      (init:cmd +.com)
      %cat-file  (cat-file:cmd +.com)
      %clone     (clone:cmd +.com)
      %delete    (delete:cmd +.com)
      %pull      (pull:cmd +.com)
      %list      list:cmd
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
  ?+  wire  !!
    ::  /clone/repo
    [%clone @tas ~]
      =+  name=i.t.wire
      ?>  ?=([%khan %arow *] sign)
      ?:  ?=(%| -.p.sign)
         %-  (slog +.p.p.sign)
         ~&  clone-failed+name
         `this(repos.state (~(del by repos.state) name))
      =/  [refs=(^list reference:git) pack=pack:git]
        !<  [(^list reference:git) pack:git]
        q.p.p.sign
      ~&  "Successfully cloned new repository {<name>}"
      =+  repo=(~(got by repos.state) name)
      =/  origin=remote:git
        %-  got:~(phone git remote.repo) %origin
      =.  refs.origin  (malt refs)
      ::
      =|  repo=repository:git
      ::  Find main branch
      ::
      =+  main=(find-main-branch:git refs)
      ?~  main
        ~|  "No main branch detected"  !!
      =.  repo  =~  repo
        (put:~(refer git .) u.main)
        (put:~(track git .) -.u.main
        (put:~(phone git .) %origin origin)
      ==
      `this(repos.state  (~(put by repos.state) name repo))
    ::  /fetch/repo/remote
    ::
    ::  /pull/repo/remote
    [%pull @tas @tas ~]
      =+  repo-name=i.t.wire
      =+  remote-name=i.t.t.wire
      ?>  ?=([%khan %arow *] sign)
      ?:  ?=(%| -.p.sign)
        ~&  fetch-failed+name
        %-  (slog +.p.p.sign)
        `this
      =+  fetch-pack=!<(fetch-pack:git q.p.p.sign)
      ~&  "Successfully fetched refs for {<remote-name>}"
      =+  repo=(~(got by repos.state) repo-name
      =.  repo 
        =~  repo
          (receive-pack:~(store git .) pack.fetch-pack)
          (update-refs:~(phone git .) remote-name refs.fetch-pack)
          (update:~(track git .) remote-name refs.fetch-pack)
        ==
      ::  Update the master branch
      ::
      `this(repos.state (~(put by repos.state) repo-name repo))
  ==
::
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
::
++  clone
  |=  [name=@tas url=@t]
  ^-  (quip card _state)
  ?:  (~(has by repos.state) name)
    ~|  "Repository {<name>} already exists"  !!
  =+  ted=[%fard q.byk.bowl %git-clone %noun !>(url)]
  ::  Start the clone thread
  ::
  :-
  [%pass ~[%clone name] %arvo %k ted]~
  ::  Create an empty repository
  ::
  =/  origin=remote:git
    [url ~]
  =|  repo=repository:git
  =.  remotes.repo
    (malt ~[[%origin origin]])
  state(repos (~(put by repos) [name repo]))
::
++  pull
  |=  [name=@tas remote=@tas]
  ^-  (quip card _state)
  =+  repo=(~(get by repos.state) name)
  ?~  repo
    ~|  "Repository {<name>} not found"  !!
  ?.  (~(has by remotes.u.repo) remote)
    ~|  "Remote {<remote>} not found"  !!
  =+  ted=[%fard q.byk.bowl %git-fetch %noun !>([u.repo remote])]
  :_  state
  :~
    [%pass ~[%pull name remote] %arvo %k ted]
  ==
::
++  delete
  |=  name=@tas
  ~&  delete-repo+name
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
++  cat-file
  |=  [repository=@tas hash=@ta]
  ^-  (quip card _state)
  ?:  (lth (met 3 hash) 4)
    ~|  "Not a valid object name {<hash>}"  !!
  =/  repo  (~(got by repos) repository)
  ?~  archive.object-store.repo  !!
  =/  keys
    (~(find-keys pak:git i.archive.object-store.repo) hash)
  ?~  keys
    ~|  "No object found for {<hash>}"  !!
  ?:  (gth (lent keys) 1)
    ~|  "Short object ID {<hash>} is ambiguous"
    ~|  "{<keys>}"
    !!
  ~&  cat-file+i.keys
  ~&  (~(got pak:git i.archive.object-store.repo) i.keys)
  `state
--
