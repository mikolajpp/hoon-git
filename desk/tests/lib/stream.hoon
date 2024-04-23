/+  *test
/+  *stream
|%
::
++  test-append-read-bytes
  ::
  =/  sea=stream  0+[2 0xcafe]
  =/  red=stream  0+[2 0xbabe]
  ::  XX is there a way to mutate two variables together?
  =^  red  sea  (append-read-bytes 1 red sea)
  =.  ^red  red
  ::
  ;:  weld
  ::
  %+  expect-eq
  !>  1+[2 [0xcafe]]
  !>  sea
  ::
  %+  expect-eq
  !>  0+[3 0xfe.babe]
  !>  red
  ::
  ==
++  test-append-get-bytes
  ::
  =/  sea=stream  0+[2 0xcafe]
  =/  red=stream  0+[2 0xbabe]
  ::  XX is there a way to mutate two variables together?
  =^  red  sea  (append-get-bytes 1 red sea)
  =.  ^red  red
  ::
  ;:  weld
  ::
  %+  expect-eq
  !>  0+[2 [0xcafe]]
  !>  sea
  ::
  %+  expect-eq
  !>  0+[3 0xfe.babe]
  !>  red
  ::
  ==
++  test-seek-byte
  =/  sea=stream  0+[4 0xbabe.cabe]
  ;:  weld
    %+  expect-eq
    !>  `2
    !>  (seek-byte 0xbe sea)
    %+  expect-eq
    !>  ~
    !>  (seek-byte 0xff sea)
  ==
--
