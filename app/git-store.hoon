/+  default-agent, dbug
/+  server, agentio
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
  :_  this(state [%0 ~])
  ::  Handle HTTP requests on /git
  ::
  ::  XX can we just assume the binding was successful?
  ::
  ~[[%pass /connect %arvo %e %connect [~ [%git ~]] dap.bowl]]
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
  =^  cards  state
  ?:  ?=(%handle-http-request mark)
    =+  req=!<([@ta inbound-request:eyre] vase)
    (handle-http:do req)
  ?.  ?=(%noun mark)
    ~|  "Invalid request"  !!
  =+  cmd=!<(command vase)
    ?-  -.cmd
      %put     (put:do +.cmd)
      %update  (update:do +.cmd)
      %delete  (delete:do +.cmd)
    ==
  ::
  [cards this]
::
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?:  ?=([%http-response @ta ~] path)
    `this
  (on-watch:def path)
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
::
|_  =bowl:gall
++  put
  |=  [name=@tas repo=repository:git]
  ^-  (quip card _state)
  ?:  (~(has by repo-store.state) name)
    ~|  "Repository {<name>} already exists"  !!
  `state(repo-store (~(put by repo-store.state) name repo))
++  update 
  |=  [name=@tas repo=repository:git]
  ^-  (quip card _state)
  ?.  (~(has by repo-store.state) name)
    ~|  "Repository {<name>} does not exist"  !!
  `state(repo-store (~(put by repo-store.state) name repo))
++  delete
  |=  name=@tas
  ~&  delete-repo+name
  ^-  (quip card _state)
  ?:  (~(has by repo-store.state) name)
    ~&  "Deleted Git repository {<name>}"
    `state(repo-store (~(del by repo-store.state) name))
  `state
++  handle-http
  |=  [eyre-id=@ta =inbound-request:eyre]
  ^-  (quip card _state)
  ~&  handle-http+url.request.inbound-request
  ?+  url.request.inbound-request  !!
    %'/git/info/refs?service=git-upload-pack'  
      (handle-upload-pack eyre-id request.inbound-request)
    %'/git/info/refs?service=git-receive-pack'
      (handle-receive-pack eyre-id request.inbound-request)
  ==
++  handle-upload-pack
  |=  [eyre-id=@ta request=request:http]
  ^-  (quip card _state)
  ~&  handle-upload-pack+request
  :_  state
  %+  give-simple-payload:app:server  eyre-id
    [[501 ~] ~]
++  handle-receive-pack
  |=  [eyre-id=@ta request=request:http]
  ^-  (quip card _state)
  :_  state
  %+  give-simple-payload:app:server  eyre-id
    [[501 ~] ~]
--

