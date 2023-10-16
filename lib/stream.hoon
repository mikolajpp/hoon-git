/-  *stream
|%
::  Should return a unit?
::  XX should return byts, not @ux
::
++  get-bytes
  |=  [n=@ud sea=stream]
  ^-  [(unit @ux) @ud stream]
  ?:  (gte pos.sea wid.byts.sea)
    [~ pos.sea sea]
  :_  [(add n pos.sea) sea]
  `(cut 3 [pos.sea n] dat.byts.sea)
::  XX should return byts not @ux
::
++  read-bytes
  |=  [n=@ud sea=stream]
  ^-  [(unit @ux) stream]
  =/  nex  (get-bytes n sea)
  :_  [+<.nex byts.+>.nex]
    -.nex
::  XX handle leading zeros
++  get-line
  |=  sea=stream
  ^-  [(unit tape) @ud stream]
  =/  i  pos.sea
  |-
  ?:  (gte i wid.byts.sea)
    [~ [pos.sea sea]]
  ?:  =('\0a' (get-char i sea))
    :_  [pos=+(i) sea=sea]
      lan=`(get-string [pos.sea i] sea)
  $(i +(i))
::
++  read-line
  |=  sea=stream
  ^-  [(unit tape) stream]
  =/  nex  (get-line sea)
  :_  [+<.nex byts.+>.nex]
    -.nex
::
++  get-char
  |=  [i=@ sea=stream]
  ^-  @t
  (cut 3 [i 1] dat.byts.sea)
::
::  Get a [-.ran +.ran] substring
::
++  get-string
  |=  [ran=[@ud @ud] sea=stream]
  ^-  tape
  (trip (cut 3 [-.ran +((sub +.ran -.ran))] dat.byts.sea))
::
++  find-byte
  |=  [bat=@ sea=stream]
  =/  pin  pos.sea
  |-
  :: XX return a unit or position past width
  ?.  (lth pin wid.byts.sea)  !!
  =/  bet  (cut 3 [pin 1] dat.byts.sea)
  ?:  =(0x0 bet)
    pin
  $(pin +(pin))
::  Append n bytes to red from sea.
::  Advances sea.
::
::  XX should return byts not @ux
::  XX what is a jet based solution?
::  Use blocks of bytes, or lists?
::
++  append-read-bytes
  |=  [n=@ud red=stream sea=stream]
  ^-  [stream stream]
  ?:  =(n 0)
    [red sea]
  =^  byt  sea  (read-bytes n sea)
  =+  bat=(need byt)
  =*  byts  byts.red
  :_  sea
  ::
  :-  pos.red
  :-  (add wid.byts n)
  (add dat.byts (lsh [3 wid.byts] bat))
::
::  Append n bytes to red from sea
::  Does not advance sea.
:::
++  append-get-bytes
  |=  [n=@ud red=stream sea=stream]
  ^-  [stream stream]
  ?:  =(n 0)
    [red sea]
  =+  nex=(get-bytes n sea)
  =+  bat=(need -.nex)
  =*  byts  byts.red
  :_  +>.nex
  ::
  :-  pos.red
  :-  (add wid.byts n)
  (add dat.byts (lsh [3 wid.byts] bat))
::
++  is-dry
  |=  sea=stream
  (gte pos.sea wid.byts.sea)
::
++  is-wet
  |=  sea=stream
  (lth pos.sea wid.byts.sea)
--
