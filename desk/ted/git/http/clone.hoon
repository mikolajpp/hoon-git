/-  spider
/+  strandio
/+  *git, git-http, stream
=,  strand=strand:spider
^-  thread:spider
|=  arg=vase
=/  m  (strand ,vase)
^-  form:m
=/  url  !<((unit @t) arg)
=*  http  ~(. git-http (need url))
;<  caps=(map @ta (unit @t))  bind:m  greet-server-upload:http
;<  refs=(list [path hash:git])  
  bind:m  (ls-refs:http ~)
::
::  Retrieve HEAD hash
::
:: =/  head=hash:git
::   |-
::   ?~  refs
::     0x0
::   ?:  =(~['HEAD'] -.i.refs)
::     +.i.refs
::   $(refs t.refs)
:: ;<  pack=pack:git  bind:m  (fetch:http ~ ~)
;<  pack=pack:git  bind:m
  %+  fetch:http
    ::  have
    ::
    ~
    ::  want
    ::
    (turn refs tail)
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
=|  repo=repository:git
=.  repo  (add-pack:~(store git repo) pack)
=.  refs.repo  %+  roll  refs
  |=  [[=path =hash] =refs:git]
  ^-  refs:git
  ?.  (has:~(store git repo) hash)
    ~|  "Reference {<path>} points to invalid object {<hash>}"  !!
  (~(put of refs) path hash)
~&  (~(dip of refs.repo) /refs/heads/main)
(pure:m !>(repo))
