/-  ted-sync=git-ted-sync
/+  default-agent, dbug
/+  server, io=agentio
/+  bs=bytestream, zlib
::
/+  *git, *git-http
/+  git=git-repository
/+  git-revision, git-pack, git-pack-objects, git-graph
/=  webui  /app/git-store/webui
:: XX this syntax is broken /=  webui=/app/git-store-webui
::
=,  html
|%
+$  versioned-state
  $%  state-0
  ==
+$  repo-store  (map @ta repository:git)
+$  access  (map @ta (set @p))
+$  sync       $:  =refname
                   dir=path
                   desk=@tas
                   =aeon:clay  :: XX is this needed?
                   =hash:git
               ==
::  Read-only
::
+$  lock  (set @ta)
::  Sync to clay
::
+$  repo-sync  (map @ta sync)
::
+$  state-0  $:  %0
                 =repo-store
                 =lock
                 =access
                 =repo-sync
             ==
+$  card  card:agent:gall
::  XX refactor name -> repo
+$  action
  $%  [%put name=@ta =repository:git]
      [%update name=@ta =repository:git]
      [%delete name=@ta]
      ::
      [%lock name=@ta]  :: Lock read-only
      [%unlock name=@ta]
      ::
      [%allow name=@ta ship=@p]
      [%set-private name=@ta]
      [%set-public name=@ta]
      ::
      [%sync name=@ta =refname dir=path desk=@tas]
      [%unsync name=@ta]
  ==
--
=|  state-0
=*  state  -
%-  agent:dbug
^-  agent:gall
=<
|_  =bowl:gall
+*  this  .
    def  ~(. (default-agent this %.n) bowl)
    do   ~(. +> bowl)
++  on-init
  ^-  (quip card _this)
  :_  this(state *state-0)
  ::  Handle HTTP requests on /git
  ::
  ::  XX can we just assume the binding was successful?
  ::  XX does the binding survive suspend and load sequence?
  ::
  [%pass /connect %arvo %e %connect [~ [%git ~]] dap.bowl]~
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
  =+  cmd=!<(action vase)
  ?-  -.cmd
    %put  (put:do +.cmd)
    %update  (update:do +.cmd)
    %delete  (delete:do +.cmd)
    ::
    %lock  (lock:do +.cmd)
    %unlock  (unlock:do +.cmd)
    ::
    %set-private   (set-private:do +.cmd)
    %set-public    (set-public:do +.cmd)
    %allow  (allow:do +.cmd)
    ::
    %sync    (sync:do +.cmd)
    %unsync  (unsync:do +.cmd)
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
::  Scry Endpoints
::
::  /x                      -- return set of repository names
::  /x/repo                 -- return git repository
::  /x/repo/lock            -- check lock status
::  /x/repo/blob/[hash]     -- retrieve a blob
::  /x/repo/commit/[hash]   -- retrieve a commit
::  /x/repo/tree/[hash]     -- retrieve a tree
::  /x/repo/tag/[hash]      -- retrieve a tag
::
++  on-peek
  |=  =path
  ^-  (unit (unit cage))
  ?:  ?=([%x ~] path)
    ``[%noun !>(~(key by repo-store))]
  ?>  ?=([%x @ta *] path)
  =+  repo=i.t.path
  ?>  (~(has by repo-store.state) repo)
  ?:  ?=([%x @ta ~] path)
    ``[%noun !>((~(got by repo-store.state) repo))]
  ?+  t.t.path  !!
    [%lock ~]
      ``[%noun !>((~(has in lock.state) repo))]
  ==
++  on-agent   on-agent:def
++  on-arvo
  |=  [=wire sign=sign-arvo]
  ^-  (quip card _this)
  ?+  wire  (on-arvo:def wire sign)
    [%sync @tas ~]
      ?>  ?=([%khan %arow *] sign)
      ::  XX how to handle sync failure?
      ::  Should we just print the error, or somehow
      ::  notify the user
      ::
      ?:  ?=(%.n -.p.sign)
        ((slog p.p.sign) `this)
      `this
  ==
::
++  on-fail    on-fail:def
--
::
|_  =bowl:gall
++  put
  |=  [name=@ta repo=repository:git]
  ^-  (quip card _state)
  ?<  =(%$ name)
  ?:  (~(has by repo-store.state) name)
    ~|  "Git repository {<name>} already exists"  !!
  `state(repo-store (~(put by repo-store.state) name repo))
++  update
  |=  [name=@ta repo=repository:git]
  ^-  (quip card _state)
  ::  XX why are state faces not accesible directly?
  ::
  ?.  (~(has by repo-store.state) name)
    ~|  "Git repository {<name>} does not exist"  !!
  ?:  (~(has in lock.state) name)
    ~|  "Git repository {<name>} is read-only"  !!
  =/  sync=(unit ^sync)
    =+  sync=(~(get by repo-sync.state) name)
    ?~  sync
      ~
    =+  tepo=(~(got by repo-store.state) name)
    =/  old=(unit hash)
      (get:~(refs git tepo) refname.u.sync)
    =/  new=(unit hash)
      (get:~(refs git repo) refname.u.sync)
    ?:  =(old new)
      ~
    sync
  ?~  sync
    `state(repo-store (~(put by repo-store.state) name repo))
  =/  [cards=(list card) =^^sync]
    (run-sync name repo refname.u.sync dir.u.sync desk.u.sync)
  :-  cards
  %=  state
    repo-store  (~(put by repo-store.state) name repo)
    repo-sync   (~(put by repo-sync.state) name sync)
  ==
++  delete
  |=  name=@ta
  :: ~&  delete-repo+name
  ^-  (quip card _state)
  ?.  (~(has by repo-store.state) name)
    ~|  "Git repository {<name>} does not exist"  !!
  :: ~&  "Deleted git repository {<name>}"
  :-  ~
  %=  state
    repo-store  (~(del by repo-store.state) name)
    access  (~(del by access.state) name)
    lock  (~(del in lock.state) name)
    repo-sync  (~(del by repo-sync.state) name)
  ==
++  lock
  |=  name=@ta
  :: ~&  lock+name
  ^-  (quip card _state)
  ?>  (~(has by repo-store.state) name)
  ?:  (~(has in lock.state) name)
    ~|  "Repository {<name>} is already locked"  !!
  :: ~&  "Locked git repository {<name>}"
  `state(lock (~(put in lock.state) name))
++  unlock
  |=  name=@ta
  :: ~&  unlock+name
  ^-  (quip card _state)
  ?>  (~(has by repo-store.state) name)
  :: ~&  "Unlocked git repository {<name>}"
  `state(lock (~(del in lock.state) name))
++  set-private
  |=  name=@ta
  :: ~&  set-private+name
  ^-  (quip card _state)
  ?.  (~(has by repo-store.state) name)
    ~|  "Git repository {<name>} does not exist"  !!
  :: ~&  "Restricted Git repository {<name>}"
  `state(access (~(put by access) name ~))
++  allow
  |=  [name=@ta ship=@p]
  :: ~&  allow-access+[name ship]
  ^-  (quip card _state)
  ?.  (~(has by repo-store.state) name)
    ~|  "Git repository {<name>} does not exist"  !!
  ?.  (~(has by access.state) name)
    ~|  "Git repository {<name>} is public"  !!
  :: ~&  "Restricted Git repository {<name>}"
  ::  XX double get
  =+  allow=(~(got by access.state) name)
  =.  allow  (~(put in allow) ship)
  `state(access (~(put by access.state) name allow))
++  set-public
  |=  name=@ta
  ~&  set-public+name
  ^-  (quip card _state)
  ?.  (~(has by repo-store.state) name)
    ~|  "Git repository {<name>} does not exist"  !!
  :: ~&  "Git repository {<name>} is now public"
  `state(access (~(del by access.state) name))
++  sync
  |=  [name=@ta =refname dir=path desk=@tas]
  ^-  (quip card _state)
  ::  XX Really need to solve double get problem with zippers,
  ::  or switch to unit get.
  ::
  ?.  (~(has by repo-store.state) name)
    ~|  "Git repository {<name>} does not exist"  !!
  ?:  (~(has by repo-sync.state) name)
    =+  des=desk:(~(got by repo-sync.state) name)
    ~|  "Git repository {<name>} already synced to {<des>}"  !!
  =+  repo=(~(got by repo-store.state) name)
  :: ~&  "Syncing repository {<name>} to {<desk>}"
  =/  [cards=(list card) =^sync]
    (run-sync name repo refname dir desk)
  :-  cards
  state(repo-sync (~(put by repo-sync.state) name sync))
++  run-sync
  |=  [name=@tas repo=repository:git =refname dir=path desk=@tas]
  ^-  (quip card ^sync)
  =/  =args:ted-sync
    [repo `refname dir desk]
  =/  fard=(fyrd:khan cage)
    [%git %git-sync %noun !>(`args)]
  :-  [%pass /sync/[name] %arvo %k %fard fard]~
  :: XX store aeon
  [refname dir desk 0 0x0]
++  unsync
  |=  name=@ta
  ?.  (~(has by repo-sync.state) name)
    `state
  =+  des=desk:(~(got by repo-sync.state) name)
  :: ~&  "Git repository sync {<name>} to {<des>} cancelled"
  `state(repo-sync (~(del by repo-sync.state) name))
++  is-authorized
  |=  =inbound-request:eyre
  ^-  ?
  =+  auth=(get-header:http 'authorization' header-list.request.inbound-request)
  ?~  auth
    |
  =+  pass=(scan (trip u.auth) ;~(pfix (jest 'Basic ') (star prn)))
  =('lagrev-nocfep:rri0e.e8nhc' q:(need (de:base64:mimes:html (crip pass))))
++  handle-http
  |=  [eyre-id=@ta =inbound-request:eyre]
  ^-  (quip card _state)
  =/  =request-line:server
    (parse-request-line:server url.request.inbound-request)
  ~&  handle-http+[eyre-id request-line]
  ?>  ?=([%git @t *] site.request-line)
  =+  repo-name=i.t.site.request-line
  =+  repo=(~(get by repo-store.state) repo-name)
  ?<  ?=(~ repo)
  =+  access=(~(get by access) i.t.site.request-line)
  ?.  ?|  ?=(~ access)
          (is-authorized inbound-request)
      ==
    ::  Access restricted
    ::
    :_  state
    %+  give-simple-payload:app:server  eyre-id
      :-  [401 ~[['www-authenticate' 'Basic realm="access to git repo"']]]
      `(as-octt:mimes:html "Access denied")
  ?+  site.request-line
    ::  Default to web view
    ::
    :_  state
    =|  =route:webui
    =.  base.route  'git'
    (~(view webui [bowl eyre-id]) u.repo request-line)
    ::  Git server: handshake
    ::
    [%git @t %info %refs ~]
      ?>  ?=([[%service @t] ~] args.request-line)
      ?+  value.i.args.request-line  !!
        %git-upload-pack
          (handle-upload-pack repo-name u.repo eyre-id request.inbound-request)
        %git-receive-pack
          (handle-receive-pack repo-name u.repo eyre-id request.inbound-request)
      ==
    ::  Git server: upload-pack
    ::
    [%git @t %git-upload-pack ~]
      (handle-upload-pack repo-name u.repo eyre-id request.inbound-request)
    ::  Git server: receive-pack
    ::
    [%git @t %git-receive-pack ~]
      (handle-receive-pack repo-name u.repo eyre-id request.inbound-request)
  ==
::
::  XX Move below utility functions to /lib/git/reference.hoon
::
++  write-ref
  |=  [=refname:git =hash]
  ^-  @t
  ::  XX  handle reference peeling
  ::
  (print-ref refname hash)
++  print-ref
  |=  [=refname:git =hash]
  ^-  @t
  ;:  (cury cat 3)
    (crip (print-hash-sha-1 hash))
    ' '
    (print-refname refname)
  ==
++  print-refname
  |=  =path
  ^-  @t
  (rsh [3 1] (spat path))
++  handle-upload-pack
  |=  $:  repo-name=@t
          repo=repository:git
          eyre-id=@ta
          request=request:http
      ==
  ^-  (quip card _state)
  =+  ver=(get-header:http 'git-protocol' header-list.request)
  ?~  ver  !!
  ::  Only support git-upload-pack in version 2
  ::
  ?>  =('version=2' u.ver)
  =<
  ?+  method.request
    ~|  "upload-pack: unsupported method {<method.request>}"  !!
  %'GET'   greet-client
  %'POST'
    ?~  body.request  !!
    ::  Check for compression
    ::
    =/  body=octs
      =+  cen=(get-header:http 'content-encoding' header-list.request)
      ?~  cen
        u.body.request
      ?>  =('gzip' u.cen)
      ~&  %http-gzip-encoded
      -:(decompress-zlib:zlib (from-octs:bs u.body.request))
    ~&  `@t`q.body
    =/  sea  (from-octs:bs body)
    ::  Extract command name
    ::
    =^  cmd=pkt-line  sea  (read-pkt-line & sea)
    ?@  cmd  !!
    ?>  ?=(%data -.cmd)
    ::  Extract caps
    ::
    =^  caps  sea  (parse-caps-stream sea)
    =.  sea  (read-pkt-delim sea)
    ~&  handle-upload-pack-post+caps
    ?>  =(`'sha1' (~(got by caps) ~.object-format))
    ?+  q.octs.cmd  ~|  "Command not implemented"  !!
      %'command=ls-refs'  (ls-refs sea)
      %'command=fetch'    (fetch sea)
    ==
  ==
  |%
  ++  greet-client
    ^-  (quip card _state)
    =/  payload=simple-payload:http
      =-  :_  -
        [200 ~[['content-type' 'application/x-git-upload-pack-advertisement']]]
      %-  some  %-  can-octs:bs
        :~  (write-pkt-lines-txt '# service=git-upload-pack')
            (write-pkt-len flush-pkt)
            (write-pkt-lines-txt 'version 2')
            (write-pkt-lines-txt (cat 3 'agent=' git-agent))
            (write-pkt-lines-txt 'ls-refs')
            (write-pkt-lines-txt 'fetch=wait-for-done')
            (write-pkt-lines-txt 'object-format=sha1')
            (write-pkt-len flush-pkt)
        ==
    :_  state
    (give-simple-payload:app:server eyre-id payload)
  ++  ls-refs
    |=  sea=bays:bs
    ^-  (quip card _state)
    =|  args=[symrefs=_| peel=_| ref-prefix=(list path)]
    ::  Parse arguments
    ::
    =.  args
      |-
      ?<  (is-empty:bs sea)
      =^  pkt  sea  (read-pkt-line & sea)
      ?@  pkt
        ?>  ?=(%flush pkt)
        args
      =/  arg=$@($?(%symrefs %peel) [%ref-prefix =path])
        %+  scan  (trip q.octs.pkt)
            ;~  pose
              (cold %symrefs (jest 'symrefs'))
              (cold %peel (jest 'peel'))
              %+  stag  %ref-prefix
                ;~  pfix  (jest 'ref-prefix ')
                  ;~(plug parse-refname-ext)
                ==
            ==
      ?-  arg
        %symrefs  $(symrefs.args &)
        %peel     $(peel.args &)
        [%ref-prefix *]  $(ref-prefix.args [path.arg ref-prefix.args])
      ==
    ~&  args
    ~&  refs.repo
    =|  sea=bays:bs
    =+  ref-prefix=ref-prefix.args
    ::  XX handle glob ref prefixes
    ::  a/b/c should match any refs in a/b/ starting with c
    ::
    =.  sea  %+  roll  ?~(ref-prefix `(list refname:git)`~[~] ref-prefix)
      |=  [prefix=refname:git =_sea]
      %+  rep-prefix:~(refs git repo)  prefix
        |=  [[=refname:git =ref:git] =_sea]
        ?@  ref
          %+  append-octs:bs  sea
            %-  write-pkt-lines-txt
            (write-ref refname ref)
        =+  hash=(got:~(refs git repo) refname.ref)
        %+  append-octs:bs  sea
          %-  write-pkt-lines-txt
          ;:  (cury cat 3)
            (write-ref refname hash)
            ' '
            (crip "symref-target:{(trip (print-refname refname.ref))}")
          ==
    =.  sea  %+  append-octs:bs  sea
      (write-pkt-len flush-pkt)
    :: ~&  `@t`q.octs.sea
    :_  state
    (give-simple-payload:app:server eyre-id [[200 ~] `(to-octs:bs sea)])
  ++  fetch
    |=  sea=bays:bs
    ^-  (quip card _state)
    =/  args
      $:  done=_|
          thin-pack=_|
          no-progress=_|
          include-tag=_|
          ofs-delta=_|
          wait-for-done=_|
          want=(list hash)
          have=(list hash)
      ==
    =|  =args
    ::  Parse arguments
    ::
    =.  args
      |-
      ?<  (is-empty:bs sea)
      =^  pkt  sea  (read-pkt-line & sea)
      ?@  pkt
        ?>  ?=(%flush pkt)
        args
      :: ~&  `@t`q.octs.pkt
      ::  XX arguments library for Hoon
      ::
      =/  arg
        $@  $?  %done
                %thin-pack
                %no-progress
                %include-tag
                %ofs-delta
                %wait-for-done
            ==
            $%([%want =hash] [%have =hash])
      =/  =arg
        %+  scan  (trip q.octs.pkt)
            ;~  pose
              ::  XX direct parser into symbols
              ::
              (cold %done (jest 'done'))
              (cold %thin-pack (jest 'thin-pack'))
              (cold %no-progress (jest 'no-progress'))
              (cold %include-tag (jest 'include-tag'))
              (cold %ofs-delta (jest 'ofs-delta'))
              (cold %wait-for-done (jest 'wait-for-done'))
              ::  XX parametrize by hash algo
              ;~(pfix (jest 'want ') (stag %want parse-hash-sha-1))
              ;~(pfix (jest 'have ') (stag %have parse-hash-sha-1))
            ==
      ?-  arg
        %done           $(done.args &)
        %thin-pack      $(thin-pack.args &)
        %no-progress    $(no-progress.args &)
        %include-tag    $(include-tag.args &)
        %ofs-delta      $(ofs-delta.args &)
        %wait-for-done  $(wait-for-done.args &)
        [%want *]       $(want.args [hash.arg want.args])
        [%have *]       $(have.args [hash.arg have.args])
      ==
    ~&  args
    ::
    =+  have=have.args
    =+  want=want.args
    ::  Verify wants
    ::
    ?<  ?=(~ (skim want has:~(store git repo)))
    =|  red=bays:bs  =.  red
      ::  The client does not want anything,
      ::  and as we don't need to wait, we simply
      ::  return empty response.
      ::
      ::  XX This seems to violate the specification
      ::  for the flush command. We always send either
      ::  the acknowledgments or the packfile, or both.
      ::  Yet, the git implementation seems not to care.
      ::
      ?:  ?&(?=(~ want) !wait-for-done.args)
        red
      ::  Process haves
      ::  A. Construct the common set to send acks
      ::  B. Construct a unique haves set and set
      ::  the flags of object to THEY_HAVE, and if
      ::  the object is a commit, set its parents
      ::  to THEY_HAVE
      ::
      ::  Walk over the list, generating a list of
      ::  ack packet lines and an object-store with modified
      ::  flags (XX is it structural sharing friendly?)
      ::
      =/  [acks=(list octs) oldest-have=@ud have-set=(set hash)]
        ::  XX to reel or to roll?
        ::
        %+  reel  have
          |=  [=hash acc=[acks=(list octs) oldest-have=@ud have-set=(set hash)]]
          ^-  [(list octs) @ud (set ^hash)]
          ::  XX Cache on get
          ::
          =+  obj=(get:~(store git repo) hash)
          ?~  obj
            acc
          :+  [(write-pkt-lines-txt (crip "ACK {((x-co:co 20) hash)}")) acks.acc]
            ?.  ?=(%commit -.u.obj)
              oldest-have.acc
            ::  XX rename time -> date
            ::  XX why is the cast needed?
            =+  time=`@ud`date.commit-time.commit.u.obj
            ?:  |(=(0 oldest-have.acc) (lth time oldest-have.acc))
              time
            oldest-have.acc
          ?.  ?=(%commit -.u.obj)
            (~(put in have-set.acc) hash)
          =.  have-set.acc
            (~(put in have-set.acc) hash)
          ::  If they have a commit, they must
          ::  also have its parents. This is an assumption
          ::  made by git.
          ::
          %+  roll  parents.commit.u.obj
            |=  [=^hash have-set=_have-set.acc]
            (~(put in have-set) hash)
      ~&  [acks=acks have-set=have-set oldest-have=oldest-have]
      ::
      ::  done and wait-for-done logic
      ::
      ::  If the client says "done", we skip
      ::  sending the acknowledgements and attempt to send the packfile.
      ::
      ::  If the client did not say "done", we send the acknowledgements
      ::  first. Then, we consider two cases regarding wait-for-done.
      ::  (1) The client requested wait-for-done. In such case our
      ::  response shall only consist of acknowledgments.
      ::  (2) otherwise, if the client did not request wait-for-done,
      ::  we check whether all `want` objects are reachable from the
      ::  common `have` set; if they are we send the packfile.
      ::
      =?  red  !done.args
        =.  red
          (append-octs:bs red (write-pkt-lines-txt 'acknowledgments'))
        ?~  acks
          (append-octs:bs red (write-pkt-lines-txt 'NAK'))
        %+  roll  `(list octs)`acks
          |=  [=octs red=_red]
          ^-  bays:bs
          (append-octs:bs red octs)
      ::  We send the packfile if either the client says done,
      ::  or it does not say wait-for-done, while we can reach
      ::  everything he needs.
      ::
      =/  can-reach=?
        (~(can-all-reach-from git-graph repo) want have-set oldest-have)
      ::  XX Fix the NAK case -- the packfile should not be generated.
      ::  If the have-set is empty, can-all-reach-from should logically
      ::  return false
      ::
      ?.  |(done.args &(!wait-for-done.args can-reach))
        (append-octs:bs red (write-pkt-len flush-pkt))
      ::  Build and send the packfile
      ::
      ::  Currently this only sends all the packfiles
      ::  in the repository. For full functionality we
      ::  need to implement git build-pack.
      ::
      ::  XX We throw away a ready made have-set, only
      ::  to rebuild it later
      ::
      =/  pack-octs
        (write-packs:git-pack-objects archive.object-store.repo)
      =/  pack-pkt-lines
        (write-pkt-lines-on-band 1 (from-octs:bs pack-octs))
      =.  red  (append-octs:bs red (write-pkt-lines-txt 'packfile'))
      ::  XX This should properly be done in a thread.
      ::  The point of packet lines is not to send them all
      ::  at once.
      ::
      =.  red  %+  append-octs:bs  red
                  (write-pkt-lines-txt-on-band git-agent 2)
      =.  red  (append-octs:bs red pack-pkt-lines)
      (append-octs:bs red (write-pkt-len flush-pkt))
    ~&  transfer-bytes+(size:bs red)
    :_  state
    %+  give-simple-payload:app:server  eyre-id
    [[200 ~] ?:(=(0 (size:bs red)) ~ `(to-octs:bs red))]
  --
++  handle-receive-pack
  |=  $:  repo-name=@t
          repo=repository:git
          eyre-id=@ta
          request=request:http
      ==
  ^-  (quip card _state)
  ?:  (~(has in lock.state) repo-name)
    :_  state
    %+  give-simple-payload:app:server  eyre-id
    =-  [[503 ~] `(as-octs:mimes -)]
    'Repository is locked read-only, try again later'
  =<
  ?+  method.request  !!
    %'GET'   advertise-refs
    %'POST'  update-refs
  ==
  ::  there is no git push protocol in version 2,
  ::  we implement version 1.
  ::
  |%
  ++  advertise-refs
    |-
    ^-  (quip card _state)
    ::  Assemble advertised references
    ::
    =/  refs=(list [refname:git hash])
      ::  XX These paths should be obtained
      ::  through repo interface and should
      ::  all be dereferenced to destination hash
      ::
      ::  XX Should we handle non-existent HEAD?
      ::  Should all repos have a HEAD?
      ::  A fresh repository will point to an unborn branch
      ::  and thus will not have a head
      ::
      ::  If HEAD is a valid ref, it must appear as the
      ::  first ref. If HEAD is not a valid ref, it must
      ::  not be advertised at all. However, git seems
      ::  to support a symref capability, that can
      ::  be used to advertise a symref for an unborn head.
      ::
      ::  XX advertise symrefs
      ::
      :-  [['HEAD' ~] (got:~(refs git repo) ['HEAD' ~])]
      %+  weld
        (tap-prefix-full:~(refs git repo) /refs/heads)
        (tap-prefix-full:~(refs git repo) /refs/tags)
    =|  red=bays:bs
    =.  red  %+  append-octs:bs  red
      %-  can-octs:bs
      :~  (write-pkt-lines-txt '# service=git-receive-pack')
          (write-pkt-len flush-pkt)
      ==
    ::  Write head reference with caps
    ::
    =.  red  %+  append-octs:bs  red
      ?:  ?=(~ refs)
        (write-pkt-lines (write-caps |))
      %-  write-pkt-lines
        %-  can-octs:bs
        :~  (as-octs:mimes:html (write-ref (head refs)))
            (write-caps &)
        ==
    ::  Write remaining references
    ::
    ::  XX As soon as we have the head reference,
    ::  we should use a rep-at-prefix
    ::
    =.  red  %+  append-octs:bs  red
      %+  roll  (tail refs)
      |=  [[=refname:git =hash] =octs]
      %-  can-octs:bs
      :~  octs
          (write-pkt-lines-txt (write-ref refname hash))
      ==
    ::  XX handle shallow references
    ::
    ::  Write flush packet
    =.  red  (append-octs:bs red (write-pkt-len flush-pkt))
    ~&  `@t`q.data.red
    :_  state
    %+  give-simple-payload:app:server  eyre-id
    :-  :-  200
      :~
        ['content-type' 'application/x-git-receive-pack-advertisement']
      ==
    `data.red
  ++  write-caps
    |=  have=?
    ^-  octs
    =+  caps='report-status delete-refs ofs-delta'
    ?:  have
      ::  XX implement more options
      ::  report-status-v2 delete-refs ofs-delta atomic push-options
      %-  can-octs:bs
      :~  [1 0x0]
          (as-octs:mimes:html caps)
          [1 '\0a']
      ==
    ::  XX parametrize by hash type
    ::
    %-  can-octs:bs
    :~  [20 0x0]  ::  zero hash
        [1 ' ']
        (as-octs:mimes:html 'capabilities^{}')
        [1 0x0]
        (as-octs:mimes:html caps)
        [1 '\0a']
    ==
  +$  cap  $?  %delete-refs
               %ofs-delta
               %report-status
           ==
  +$  push-cmd  [old=hash:git new=hash:git ref-name=path]
  ++  parse-push-cmd
    ;~  plug
      parse-hash-sha-1
      ;~(pfix ace parse-hash-sha-1)
      ;~(pfix ace parse-refname)
    ==
  ++  update-refs
    |-
    ^-  (quip card _state)
    ::  XX verify headers
    ?>  .=  (need (get-header:http 'content-type' header-list.request))
            'application/x-git-receive-pack-request'
    =/  sea  (from-octs:bs (need body.request))
    ::  Parse head command and capabilities
    ::
    ::  XX migrate to bytestream view
    =^  pkt  sea  (read-pkt-line & sea)
    ?>  ?=(%data -.pkt)
    =+  pin=(need (find-byte:bs 0x0 (from-octs:bs octs.pkt)))
    =+  cmd-txt=(cut 3 [0 pin] q.octs.pkt)
    =+  caps-txt=(cut 3 [+(pin) (sub (dec p.octs.pkt) pin)] q.octs.pkt)
    =/  caps=(set cap)  %-  silt
      %+  scan  (trip caps-txt)
        %-  star
        ;~  pfix  ace
          ;~  pose
            (cold %delete-refs (jest 'delete-refs'))
            (cold %ofs-delta (jest 'ofs-delta'))
            (cold %report-status (jest 'report-status'))
          ==
        ==
    ~&  caps
    =/  cmd-list=(list push-cmd)
      ~[(scan (trip cmd-txt) parse-push-cmd)]
    ::  Parse remaining commands
    ::
    =^  cmd-list  sea
      |-
      =^  pkt  sea  (read-pkt-line & sea)
      ?@  pkt
        ?>  ?=(%flush pkt)
        :_  sea
        cmd-list
      ?>  ?=(%data -.pkt)
      =+  cmd=(scan (trip q.octs.pkt) parse-push-cmd)
      $(cmd-list [cmd cmd-list])
    ~&  cmd-list
    ::  Read packfile
    ::
    ::  The git logic for processing the packfile is the following:
    ::  1. Index the packfile with git-index-pack, thickening it with --fix-thin,
    ::  and prevent git-repack from deleting the newly received packfile
    ::  with --keep
    ::  2. Save file to disk
    ::
    =|  status=bays:bs
    =/  pack=(unit pack:git-pack)
      ?:  (is-empty:bs sea)
        ~
      %-  some
        %+  read-thin:git-pack  sea
          |=  =hash
          ~&  resolving-obj+hash
          (get-raw:~(store git repo) hash)
    =?  repo  ?=(^ pack)
      (add-pack:~(store git repo) u.pack)
    =.  status
      %+  append-octs:bs  status
        (write-pkt-lines-txt 'unpack ok')
    ::  Update references
    ::
    ~&  (~(dip of refs.repo) /refs/heads)
    ::  XX should return a list of (each @t @t)
    ::  with [& 'ok'] indicating success and
    ::  [| 'failure description'] indicating failure
    ::
    =^  status=bays:bs  refs.repo
      %+  roll  cmd-list
      ::  XX a refs zipper would be most efficient here
      ::
      |=  [cmd=push-cmd [=_status =_refs.repo]]
      ::  Create reference
      ::
      ?:  =(0x0 old.cmd)
        ?:  (~(has of refs) ref-name.cmd)
          :-  %+  append-octs:bs  status
              %-  write-pkt-lines-txt  %-  crip
                "ng {(trip (print-refname ref-name.cmd))} reference already exists"
          refs
        ?.  (has:~(store git repo) new.cmd)
          :-  %+  append-octs:bs  status
              %-  write-pkt-lines-txt  %-  crip
                "ng {(trip (print-refname ref-name.cmd))} object {<new.cmd>} not found"
          refs
        :-  %+  append-octs:bs  status
            %-  write-pkt-lines-txt  %-  crip
              "ok {(trip (print-refname ref-name.cmd))}"
        ~&  ref-create+cmd
        (~(put of refs) ref-name.cmd new.cmd)
      ::  Delete reference
      ::
      ?:  =(0x0 new.cmd)
        ?.  (~(has of refs) ref-name.cmd)
          :-  %+  append-octs:bs  status
              %-  write-pkt-lines-txt  %-  crip
                "ng {(trip (print-refname ref-name.cmd))} reference not found"
          refs
        ::  XX Hoon should really have typed equality
        ::  to slap .= with typechecking
        ::
        ?.  .=  (need (~(get of refs) ref-name.cmd))
                old.cmd
          :-  %+  append-octs:bs  status
              %-  write-pkt-lines-txt  %-  crip
                "ng {(trip (print-refname ref-name.cmd))} object id mismatch"
          refs
        :-  %+  append-octs:bs  status
            %-  write-pkt-lines-txt  %-  crip
              "ok {(trip (print-refname ref-name.cmd))}"
        ~&  ref-delete+ref-name.cmd
        (~(del of refs) ref-name.cmd)
      ::  Update reference
      ::
      ::  XX A zipper would be useful here
      ::
      ?.  .=  (need (~(get of refs) ref-name.cmd))
              old.cmd
        :-  %+  append-octs:bs  status
            %-  write-pkt-lines-txt  %-  crip
              "ng {(trip (print-refname ref-name.cmd))} object id mismatch"
        refs
      ~&  ref-update+cmd
      :-  %+  append-octs:bs  status
          %-  write-pkt-lines-txt  %-  crip
            "ok {(trip (print-refname ref-name.cmd))}"
      (~(put of refs) ref-name.cmd new.cmd)
    ::  XX update repository
    =.  status  %+  append-octs:bs  status
                  (write-pkt-len flush-pkt)
    ~&  (~(dip of refs.repo) /refs/heads)
    ::  XX We should only keep the pack if the update is successful
    ::  for at least one reference. What's the git logic
    ::  in case of failure? Does it extract objects
    ::  associated with succesful update?
    ::
    ~&  no-packs+(lent archive.object-store.repo)
    ::  XX rename repo-name -> name
    ::
    =^  cards  state  (update repo-name repo)
    :_  state
    %+  weld
      cards
    %+  give-simple-payload:app:server  eyre-id
    [[200 ~] `(to-octs:bs status)]
  --
--
