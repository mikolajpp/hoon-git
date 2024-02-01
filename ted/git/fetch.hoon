::  
::  Git fetch
::
::  XX handle deleted reference
::
/-  spider
/+  strandio
/+  git, git-io, stream
=,  strand=strand:spider
^-  thread:spider
|=  arg=vase
=/  m  (strand ,vase)
^-  form:m
=/  [repo=repository:git remote=@tas]  
  !<([repository:git @tas] arg)
=/  remote=remote:git
  (~(got by remotes.repo) remote)
=*  gitio  ~(. git-io url.remote)
;<  caps=(map @ta (unit @t))  bind:m  greet-server:gitio
;<  refs=(list reference:git)  bind:m  (ls-refs:gitio ~)
=+  have=~(val by refs.remote)
=/  want=(list hash:git)
  ::  As we all learned in the kindergarden
  ::  -- +< is the sample
  ::
  (turn refs |=(reference:git +<+))
;<  pack=pack:git  bind:m  (fetch:gitio have want)
(pure:m !>([refs pack]))

