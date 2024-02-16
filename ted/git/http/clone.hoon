/-  spider
/+  strandio
/+  git, git-io, stream
=,  strand=strand:spider
^-  thread:spider
|=  arg=vase
=/  m  (strand ,vase)
^-  form:m
=/  url  !<(@t arg)
=*  gitio  ~(. git-io url)
;<  caps=(map @ta (unit @t))  bind:m  greet-server:gitio
;<  refs=(list reference:git)  bind:m  (ls-refs:gitio ~)
::  Retrieve HEAD hash
::
=/  head=hash:git
  |-
  ?~  refs
    0x0
  ?:  =(~['HEAD'] -.i.refs)
    +.i.refs
  $(refs t.refs)
:: ~&  refs
;<  pack=pack:git  bind:m  (fetch:gitio ~ ~[head])
  :: %+  fetch:gitio 
  ::   ::  have
  ::   ~
  ::   ::  want
  ::   %+  turn
  ::     refs
  ::   |=  ref=reference:git
  ::   ^-  hash:git
  ::   +.ref
(pure:m !>([refs pack]))
