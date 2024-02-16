/-  spider
/+  strandio
/+  git, git-http, stream
=,  strand=strand:spider
^-  thread:spider
|=  arg=vase
=/  m  (strand ,vase)
^-  form:m
=/  url  !<((unit @t) arg)
=*  http  ~(. git-http (need url))
;<  caps=(map @ta (unit @t))  bind:m  greet-server:http
;<  refs=(list [reference:git hash:git])  
  bind:m  (ls-refs:http ~)
::  Retrieve HEAD hash
::
~&  refs
=/  head=hash:git
  |-
  ?~  refs
    0x0
  ?:  =(~['HEAD'] -.i.refs)
    +.i.refs
  $(refs t.refs)
:: ~&  refs
;<  pack=pack:git  bind:m  (fetch:http ~ ~[head])
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
