::
::  git pull
::
/-  spider
/+  strandio
/+  stream
/+  git=git-repository, *git-refs, git-pack, git-http
::
=,  strand=strand:spider
^-  thread:spider
|=  arg=vase
=/  m  (strand ,vase)
^-  form:m
::  XX Fetch according to refspec
::
::  1. Fetch from default remote %origin
::  2. Receive references: go one by one and update 
::     them
::  3. Return updated repository
::
=/  repo
  ::  XX Why does spider always pass arguments 
  ::  as a unit? Is it to accomodate dojo?
  ::
  %-  need  !<((unit repository:git) arg)
=+  remote-name=%origin
=/  =^remote:git
  (~(got by remotes.repo) remote-name)
~&  pull-from+[remote-name url.remote]
=*  http  ~(. git-http url.remote)
::  Greet server -- receive caps
::
;<  caps=(map @ta (unit @t))  bind:m  greet-server-upload:http
::  Receive references
::
;<  ls-refs=(list [refname:git ref:git (unit hash:git)])  bind:m  
  =/  ref-prefix=(list @t)
    :~  'HEAD'
        'refs/heads'
        'refs/tags'
    ==
  =|  args=^args:ls-refs:http
  =.  symrefs.args  &
  =.  ref-prefix.args  ref-prefix
  (ls-refs:http args)
=/  remote-refs=refs
  %+  roll  ls-refs
  |=  [[=refname:git =ref:git peel=(unit hash:git)] =refs]
  =+  new-refs=(~(put of refs) refname ref)
  new-refs
=|  want=(list hash:git)
=.  want
  %+  roll  ~(tap of remote-refs)
  ::  XX The typechecker does not catch 
  ::  invalid sample here
  |=  [[=path =ref:git] =_want]
  ?@  ref
    [ref want]
  ::  Skip symlinks
  want
=|  have=(list hash:git)
=.  have
  %+  roll  tap:~(refs git repo)
  |=  [[=refname =ref] =_have]
  ?@  ref
    [ref have]
  have
;<  pack=pack:git-pack  bind:m  
  (fetch:http have want)
::  XX Make sure the pack has got all 
::  references we requested
::
::  Update refs
::
=.  refs.repo
  %+  roll  ~(tap of remote-refs)
  |=  [[=refname:git =ref:git] =_refs.repo]
  ::  XX How does git handle changing symlinks?
  ::  Simply update?
  ?^  ref
    refs
  =+  old=(got:~(refs git repo) refname)
  ~?  !=(old ref)
    "pull update: {<refname>} {<old>} -> {<ref>}"
  ::  XX +put in refs:repository
  (~(put of refs.repo) refname ref)
=.  repo  (add-pack:~(store git repo) pack)
(pure:m !>(repo))
