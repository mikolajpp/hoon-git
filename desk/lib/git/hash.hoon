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
++  parse-sha-1
  %+  cook  
    |=(hash=@ (rev 3 hash-bytes-sha-1 hash))
  =*  haz  hash-size-sha-1
  (bass 16 (stun [haz haz] six:ab))
++  parse-sha-256  !!
--
