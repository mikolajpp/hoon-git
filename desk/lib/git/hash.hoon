::
::::  Git hash
  ::
/+  bs=bytestream
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
::  efficient object search by short hash.
::
++  hash-octs-sha-1
  |=  =octs
  ^-  @ux
  (sha-1l:sha p.octs (rev 3 octs))
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
  ((x-co:co hash-size-sha-1) hash)
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
  ^-  @t
  (cut 3 [0 len] (crip ((x-co:co 0) hash)))
++  parse-hash-sha-1
  %+  cook
    |=(hax=@ ;;(@ux hax))
  =*  haz  hash-size-sha-1
  (bass 16 (stun [haz haz] six:ab))
++  parse-hash-sha-256  !!
::  +read-hash: read hash from bytestream
::
++  read-hash
  |=  [hal=hash-algo sea=bays:bs]
  ^-  [hash bays:bs]
  (read-msb:bs (hash-bytes hal) sea)
++  read-hash-maybe
  |=  [hal=hash-algo sea=bays:bs]
  ^-  [(unit hash) bays:bs]
  (read-msb-maybe:bs (hash-bytes hal) sea)
::  +write-hash: write hash to bytestream
::
++  write-hash
  |=  [sea=bays:bs hal=hash-algo =hash]
  ^-  bays:bs
  ::  Restore LSB order
  ::
  =/  data
    =+  (hash-bytes hal)
    [- (rev 3 - hash)]
  (write-octs:bs sea data)
::  +append-hash: write hash to bytestream
::
++  append-hash
  |=  [sea=bays:bs hal=hash-algo =hash]
  ^-  bays:bs
  ::  Restore LSB order
  ::
  =/  data
    =+  (hash-bytes hal)
    [- (rev 3 - hash)]
  (append-octs:bs sea data)
--
