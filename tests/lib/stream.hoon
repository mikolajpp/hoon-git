/+  *test
/+  *stream
|%
::
++  test-append-read-bytes
  ::
  =+  sea=[0 [2 0xcafe]]
  =+  red=[0 [2 0xbabe]]
  ::  XX is there a way to mutate two variables together?
  =^  red  sea  (append-read-bytes 1 red sea)
  =.  ^red  red
  ::
  ;:  weld
  ::
  %+  expect-eq
  !>  [1 [2 [0xcafe]]]
  !>  sea
  ::
  %+  expect-eq
  !>  [0 [3 0xfe.babe]]
  !>  red
  ::
  ==
--
