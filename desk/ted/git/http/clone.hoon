/-  *git, spider
/+  io=strandio, stream
/+  git=git-repository, *git-refs, *git-refspec, git-pack
/+  git-http, git-clay
=,  strand=strand:spider
|%
::  XX most arguments are optional, 
::  making manual thread very inconvenient. 
::  Can we create a little vase utility to handle 
::  optionals automatically?
+$  args
  $:  url=@t            :: URL to clone from
      branch=(unit @t)  :: point HEAD to branch or tag
      desk=(unit @tas)  :: clone to a desk
      dir=path          :: at dir inside repository
  ==
--
^-  thread:spider
|=  args=vase
=/  m  (strand ,vase)
^-  form:m
::  XX it seems to run out of memory
::  on empty repos from github.
::
=+  args=(need !<((unit ^args) args))
=*  http  ~(. git-http url.args)
::
;<  caps=(map @ta (unit @t))  bind:m  greet-server-upload:http
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
=+  hed=(~(dip of remote-refs) ['HEAD' ~])
~&  hed
?~  fil.hed
  ~|  "Remote HEAD not found"  !!
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
::  XX Default branch should be sourced from config
::
=?  head-refs  ?=(~ head-refs)
  =+  master=(~(get of remote-refs) /refs/head/master)
  ?~  master
    ~
  ~[/refs/head/master]
=/  default-branch=refname
  (head head-refs)
=/  head-hash=hash:git
  =+  fil=(~(get of remote-refs) default-branch)
  ?~  fil  !!
  ?@  u.fil  u.fil  !!
~&  default-branch+default-branch
=|  want=(list hash:git)
=.  want
  %+  roll  ~(tap of remote-refs)
    ::  XX The typechecker does not catch 
    ::  invalid sample here
    |=  [[=path =ref:git] =_want]
    ?@  ref
      [ref want]
    want
;<  pack=pack:git-pack  bind:m  (fetch:http ~ want)
::
::  Repository setup after clone:
::  1. Insert the pack
::  2. Install references 
::  3. Setup default branch
::  4. Setup remote refs
::  5. Setup tracking branches
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
::  Track default branch
::
=.  track.repo
  ?>  ?=([%refs %heads @ %~] default-branch)
  =/  branch=@t
    i.t.t.default-branch
  %+  ~(put by track.repo)  branch
    [%origin /refs/heads/[branch]]
::  Install HEAD
::
=.  refs.repo  
  %+  ~(put of refs.repo)  ['HEAD' ~]
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
    (~(put of refs) /refs/tags/[i.refname] ref)
::  Setup origin
::
=|  origin=^remote:git
=.  url.origin  url.args
=.  refspec.origin
  %+  turn  ~["+refs/heads/*:refs/remotes/origin/*"]
  (curr scan refspec:parse)
=.  refs.origin
  (~(put of refs.origin) ~['HEAD'] u.fil.hed)
=.  refs.origin
  %+  roll  ~(tap of (~(dip of remote-refs) /refs/heads))
    |=  [[=refname =ref] =_refs.repo]
    (~(put of refs) (weld /refs/heads refname) ref)
=.  remotes.repo
  (~(put by remotes.repo) %origin origin)
?~  desk.args
  (pure:m !>(repo))
=/  =soba:clay
  (as-soba:git-clay repo default-branch dir.args)
;<  dek=(set desk)  bind:m  (scry:io (set desk) /cd/$)
?:  (~(has in dek) u.desk.args)
  ~|  "Desk {<u.desk.args>} already exists"  !!
;<  ~  bind:m
  (send-raw-card:io %pass /clay %arvo %c %info u.desk.args &+soba)
(pure:m !>(repo))
