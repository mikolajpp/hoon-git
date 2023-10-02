::
:: Zlib compression library
::
~%  %zlib  ..part  ~
|%
+$  zlib-cmf         [cm=@udD cinfo=@udD]
+$  zlib-flg         [fcheck=@uxD fdict=@uxD flevel=@udD]
+$  zlib-raw-header  [cmf=zlib-cmf flg=zlib-flg]
+$  zlib-header      [%deflate [wbits=@ud fdict=?]]
::
+$  accumulator      [hold=@ux bits=@ud]
+$  bit-stream       [acu=accumulator pos=@ud stream=byts]
+$  stream           [pos=@ud =byts]
::
::  Expand Zlib stream
::
::  This is a jet stub for now
++  expand
  ~/  %expand
  |=  sea=stream
  ^-  [byts stream]
  :_  sea
  [0 0x0]
  :: |=  sea=bit-stream
  :: ^-  (list byts)

  :: Parse Zlib header
  ::
  :: =^  hed  sea  (header sea)
  :: ?-  -.hed
  :: %deflate  (expand-deflate hed sea)
  :: ==
::
++  expand-deflate
  |=  [hed=zlib-header sea=bit-stream]
  ^-  (list byts)
  ?>  =(-.hed %deflate)
  ?:  fdict.hed
    ~|  "Compression dictionary is unsupported"  !!
  ::
  ~&  hed
  =/  window=byts  [(sub wbits.hed 3) 0x0]
  =/  out=(list byts)  ~
  =<
  |-
  =/  bok  (expand-block)
  ?:  -.bok
    [+.bok out]
  $(out [+.bok out])
  ::
  ::  DEFLATE expansion core
  ::
  |%
  ++  expand-block
    |.
    =.  sea  (~(need-bits of sea) 3)
    ::
    =/  bfinal=?  =(0b1 (~(bits of sea) 1))
    =.  sea  (~(drop-bits of sea) 1)
    =/  btype=@ub  (~(bits of sea) 2)
    ::
    =.  sea  (~(drop-bits of sea) 3)
    ::
    :-  bfinal
    ?+  btype  !!
    %0   (expand-block-loose)
    %1   (expand-block-fixed)
    %2   (expand-block-dynamic)
    %3  ~|  "Block corrupted: invalid BTYPE = {<btype>}"  !!
    ==
  ::
  ++  expand-block-loose
    |.
    ^-  byts
    =.  sea  (~(byte-bits of sea))
    =.  sea  (~(need-bits of sea) 16)
    =^  len  sea  (~(read-bits of sea) 16)
    =.  sea  (~(need-bits of sea) 16)
    =^  nlen  sea  (~(read-bits of sea) 16)
    ::
    ?.  =(len (mix nlen 0xffff))
      ~|  "Loose block corrupted: NLEN check failed"  !!
    ?:  (lth wid.stream.sea len)
      ~|  "Bit stream exhausted"  !!
    [len (cut 3 [pos.sea len] dat.stream.sea)]
  ::
  ++  expand-block-fixed
    |.
    [0 0x0]
  ::
  ++  expand-block-dynamic
    |.
    [0 0x0]
  ::
  --
++  header
  |=  sea=bit-stream
  ^-  [zlib-header bit-stream]
  ::  Parse CMF
  ::
  =^  cmf=byts  sea  (~(byte of sea))
  ?:  =(0 wid.cmf)
    ~|  "Header corrupted: CMF byte missing"  !!
  =/  cm     (dis 0x8 dat.cmf)              :: bits 0-3
  =/  cinfo  (rsh [2 1] (dis 0xf0 dat.cmf)) :: bits 4-7
  ::  Parse FLG
  ::
  =^  flg=byts  sea  (~(byte of sea))
  ?:  =(0 wid.flg)
    ~|  "Header corrupted: FLG byte missing"  !!
  =/  fcheck  (dis 0x1f dat.flg)              :: bits 0-4
  =/  fdict   (rsh [2 1] (dis 0x20 dat.flg))  :: bit 5
  =/  flevel  (rsh [2 1] (dis 0xc0 dat.flg))  :: bits 6-7 XX - correct?
  ::
  ::  Verify
  ::
  =/  check  (add (lsh [3 1] dat.cmf) dat.flg)
  ?.  =(0 (mod check 31))
    ~|  "Header corrupted"  !!
  ::
  ::  Detect compression type
  ::
  ?.  =(8 cm)
    ~|  "Unsupported compression method CM = {<cm>}"  !!
  :_  sea
  (header-deflate [[cm cinfo] [fcheck fdict flevel]])
::
++  header-deflate
  |=  zed=zlib-raw-header
  ~&  zed
  ?.  (lte cinfo.cmf.zed 7)
    ~|  "Unsupported window size CINFO = {<cinfo.cmf.zed>}"  !!
  [%deflate wbits=(add cinfo.cmf.zed 8) =(fdict.flg.zed 1)]
::
++  bytes
  |=  [n=@ud stream=byts]
  ^-  [byts byts]
  ?:  |(=(0 wid.stream) (lth wid.stream n))
    :-  [0 0x0]  [0 0x0]
  =/  len  (sub wid.stream n)
  ?:  (lte (met 3 dat.stream) n)
    :-  [n dat.stream]  [len 0x0]
  :-  [n (end [3 n] dat.stream)]  [len (rsh [3 n] dat.stream)]
::
::  Binary stream core
::
++  of
  |_  bit-stream
  +*  this  .
      sea  +6
  ::
  ::  Initialize from byts
  ::
  ++  fill
    |=  red=byts
    sea(stream red)
  ::
  ::  Read one byte without accumulation
  ::
  ++  byte
    |.
    ^-  [byts bit-stream]
    =^  bat  sea  (pull-byte)
    [bat (drop-bits 8)]
  ::
  ::  Accumulate one byte
  ::
  ++  pull-byte
    |.
    ^-  [byts bit-stream]
    ?:  (gte pos wid.stream)
      :_  sea
      [0 0x0]
    =/  bat=byts
      ?:  (gte pos (met 3 dat.stream))
        [1 0x0]
      [1 (cut 3 [pos 1] dat.stream)]
    :-  bat
      %=  sea
        acu  [hold=(add hold.acu (lsh [0 bits.acu] dat.bat)) bits=(add bits.acu 8)]
        pos  +(pos)
      ==
  ::
  ::  Assure that there are at least n bits
  ::  in the bit accumulator
  ::
  ++  need-bits
    |=  n=@ud
    ?:  (gte bits.acu n)
      sea
    =/  bas  (pull-byte)
    ?>  (gth wid.-:bas 0)
    $(sea +:bas)
  ::
  ::  Return the low n bits of the bit accumulator
  ::
  ++  bits
    |=  n=@ud
    =/  mak  (dec (lsh [0 n] 0x1))
    (dis mak hold.acu)
  ::
  ::  Return the low n bits of the accumulator and drop them
  ::
  ++  read-bits
    |=  n=@ud
    =/  bis  (bits n)
    :-  bis  (drop-bits n)
  ::
  ::  Remove n bits from the bit accumulator
  ::
  ++  drop-bits
    |=  n=@ud
    =/  hod  (rsh [0 n] hold.acu)
    sea(hold.acu hod, bits.acu (sub bits.acu n))
  ::
  ::  Remove zero to seven bits as needed to go to a byte boundary
  ::
  ++  byte-bits
    |.
    =/  bas  (dis bits.acu 0x7)
    =/  hod  (rsh [0 bas] hold.acu)
    sea(acu [hod (sub bits.acu bas)])
  --
--
:: ++  bytes
::   |=  [n=@ud sea=byts]
::   ^-  [byts byts]
::   ?:  |(=(0 wid.sea) (lth wid.sea n))
::     :-  [0 0x0]  [0 0x0]
::   =/  len  (sub wid.sea n)
::   ?:  (lte (met 3 dat.sea) n)
::     :-  [n dat.sea]  [len 0x0]
::   :-  [n (end [3 n] dat.sea)]  [len (rsh [3 n] dat.sea)]
::
::  Parser types
::
::   +$  byts  [wid=@ud dat=@ux]                  :: MSB order
::   :: +$  bits  [p=@ud q=@ux]                   :: bit accumulator
::   +$  here  @ud                                :: position in the stream
::   +$  swim  [p=here q=byts]                    :: binary stream
::   +$  buoy  [p=here q=(unit [p=* q=swim])]     :: parsing result
::   ::
::   +$  boat  _|:($:swim $:buoy)                      :: binary parser rule
::   ::
::   ::  Parser tracing
::   ::
::   ++  last
::     |=  [a=here b=here]
::     ?:  (gth a b)
::       a
::     b
::   ::
::   ::  Parser combinators
::   ::
::   ++  cook                                                ::  apply gate
::     |*  [oar=gate kan=boat]
::     |=  sea=swim
::     =+  row=(kan sea)
::     ?~  q.row
::       row
::     [p=p.row q=[~ u=[p=(oar p.u.q.row) q=q.u.q.row]]]
::   ::
::   ++  pose  *boat                             :: alternative
::   ::
::   ++  plug                                    :: sequence
::     |*  [boy=buoy kan=boat]
::     ^-  buoy
::     ?~  q.boy
::       boy
::     =+  row=(kan q.u.q.boy)
::     =+  pos=(last p.boy p.row)
::     ?~  q.row
::       row
::     [pos q=[~ u=[p=[p.u.q.row p.u.q.boy] q=q.u.q.row]]]
::   ::
::   :: Parse n bytes
::   ::
::   ++  bytes
::     |=  n=@
::     |=  sea=swim
::     ^-  buoy
::     ?:  |(=(0 wid.q.sea) (lth wid.q.sea n))
::       [p.sea ~]
::     =/  pos  (add p.sea n)
::     =/  len  (sub wid.q.sea n)
::     ?:  (lte (met 3 dat.q.sea) n)
::       [pos `[[n dat.q.sea] [pos [len 0x0]]]]
::     [pos `[[n (end [3 n] dat.q.sea)] [pos [len (rsh [3 n] dat.q.sea)]]]]
::   ::
::   ++  byte  (bytes 1)
::   ++  word  (bytes 4)
::   --
