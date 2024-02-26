/+  default-agent, dbug
/+  server, agentio
/+  git, *git-http, stream
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
  =/  =request-line:server
    (parse-request-line:server url.request.inbound-request)
  ?>  ?=([%git @t %info %refs ~] site.request-line)
  =+  repo=i.t.site.request-line
  ~&  handle-http+[eyre-id request-line]
  ?>  ?=([[%service @t] ~] args.request-line)
  ?+  value.i.args.request-line  !!
    %git-upload-pack
      (handle-upload-pack repo eyre-id request.inbound-request)
    %git-receive-pack
      (handle-receive-pack repo eyre-id request.inbound-request)
  ==
++  handle-upload-pack
  |=  [repo=@ta eyre-id=@ta request=request:http]
  ^-  (quip card _state)
  =+  ver=(get-header:http 'git-protocol' header-list.request)
  ?~  ver  !!
  ~&  request
  ::  Only support upload-pack
  ::  v2 protocol
  ::
  ?>  =('version=2' u.ver)
  =<
  ?+  method.request
    ~|  "upload-pack: unsupported method {<method.request>}"  !!
  %'GET'  greet-client
  %'POST'  ~&  handle-upload-pack+%post  !!
  ==
  |%
  ++  greet-client
    ^-  (quip card _state)
    =/  payload=simple-payload:http
      =-  [[200 ~[['git-protocol' 'version=2']]] -]
      %-  some  %-  can-octs:stream
        :~  (write-pkt-line-txt '# service=git-upload-pack')
            (write-pkt-len flush-pkt)
            (write-pkt-line-txt 'version 2')
            (write-pkt-line-txt (cat 3 'agent=' git-agent))
            (write-pkt-line-txt 'ls-refs=unborn')
            (write-pkt-line-txt 'fetch=filter')
            (write-pkt-line-txt 'object-format=sha1')
            (write-pkt-len flush-pkt)
        ==
    :_  state
    (give-simple-payload:app:server eyre-id payload)
  --
++  handle-receive-pack
  |=  [repo=@ta eyre-id=@ta request=request:http]
  ^-  (quip card _state)
  :_  state
  %+  give-simple-payload:app:server  eyre-id
    [[501 ~] ~]
--
