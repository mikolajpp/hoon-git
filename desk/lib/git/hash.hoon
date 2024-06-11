::
::::  Git hash
  ::
|%
+$  hash-algo
  $?  %sha-256
      %sha-1
  ==
+$  hash  @ux
--
::
|%
++  hash-bytes-sha-1  20
++  hash-bytes-sha-256  !!
++  hash-size-sha-1  ^~((mul 2 hash-bytes-sha-1))
++  hash-size-sha-256  ^~((mul 2 hash-bytes-sha-256))
::    +hash-bytes
::  determine the corresponding hash size in bytes
::
++  hash-bytes
  |=  hal=hash-algo
  ?-  hal
    %sha-1    hash-bytes-sha-1
    %sha-256  hash-bytes-sha-256
  ==
::    +hash-size
::  determine the corresponding hash size in hex
::
++  hash-size
  |=  hal=hash-algo
  ?-  hal
    %sha-1    hash-size-sha-1
    %sha-256  hash-size-sha-256
  ==
::    +as-hash
::  convert hexadecimal cord to hash
::
++  as-hash
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
:: ++  match-key
::   |=  [kes=@ud a=octs b=@ux]
::   ^-  ?
::   ?:  =(a b)
::     &
::   ::  size in half-bytes
::   ::
::   .=  q.a
::   %+  cut  2
::     :_  b
::     [(sub kes p.a) p.a]
::    +print-sha-1
::  print hash as tape
++  print-sha-1
  |=  =hash
  ^-  tape
  ((x-co:co hash-size-sha-1) (rev 3 hash-bytes-sha-1 hash))
++  hex-dit
  |=  c=@C
  ?:  (lth c 0xa)
    (add '0' c)
  ?<  (gth c 0xf)
  (add 'a' (sub c 0xa))
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
++  parse-sha-1
  %+  cook  
    |=(hash=@ (rev 3 hash-bytes-sha-1 hash))
  =*  haz  hash-size-sha-1
  (bass 16 (stun [haz haz] six:ab))
++  parse-short-sha-1
  %+  cook  
    ::  XX works only with even hash keys
    |=(hash=@ (rev 3 (met 3 hash) hash))
  =*  haz  hash-size-sha-1
  (bass 16 (stun [4 haz] six:ab))
++  parse-sha-256  !!
--
