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
;<  caps=(map @ta (unit @t))  bind:m  greet-server-receive:http
~&  caps
(pure:m !>(caps))
