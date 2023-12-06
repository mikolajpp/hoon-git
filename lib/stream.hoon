/-  *stream
::
::  Byte- and bit-stream library. 
::
::  Reading data. There are two families of functions: 
::  "get" and "read".
::
::  1. "get" functions read data from a stream 
::     without advancing the stream. On failure
::     the returned position is the initial position. 
::
::  2. "read" functions read data from a stream 
::    advancing the stream. On failure
::    the position of the returned stream is unchanged.
::
::  A bit stream is a byte stream with a bit 
::  accumulator attached. 
::
::  A conventional variable name for a byte-stream is sea.
::  
::  A conventional name for a bit-stream is zea.
::  
~%  %stream  ..part  ~
|%
::
::  Is the stream dry?
::
++  is-dry
  |=  sea=stream
  (gte pos.sea p.octs.sea)
::
::  Is the stream wet?
::
++  is-wet
  |=  sea=stream
  !(is-dry sea)
::
::  Get a byte without advancing the stream
::
++  get-byte
  |=  sea=stream
  ^-  [(unit @) @ud]
  =+  i=+(pos.sea)
  ?:  (gth i p.octs.sea)
    [~ pos.sea]
  :_  i
  `(cut 3 [pos.sea 1] q.octs.sea)
::
::  Read a byte. Advances the stream. 
::
++  read-byte
  |=  sea=stream
  ^-  [(unit @) stream]
  =/  [bat=(unit @) pos=@ud]
    (get-byte sea)
  :-  bat
  [pos octs.sea]
::
::  Get n bytes without advancing the stream
::
++  get-bytes
  |=  [n=@ud sea=stream]
  ^-  [(unit octs) @ud]
  =+  i=(add pos.sea n)
  ?:  (gth i p.octs.sea)
    [~ pos.sea]
  :_  i
  `[n (cut 3 [pos.sea n] q.octs.sea)]
::
::  Read n bytes. Advances the stream. 
::
++  read-bytes
  |=  [n=@ud sea=stream]
  ^-  [(unit octs) stream]
  =/  [data=(unit octs) pos=@ud]
    (get-bytes n sea)
  :-  data
  [pos octs.sea]
::
::  Get bytes until newline, inclusive, 
::  without advancing the stream.
::
++  get-line
  |=  sea=stream
  ^-  [(unit octs) @ud]
  =+  i=pos.sea
  |-
  ?:  (gte i p.octs.sea)
    [~ pos.sea]
  =+  bat=(cut 3 [i 1] q.octs.sea)
  ?.  =('\0a' bat)
    $(i +(i))
  =+  len=+((sub i pos.sea))
  :_  +(i)
  `[len (cut 3 [pos.sea len] q.octs.sea)]
::
::  Read bytes until newline, inclusive, 
::  advancing the stream.
::
++  read-line
  |=  sea=stream
  ^-  [(unit octs) stream]
  =/  [data=(unit octs) pos=@ud]
    (get-line sea)
  :-  data
  [pos octs.sea]
::
::  Read bytes until newline, exclusive,
::  without advancing. 
::
++  get-until-line  !!
::
::  Read bytes until newline, exclusive,
::  advancing the stream.
::
++  read-until-line  !!
::
::  Find first occurence of the fit byte
::
++  find-byte
  |=  [fit=@D sea=stream]
  ^-  (unit @ud)
  =+  pin=pos.sea
  |-
  ?.  (lth pin p.octs.sea)
    ~
  =/  bat  (cut 3 [pin 1] q.octs.sea)
  ?:  =(fit bat)
    `pin
  $(pin +(pin))
::
::  Append n bytes to red from sea without advancing sea
::
++  append-get-bytes
  ~/  %append-get-bytes
  |=  [n=@ud red=stream sea=stream]
  ^-  [stream stream]
  ?:  =(n 0)
    [red sea]
  =/  [data=(unit octs) pos=@ud]
    (get-bytes n sea)
  ?~  data  !!
  :_  sea
  :+  pos.red
    (add p.octs.red n)
  (add q.octs.red (lsh [3 p.octs.red] q.u.data))
::
::  Append n bytes to red from sea, advancing sea
::
++  append-read-bytes
  ~/  %append-read-bytes
  |=  [n=@ud red=stream sea=stream]
  ^-  [stream stream]
  ?:  =(n 0)
    [red sea]
  =^  data  sea  (read-bytes n sea)
  ?~  data  !!
  :_  sea
  :+  pos.red
    (add p.octs.red n)
  (add q.octs.red (lsh [3 p.octs.red] q.u.data))
--
