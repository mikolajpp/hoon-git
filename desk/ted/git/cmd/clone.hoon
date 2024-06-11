:: 
::  git clone
::  
::  Produces a (pair dir repository)
::
/-  spider, *sole
/-  *git, git-cmd
/+  io=strandio, stream
/+  git=git-repository, *git-refs, *git-refspec, git-pack
/+  *git-cmd-parser-clone, git-http, git-clay
=,  strand=strand:spider
^-  thread:spider
::
|=  arg=vase
=/  m  (strand ,vase)
^-  form:m
::  XX =, really needs to be fixed
=/  [=sole-id =dir:git-cmd repo=(unit repository:git) =args =opts-map]
  !<((ted-args:git-cmd args) arg)
::  XX again, tiscom is broken with units
:: =,  arg
=/  vex=(like purl:eyre)
  (auri:de-purl:html [[1 1] (trip url.args)])
::  XX print out the offending url portion
?~  q.vex
  ~|  "Invalid URL: syntax error at {<p.p.vex>}:{<q.p.vex>}"  !!
=+  purl=p.u.q.vex
::  XX progress reporting
::  To match the git clone output would require:
::  1. Change of %iris API to transfer received chunks
::  2. A receive-pkt-lines strand that transfers
::  pkt-lines to main thread as it receives them from %iris
::  3. A suspendable pack indexer to properly report progress, or
::  just use sigpams. Preferably the former, since in the future
::  we might want to send progress elsewhere, not just to terminal...
::
=+  opts=(get-opts opts-map)
?.  =(*refname single-branch.opts)
  ~|  "--single-branch not implemented"  !!
=*  http  ~(. git-http url.args)
::
;<  caps=(map @ta (unit @t))  bind:m  greet-server-upload:http
;<  ls-refs=(list [refname:git ref:git (unit hash:git)])  bind:m  
  =/  ref-prefix=(list refname)
    %+  welp
      :~  ~['HEAD']
          /refs/heads
      ==
    ?:(no-tags.opts ~ ~[/refs/tags])
  =|  args=^args:ls-refs:http
  =.  symrefs.args  &
  =.  ref-prefix.args  ref-prefix
  (ls-refs:http args)
::  XX print through dill
::
~?  verbose.opts  "Received {<(lent ls-refs)>} references"
=/  remote-refs=refs
  %+  roll  ls-refs
  |=  [[=refname:git =ref:git peel=(unit hash:git)] =refs]
  =+  new-refs=(~(put of refs) refname ref)
  new-refs
=+  hed=(~(dip of remote-refs) ['HEAD' ~])
?~  fil.hed
  ~|  "Remote HEAD not found"  !!
~?  verbose.opts  "HEAD {(print-ref u.fil.hed)}"
=/  head-refs=(list refname)
  ::  HEAD is a symref, no need to search
  ::
  ?^  u.fil.hed
    ~[refname.u.fil.hed]
  %+  turn
    %+  skim  ls-refs
      |=  [=refname:git =ref:git peel=(unit hash:git)]
      ?&  ?=([%refs %heads @ta *] refname)
          =(hash u.fil.hed)
      ==
  head
::  No HEAD found, attempt to point to 
::  default branch
::
::  XX Default branch should also be sourced from config
::
=?  head-refs  ?=(~ head-refs)
  =+  master=(~(get of remote-refs) /refs/head/master)
  ?~  master
    ~
  ~[/refs/head/master]
=/  default-branch=refname
  ?.  =(/ branch.opts)
    (weld /refs/heads branch.opts)
  (head head-refs)
=/  head-hash=hash:git
  =+  fil=(~(get of remote-refs) default-branch)
  ?~  fil
    ~|  "Branch {<default-branch>} not found"  !!
  ::  XX resolve a symref
  ::  Remember to check for infinite loop
  ::
  ?@  u.fil  u.fil  !!
~?  verbose.opts  "Default branch is {<default-branch>}"
=|  want=(list hash:git)
::  XX handle --single-branch
=.  want
  %+  roll  ~(tap of remote-refs)
    ::  XX The typechecker does not catch 
    ::  invalid sample here
    |=  [[=path =ref:git] =_want]
    ?@  ref
      [ref want]
    want
;<  pack=pack:git-pack  bind:m  (fetch:http ~ want)
~?  verbose.opts  "Received {<p.octs.data.pack>} bytes"
::
::  Repository setup after clone
::
::  1. Insert the pack
::  2. Install references 
::  3. Setup default branch
::  4. Setup remote refs
::  5. Setup tracking branch
::
=|  repo=repository:git
=.  repo  (add-pack:~(store git repo) pack)
::  Install default branch
::
=.  refs.repo 
  %+  ~(put of *refs)
    default-branch
  =+  hash=(need (~(get of remote-refs) default-branch))
  ?^(hash !! hash)
::  Install HEAD
::
=.  refs.repo  
  %+  ~(put of refs.repo)  head:refspace
    [%symref default-branch]
::  Install tags 
::
::  XX Move ++of from /sys/arvo/hoon to
::  /sys/hoon/hoon, extend it, and jet it, 
::  also providing a type with more general path
::
=.  refs.repo  
  %+  roll  ~(tap of (~(dip of remote-refs) /refs/tags))
    |=  [[=refname =ref] =_refs.repo]
    ?>  ?=([@ %~] refname)
    (~(put of refs) (weld tags:refspace /[i.refname]) ref)
::  Install remote refs
::
=.  refs.repo
  %+  ~(put of refs.repo)
    :(weld remote:refspace /[origin.opts] head:refspace)
  ?@  u.fil.hed
    u.fil.hed
  :-  %symref
  ::  XX is this how git does it?
  (weld remote:refspace /[origin.opts]/(rear refname.u.fil.hed))
=.  refs.repo
  %+  roll  ~(tap of (~(dip of remote-refs) /refs/heads))
    |=  [[=refname =ref] =_refs.repo]
    %+  ~(put of refs)
      :(weld remote:refspace /[origin.opts] refname)
    ref
~&  ~(tap of refs.repo)
::  Setup remote
::
=|  origin=^remote:git
=.  url.origin  url.args
=.  fetch.origin
  :~  %+  scan  
        "+refs/heads/*:refs/remotes/{(trip origin.opts)}/*"
      (parse-refspec &)
  ==
=.  remotes.repo
  (~(put by remotes.repo) origin.opts origin)
::  Track default branch
::
=.  branches.repo
  ?>  ?=([%refs %heads *] default-branch)
  =|  =branch:git
  =.  remote.branch  origin.opts
  =.  merge.branch
    ~[:(weld remote:refspace /[origin.opts] t.t.default-branch)]
  %+  ~(put by branches.repo)  default-branch
  branch
::  Determine repository directory
::
=/  name=@ta
  ?^  dir.args
    u.dir.args
  (rear q.q.purl)
?:  =(%$ name)
  ~|  "Invalid empty repository directory"  !!
(pure:m !>([p=name q=repo]))
:: ?~  desk.args
::   (pure:m !>(repo))
:: =/  =soba:clay
::   (as-soba:git-clay repo default-branch dir.opts)
:: ;<  dek=(set desk)  bind:m  (scry:io (set desk) /cd/$)
:: ?:  (~(has in dek) u.desk.args)
::   ~|  "Desk {<u.desk.args>} already exists"  !!
:: ;<  ~  bind:m
::   (send-raw-card:io %pass /clay %arvo %c %info u.desk.args &+soba)
:: (pure:m !>(repo))
