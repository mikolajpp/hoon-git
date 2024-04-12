/-  *git, spider
/+  strandio, stream
/+  git=git-repository, git-http, git-pack
=,  strand=strand:spider
^-  thread:spider
|=  arg=vase
=/  m  (strand ,vase)
^-  form:m
=/  url  !<((unit @t) arg)
=*  http  ~(. git-http (need url))
;<  caps=(map @ta (unit @t))  bind:m  greet-server-upload:http
::  XX it seems git reference path can contain quite arbitrary
::  characters, including @. We need a ref-path=(list @t) type
::
;<  refs=(list [path hash:git])  
  bind:m  (ls-refs:http ~)
::  Filter references for /refs/heads and /refs/tags
::
=|  remote-refs=^refs:git
=.  remote-refs
  |-
  ?~  refs
    remote-refs
  =+  ref=i.refs
  ?.  ?|  ?=([%refs %heads *] -.ref)
          ?=([%refs %tags *] -.ref)
          ?=([%'HEAD' ~] -.ref)
      ==  
    $(refs t.refs)
  %=  $
    remote-refs  (~(put of remote-refs) ref)
    refs  t.refs
  ==
::  Find out the default branch: use 
::  the first branch name which matches the hash of HEAD
::
~&  ~(tap of remote-refs)
=+  head=(~(dip of remote-refs) ['HEAD' ~])
?~  fil.head
  ~|  "HEAD not found"  !!
=/  refs-at-head=_refs
  %+  skim  refs
    |=  [=path =hash:git]
    ?.  ?|  ?=([%refs %heads @ta *] path)
            ?=(^ u.fil.head)
        ==
      |
    =(hash u.fil.head)
?~  refs-at-head
  ~|  "Default branch name not found"  !!
=/  default-branch=@t
  -:(flop -.i.refs-at-head)
~&  default-branch+default-branch
=/  want=(list hash:git)
  ::  XX traversal routines for axal
  %+  turn  ~(tap of remote-refs)
    |=  [=path =ref:git]
    ?^  ref  !!
    ref
;<  pack=pack:git-pack  bind:m  (fetch:http ~ want)
::
::  Repository setup after clone:
::  1. Insert the pack
::  2. Install references 
::  3. Setup remote
::  4. Setup tracking branches
::
::  Integrity: all objects in the pack have computed checksums, 
::  thus their content matches the hash. 
::
::  Commit graph: If the top commit is trusted, the rest
::  of the commit chain can be trusted as well.
::
::  XX Try a self-clone from an Urbit ship!
::
=|  repo=repository:git
=.  repo  (add-pack:~(store git repo) pack)
=.  refs.repo 
  %+  ~(put of *^refs:git) 
    /refs/heads/[default-branch]
  =+  hash=(need (~(get of remote-refs) /refs/heads/[default-branch]))
  ?^(hash !! hash)
::  XX handle symbolic references
=.  refs.repo  
  %+  ~(put of refs.repo)  ['HEAD' ~]
    ?^(u.fil.head !! [%symref /refs/heads/[default-branch]])
=.  remotes.repo  (~(put by remotes.repo) %origin [(need url) remote-refs])
~&  refs.repo
(pure:m !>(repo))
