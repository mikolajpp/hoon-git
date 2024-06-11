::  
::::  Git http
  ::
::  git-http is a library of git smart HTTP protocol 
::  component strands.
::
::  Supports only protocol v2 for git-upload-pack and 
::  protocol v0 for git-receive-pack functionality
:: 
/-  spider
/+  stream, strandio
/+  *git, git-pack, git=git-repository
~%  %git-http  ..part  ~
=,  strand=strand:spider
|%
++  git-agent  'hoon-git/0.1'
+$  caps  (map @ta (unit @t))
::  XX data=octs
+$  pkt-line  $@  $?(%flush %delim %end)
                  [%data =octs]
+$  command  $?(%ls-refs %fetch)
+$  request  $:  cmd=command
                 caps=(list @t)
                 args=(list @t)
             ==
++  default-caps  :~  ;;(@t (cat 3 'agent=' git-agent))
                  ==
--
|_  url=@t
::
::  Greet the pack upload service to obtain capabilities
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
  ::  Read service string
  ::
  =|  red=stream:stream
  =^  pil  red  (read-pkt-lines & sea)
  =+  lip=(flop pil)
  ?~  lip 
    ~|  "Server response empty"  !!
  ?>  ?=(%data -.i.lip)
  ::  "Clients MUST verify the first pkt-line is # service=$servicename"
  ::  Yet, as of version 2.43.0, git no longer sends this line in v2 
  ::  protocol.
  ::
  =?  sea  =('# service=git-upload-pack' q.octs.i.lip)
    red
  ::  Read capabilities
  ::
  =^  pil  sea  (read-pkt-lines & sea)
  =+  lip=(flop pil)
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
      (write-pkt-lines-txt (crip "command={(trip cmd.request)}"))
      (can-octs:stream (turn caps.request write-pkt-lines-txt))
      (write-pkt-len delim-pkt)
      (can-octs:stream (turn args.request write-pkt-lines-txt))
      (write-pkt-len flush-pkt)
    ==
  %-  send-request:strandio
    :^  %'POST'
        (cat 3 url '/git-upload-pack')
        :~  ['Git-Protocol' 'version=2']
            ['User-Agent' git-agent]
            ['Content-Type' 'application/x-git-upload-pack-request']
        ==
        `req
::
::  Parse ls-refs output to a triple of 
::  refname, reference, and optional peeled hash
::
++  ls-refs
  =>  |%
      :: XX Implement a show command for types
      :: so that args can be automatically printed.
      ::
      +$  args
        $:  symrefs=_|
            peel=_|
            ref-prefix=(list refname)
        ==
      --
  |=  =args
  ::  Return a triple of refname, reference, 
  ::  and optional peeled hash.
  ::
  =/  m  (strand ,(list [refname ref (unit hash)]))
  ^-  form:m
  =+  cmd-caps=default-caps
  =|  cmd-args=(list @t)
  =.  cmd-args
    %+  turn  ref-prefix.args
    |=  ren=refname
    (cat 3 'ref-prefix ' (print-refname ren))
  =?  cmd-args  peel.args
    ['peel' cmd-args]
  =?  cmd-args  symrefs.args
    ['symrefs' cmd-args]
  ::
  ~&  ls-refs+cmd-args
  ;<  ~  bind:m  (send-request %ls-refs cmd-caps cmd-args)
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
  ::  Parse references
  ::
  =>  |%
      +$  attribute
        $%  [%symref =refname:git]
            [%peeled =hash]
        ==
      ++  ref-attribute
        ;~  pose
          (stag %symref ;~(pfix (jest ' symref-target:') parse-refname))
          ::  XX parametrize by hash-algo
          (stag %peeled ;~(pfix (jest ' peeled:') parse-sha-1))
        ==
      ++  ref-parser
        %+  cook 
          |=  [=hash =refname:git attr=(unit (list attribute))]
          ^-  [refname:git ref:git (unit ^hash)]
          ?~  attr
            [refname hash ~]
          =|  peeled=(unit ^hash)
          =|  symref=(unit refname:git)
          =+  attr=u.attr
          |-
          ?~  attr
            ?~  symref
              [refname hash peeled]
            [refname [%symref u.symref] peeled]
          ?-  -.i.attr
            %symref  $(symref `+.i.attr, attr t.attr)
            %peeled  $(peeled `+.i.attr, attr t.attr)
          ==
          ::
          ;~  plug
            parse-sha-1
            ;~(pfix ace parse-refname)
            (punt (plus ref-attribute))
          ==
        --
  ::  A list of triples: refname, ref,
  ::  and optional peeled hash
  ::
  =|  rel=(list [=refname:git =ref:git peel=(unit hash)])
  =.  rel
  |-
  ?~  lip
    rel
  ?>  ?=(%data -.i.lip)
  =+  ref=(scan (trip q.octs.i.lip) ref-parser)
  $(rel [ref rel], lip t.lip)
  ::
  (pure:m (flop rel))
  ::
::
::  Fetch strand
::  XX should return a full response, not
::  just the pack (which could be missing)
::
++  fetch
  |=  [have=(list hash) want=(list hash)]
  =/  m  (strand ,pack:git-pack)
  ^-  form:m
  =+  caps=~
  =/  args
    ;:  weld
    ~['ofs-delta']
    ::
    %+  turn
      have
    |=  =hash
    (crip "have {(print-sha-1 hash)}")
    ::
    %+  turn
      want
    |=  =hash
    (crip "want {(print-sha-1 hash)}")
    ==
  ;<  ~  bind:m  (send-request %fetch caps args)
  ;<  res=client-response:iris  bind:m  take-client-response:strandio
  ?>  ?=(%finished -.res)
  ?~  full-file.res
    ~|  "No pack received"  !!
  =/  sea=stream:stream  0+data.u.full-file.res
  ::  Handle packfile response
  ::
  =<
  =|  red=stream:stream
  ::  Acknowledgements
  ::
  =^  ack  sea  (read-acks sea)
  =^  pkt  red  (read-pkt-line & sea)
  ::  Acks only
  ::
  ?:  &(?=(@ pkt) ?=(%flush pkt))
    (pure:m *pack:git-pack)
  =?  sea  &(?=(@ pkt) ?=(%delim pkt))
    red
  =^  sal  sea  (read-shallow-info sea)
  =^  wef  sea  (read-wanted-refs sea)
  =^  pur  sea  (read-pack-uris sea)
  =^  pack=pack:git-pack  sea  (read-pack sea)
  (pure:m pack)
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
    |-
    ?:  (is-dry:stream sea)
      :_  sea
      ack
    =^  pkt  red  (read-pkt-line & sea)
    ?@  pkt
      :_  sea
      ack
    ?:  =('ready' q.octs.pkt)
      :_  red
      ack
    ::
    =>  |%
        ++  parse-ack
          :: XX seems to be another bug,
          :: this does not work properly
          :: |=  pkt=$>(%data pkt-line)
          |=  pkt=pkt-line
          ^-  hash
          ?<  ?=(@ pkt)
          %+  scan
            (trip q.octs.pkt)
          ;~(pfix (jest 'ACK ') parse-sha-1)
        --
    %=  $
      ack  [(parse-ack pkt) ack]
      sea  red
    ==
    ::
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
    ^-  [pack:git-pack stream:stream]
    ::  Read header
    ::
    =^  pkt  sea  (read-pkt-line & sea)
    ?@  pkt
      ?:  ?=(%flush pkt)
        ~|  "Expected packfile stream"  !!
      :_  sea
      *pack:git-pack
    ?>  =('packfile' q.octs.pkt)
    ::  Read packfile
    ::
    =^  red=stream:stream  sea  (read-pkt-lines-on-band sea 1)
    :_  sea
    (read:git-pack red)
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
++  write-pkt-lines-txt-on-band
  |=  [txt=@t band=@udD]
  ^-  octs
  =+  len=(met 3 txt)
  ::  XX split large requests across 
  ::  multiple pkt lines
  ::
  ?>  (lte +(len) (sub 0xffff 5))
  ::  Assemble packet line
  ::  cafe_data_LF
  ::
  %-  can-octs:stream
  :~
    (write-pkt-len ;:(add 5 len 1))
    [1 band]
    [len txt]
    [1 '\0a']
  ==
::  XX rename to write-pkt-line-txt
++  write-pkt-lines-txt
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
++  write-pkt-lines
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
::  Split octs into pkt-lines
::
::  XX What's preventing us from invoking
::  a jet with wrong arguments directly from nock?
::  Do most jet verify their arguments?
::
++  write-pkt-lines-on-band
  ~/  %write-pkt-lines-on-band
  |=  [sea=stream:stream band=@ud]
  ^-  octs
  =+  chunk-size=8.192
  ::  chunk-size - pkt-line-len - band byte
  ::  
  ::  XX  Alternative syntax for monadic bind
  ::  ;<  monad
  ::  a b
  ::  c d
  ::  ==
  =+  max-len=(sub chunk-size 5)
  =|  pkt-lines=octs
  |-  
  ?:  (is-dry:stream sea)
    pkt-lines
  =+  sea-len=(sub p.octs.sea pos.sea)
  =/  len=@ud
    ?:  (gth sea-len max-len)
      max-len
    sea-len
  =^  data  sea  (read-bytes:stream len sea)
  ?~  data  !!
  ?>  =(p.u.data len)
  =/  new-line=octs
    ;:  cat-octs:stream
      (write-pkt-len (add len 5))
      [1 band]
      u.data
    ==
  ?>  =(p.new-line (add len 5))
  $(pkt-lines (cat-octs:stream pkt-lines new-line))
::
:: 
::  Assemble pkt-lines into a stream, filtering on band
::
++  read-pkt-lines-on-band
:: { "read-pkt-lines-on-band", 7, _139_hex_git_http_read_pkt_lines_on_band_a, 0, no_hashes},
  :: ~%  %read-pkt-lines-on-band  +3  ~
  ~/  %read-pkt-lines-on-band
  |=  [sea=stream:stream band=@ud]
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
