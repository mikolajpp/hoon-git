/-  *sole
/-  *git-cmd
/+  shoe, verb, default-agent, dbug, agentio
::  XX clay seems not to mind non-existent libraries
::
/+  *git, *git-cmd-parser
/+  git=git-repository, git-refs, git-pack
::  XX Find a way to import commands in bulk
::
::  Commands
::
::  Built-in
::
/+  cmd-ls=git-cmd-parser-ls
/+  cmd-cd=git-cmd-parser-cd
/+  cmd-rm=git-cmd-parser-rm
/+  cmd-cat=git-cmd-parser-cat
::
/+  cmd-clone=git-cmd-parser-clone
/+  cmd-diff=git-cmd-parser-diff
/+  cmd-fetch=git-cmd-parser-fetch
/+  cmd-log=git-cmd-parser-log
/+  cmd-merge=git-cmd-parser-merge
::
|%
+$  state-0
  $:  =dir             :: repository
      trash=(set @ta)  :: repository trash
  ==
+$  versioned-state
  $%  [%0 state-0]
  ==
+$  card  card:shoe
+$  sign  sign:agent:gall
+$  command
  $%  [%ls args:cmd-ls]
      [%cd args:cmd-cd]
      [%cat args:cmd-cat]
      [%rm args:cmd-rm]
      [%lock %~]
      ::
      [%clone args:cmd-clone]
      [%diff args:cmd-diff]
      [%fetch args:cmd-fetch]
      [%log args:cmd-log]
      [%merge args:cmd-merge]
      [%pull pull-args]
  ==
+$  cat-file-args  ~
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
    io   ~(. agentio bowl)
++  on-init  on-init:def
++  on-save  !>(state)
++  on-load  on-load:def
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?>  ?=(%noun mark)
  =/  action  !<(action vase)
  :_  this
  ~[action]
++  on-watch  on-watch:def
++  on-leave  on-leave:def
++  on-peek  on-peek:def
++  on-agent
  |=  [=wire =sign]
  ^-  (quip card _this)
  ::  XX Support multiple sessions
  ::  All on-agent and on-arvo calls
  ::  originate in response to user commands.
  ::
  ::  The wire should begin with sole-id, 
  ::  /who/ses/...
  ::
  ::  In this way, we can emit notifications and 
  ::  manage prompt for each sessions separately.
  ::
  ?+  wire  (on-agent:def wire sign)
    ::  /rm/repo
    ::
    [%rm @tas ~]
      =+  repo=i.t.wire
      ?>  ?=(%poke-ack -.sign)
      ?~  p.sign
        :_  this
        ?:  !=(repo.dir repo)  ~
        [%shoe ~ (sole-prompt dir.state)]~
      ~|  "Failed to delete repository {<repo>}"
      (mean u.p.sign)
    ::  XX Should this be handled by the clone thread?
    ::  /exec/clone/store/repo
    ::
    [%exec %clone %store @tas ~]
      =+  repo=i.t.t.t.wire
      ?>  ?=(%poke-ack -.sign)
      ?~  p.sign
        `this
      ~|  "Failed to store repository {<repo>}"
      (mean u.p.sign)
  ==
++  on-arvo  
  |=  [=wire sign=sign-arvo]
  ^-  (quip card _this)
  ?+  wire  (on-arvo:def wire sign)
    [%rm @tas *]
      =+  repo=i.t.wire
      ?+  t.t.wire  !!
        ::  XX Display 'rm aborted' message?
        ::  XX update prompt upon deletion
        [%timeout ~]
          `this(trash (~(del in trash) repo))
      ==
    ::  /exec/command/repo
    ::
    ::  XX  The command threads should probably
    ::  communicate directly with the git-store.
    ::  This would free git-cmd from dependending 
    ::  on output type of command threads.
    ::
    [%exec @tas @ta ~]
      ?>  ?=([%khan %arow *] sign)
      ::
      ?:  ?=(%| -.p.sign)
        ((slog p.p.sign) `this)
      =/  =cage  p.p.sign
      =+  cmd=i.t.wire
      =+  dir=i.t.t.wire
      ::
      ?+  i.t.wire
        ::  XX some commands should lock repository read-only
        ::  to prevent run conditions
        ::
        =/  repo
          !<((unit repository:git) q.cage)
        ?~  repo  `this
        :_  this
        :~
          %+  ~(poke-our pass:io /exec/[cmd]/[dir]/update)
          %git-store  [%noun !>([%update dir u.repo])]
        ==
        ::  /exec/clone
        ::
        %clone
          =/  res
            !<((pair @ta repository:git) q.cage)
          :_  this
          :~
            %+  ~(poke-our pass:io /exec/clone/store/[p.res])
            %git-store  [%noun !>([%put res])]
          ==
      ==
  ==
++  on-fail  on-fail:def
::
++  command-parser
  |=  =sole-id
  ^+  |~(nail *(like [? command (list option)]))
  %+  cook
    |=  [cmd=command opts=(list option)]
    [| cmd opts]
  ::  Accomodate muscle memory
  ::
  ;~  pfix  (punt ;~(plug (jest 'git') (star ace)))
    ;~  pose
      parse:cmd-ls
      parse:cmd-cd
      parse:cmd-rm
      parse:cmd-cat
      ::
      parse:cmd-clone
      parse:cmd-diff
      parse:cmd-fetch
      parse:cmd-log
      parse:cmd-merge
    ==
  ==
++  tab-list
  |=  =sole-id
  :~  ['ls' leaf+"list available repositories"]
      ['cd' leaf+"change to directory"]
      ['rm' leaf+"delete repository"]
      ['clone' leaf+"clone a repository"]
      ['diff' leaf+"show changes between commits"]
      ['fetch' leaf+"download objects and refs"]
      ['log' leaf+"show commit logs"]
      ['merge' leaf+"fast-forward merge"]
  ==
++  on-command
  |=  [=sole-id =command opts=(list option)]
  ^-  (quip card _this)
  :: ~&  cmd+command
  :: ~&  opts+opts
  =^  cards  state
    ?+  -.command
      :_   state
      [%shoe ~[sole-id] %sole %txt "command not found: {(trip -.command)}"]~
      :: built-in
      ::
      %ls  (ls:do sole-id command opts)
      %cd  (cd:do sole-id command opts)
      %rm  (rm:do sole-id command opts)
      ::
      %clone  (exec:do sole-id command opts)
      %diff   (exec:do sole-id command opts)
      %fetch  (exec:do sole-id command opts)
      %log    (exec:do sole-id command opts)
      %merge  (exec:do sole-id command opts)
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
  (sole-prompt dir)
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
  =;  [fec=shoe-effect:shoe =_state]
    :_  state
    [%shoe ~[sole-id] fec]~
  ::  List repositories
  ::
  ?:  =(~. repo.dir)
    =+  repos=scry-repos-set
    :_  state
    :+  %sole  %tan
    [rose+[[" " " " " "] ~(tap in repos)]]~
  ::  List branches
  ::
  =/  repo=repository:git
    .^(repository:git %gx (scry:io /git-store/[repo.dir]/noun))
  :_  state
  :+  %sole  %tan
  :~
    :+  %rose
      [" " " " " "]
    %+  turn  (tap-prefix:~(refs git repo) /refs/heads)
    |=  [=refname =hash]
    (print-refname refname)
  ==
++  cd
  |=  [=sole-id cd=command opts=(list option)]
  ^-  (quip card _state)
  ?>  ?=(%cd -.cd)
  =+  branch=(scan (trip branch.cd) parse-refname)
  =+  repos=scry-repos-set
  =;  [fec=shoe-effect:shoe =_state]
    [[%shoe ~[sole-id] fec]~ state]
  ::
  ?.  |(=(%$ repo.cd) (~(has in repos) repo.cd))
    :_  state
    [%sole %txt "cd: no such repository: /{(trip repo.cd)}"]
  =.  dir.state
    [repo.cd branch /]
  ?:  =(~. repo.cd)
    :_  state
    (sole-prompt dir.state)
  =/  repo=repository:git
    .^(repository:git %gx (scry:io /git-store/[repo.cd]/noun))
  ?:  ?&  !=(/ branch)
          !(has:~(refs git repo) (weld branches:refspace branch))
      ==
    :_  state
    [%sole %txt "cd: no such branch: {(trip (print-refname branch))}"]
  :_  state
  (sole-prompt dir.state)
++  rm
  |=  [=sole-id rm=command opts=(list option)]
  ^-  (quip card _state)
  ?>  ?=(%rm -.rm)
  =+  repos=scry-repos-set
  ::  Carefully handle request to delete a repository
  ::
  ?.  (~(has in repos) name.rm)
    :_  state
    [%shoe ~[sole-id] %sole %txt "rm: no such repository: /{(trip name.rm)}"]~
  ?.  (~(has in trash) name.rm)
    :_  state(trash (~(put in trash) name.rm))
    :: XX set a timeout for this, style with red color
    :~
      [%shoe ~[sole-id] %sole %txt "rm: you are about to DELETE /{(trip name.rm)} repository"]
      [%shoe ~[sole-id] %sole %txt "rm: repeat within 10s to confirm"]
      %-  ~(arvo pass:io /rm/[name.rm]/timeout)
        [%b %wait (add now.bowl ~s10)]
    ==
  :_  state(trash (~(del in trash) name.rm))
  :~
    (~(poke-our pass:io /rm/[name.rm]) %git-store %noun !>([%delete name.rm]))
  ==
  :: :_  state(trash (~(del in trash) name.rm))
  :: :*  [%shoe ~[sole-id] %sole %txt "rm: deleted repository /{(trip name.rm)}"]
  ::     [%shoe ~[sole-id] (set-prompt ' /> ')]
++  cat  !!
::  Execute the command thread 
::
::  XX commands should be executed synchronously
::
++  exec
  |*  [=sole-id cmd=command opts=(list option)]
  ^-  (quip card _state)
  ~&  dir+dir
  =+  ted=(^cat 3 %git-cmd- -.cmd)
  =+  repos=scry-repos-set
  ::  Target repository
  ::
  =/  repo=(unit repository:git)
    ?:  =(repo.dir %$)
      ~
    %-  some
    .^(repository:git %gx (scry:io /git-store/[repo.dir]/noun))
  =/  args
    ::  XX This is a workaround for bug with vase mode 
    ::  in wet gates (see issue 1347)
    ::
    ?+  -.cmd  !!
      %clone  !>([sole-id dir repo +.cmd (malt opts)])
      %diff   !>([sole-id dir repo +.cmd (malt opts)])
      %fetch  !>([sole-id dir repo +.cmd (malt opts)])
      %log    !>([sole-id dir repo +.cmd (malt opts)])
      %merge  !>([sole-id dir repo +.cmd (malt opts)])
    ==
  =/  fard=(fyrd:khan cage)
    [q.byk.bowl ted %noun args]
  :_  state
  :: /exec/cmd/repo
  ::
  [%pass /exec/[-.cmd]/[repo.dir] %arvo %k %fard fard]~
++  scry-repos-set
  .^((set @ta) %gx (scry:io /git-store/noun))
++  sole-prompt
  |=  =^dir
  ^-  shoe-effect:shoe
  :+  %sole  %pro
  :+  &  %$
  :~ 
  ' /'  repo.dir
  ?:(=(branch.dir /) '' (^cat 3 ':' (print-refname branch.dir)))
  '> '
  ==
--
