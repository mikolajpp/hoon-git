::  
:: git-http is a library of smart HTTP protocol 
:: component strands.
:: 
:: Only smart git protocol version 2 is supported.
::
/-  git, *git-io, spider
/+  git, stream, strandio
=,  strand=strand:spider
~%  %git-io  ..part  ~
|_  url=@t
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
    (cook crip (plus ;~(less fas prn)))
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
::
::  Fetch references
::
++  fetch
  |=  [have=(list hash:git) want=(list hash:git)]
  =/  m  (strand ,pack:git)
  ^-  form:m
  =+  caps=~
  =/  args
    ;:  weld
    ~['ofs-delta']
    ::
    %+  turn
      have
    |=  hax=hash:git
    (crip "have {((x-co:co 40) hax)}")
    ::
    %+  turn
      want
    |=  hax=hash:git
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
  =^  pak=pack:git  sea  (read-pack sea)
  :: =+  pak=*pack:git
  (pure:m pak)
  ::
  |%
  ++  read-acks
    |=  sea=stream:stream
    ^-  [(list hash:git) stream:stream]
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
    =|  ack=(list hash:git)
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
      ^-  hash:git
      ?<  ?=(@ pkt)
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
      ?:  ?=(%flush pkt)
        ~|  "Expected packfile stream"  !!
      ~&  %read-pack-empty
      :_  sea
      *pack:git
    ?>  =('packfile' q.octs.pkt)
    ::  Read packfile
    ::
    =^  red=stream:stream  sea  (stream-pkt-lines-on-band 1 sea)
    =/  pack-file  -:(read:pak:git red)
    ~&  read-pack+header.pack-file
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
::
::  Server capabilities
::
++  cap
  ::  key[=value]
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
::
::  Pkt-line
::
++  flush-pkt  0
++  delim-pkt  1
++  end-pkt    2
++  print-pkt-len
  |=  len=@D
  ^-  tape
  ((x-co:co 4) len)
::
++  print-pkt-line-txt
  |=  txt=tape
  ^-  tape
  ?>  (lte (lent txt) (sub 0xffff 4))
  ::  len_txt_LF
  ::
  ;:  weld
  (print-pkt-len (add (lent txt) 5))
  txt
  "\0a"
  ==
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
:: XX return unit instead of crashing?
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
