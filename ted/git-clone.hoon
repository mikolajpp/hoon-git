/-  spider
/+  strandio
/+  git, *git-protocol, stream
=,  strand=strand:spider
^-  thread:spider
|=  arg=vase
=/  m  (strand ,vase)
^-  form:m
::
=/  url=@t  (need !<((unit @t) arg))
=<
;<  caps=(map @ta (unit @t))  bind:m  greet-server
;<  refs=(list reference:git)  bind:m  (ls-refs ~)
::  Retrieve HEAD hash
::
=/  head=hash:git
  |-
  ?~  refs
    0x0
  ?:  =(~['HEAD'] -.i.refs)
    +.i.refs
  $(refs t.refs)
;<  pack=pack:git  bind:m  (fetch head)
(pure:m !>(pack))
::
|%
::
::  Greet the server to obtain a map of capabilities
::
++  greet-server
  =/  m  (strand ,caps)
  ^-  form:m
  ;<  ~  bind:m
  %-  send-request:strandio  
    :^  %'GET'
        (cat 3 url '/info/refs?service=git-upload-pack')
        :~  ['Git-Protocol' 'version=2']
            ['User-Agent' agent]
        ==
        ~
  ;<  res=client-response:iris  bind:m  take-client-response:strandio
  ?>  ?=(%finished -.res)
  ?.  =(%200 status-code.response-header.res)
    ~|  "Response failed {<res>}"  !!
  ?~  full-file.res  !!
  ::
  =/  sea=stream:stream  0+data.u.full-file.res
  =^  pil  sea  (read-pkt-lines & sea)
  =+  lip=(flop pil)
  ?~  lip 
    ~|  "Server response empty"  !!
  ::  Handle non-standard behaviour
  ::  of servers advertising the service name
  ::
  ?>  ?=(%data -.i.lip)
  =/  lip
    ?:  =(q.octs.i.lip '# service=git-upload-pack')
      =^  pil  sea  (read-pkt-lines & sea)
      (flop pil)
    lip
  ?~  lip
    ~|  "Server response empty"  !!
  ::  Enforce version
  ::
  ?>  ?=(%data -.i.lip)
  ?>  =('version 2' q.octs.i.lip)
  =+  caps=(parse-caps t.lip)
  (pure:m caps)
::
++  send-request
  |=  =request
  ::  Assemble request 
  ::
  =/  req=octs
    %-  as-octt:mimes:html
    ;:  weld
      (print-pkt-line-txt "command={(trip cmd.request)}")
      `tape`(zing (turn (turn caps.request trip) print-pkt-line-txt))
      (print-pkt-len delim-pkt)
      `tape`(zing (turn (turn args.request trip) print-pkt-line-txt))
      (print-pkt-len flush-pkt)
    ==
  ~&  `@t`q.req
  %-  send-request:strandio
    :^  %'POST'
        (cat 3 url '/git-upload-pack')
        :~  ['Git-Protocol' 'version=2']
            ['User-Agent' agent]
            ['Content-Type' 'application/x-git-upload-pack-request']
        ==
        `req
::
++  ls-refs
  |=  args=(list @t)
  =/  m  (strand ,(list reference:git))
  ^-  form:m
  =+  caps=~
  ;<  ~  bind:m  (send-request %ls-refs caps args)
  ;<  res=client-response:iris  bind:m  take-client-response:strandio
  ?>  ?=(%finished -.res)
  ?~  full-file.res
  ~|  "No references received"  !!
  ::
  ~&  `@t`(cut 3 [0 53] q.data.u.full-file.res)
  =<
  =/  sea=stream:stream  0+data.u.full-file.res
  ::  XX we don't really need to flop here
  ::
  =^  pil  sea  (read-pkt-lines & sea)
  =+  lip=(flop pil)
  =|  rel=(list reference:git)
  =.  rel
  ::  Parse references
  ::
  !.
  |-
  ?~  lip
    rel
  =/  ref  
    ?>  ?=(%data -.i.lip)
    (scan (trip q.octs.i.lip) reference)
  $(rel [ref rel], lip t.lip)
  ::
  (pure:m (flop rel))
  ::
  |%
  ::  XX conform to git-check-ref-format
  ::
  ++  segment
    (cook crip (plus prn))
  ++  paf
    ;~  pose
      ;~(plug (jest 'HEAD') (easy ~))
      ;~(plug segment (star ;~(pfix fas segment)))
    ==
  ++  reference
    %+  cook 
      |=([hax=@ux =path] [path hax])
      ;~(plug hax-sha-1:obj:git ;~(pfix ace paf))
  --
++  fetch
  |=  hax=@ux
  =/  m  (strand ,pack:git)
  ^-  form:m
  =+  caps=~
  =/  args
    :~  (crip "want {((x-co:co 40) hax)}")
        'ofs-delta'
    ==
  ;<  ~  bind:m  (send-request %fetch caps args)
  ;<  res=client-response:iris  bind:m  take-client-response:strandio
  ?>  ?=(%finished -.res)
  ?~  full-file.res
  ~|  "No pack received"  !!
  ~&  "Received {<p.data.u.full-file.res>} bytes"
  =/  sea=stream:stream  0+data.u.full-file.res
  ~&  `@t`(cut 3 [0 50] q.octs.sea)
  ::  Handle packfile response
  ::
  =<
  ::  Acknowledgements
  ::
  =^  ack  sea  (read-acknowledgements sea)
  ::  Ack-only response
  ::
  =+  pkt=-:(read-pkt-line | sea)
  ?@  pkt
    (pure:m *pack:git)
  ::
  =^  sal  sea  (read-shallow-info sea)
  =^  wef  sea  (read-wanted-refs sea)
  =^  pur  sea  (read-pack-uris sea)
  =^  pak=pack:git  sea  (read-pack sea)
  :: =+  pak=*pack:git
  (pure:m pak)
  ::
  |%
  ++  read-acknowledgements 
    |=  sea=stream:stream
    ^-  [(list hash:git) stream:stream]
    =|  red=stream:stream
    =^  pkt  red  (read-pkt-line | sea)
    ?@  pkt
      :_  sea
      ~
    ?.  =('acknowledgements' q.octs.pkt)
      :_  sea
      ~
    =.  sea  red
    =^  pkt  red  (read-pkt-line | sea)
    ?@  pkt
      :_  sea
      ~
    ::  No acceptable common object set 
    ::  found. 
    ::
    ?:  =('NAK' q.octs.pkt)
      :_  red
      ~
    ::  Server found a common object set and 
    ::  is ready for transfer.
    ::
    ?:  =('ready' q.octs.pkt)
      :_  red
      ~
    ::  Acknowledge all 'have' objects also 
    ::  possessed by the server.
    ::
    =.  sea  red
    =|  ack=(list hash:git)
    =<
    |-
    ?:  (is-dry:stream sea)
      :_  sea
      ack
    =^  pkt  red  (read-pkt-line & sea)
    ?@  pkt
      :_  sea
      ~
    %=  $
      ack  [(parse-ack pkt) ack]
      sea  red
    ==
    ::
    |%
    ++  parse-ack
      |=  pkt=$>(%data pkt-line)
      ^-  hash:git
      %+  scan
        (trip q.octs.pkt)
      ;~(pfix (jest 'ACK ') hax-sha-1:obj:git)
    --
  ++  read-shallow-info
    |=  sea=stream:stream 
    :_  sea
    ~
  ++  read-wanted-refs
    |=  sea=stream:stream
    :_  sea
    ~
  ++  read-pack-uris
    |=  sea=stream:stream
    :_  sea
    ~
  ++  read-pack
    |=  sea=stream:stream
    ^-  [pack:git stream:stream]
    ::  Read header
    ::
    =^  pkt  sea  (read-pkt-line & sea)
    ?@  pkt
      ~|  "Expected packfile stream"  !!
    ?>  =('packfile' q.octs.pkt)
    ::  Read packfile
    ::
    ~&  read-packfile+pos.sea
    ~&  `@t`(cut 3 [pos.sea 10] q.octs.sea)
    =^  red=stream:stream  sea  ~>  %bout  (stream-pkt-lines-on-band 1 sea)
    =/  pack-file  -:(read:pak:git red)
    =+  pack=(index:pak:git pack-file)
    :_  sea
    pack
  --
::
++  send-caps
  |=  =caps
  ^-  tape
  %+  roll
  ^-  (list tape)
  %+  turn
  ~(tap by caps)
  |=  [key=@ta value=(unit @t)]
  %-  print-pkt-line-txt
  ?~  value
  (trip key)
  :(weld (trip key) "=" (trip u.value))
  |=([a=tape b=tape] (weld a b))
--
