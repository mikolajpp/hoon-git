/-  spider
/+  git, stream, strandio
=,  strand=strand:spider
^-  thread:spider
|=  arg=vase
=/  m  (strand ,vase)
^-  form:m
::
=/  url=@t  (need !<((unit @t) arg))
=<
::  Greet the server to obtain the list of capabilities
::
;<  caps=(map @ta (unit @t))  bind:m  greet-server
;<  refs=(list reference:git)  bind:m  (ls-refs ~)
:: ;<  pack=pack:git  bind:m  (fetch %HEAD)
(pure:m !>(refs))
::
|%
::  Server capabilities
::
+$  caps  (map @ta (unit @t))
++  tape-to-octs
  |=  txt=tape
  ^-  octs
  [(lent txt) (crip txt)]
::
++  ls-refs
  |=  =caps
  =/  m  (strand ,(list reference:git))
  ^-  form:m
  =/  cmd=octs
    %-  tape-to-octs
    ;:  weld
      (send-pkt-line "command=ls-refs")
      :: (send-caps caps)
      send-delim-pkt
      :: (send-pkt-line "ref-prefix HEAD")
      send-flush-pkt
    ==
  ;<  ~  bind:m  %-  send-request:strandio
                   :^  %'POST'
                       (cat 3 url '/git-upload-pack')
                       :~  ['Git-Protocol' 'version=2']
                           ['Content-Type' 'application/x-git-upload-pack-request']
                       ==
                       `cmd
  ;<  res=client-response:iris  bind:m  take-client-response:strandio
  ?>  ?=(%finished -.res)
  ?~  full-file.res
  ~|  "No references received"  !!
  ::
  =>
  |%
  ++  segment
    (cook crip ;~(plug low (star ;~(pose low nud hep dot))))
  ++  paf
    ;~  pose
      ;~(plug (jest 'HEAD') (easy ~))
      ;~(plug segment (star ;~(pfix fas segment)))
    ==
  ++  reference
    %+  cook 
      |=([hax=@ux =path] [path hax])
      ;~(plug hax-sha-1:git ;~(pfix ace paf))
  --
  ::
  =+  lap=(flop (read-pkt-lines full-file.res))
  =|  rel=(list reference:git)
  =.  rel
  ::  Parse references
  ::
  |-
  ?~  lap
    rel
  =/  ref  
    (scan (trip q.i.lap) reference)
  $(rel [ref rel], lap t.lap)
  ::
  (pure:m (flop rel))
  ::
  ++  send-pkt-line
    |=  txt=tape
    ^-  tape
    ?>  (lte (lent txt) (sub 0xffff 4))
    ::  abcd_txt_LF
    ::
    ;:  weld
    ((x-co:co 4) (add (lent txt) 5))
    txt
    "\0a"
    ==
  ::
  ++  send-caps
    |=  =caps
    ^-  tape
    %+  roll
    ^-  (list tape)
    %+  turn
    ~(tap by caps)
    |=  [key=@ta value=(unit @t)]
    %-  send-pkt-line
    ?~  value
    (trip key)
    :(weld (trip key) "=" (trip u.value))
    |=([a=tape b=tape] (weld a b))
  ::
  ++  send-flush-pkt  ((x-co:co 4) flush-pkt)
  ::
  ++  send-delim-pkt  ((x-co:co 4) delim-pkt)
  ::
  ++  send-end-pkt  ((x-co:co 4) end-pkt)
  ::
  ++  greet-server
    =/  m  (strand ,caps)
    ^-  form:m
    ;<  ~  bind:m
    %-  send-request:strandio  :^
    %'GET'
    (cat 3 url '/info/refs?service=git-upload-pack')
    ~[['Git-Protocol' 'version=2']]
    ~
    ;<  res=client-response:iris  bind:m  take-client-response:strandio
    ?>  ?=(%finished -.res)
    ?~  full-file.res  !!
    =+  lap=(flop (read-pkt-lines full-file.res))
    ?~  lap
    ~|  "Server advertised no capabilities"  !!
    ::  Enforce version
    ::
    ?>  =('version 2' q.i.lap)
    =+  caps=(parse-caps t.lap)
    (pure:m caps)
  ::
  ++  flush-pkt  0
  ++  delim-pkt  1
  ++  end-pkt    2
  ::
  ++  cap
    ::  key=[value]
    ::
    ;~  plug
    sym
    %-  punt
    ;~(pfix tis (cook crip (plus prn)))
    ==
    ++  git-agent  'git/2.42.0'
    ++  write-caps  !!
    ++  parse-caps
    |=  lap=(list octs)
    ^-  caps
    =|  =caps
    |-
    ?~  lap
    caps
    =+  txt=(trip q.i.lap)
    =/  cap=[@ta (unit @t)]
    (scan txt cap)
    $(caps (~(put by caps) cap), lap t.lap)
    ::
    ++  read-pkt-lines
      |=  full-file=(unit mime-data:iris)
      ^-  (list octs)
      ?~  full-file
      ~|  "Server response empty"  !!
      ::  XX do we really need to check it?
      :: ?>  =('application/x-git-upload-pack-advertisement' type.u.full-file)
      =/  sea=stream:stream  [0 data.u.full-file]
      ::  Parse pkt lines
      ::
      =|  lap=(list octs)
      |-
      ?:  (is-dry:stream sea)
        lap
      =^  byt  sea  (read-bytes:stream 4 sea)
      ?~  byt
      ~|  "Insufficient data: expected packet-line length"  !!
      =+  len=(scan (trip u.byt) (bass 16 (stun [4 4] six:ab)))
      ::  0000 - flush packet
      ::
      ?:  =(flush-pkt len)
      lap
      ?:  (lte len 4)
      ~|  "Unhandled special packet-line"  !!
      =.  len  (sub len 4)
      =^  byt  sea  (read-bytes:stream len sea)
      ?~  byt
      ~|  "Insufficient data: expected packet-line data"  !!
      ::  Strip trailing newline
      ::
      ?:  =('\0a' (cut 3 [(dec len) 1] u.byt))
      $(lap [[(dec len) (cut 3 [0 (dec len)] u.byt)] lap])
    $(lap [[len u.byt] lap])
--
