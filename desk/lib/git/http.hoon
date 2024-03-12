::  
::  git-http is a library of smart HTTP protocol 
::  component strands.
::
::  Supports only protocol v2 for git-upload-pack and 
::  protocol v0 for git-receive-pack functionality
:: 
/-  *git, *git-http, spider
/+  *git, stream, strandio
=,  strand=strand:spider
~%  %git-http  ..part  ~
|_  url=@t
::
::  Greet the "upload" server service to obtain a map of capabilities
::
++  greet-server-upload
  =/  m  (strand ,caps)
  ^-  form:m
  ;<  ~  bind:m
  %-  send-request:strandio  
    :^  %'GET'
        (cat 3 url '/info/refs?service=git-upload-pack')
        :~  ['Git-Protocol' 'version=2']
            ['User-Agent' git-agent]
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
::  Greet the receive server service to obtain a map of capabilities
::
++  greet-server-receive
  =/  m  (strand ,caps)
  ^-  form:m
  ;<  ~  bind:m
  %-  send-request:strandio  
    :^  %'GET'
        (cat 3 url '/info/refs?service=git-receive-pack')
        :~  ['Git-Protocol' 'version=0']
            ['User-Agent' git-agent]
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
  ~&  `@t`q.data.u.full-file.res
  ::  Handle non-standard behaviour
  ::  of servers advertising the service name
  ::
  ?>  ?=(%data -.i.lip)
  =/  lip
    ?:  =(q.octs.i.lip '# service=git-receive-pack')
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
    %-  can-octs:stream
    :~
      (write-pkt-line-txt (crip "command={(trip cmd.request)}"))
      (can-octs:stream (turn caps.request write-pkt-line-txt))
      (write-pkt-len delim-pkt)
      (can-octs:stream (turn args.request write-pkt-line-txt))
      (write-pkt-len flush-pkt)
    ==
  ~&  req+`@t`q.req
  %-  send-request:strandio
    :^  %'POST'
        (cat 3 url '/git-upload-pack')
        :~  ['Git-Protocol' 'version=2']
            ['User-Agent' git-agent]
            ['Content-Type' 'application/x-git-upload-pack-request']
        ==
        `req
::
++  ls-refs
  |=  args=(list @t)
  =/  m  (strand ,(list [path hash]))
  ^-  form:m
  =+  caps=~
  ;<  ~  bind:m  (send-request %ls-refs caps args)
  ;<  res=client-response:iris  bind:m  take-client-response:strandio
  ?>  ?=(%finished -.res)
  ?~  full-file.res
  ~|  "No references received"  !!
  ::
  =/  sea=stream:stream  0+data.u.full-file.res
  ::  XX we don't really need to flop here
  ::
  =^  pil  sea  (read-pkt-lines & sea)
  =+  lip=(flop pil)
  =|  rel=(list [path hash])
  =.  rel
  ::  Parse references
  ::
  |-
  ?~  lip
    rel
  =/  ref  
    ?>  ?=(%data -.i.lip)
    (scan (trip q.octs.i.lip) parser-ref)
  $(rel [ref rel], lip t.lip)
  ::
  (pure:m (flop rel))
  ::
::
::  Fetch references
::
++  fetch
  |=  [have=(list hash) want=(list hash)]
  =/  m  (strand ,pack)
  ^-  form:m
  =+  caps=~
  =/  args
    ;:  weld
    ~['ofs-delta']
    ::
    %+  turn
      have
    |=  hax=hash
    (crip "have {((x-co:co 40) hax)}")
    ::
    %+  turn
      want
    |=  hax=hash
    (crip "want {((x-co:co 40) hax)}")
    ==
  ;<  ~  bind:m  (send-request %fetch caps args)
  ;<  res=client-response:iris  bind:m  take-client-response:strandio
  ?>  ?=(%finished -.res)
  ?~  full-file.res
    ~|  "No pack received"  !!
  ~&  "Received {<p.data.u.full-file.res>} bytes"
  =/  sea=stream:stream  0+data.u.full-file.res
  ::  Handle packfile response
  ::
  =<
  ::  Acknowledgements
  ::
  =^  ack  sea  (read-acks sea)
  =^  sal  sea  (read-shallow-info sea)
  =^  wef  sea  (read-wanted-refs sea)
  =^  pur  sea  (read-pack-uris sea)
  =^  pak=pack  sea  (read-pack sea)
  :: =+  pak=*pack
  (pure:m pak)
  ::
  |%
  ++  read-acks
    |=  sea=stream:stream
    ^-  [(list hash) stream:stream]
    =|  red=stream:stream
    =^  pkt  red  (read-pkt-line & sea)
    ?@  pkt
      :_  sea
      ~
    ?.  =('acknowledgments' q.octs.pkt)
      :_  sea
      ~
    =.  sea  red
    =^  pkt  red  (read-pkt-line & sea)
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
    =|  ack=(list hash)
    =<
    |-
    ?:  (is-dry:stream sea)
      :_  sea
      ack
    =^  pkt  red  (read-pkt-line & sea)
    ?@  pkt
      :_  (read-pkt-delim red)
      ack
    ?:  =('ready' q.octs.pkt)
      :_  (read-pkt-delim red)
      ack
    %=  $
      ack  [(parse-ack pkt) ack]
      sea  red
    ==
    ::
    |%
    ++  parse-ack
      :: XX seems to be another bug,
      :: this does not work properly
      :: |=  pkt=$>(%data pkt-line)
      |=  pkt=pkt-line
      ^-  hash
      ?<  ?=(@ pkt)
      %+  scan
        (trip q.octs.pkt)
      ;~(pfix (jest 'ACK ') parser-sha-1)
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
    ^-  [pack stream:stream]
    ::  Read header
    ::
    =^  pkt  sea  (read-pkt-line & sea)
    ?@  pkt
      ?:  ?=(%flush pkt)
        ~|  "Expected packfile stream"  !!
      ~&  %read-pack-empty
      :_  sea
      *pack
    ?>  =('packfile' q.octs.pkt)
    ::  Read packfile
    ::
    =^  red=stream:stream  sea  (stream-pkt-lines-on-band 1 sea)
    =/  pack-file  -:(read:pak red)
    ~&  read-pack+header.pack-file
    =+  pack=(index:pak pack-file)
    :_  sea
    pack
  --
::
::  Capability
::
++  cap
  ::  key[=value-1 value-2...]
  ::
  ;~  plug
  sym
  %-  punt
  ;~(pfix tis (cook crip (plus prn)))
  ==
++  parse-caps
  |=  lap=(list pkt-line)
  ^-  caps
  =|  =caps
  |-
  ?~  lap
    caps
  ?>  ?=(%data -.i.lap)
  =+  txt=(trip q.octs.i.lap)
  =/  cap=[@ta (unit @t)]
    (scan txt cap)
  $(caps (~(put by caps) cap), lap t.lap)
++  parse-caps-stream
  |=  sea=stream:stream
  ^-  [caps stream:stream]
  =|  =caps
  |-
  ?:  (is-dry:stream sea)
    [caps sea]
  =/  [pkt=pkt-line red=stream:stream]
    (read-pkt-line & sea)
  ?@  pkt
    [caps sea]
  ?>  ?=(%data -.pkt)
  =+  txt=(trip q.octs.pkt)
  =/  cap=[@ta (unit @ta)]
    (scan txt cap)
  $(caps (~(put by caps) cap), sea red)
::
::  Pkt-line
::
++  flush-pkt  0
++  delim-pkt  1
++  end-pkt    2
++  write-pkt-len
  |=  len=@D
  ^-  octs
  [4 (crip ((x-co:co 4) len))]
++  write-pkt-line-txt
  |=  txt=@t
  ^-  octs
  =+  len=(met 3 txt)
  ::  XX split large requests across 
  ::  multiple pkt lines
  ::
  ?>  (lte +(len) (sub 0xffff 4))
  ::  Assemble packet line
  ::  cafe_data_LF
  ::
  %-  can-octs:stream
  :~
    (write-pkt-len ;:(add 4 len 1))
    [len txt]
    [1 '\0a']
  ==
++  write-pkt-line
  |=  data=octs
  ^-  octs
  ::  XX split large requests across 
  ::  multiple pkt lines
  ::
  ?>  (lte p.data (sub 0xffff 4))
  ::  Assemble packet line
  ::  cafe_data
  ::
  %+  cat-octs:stream
    (write-pkt-len (add p.data 4))
    data
:: XX there is an input for which q.octs.pkt crashes!
:: This looks like another 
:: bug: 
:: |=  [band=@ud pkt=$>(%data pkt-line)]
::
++  pkt-line-is-band
  |=  [band=@ud pkt=pkt-line]
  ^-  ?
  ?<  ?=(@ pkt)
  =(band (cut 3 [0 1] q.octs.pkt))
::
:: 
::  Assemble pkt-lines into a stream, filtering on band
::
++  stream-pkt-lines-on-band
  ~/  %stream-pkt-lines-on-band
  |=  [band=@ud sea=stream:stream]
  ^-  [stream:stream stream:stream]
  =|  red=stream:stream
  |-
  =^  pkt=pkt-line  sea  (read-pkt-line | sea)
  ?@  pkt
    ?:  ?=(%flush pkt)
      :_  sea
      red
    ~|  "Pack stream not terminated"  !!
  ?.  (pkt-line-is-band band pkt)
    $
  $(red -:(append-get-bytes:stream (dec p.octs.pkt) red 1+octs.pkt))
::
++  read-pkt-lines
  |=  [is-txt=? sea=stream:stream]
  ^-  [(list pkt-line) stream:stream]
  ::  Parse pkt lines
  ::
  =|  lap=(list pkt-line)
  ::
  |-
  =^  pkt  sea  (read-pkt-line is-txt sea)
  ?:  ?=(%flush pkt)
    :_  sea
    lap
  $(lap [pkt lap])
::
:: XX Return unit instead of crashing?
::
++  read-pkt-line
  |=  [is-txt=? sea=stream:stream]
  ^-  [pkt-line stream:stream]
  ?:  (is-dry:stream sea)  !!
  =^  byt  sea  (read-bytes:stream 4 sea)
  ?~  byt
    ~|  "Insufficient data: expected pkt-line length"  !!
  =+  len=(scan (trip q.u.byt) (bass 16 (stun [4 4] six:ab)))
  ?:  =(flush-pkt len)
  ::
    :_  sea
    %flush
  ?:  =(delim-pkt len)
    :_  sea
    %delim
  ?:  =(end-pkt len)
    :_  sea
    %end
  ?:  (lte len 4)
    ~|  "Unhandled special pkt-line"  !!
  =.  len  (sub len 4)
  =^  byt  sea  (read-bytes:stream len sea)
  ?~  byt
    ~|  "Insufficient data: expected pkt-line data"  !!
  =/  pkt=pkt-line
    ::  Strip trailing newline
    ::
    ?:  &(is-txt =('\0a' (cut 3 [(dec len) 1] q.u.byt)))
      data+[(dec len) (cut 3 [0 (dec len)] q.u.byt)]
    data+[p=len octs=q.u.byt]
  ?>  ?=(%data -.pkt)
  :_  sea
  pkt
  ::
  ++  read-pkt-delim
    |=  sea=stream:stream
    ^-  stream:stream
    =^  pkt  sea  (read-pkt-line | sea)
    ?>  &(?=(@ pkt) ?=(%delim pkt))
    sea
::
--
