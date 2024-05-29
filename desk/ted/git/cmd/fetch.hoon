:: 
::  git fetch
::
::  XX Handle refspec pattern matching
::  XX Handle multiple refspec for remote, in combination with 
::  refspecs from the command line
::  XX Handle negative refspecs
::
/-  spider
/-  *git, *git-cmd
/+  io=strandio, stream
/+  git=git-repository, *git-refs, *git-refspec, git-pack
/+  git-http
/+  *git-cmd-fetch, *git-cmd-parser-fetch
=,  strand=strand:spider
^-  thread:spider
::
|=  ted-arg=vase
=/  m  (strand ,vase)
^-  form:m
=/  [=sole-id repo=(unit repository:git) =args =opts-map]
  !<([=sole-id (unit repository:git) args opts-map] ted-arg)
=/  opts  (get-opts opts-map)
?~  repo
  ~|  "fatal: not a git repository"  !!
=+  repo=(need repo)
::  Find out the URL and remote
::
::  XX find out remote based on HEAD - if on a branch, find the remote
::  otherwise fall back on origin
::
=/  [url=@t remote=(unit @ta)]
  ?~  remote.args
    :_  `%origin
    (got-url:~(remote git repo) %origin)
  ?^  (rust (trip u.remote.args) parse-url)
    :_  ~
    u.remote.args
  :_  `u.remote.args
  (got-url:~(remote git repo) u.remote.args)
::
=*  http  ~(. git-http url)
~&  fetch-url+url
::  XX git fetch origin refspec will 
::  use refspecs both from the remote and the command line.
::  Verify behaviour is the same wrt remote and command line 
::  refspects
::
=/  refspecs=(list refspec)
  %+  weld
    ?~  remote  ~
    fetch:(~(got by remotes.repo) u.remote)
  %+  turn  raw-refspecs.args
    |=  =raw-refspec
    =+  res=(raw-to-refspec raw-refspec &)
    ?~  res
      ~|  "Invalid refspec {<raw-refspec>}"  !!
    u.res
~&  fetch-refspec+refspecs
::  git fetch sequence
::
::  1. Generate ref prefixes from refspec
::  2. ls-refs to get refs
::  3. XX handle tag following logic
::  4. map remote refs to local refs using refspecs
::  5. fetch pack using obtained refs
::  6. return a (pair refs pack)
::
::  XX avoid listing refs if all refspecs are hash
::  XX handle --atomic
::  XX implement git refmap logic
::
::
;<  ls-refs=(list [=refname =ref:git peel=(unit hash:git)])  bind:m
  ::  XX fix args shadowing in git-http
  =|  =^args:ls-refs:http
  =.  ref-prefix.args  
    %.  %+  turn  refspecs
      (curr ref-prefixes &)
    zing
  (ls-refs:http args)
:: =?  refspecs  prefetch.opts
::   %+  reel  refspecs
::   |=  [res=refspec les=(list refspec)]
::   =+  fir=(filter-prefetch-refspec res)
::   ?~  fir  les
::   [u.fir les]
::  XX Implement full git fetch logic. For now we simply
::  map received references according to first matching refspec
::  XX handle symrefs
::  Build a reference map to be injected into our refs
::  [refname old-id new-id]  
::  old-id is at our side, while new-id at server side
::  We fetch, declaring haves to be the list of old-ids, 
::  and wants to be the list of new-ids
::
::  For each ls-refs reference
::  1. perform mapping using first matching refspec
::  2. Retrieve old-id
::  3. Save new-id
=/  ref-map=(list [=refname old=hash new=hash])
  %+  reel  ls-refs
  ::  XX  output of strands should have their own type
  ::
  |=  $:  lir=[=refname =ref:git peel=(unit hash:git)]
          ref-map=(list [=refname old=hash new=hash])
      ==
  ^-  _ref-map
  :: ref-map
  ::  XX Handle symbolic refs
  ::  XX Handle peeled objects
  ::
  ?^  ref.lir  ref-map
  =/  mef=(unit refname)
    %-  head
    %+  turn  refspecs
    (curr map-refname refname.lir)
  ?~  mef  ref-map
  =/  old=hash
    =+  (get:~(refs git repo) u.mef)
    ?~  -  0x0  u.-
  =/  new  ref.lir
  ~&  "ref map: {<refname.lir>} -> {<u.mef>}"
  :_  ref-map
  [u.mef `hash`old `hash`new]
::  XX optimize: request only for changed refs
=/  have=(list hash)
  %+  reel  ref-map
  ::  XX Is there a way to get the element type
  ::  given a list type?
  ::
  |=  $:  [=refname old=hash new=hash]
          have=(list hash)
      ==
  ::  New reference
  ?:  =(0x0 old)
    have
  [old have]
=/  want=(list hash)
  %+  turn  ref-map
  |=  [=refname old=hash new=hash]
  new
;<  =pack:git-pack  bind:m  (fetch:http want have)
=?  repo  (gth count.pack 0)
  (add-pack:~(store git repo) pack)
=.  refs.repo
  %+  reel  ref-map
  |=  $:  [=refname old=hash new=hash]
          =_refs.repo
      ==
  ::  XX does git always override remote references?
  ::  XX handle ref deletion
  ::
  =+  hash-old=(print-short-hash 7 old)
  =+  hash-new=(print-short-hash 7 new)
  ~?  !=(old new)
    fetch-update+"{<refname>}: {hash-old}..{hash-new}"
  (~(put of refs) refname new)
::  XX verify presence of referenced objects
(pure:m !>(`repo))
