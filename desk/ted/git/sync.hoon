/-  *git-ted-sync, *git, spider
/+  io=strandio, stream
::  XX *git-object, *git-refs
::  XX do we have to prefix with git?
::  It seems so, since this is a library that's going to be put in 
::  dev desks
::
/+  git=git-repository, *git-refs, git-pack
/+  git-clay
=,  strand=strand:spider
^-  thread:spider
|=  args=vase
=/  m  (strand ,vase)
^-  form:m
::  XX it seems to run out of memory
::  on empty repos from github.
::
=+  args=(need !<((unit ^args) args))
:: =*  http  ~(. git-http url.args)
::
:: XX Improve performance: export the git workdir 
:: as a clay namespace. Then compare the two maps, 
:: and insert only the files that has changed.
:: Note: clay does not have any delta functionality
::
=/  =soba:clay
  %^  as-soba:git-clay  repo.args
    ?~(refname.args ['HEAD']~ u.refname.args)
    dir.args
;<  dek=(set desk)  bind:m  (scry:io (set desk) %cd /$)
?.  (~(has in dek) desk.args)
  ~|  "Desk {<desk.args>} not found"  !!
;<  ~  bind:m
  (send-raw-card:io %pass / %arvo %c %info desk.args &+soba)
~&  "Synced {<(lent soba)>} files to {<desk.args>}"
(pure:m !>(~))
