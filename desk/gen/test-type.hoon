::
::  Test an unexpected compiler behaviour
::  regarding union atom/cell type and an ?> assertion.
::
::  - When run with data+*octs, the code runs
::  - When run with %flush (or any other pkt-line atom),
::  at the last line in +get-pkt-line-octs
::
::  The expected behaviour would be to crash at the 
::  ?> assertion. After all, after that line the compiler 
::  should guarantee that: 
::  1. +2 exists in pkt
::  2. ?=(%data -.pkt) exists
::
::  Instead, get-pkt-line-octs receives a pkt, 
::  which passes through the mold filter and only 
::  crashes when trying to find octs.pkt.
::
::  The behaviour of ?> is to be contrasted with
::  ?:  ?=(%data -.pkt)
::  which at least results in mint-vain error.
::
=<
|=  pkt=pkt-line
^-  (unit octs)
::
::  When replaced by a ?: conditional, 
::  ?=(%data -.pkt) throws a mint-vain 
::  compilation error
::
?>  ?=(%data -.pkt)
`(get-pkt-line-octs pkt)
::
|%
+$  pkt-line  $@  $?(%flush %delim %end)
                  [%data =octs]
++  get-pkt-line-octs 
  |=  pkt=$>(%data pkt-line)
  ^-  octs
  octs.pkt
--
