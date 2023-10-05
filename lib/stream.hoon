/-  *stream
|%
:: Should return a unit?
::
++  get-bytes
  |=  [n=@ud sea=stream]
  ^-  [(unit @ux) @ud stream]
  ?:  (gte pos.sea wid.byts.sea)
    [~ pos.sea sea]
  :_  [(add n pos.sea) sea]
  `(cut 3 [pos.sea n] dat.byts.sea)
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
--
