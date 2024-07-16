::
::::  Git hash
  ::
|%
+$  hash  @ux
+$  hash-algo
  $?  %sha-256
      %sha-1
  ==
--
::
|%
++  hash-bytes-sha-1  20
++  hash-bytes-sha-256  !!
++  hash-size-sha-1  ^~((mul 2 hash-bytes-sha-1))
++  hash-size-sha-256  ^~((mul 2 hash-bytes-sha-256))
::    +hash-bytes: hash size in bytes
::
++  hash-bytes
  |=  hal=hash-algo
  ?-  hal
    %sha-1    hash-bytes-sha-1
    %sha-256  hash-bytes-sha-256
  ==
::    +hash-size: hash size in characters
::
++  hash-size
  |=  hal=hash-algo
  ?-  hal
    %sha-1    hash-size-sha-1
    %sha-256  hash-size-sha-256
  ==
::    +hash-octs-sha-1: big-endian octs hash
::
::  Hash is stored in big-endian order to facilitate
::  efficient object search.
::
++  hash-octs-sha-1
  |=  =octs
  ^-  @ux
  (rev 3 20 (sha-1l:sha p.octs (rev 3 p.octs q.octs)))
::  +hash-txt-sha-1: big-endian text hash
::
++  hash-txt-sha-1
  |=  txt=@t
  ^-  @ux
  (hash-octs-sha-1 (met 3 txt) txt)
++  hash-octs-sha-256  !!
::  +txt-to-hash: parse partial hash
::
++  txt-to-hash
  |=  a=@ta
  ^-  hash
  =|  =hash
  |-
  ?:  =(a 0)
    hash
  =+  dit=(end [3 1] a)
  =/  val=@ux
  ?:  (gth dit '9')
    (add (sub dit 'a') 10)
  (sub dit '0')
  $(a (rsh [3 1] a), hash (add (lsh [2 1] hash) val))
::  +print-hash-sha-1: print hash
::
++  print-hash-sha-1
  |=  =hash
  ^-  tape
  ((x-co:co hash-size-sha-1) (rev 3 hash-bytes-sha-1 hash))
++  hex-dit
  |=  c=@C
  ^-  @
  ?:  (lth c 0xa)
    (add '0' c)
  ?<  (gth c 0xf)
  (add 'a' (sub c 0xa))
::  +print-short-hash: print first .len hash characters
::
::   XX improve algorithm
++  print-short-hash
  |=  [len=@ud =hash]
  ^-  tape
  ?:  =(len 0)  ""
  ::  Odd head digit
  ::
  =^  hat=tape  len
    ?:  =(0 (mod len 2))
      ["" len]
    =+  (cut 3 [(div (dec len) 2) 1] hash)
    :_  (dec len)
    ~[(hex-dit (rsh [2 1] -))]
  |-
  ?:  =(0 len)  hat
  =/  pin  (dec (div len 2))
  =+  byt=(cut 3 [pin 1] hash)
  =+  hig=(hex-dit (rsh [2 1] byt))
  =+  low=(hex-dit (dis byt 0xf))
  $(hat [hig low hat], len (sub len 2))
++  parse-hash-sha-1
  %+  cook  
    |=(hax=@ ;;(hash (rev 3 hash-bytes-sha-1 hax)))
  =*  haz  hash-size-sha-1
  (bass 16 (stun [haz haz] six:ab))
++  parse-hash-sha-256  !!
--
