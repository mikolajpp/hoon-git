/-  ted-job=git-ted-job
/+  default-agent, dbug
/+  server, io=agentio
/+  stream, zlib
/+  *git-refs, *git-http
/+  git=git-repository
/+  git-revision, git-pack, git-pack-objects, git-graph
|%
+$  versioned-state
  $%  state-0
  ==
+$  job-id  @uv
+$  job  $:  repo=@ta  :: target repository
             ted=@ta   :: path to thread, relative to /ted/git/jobs/
             wait=@dr  :: recurrence time
             desc=@t   :: description
         ==
+$  job-stats  $:  last=@da  :: Last run time
                   next=@da  :: Wake up time
               ==

+$  jobs   (map job-id job)
+$  stats  (map job-id job-stats)
+$  state-0  $:  %0
                 =jobs
                 =stats
             ==
+$  card  card:agent:gall
+$  command
  $%  [%start =job]
      [%stop =job-id]
      :: [%run =id]  :: Trigger the job
      :: [%cancel repo=@ta] :: Cancel all jobs for repository
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
    io   ~(. ^io bowl)
++  on-init
  ^-  (quip card _this)
  `this(state *state-0)
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
  =+  cmd=!<(command vase)
    ?-  -.cmd
      %start  (start:do +.cmd)
      %stop   (stop:do +.cmd)
    ==
  ::
  [cards this]
::
++  on-watch
  |=  =path
  ^-  (quip card _this)
  (on-watch:def path)
++  on-leave   on-leave:def
++  on-peek    on-peek:def
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  ~&  on-agent+wire
  ?+  wire  (on-agent:def wire sign)
    [%lock @ta ~]
      ?>  ?=(%poke-ack -.sign)
      ?^  p.sign
        ((slog u.p.sign) `this)
      =/  id=job-id
        (need (slaw %uv i.t.wire))
      =^  cards  state  (run:do id)
      [cards this]
  ==
++  on-arvo
  |=  [=wire sign=sign-arvo]
  ^-  (quip card _this)
  ~&  on-arvo+wire
  ?+  wire  (on-arvo:def wire sign)
    [%run @ta ~]
      =/  id=job-id
        (need (slaw %uv i.t.wire))
      =+  job=(~(get by jobs.state) id)
      ?~  job
        ~|  "Job {<id>} does not exist"  !!
      ~&  run+id
      ::  XX improve the pipeline
      ::  1. Upon run, lock the repository
      ::  2. When poke-ack is received, either
      ::  schedule the thread to run, or add the job
      ::  to the delayed threads
      ::
      =/  lock
        %+  ~(poke-our pass:io /lock/(scot %uv id))
          %git-store
          [%noun !>([%lock repo.u.job])]
      :_  this
      ~[lock]
    ::
    [%finish @ta ~]
      ~&  job-finished+wire
      =/  id=job-id
        (need (slaw %uv i.t.wire))
      =+  job=(~(get by jobs.state) id)
      ?~  job
        ~|  "Job {<id>} does not exist"  !!
      ?>  ?=([%khan %arow *] sign)
      ?:  ?=(%| -.p.sign)
        ::  XX How to best handle failed jobs?
        ::  Should we re-run, or simply notify failure
        ::  to the user and delete the job?
        ::
        ((slog p.p.sign) `this)
      =/  repo
        !<(repository:git q.p.p.sign)
      :_  this
      :*
        ::  Unlock repository
        ::
        %+  ~(poke-our pass:io /unlock/(scot %uv id))
          %git-store
          [%noun !>([%unlock repo.u.job])]
        ::  Update repository
        ::
        %+  ~(poke-our pass:io /update/(scot %uv id))
          %git-store
          [%noun !>([%update repo.u.job repo])]
        ::  Schedule next run
        ::
        ?.  (gth wait.u.job 0)
          ~
        =+  next=(add now.bowl wait.u.job)
        [(~(arvo pass:io /run/(scot %uv id)) %b %wait next)]~
      ==
  ==
    :: [%sync @tas ~]
    ::   ?>  ?=([%khan %arow *] sign)
    ::   ::  XX how to handle sync failure?
    ::   ::  Should we just print the error, or somehow
    ::   ::  notify the user
    ::   ::
    ::   ?:  ?=(%.n -.p.sign)
    ::     ((slog p.p.sign) `this)
    ::   `this
  :: ==
::
++  on-fail    on-fail:def
--
::
|_  =bowl:gall
+*  io  ~(. ^io bowl)
++  start
  |=  =job
  ^-  (quip card _state)
  =+  id=(gen-id eny.bowl)
  ~&  git-job+[%start id job]
  :: =/  =args:ted-auto
  :: =/  fard=(fyrd:khan cage)
  ::   [%git (cat 3 %git-auto ted.job) !>(`args)]
  :: :-  [%pass /job]
  :_  state(jobs (~(put by jobs.state) id job))
  ?.  (gth wait.job 0)  ~
  [%pass /run/(scot %uv id) %arvo %b %wait (add now.bowl wait.job)]~
++  gen-id
  |=  eny=@uvJ
  ^-  job-id
  =+  id=(sham eny)
  ?:  (~(has by jobs.state) id)
    (gen-id +(eny))
  id
++  run
  |=  id=job-id
  ^-  (quip card _state)
  =/  =job
    (~(got by jobs.state) id)
  =/  lock=?
    .^(? %gx (scry:io %git-store /[repo.job]/lock/noun))
  ?>  lock
  =/  repo
    .^(repository:git %gx (scry:io %git-store /[repo.job]/noun))
  ::  XX update job stats
  ::
  =|  =args:ted-job
  =.  repo.args  repo
  ~&  run-thread+ted.job
  =/  fard=(fyrd:khan cage)
    [%git :((cury cat 3) %git-job '-' ted.job) %noun !>(`args)]
  :-  [%pass /finish/(scot %uv id) %arvo %k %fard fard]~
  state
++  stop
  |=  id=job-id
  ^-  (quip card _state)
  ::  XX Rest %behn's timer
  ::
  `state(jobs (~(del by jobs.state) id))
--
