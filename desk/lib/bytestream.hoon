|%
::  $bays: bytestream
::
::    .pos: relative cursor into .data
::    .data: octs stream
::
+$  bays  $+  bays
          $:  pos=@ud
              data=octs
          ==
::    $bits: bitstream
::
::      .num: number of bits in the acculumalator
::      .bit: accumulator
::      .bays: bytestream
::
+$  bits  $+  bits
          $:  num=@ud
              bit=@ub
              =bays
          ==
--
::    bytestream: read and write sequence of bytes
::
::  A bytestream is a pair of a cursor and octs data.
::  The cursor points at the next byte to be read or written.
::
::  There are three families of functions: for reading,
::  writing and appending to a bytestream. they operate
::  upon three kinds of data: a singular byte, a sequence of
::  bytes (octs), or a text (cord).
::
::  A combined operation of reading from a source bytestream
::  and writing the resulting data to a target bytestream is called
::  a 'write-read'.
::
::  A write or append to a bytestream always succeeds.
::  A read can fail if the source bytestream is exhausted:
::  reading arms either crash on failure, or return a unit (maybe).
::
::  Each read advances the cursor by a corresponding
::  number of bytes read; peek functions do not advance the stream.
::
::  Each write advances the cursor by a corresponding
::  number of bytes written; append functions do not advance the stream.
::
~%  %bytestream  ..part  ~
|%
::    Utilities
::
+|  %utilities
++  rip-octs
  ~/  %rip-octs
  |=  a=octs
  ^-  (list @)
  ?:  =(p.a 0)
    ~
  =|  hun=(list @)
  =+  i=p.a
  |-
  ?:  =(i 0)
    hun
  %=  $
    i  (dec i)
    hun  :_(hun (cut 3 [(dec i) 1] q.a))
  ==
++  cat-octs
  ~/  %cat-octs
  |=  [a=octs b=octs]
  :-  (add p.a p.b)
  (can 3 ~[a b])
++  cut-octs
  |=  [pin=@ud len=@ud data=octs]
  ^-  octs
  [len (cut 3 [pin len] q.data)]
++  can-octs
  ~/  %can-octs
  |=  a=(list octs)
  ^-  octs
  ?:  =(~ a)  [0 0]
  =-  [- (can 3 a)]
  %+  reel  a
  |=  [=octs size=@ud]
  (add size p.octs)
++  as-octs  as-octs:mimes:html
++  as-octt  as-octt:mimes:html
++  as-byts
  |=  =octs
  ^-  byts
  [p.octs (rev 3 octs)]
::    Conversion
::
+|  %conversion
++  from-octs
  |=  =octs
  ^-  bays
  [0 octs]
++  to-octs
  |=  sea=bays
  ^-  octs
  data.sea
++  at-octs
  |=  [n=@ud =octs]
  ^-  bays
  [n octs]
++  from-txt
  |=  txt=@t
  (from-octs [(met 3 txt) txt])
++  to-txt
  |=  sea=bays
  ^-  @t
  q.data.sea
++  to-atom
  |=  sea=bays
  ^-  @
  q.data.sea
::    Check bytestream status
::
+|  %status
::  +exceed: whether .sea is out of bound
++  exceed
  |=  sea=bays
  ^-  ?
  (gte pos.sea p.data.sea)
::  +exceed-at: whether .pos is out of bound
::
++  exceed-at
  |=  [pos=@ud sea=bays]
  ^-  ?
  (gte pos p.data.sea)
::  +still-by: whether .n bytes can be read
::
++  still-by
  |=  [n=@ud sea=bays]
  ^-  ?
  (lte (add pos.sea n) p.data.sea)
::  +still-byte: whether a byte can be read
::
++  still-byte
  |=  sea=bays
  ^-  ?
  (lte +(pos.sea) p.data.sea)
::  +is-empty: is bytestream empty?
::
++  is-empty
  |=  sea=bays
  (gte pos.sea p.data.sea)
::  +size: total bytes
::
++  size
  |=  sea=bays
  ^-  @ud
  p.data.sea
::  +out-size: bytes read
::
++  out-size
  |=  sea=bays
  ^-  @ud
  pos.sea
::  +in-size: remaining bytes
::
++  in-size
  |=  sea=bays
  ^-  @ud
  (sub p.data.sea pos.sea)
::    Navigation
::
+|  %navigation
++  rewind
  |=  sea=bays
  ^-  bays
  sea(pos 0)
::  +seek-to: navigate to .pos
::
++  seek-to
  |=  [pos=@ud sea=bays]
  ^-  bays
  sea(pos pos)
::  +seek-end: navigate to the end of stream
::
++  seek-end
  |=  sea=bays
  ^-  bays
  sea(pos p.data.sea)
::    +skip-by: advance by .n bytes
::
++  skip-by
  |=  [n=@ud sea=bays]
  ^-  bays
  ?>  (lte (add pos.sea n) p.data.sea)
  sea(pos (add pos.sea n))
::    +skip-by: advance by one byte
::
++  skip-byte
  |=  sea=bays
  (skip-by 1 sea)
::    +back-by: retreat by .n bytes
::
++  back-by
  |=  [n=@ud sea=bays]
  ^-  bays
  ?<  (lth pos.sea n)
  sea(pos (sub pos.sea n))
::    +back-byte: retreat by one byte
::
++  back-byte
  |=  [n=@ud sea=bays]
  ^-  bays
  (back-by 1 sea)
::    +skip-line: advance to the beginning of next line
++  skip-line
  ~/  %skip-line
  |=  sea=bays
  ^-  bays
  =+  i=pos.sea
  |-
  ?:  (exceed-at i sea)
    (seek-end sea)
  ?:  =('\0a' (cut 3 [i 1] q.data.sea))
    sea(pos +(i))
  $(i +(i))
::    +find-byte: find the index of first occurence of byte .byt
::
++  find-byte
  ~/  %find-byte
  |=  [bat=@D sea=bays]
  ^-  (unit @ud)
  =+  i=pos.sea
  |-
  ?:  (exceed-at i sea)
    ~
  ?:  =(bat (cut 3 [i 1] q.data.sea))
    (some i)
  $(i +(i))
::    +seek-byte: seek stream to first occurence of byte .byt
::
++  seek-byte
  ~/  %seek-byte
  |=  [bat=@D sea=bays]
  ^-  [(unit @ud) bays]
  =/  idx  (find-byte bat sea)
  ?~  idx
    [~ sea]
  [idx sea(pos u.idx)]
::
:: ++  find-octs  !!
:: ++  seek-octs  !!
:: ++  find-txt  !!
:: ++  seek-txt  !!
::
::    Read byte
::
+|  %read-byte
::
::  +read-byte: read a byte and advance the stream
::
++  read-byte
  ~/  %read-byte
  |=  sea=bays
  ^-  [@D bays]
  ?>  (still-byte sea)
  :_  sea(pos +(pos.sea))
  (cut 3 [pos.sea 1] q.data.sea)
::    +read-byte-maybe: maybe read a byte and advance the stream
::
++  read-byte-maybe
  ::    return a byte unit and advanced stream
  ::
  |=  sea=bays  ::  .sea: source bytestream
  ^-  [(unit @D) bays]
  ?.  (still-byte sea)
    [~ sea]
  :_  sea(pos +(pos.sea))
  (some (cut 3 [pos.sea 1] q.data.sea))
::  +peek-byte-maybe: read a byte, do not advance
::
++  peek-byte
  |=  sea=bays
  ^-  @D
  ?>  (still-byte sea)
  (cut 3 [pos.sea 1] q.data.sea)
::  +peek-byte-maybe: maybe read a byte, do not advance
::
++  peek-byte-maybe
  |=  sea=bays
  ^-  (unit @D)
  ?.  (still-byte sea)
    ~
  (some (cut 3 [pos.sea 1] q.data.sea))
::    Read octs
::
+|  %read-octs
::
::  +read-octs: read .n octs
::
++  read-octs
  ~/  %read-octs
  |=  [n=@ud sea=bays]
  ^-  [octs bays]
  ?>  (still-by n sea)
  :_  (skip-by n sea)
  [n (cut 3 [pos.sea n] q.data.sea)]
++  read-octs-maybe
  |=  [n=@ud sea=bays]
  ^-  [(unit octs) bays]
  ?.  (still-by n sea)
    [~ sea]
  :_  (skip-by n sea)
  %-  some
  [n (cut 3 [pos.sea n] q.data.sea)]
::  +read-octs-until: read octs until byte at position .sop
::
++  read-octs-until
  |=  [sop=@ud sea=bays]
  ^-  [octs bays]
  ?<  (exceed-at (dec sop) sea)
  =+  len=(sub sop pos.sea)
  :_  sea(pos sop)
  [len (cut 3 [pos.sea len] q.data.sea)]
++  read-octs-until-maybe
  |=  [sop=@ud sea=bays]
  ^-  [(unit octs) bays]
  ?:  (exceed-at (dec sop) sea)
    [~ sea]
  =+  len=(sub sop pos.sea)
  :_  sea(pos sop)
  %-  some
  [len (cut 3 [pos.sea len] q.data.sea)]
::  +read-octs-end: read octs until end of stream
::
++  read-octs-end
  |=  sea=bays
  ^-  [octs bays]
  =+  len=(in-size sea)
  :_  (seek-end sea)
  [len (cut 3 [pos.sea len] q.data.sea)]
++  peek-octs
  |=  [n=@ud sea=bays]
  ^-  octs
  ?>  (still-by n sea)
  [n (cut 3 [pos.sea n] q.data.sea)]
++  peek-octs-maybe
  |=  [n=@ud sea=bays]
  ^-  (unit octs)
  ?.  (still-by n sea)
    ~
  %-  some
  [n (cut 3 [pos.sea n] q.data.sea)]
++  peek-octs-end
  |=  sea=bays
  ^-  octs
  =+  len=(in-size sea)
  [len (cut 3 [pos.sea len] q.data.sea)]
::  +peek-octs-until: peek octs until .pos
::
++  peek-octs-until
  |=  [pos=@ud sea=bays]
  ^-  octs
  ?:  =(pos 0)
    [0 0]
  ?>  (lte pos p.data.sea)
  =+  len=(sub pos pos.sea)
  [len (cut 3 [pos.sea len] q.data.sea)]
::    Read atom
::
+|  %read-atom
::  +read-lsb: read atom in LSB order
::
++  read-lsb
  |=  [n=@ud sea=bays]
  ^-  [@ bays]
  =^  num  sea  (read-octs n sea)
  :_  sea
  q.num
++  peek-lsb
  |=  [n=@ud sea=bays]
  ^-  @
  q:(peek-octs n sea)
::  +read-msb: read atom in MSB order
::
++  read-msb
  |=  [n=@ud sea=bays]
  ^-  [@ bays]
  =^  num  sea  (read-octs n sea)
  :_  sea
  (rev 3 num)
++  read-msb-maybe
  |=  [n=@ud sea=bays]
  ^-  [(unit @) bays]
  =^  num  sea  (read-octs-maybe n sea)
  ?~  num  [~ sea]
  :_  sea
  (some (rev 3 u.num))
++  peek-msb
  |=  [n=@ud sea=bays]
  ^-  @
  =/  num  (peek-octs n sea)
  (rev 3 num)
::  +read-txt: read cord
::
++  read-txt  read-lsb
::    Read text
::
+|  %read-txt
::
::  +read-line: read line of text
::
::    Read bytes until newline is found, or until stream
::    is exhausted.
::
++  read-line
  |=  sea=bays
  ^-  [@t bays]
  =/  pin  (find-byte 0xa sea)
  ?~  pin
    ::  newline not found, return whole stream
    ::
    =^  data  sea  (read-octs-end sea)
    :_  sea
    q.data
  =^  data  sea  (read-octs-until u.pin sea)
  :_  sea(pos +(u.pin))
  q.data
::    +read-line-maybe: maybe read a line of text
::
++  read-line-maybe
  |=  sea=bays
  ^-  [(unit @t) bays]
  =/  pin  (find-byte 0xa sea)
  ?~  pin
    ::  newline not found, return whole stream
    ::
    =^  data  sea  (read-octs-end sea)
    :_  sea
    (some q.data)
  =^  data  sea  (read-octs-until u.pin sea)
  :_  sea(pos +(u.pin))
  (some q.data)
::    +peek-line: peek a line of text
::  read bytes until newline is found, or until stream
::  is exhausted.
::
++  peek-line
  |=  sea=bays
  ^-  @t
  =/  pin  (find-byte 0xa sea)
  ?~  pin
    ::  newline not found, return whole stream
    ::
    =/  data  (peek-octs-end sea)
    q.data
  =/  data  (peek-octs-until u.pin sea)
  q.data
::    +peek-line-maybe: maybe peek a line of text
::
++  peek-line-maybe
  |=  sea=bays
  ^-  (unit @t)
  =/  pin  (find-byte 0xa sea)
  ?~  pin
    ::  newline not found, return whole stream
    ::
    =/  data  (peek-octs-end sea)
    (some q.data)
  =/  data  (peek-octs-until u.pin sea)
  (some q.data)
::    Write data at the cursor position
::
+|  %write
++  write-byte
  |=  [sea=bays bat=@D]
  ^-  bays
  %=  sea
    pos  +(pos.sea)
    p.data  +(p.data.sea)
    q.data  (sew 3 [pos.sea 1 bat] q.data.sea)
  ==
++  write-octs
  |=  [sea=bays =octs]
  ^-  bays
  %=  sea
    pos  (add pos.sea p.octs)
    p.data  (add p.octs p.data.sea)
    q.data  (sew 3 [pos.sea p.octs q.octs] q.data.sea)
  ==
++  write-txt
  |=  [sea=bays txt=@t]
  (write-octs sea [(met 3 txt) txt])
::    Append data
::
+|  %append
++  append-byte
  |=  [sea=bays bat=@D]
  ^-  bays
  sea(data (cat-octs data.sea [1 bat]))
++  append-octs
  |=  [sea=bays data=octs]
  ^-  bays
  sea(data (cat-octs data.sea data))
++  append-txt
  |=  [sea=bays txt=@t]
  ^-  bays
  (append-octs sea [(met 3 txt) txt])
::    Read source data and write to target
::
::  read data from a source bytestream and write it to a
::  target bytestream.
::
+|  %write-read
::
++  write-read-byte
  |=  [red=bays sea=bays]
  ^-  [bays bays]
  =^  bat=@D  sea  (read-byte sea)
  :_  sea
  (write-byte red bat)
++  write-read-octs
  |=  [red=bays sea=bays n=@ud]
  ^-  [bays bays]
  =^  =octs  sea  (read-octs n sea)
  :_  sea
  (write-octs red octs)
++  write-read-line
  |=  [red=bays sea=bays]
  ^-  [bays bays]
  =^  line=@t  sea  (read-line sea)
  :_  sea
  (write-txt red (cat 3 line '\0a'))
::
++  write-peek-byte
  |=  [red=bays sea=bays]
  ^-  bays
  =/  bat=@D  (peek-byte sea)
  (write-byte red bat)
++  write-peek-octs
  |=  [red=bays sea=bays n=@ud]
  ^-  bays
  =/  =octs  (peek-octs n sea)
  (write-octs red octs)
++  write-peek-line
  |=  [red=bays sea=bays]
  ^-  bays
  =/  line=@t  (peek-line sea)
  (write-txt red (cat 3 line '\0a'))
++  append-read-byte
  |=  [red=bays sea=bays]
  ^-  [bays bays]
  =^  bat=@D  sea  (read-byte sea)
  :_  sea
  (append-byte red bat)
++  append-read-octs
  |=  [red=bays sea=bays n=@ud]
  ^-  [bays bays]
  =^  =octs  sea  (read-octs n sea)
  :_  sea
  (append-octs red octs)
++  append-read-line
  |=  [red=bays sea=bays]
  ^-  [bays bays]
  =^  line=@t  sea  (read-line sea)
  :_  sea
  (append-txt red (cat 3 line '\0a'))
++  append-peek-byte
  |=  [red=bays sea=bays]
  ^-  bays
  =/  bat=@D  (peek-byte sea)
  (append-byte red bat)
++  append-peek-octs
  |=  [red=bays sea=bays n=@ud]
  ^-  bays
  =/  =octs  (peek-octs n sea)
  (append-octs red octs)
++  append-peek-line
  |=  [red=bays sea=bays]
  ^-  bays
  =/  line=@t  (peek-line sea)
  (append-txt red (cat 3 line '\0a'))
::    Transformation
::
+|  %transformation
::    +chunk: cut the bytestream into chunks of .siz bytes
::
::  If the bytestream is not evenly divided into chunks,
::  the final chunk is a remainder.
::
++  chunk
  ~/  %chunk
  |=  [size=@ud sea=bays]
  ^-  (list octs)
  ?:  =(size 0)
    ~
  =|  hun=(list octs)
  |-
  =+  rem=(in-size sea)
  ?:  =(0 rem)
    (flop hun)
  ?:  (lth rem size)
    =^  octs  sea  (read-octs rem sea)
    (flop [octs hun])
  =^  octs  sea  (read-octs size sea)
  $(hun [octs hun])
::
::    +extract: extract a list of octs from bytestream
::
::  Repeatedly calls the user supplied gate .rac to
::  determine the offset and length of each octs chunk.
::
::  .rac accepts a bytestream and returns a pair
::  of an offset and chunk length to extract. Chunks
::  of zero length are skipped.
::
::  The process continues until either the stream is exhausted,
::  or the gate returns a pair of [0 0]
::
++  extract
  ~/  %extract
  |=  [sea=bays rac=$-(bays [@ud @ud])]
  ^-  [(list octs) bays]
  =|  dal=(list octs)
  |-
  ?:  (is-empty sea)
    :_  sea
    (flop dal)
  =/  [sip=@ud len=@ud]
    (rac sea)
  ?:  &(=(0 sip) =(0 len))
    :_  sea
    (flop dal)
  =.  sea  (skip-by sip sea)
  ?.  (gth len 0)
    $
  =^  data=octs  sea  (read-octs len sea)
  $(dal [data dal])
::    +fuse-extract: extract and fuse the resulting octs list
::
++  fuse-extract
  ~/  %fuse-extract
  |=  [sea=bays rac=$-(bays [@ud @ud])]
  ^-  [octs bays]
  =|  dal=(list octs)
  |-
  ?:  (is-empty sea)
    :_  sea
    (can-octs (flop dal))
  =/  [sip=@ud len=@ud]
    (rac sea)
  ?:  &(=(0 sip) =(0 len))
    :_  sea
    (can-octs (flop dal))
  =.  sea  (skip-by sip sea)
  ?.  (gth len 0)
    $
  =^  data=octs  sea  (read-octs len sea)
  $(dal [data dal])
::    +split: split bytestream into a list of octs
::
::  repeatedly calls the user supplied gate .pit
::  to determine the current chunk length
::
::  the process continues until either the stream
::  is exhausted or the gate returns a chunk of length 0.
::
++  split
  |=  [sea=bays pit=$-(bays @ud)]
  ^-  [(list octs) bays]
  %+  extract  sea
  |=  sea=bays
  [0 (pit sea)]
::
++  fuse-split
  |=  [sea=bays pit=$-(bays @ud)]
  ^-  [octs bays]
  %+  fuse-extract  sea
  |=  sea=bays
  [0 (pit sea)]
::    Read and write bits on a bytestream
::
+|  %bitstream
::
++  bits-from-bays
  |=  sea=bays
  ^-  bits
  [num=0 bit=0b0 sea]
++  bays-from-bits
  |=  pea=bits
  ^-  bays
  bays.pea
++  bits-is-empty
  |=  pea=bits
  ^-  ?
  =(0 (bits-in-size pea))
::  +in-size: remaining bits
::
++  bits-in-size
  |=  pea=bits
  ^-  @ud
  %+  add
    num.pea
  (mul 8 (in-size bays.pea))
::  +out-size: bits read
::
++  bits-out-size
  |=  pea=bits
  ^-  @ud
  (sub (mul 8 (out-size bays.pea)) num.pea)
::  +need-bits: require .n bits to be available
::
++  need-bits
  ~/  %need-bits
  |=  [n=@ud pea=bits]
  ^-  bits
  ?:  (gte num.pea n)
    pea
  ::  how many bytes needed
  ::  
  =+  nib=(sub n num.pea)
  =/  neb=@ud  (div nib 8)
  =?  neb  !=(0 (mod nib 8))
    +(neb)
  |-
  ?:  =(neb 0)
    pea
  =^  bat  bays.pea  (read-byte bays.pea)
  %=  $
    num.pea  (add num.pea 8)
    bit.pea
      (add bit.pea (lsh [0 num.pea] bat))
    neb  (dec neb)
  ==
::  +drop-bits: drop low .n bits
::
++  drop-bits
  ~/  %drop-bits
  |=  [n=@ud pea=bits]
  ^-  bits
  ?:  =(n 0)
    pea
  %=  pea
    bit  (rsh [0 n] bit.pea)
    num
      ?.  (gth num.pea n)
        0
      (sub num.pea n)
  ==
++  skip-bits
  |=  [n=@ud pea=bits]
  ^-  bits
  =.  pea  (need-bits n pea)
  (drop-bits n pea)
::  +peek-bits: peek low .n bits
::
++  peek-bits
  ~/  %peek-bits
  |=  [n=@ud pea=bits]
  ^-  @
  ?>  (gte num.pea n)
  ?:  =(n 0)
    0
  %+  dis  bit.pea
  (sub (lsh [0 n] 1) 1)
::  +read-bits: read low .n bits, then drop
::
++  read-bits
  ~/  %read-bits
  |=  [n=@ud pea=bits]
  ^-  [@ bits]
  ?>  (gte num.pea n)
  :_  (drop-bits n pea)
  %+  dis  bit.pea
  (sub (lsh [0 n] 1) 1)
::  +read-need-bits: read low .n bits, requiring if necessary
::
++  read-need-bits
  |=  [n=@ud pea=bits]
  ^-  [@ bits]
  =?  pea  (lth num.pea n)
    (need-bits n pea)
  :_  (drop-bits n pea)
  %+  dis  bit.pea
  (sub (lsh [0 n] 1) 1)
::  +byte-bits: remove 0 to 7 bits to reach byte boundary
::
++  byte-bits
  ~/  %byte-bits
  |=  pea=bits
  ^-  bits
  =+  rem=(dis num.pea 0x7)
  ?:  =(rem 0)
    pea
  %=  pea
    num  (sub num.pea rem)
    bit  (rsh [0 rem] bit.pea)
  ==
--
