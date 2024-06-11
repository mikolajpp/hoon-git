:: 
::  git merge branch
::
/-  spider
/-  *git, git-cmd
/+  io=strandio, stream, *shoe
/+  git=git-repository, *git-refs, *git-refspec, git-pack
/+  *git-cmd, *git-cmd-parser-merge, git-http, git-clay
::
=,  strand=strand:spider
^-  thread:spider
::
|=  arg=vase
=/  m  (strand ,vase)
^-  form:m
=/  [=sole-id =dir:git-cmd repo=(unit repository:git) =args =opts-map]
  !<((ted-args:git-cmd args) arg)
=+  opts=(get-opts opts-map)
?~  repo  (pure:m !>(~))
=+  repo=u.repo
::  target merge branch
::
?:  =(/ branch.dir)
  ~|  "Target branch is empty"  !!
::  XX =+ results in a more general type than refname (see print below).
::  Is this expected for need?
::
=/  dst=refname
  (need (find-refname repo branch.dir))
=/  src=refname
  %-  need  
    %+  find-refname  repo
    (scan (trip raw-refname.args) parse-refname)
=/  src-hash=hash
  (got:~(refs git repo) src)
=/  dst-hash=hash
  (got:~(refs git repo) dst)
?:  =(dst-hash src-hash)
  ~&  "Already merged"
  (pure:m !>(~))
=/  dst-commit
  =-  ?>(?=(%commit -.-) commit.-)
  (got:~(store git repo) dst-hash)
~&  "Fast-forward merge {<src>} into {<dst>}"
=+  tip=src-hash
=/  fast-forward=?
  |-
  ?:  =(tip dst-hash)  &
  =/  tip-commit=commit
    =-  ?>(?=(%commit -.-) commit.-)
    (got:~(store git repo) tip)
  ?:  %+  lth 
      date.commit-time.tip-commit
      date.commit-time.dst-commit
    |
  ?~  parents.tip-commit  |
  $(tip i.parents.tip-commit)
?.  fast-forward
  ~|  "Fast-forward merge failed"  !!
=.  refs.repo
  (~(put of refs.repo) dst src-hash)
~&  "{(print-short-hash 7 dst-hash)}..{(print-short-hash 7 src-hash)}"
(pure:m !>(`repo))
