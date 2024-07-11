~%  %bytestream  ..part  ~
|%
::    bytestream
::  .pos: cursor into .octs
::  .octs: bytestream data
::
+$  bays  $+  bays  
          $:  pos=@ud
              =octs
          ==
--
::    bytestream
::
::  a bytestream is a pair of a cursor and octs data.
::  the cursor points at the next byte to be read or written.
::  
::  there are three families of functions: for reading, 
::  writing and appending to a bytestream. they operate 
::  upon three kinds of data: a singular byte, a sequence of 
::  bytes (octs), or a text (cord).
::
::  a combined operation of reading from a source bytestream
::  and writing the resulting data to a target bytestream is called
::  a 'write-read'. 
::
::  a write or append to a bytestream always succeeds. 
::  a read can fail if the source bytestream is exhausted:
::  reading arms either crash on failure, or return a unit.
::
::  each read advances the cursor by a corresponding
::  number of bytes read; peek functions do not advance the stream.
::
::  each write advances the cursor by a corresponding
::  number of bytes written; append functions do not advance the stream.
::
|%
::  utilities
::
+|  %utilities
++  cat-octs
  |=  [a=octs b=octs]
  :-  (add p.a p.b)
  (can 3 ~[a b])
++  can-octs
  |=  a=(list octs)
  ^-  octs
  =-  [- (can 3 a)]
  %+  reel  a
  |=  [=octs size=@ud]
  (add size p.octs)
++  as-byts
  |=  =octs
  ^-  byts
  [p.octs (rev 3 octs)]
::    conversion
::
+|  %conversion
++  from-octs
  |=  =octs
  ^-  bays
  [0 octs]
++  to-octs  
  |=  sea=bays
  ^-  octs
  octs.sea
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
  q.octs.sea
++  to-atom
  |=  sea=bays
  ^-  @
  q.octs.sea
::    check bytestream status
+|  %status
++  size
  |=  sea=bays
  ^-  @ud
  p.octs.sea
++  in-size
  |=  sea=bays
  ^-  @ud
  (sub p.octs.sea pos.sea)
++  is-empty
  |=  sea=bays
  (gte pos.sea p.octs.sea)
::    navigate the bytestream
+|  %navigation
++  rewind
  |=  sea=bays
  ^-  bays
  sea(pos 0)
++  seek-to
  |=  [pos=@ud sea=bays]
  ^-  bays
  sea(pos pos)
::    +skip-by: advance by .n bytes
::
++  skip-by
  |=  [n=@ud sea=bays]
  ^-  bays
  ?>  (lte (add pos.sea n) p.octs.sea)
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
::    +rewind-byte: retreat by one byte
::
++  back-byte
  |=  [n=@ud sea=bays]
  ^-  bays
  (back-by 1 sea)
::    +next-line: advance to the beginning of next line
::
++  skip-line
  |=  sea=bays
  ^-  bays
  =+  i=pos.sea
  |-
  ?.  (lth i p.octs.sea)
    sea(pos p.octs.sea)
  ?:  =('\0a' (cut 3 [i 1] q.octs.sea))
    sea(pos +(i))
  $(i +(i))
::    +rewind-line: retreat to the beginning of the current line
::  if the stream is exhausted, position the cursor at the end
::  of the stream
++  rewind-line
  |=  sea=bays
  ^-  bays
  ?.  (lth pos.sea p.octs.sea)
    sea(pos p.octs.sea)
  =+  i=pos.sea
  |-
  ?:  =('\0a' (cut 3 [i 1] q.octs.sea))
    sea(pos +(i))
  ?:  =(i 0)
    sea(pos 0)
  $(i (dec i))
::    +back-line: retreat to the beginning of previous line
::
::  if the stream is exhausted, position the cursor
::  at the end of the stream
::
++  back-line
  |=  sea=bays
  ^-  bays
  ?.  (lth pos.sea p.octs.sea)
    sea(pos p.octs.sea)
  =.  sea  (rewind-line sea)
  ::  current line is first
  ::
  ?:  =(0 pos.sea)
    sea
  ::  previous line is empty
  ::
  ?:  =(1 pos.sea)
    sea(pos (dec pos.sea))
  (rewind-line sea(pos (sub pos.sea 2)))
::    +find-byte: find the index of first occurence of byte .byt
::
++  find-byte
  |=  [bat=@D sea=bays]
  ^-  (unit @ud) 
  =+  i=pos.sea
  |-
  ?.  (lth i p.octs.sea)
    ~
  ?:  =(bat (cut 3 [i 1] q.octs.sea))
    (some i)
  $(i +(i))
::    +seek-byte: seek stream to first occurence of byte .byt
::
++  seek-byte
  |=  [bat=@D sea=bays]
  ^-  [(unit @ud) bays]
  =/  idx  (find-byte bat sea)
  ?~  idx
    [~ sea]
  [idx sea(pos u.idx)]
:: ++  find-octs  !!
:: ++  seek-octs  !!
:: ++  find-txt  !!
:: ++  seek-txt  !!
::
::    read bytes
::
+|  %read-byte
::    +read-byte-maybe: maybe read a byte and advance the stream
::
++  read-byte-maybe
  ::    return a byte unit and advanced stream
  ::
  |=  sea=bays  ::  .sea: source bytestream
  ^-  [(unit @D) bays]
  =+  i=+(pos.sea)
  ?:  (gth i p.octs.sea)
    [~ sea]
  :_  sea(pos i)
  (some (cut 3 [pos.sea 1] q.octs.sea))
::  +read-byte: read a byte and advance the stream
::
++  read-byte
  |=  sea=bays
  ^-  [@D bays]
  =^  bam  sea  (read-byte-maybe sea)
  :_  sea
  (need bam)
::  +peek-byte-maybe: maybe read a byte, do not advance
::
++  peek-byte-maybe
  |=  sea=bays
  ^-  (unit @D)
  -:(read-byte-maybe sea)
::  +peek-byte-maybe: read a byte, do not advance
::
++  peek-byte
  |=  sea=bays
  ^-  @D
  (need (peek-byte-maybe sea))
::    read octs
::
+|  %read-octs
++  read-octs-maybe
  |=  [n=@ud sea=bays]
  ^-  [(unit octs) bays]
  =+  i=(add pos.sea n)
  ?:  (gth i p.octs.sea)
    [~ sea]
  :_  sea(pos i)
  %-  some
  [n (cut 3 [pos.sea n] q.octs.sea)]
++  read-octs  
  |=  [n=@ud sea=bays]
  ^-  [octs bays]
  =^  octs  sea  (read-octs-maybe n sea)
  :_  sea
  (need octs)
++  read-octs-end
  |=  sea=bays
  ^-  [octs bays]
  (read-octs (sub p.octs.sea pos.sea) sea)
++  peek-octs-maybe
  |=  [n=@ud sea=bays]
  ^-  (unit octs)
  -:(read-octs-maybe n sea)
++  peek-octs
  |=  [n=@ud sea=bays]
  ^-  octs
  (need (peek-octs-maybe n sea))
++  peek-octs-end
  |=  sea=bays
  ^-  octs
  -:(read-octs-end sea)
::    read text
::
+|  %read-txt
::    +read-line-maybe: maybe read a line of text
::
++  read-line-maybe
  |=  sea=bays
  ^-  [(unit @t) bays]
  =+  i=pos.sea
  |-
  ::  newline not found, return whole stream
  ::
  ?.  (lth i p.octs.sea)
    :_  sea(pos p.octs.sea)
    (some (cut 3 [pos.sea (sub p.octs.sea pos.sea)] q.octs.sea))
  ?:  =('\0a' (cut 3 [i 1] q.octs.sea))
    :_  sea(pos +(i))
    (some (cut 3 [pos.sea (sub i pos.sea)] q.octs.sea))
  $(i +(i))
::    +read-line: read a line of text
::  read bytes until newline is found, or until stream
::  is exhausted.
::
++  read-line
  |=  sea=bays
  ^-  [@t bays]
  =^  line  sea  (read-line-maybe sea)
  :_  sea
  (need line)
::    +peek-line-maybe: maybe peek a line of text
::
++  peek-line-maybe
  |=  sea=bays
  ^-  (unit @t)
  -:(read-line-maybe sea)
::    +peek-line: peek a line of text
::  read bytes until newline is found, or until stream
::  is exhausted.
::
++  peek-line
  |=  sea=bays
  ^-  @t
  (need (peek-line-maybe sea))
::    write data at the cursor position
::
+|  %write
++  write-byte
  |=  [sea=bays bat=@D]
  ^-  bays
  %=  sea
    pos  +(pos.sea)
    p.octs  +(p.octs.sea)
    q.octs  (sew 3 [pos.sea 1 bat] q.octs.sea)
  ==
++  write-octs
  |=  [sea=bays =octs]
  ^-  bays
  %=  sea
    pos  (add pos.sea p.octs)
    p.octs  (add p.octs p.octs.sea)
    q.octs  (sew 3 [pos.sea p.octs q.octs] q.octs.sea)
  ==
++  write-txt
  |=  [sea=bays txt=@t]
  (write-octs sea [(met 3 txt) txt])
::    append data to the end of bytestream
::
+|  %append
::  XX change all sew into cats
++  append-byte
  |=  [sea=bays bat=@D]
  ^-  bays
  %=  sea
    p.octs  +(p.octs.sea)
    q.octs  (sew 3 [p.octs.sea 1 bat] q.octs.sea)
  ==
++  append-octs
  |=  [sea=bays =octs]
  ^-  bays
  %=  sea
    p.octs  (add p.octs.sea p.octs)
    q.octs  (sew 3 [p.octs.sea p.octs q.octs] q.octs.sea)
  ==
++  append-txt
  |=  [sea=bays txt=@t]
  ^-  bays
  (append-octs sea [(met 3 txt) txt])
::    write-read operations
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
::
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
::
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
+|  %transformation
::    +chunk: split the bytestream into chunks of .siz bytes
::
++  chunk
  ~/  %chunk
  |=  [sea=bays siz=@ud]
  ^-  (list octs)
  ~
::
::
::    +extract: extract a list of octs from bytestream 
::  
::  repeatedly calls the user supplied gate .rac to
::  determine the offset and length of each octs chunk. 
::
::  .rac accepts a bytestream and returns a pair 
::  of an offset and chunk length to extract.
::
::  the process continues until either the stream is exhausted, 
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
  =^  data  sea  (read-octs len sea)
  $(dal [data dal])
::    +fuse-extract: extract and fuse the resulting octs list
::
++  fuse-extract
  ~/  %fuse-extract
  |=  [sea=bays rac=$-(bays [@ud @ud])]
  ^-  [octs bays]
  =|  res=octs
  |-
  ?:  (is-empty sea)
    :_  sea
    res
  =/  [sip=@ud len=@ud]
    (rac sea)
  ?:  &(=(0 sip) =(0 len))
    :_  sea
    res
  =.  sea  (skip-by sip sea)
  ?.  (gth len 0)
    $
  =^  data=octs  sea  (read-octs len sea)
  $(res (cat-octs res data))
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
--
