/+  *test
/+  *bytestream
|%
++  test-convert
  ;:  weld
    ::
    %+  expect-eq
    !>  [0 [4 0xcafe.babe]]
    !>  (from-octs [4 0xcafe.babe])
    ::
    %+  expect-eq
    !>  [4 0xcafe.babe]
    !>  (to-octs (from-octs [4 0xcafe.babe]))
    ::
    %+  expect-eq
    !>  [pos=2 [4 0xcafe.babe]]
    !>  (at-octs 2 [4 0xcafe.babe])
  ==
++  test-status
  ;:  weld
    ::
    %+  expect-eq
    !>  &
    !>  (is-empty 2+[2 0xcafe])
    ::
    %+  expect-eq
    !>  |
    !>  (is-empty 0+[2 0xcafe])
  ==
++  test-read-byte
  =/  sea=bays
    (from-octs [3 0xca.babe])
  =^  bar  sea  (read-byte-maybe sea)
  =^  bas  sea  (read-byte sea)
  =^  bat  sea  (read-byte sea)
  =^  bau  sea  (read-byte-maybe sea)
  ::
  ;:  weld
    %+  expect-eq
    !>  `0xbe
    !>  bar
    ::
    %+  expect-eq
    !>  0xba
    !>  bas
    ::
    %+  expect-eq
    !>  0xca
    !>  bat
    ::
    %+  expect-eq
    !>  ~
    !>  bau
    ::
    %+  expect-eq
    !>  3
    !>  pos.sea
    ::
    %+  expect-eq
    !>  &
    !>  (is-empty sea)
  ==
++  test-read-octs
  =/  sea=bays
    (from-octs [4 0xcafe.babe])
  ;:  weld
    %+  expect-eq
    !>  :_  sea(pos 2)
        [2 0xbabe]
    !>  (read-octs 2 sea)
    ::
    %+  expect-eq
    !>  [~ sea]
    !>  (read-octs-maybe 5 sea)
    ::
    %+  expect-eq
    !>  [3 0xfe.babe]
    !>  (peek-octs 3 sea)
  ==
++  test-read-line
  =/  sea=bays
    (from-octs (as-octs:mimes:html 'river\0anile\0atail'))
  =^  kin  sea  (read-line sea)
  =^  lin  sea  (read-line sea)
  =/  min  (peek-line sea)
  ::
  ;:  weld
    ::
    %+  expect-eq
    !>  'river'
    !>  kin
    ::
    %+  expect-eq
    !>  'nile'
    !>  lin
    ::
    %+  expect-eq
    !>  'tail'
    !>  min
    ::
    %+  expect-eq
    !>  11
    !>  pos.sea
  ==
++  test-write-txt
  =/  sea=bays
    %-  from-txt
    'the quick fox'
  =.  sea  (skip-by 4 sea)
  =.  sea  (write-txt sea 'lucky')
  %+  expect-eq
  !>  'the lucky fox'
  !>  `@t`q:(to-octs sea)
++  test-write-byte
  =/  sea=bays
    (from-octs [2 0xbabe])
  =.  sea  (skip-by 2 sea)
  =.  sea  (write-byte sea 0xfe)
  =.  sea  (write-byte sea 0xca)
  ::
  %+  expect-eq
  !>  (at-octs 4 [4 0xcafe.babe])
  !>  sea
++  test-write-octs
  =/  sea=bays
    (from-octs [2 0xbabe])
  =.  sea  (write-byte sea 0xfe)
  =.  sea  (skip-byte sea)
  =.  sea  (write-octs sea [2 0xcafe])
  ::
  %+  expect-eq
  !>  [5 0xcafe.bafe]
  !>  (to-octs sea)
++  test-append-octs
  =/  sea=bays
    (from-octs [2 0xbabe])
  =.  sea  (append-octs sea [2 0xcafe])
  =^  cos  sea  (read-octs 2 sea)
  =^  cot  sea  (read-octs 2 sea)
  ::
  ;:  weld
    %+  expect-eq
    !>  [4 0xcafe.babe]
    !>  (to-octs sea)
    ::
    %+  expect-eq
    !>  [2 0xbabe]
    !>  cos
    ::
    %+  expect-eq
    !>  [2 0xcafe]
    !>  cot
  ==
++  test-append-txt
  =/  sea=bays
    (from-txt 'the lazy fox')
  =.  sea  (append-txt sea ' jumped over')
  =.  sea  (append-txt sea ' the lazy dog')
  %+  expect-eq
  !>  'the lazy fox jumped over the lazy dog'
  !>  (to-txt sea)
++  test-write-read-byte
  =/  sea=bays
    (from-octs [2 0xcafe])
  =/  red=bays
    (from-octs [1 0xfe])
  =.  red  (skip-byte red)
  =^  red  sea  (write-read-byte red sea)
  ::
  ;:  weld
    %+  expect-eq
    !>  1
    !>  pos.sea
    ::
    %+  expect-eq
    !>  2
    !>  pos.red
    ::
    %+  expect-eq
    !>  [2 0xfefe]
    !>  (to-octs red)
  ==
++  test-write-read-octs
  =/  sea=bays
    (from-txt 'lazy fox')
  =/  red=bays
    (from-txt 'the fox')
  =.  red  (skip-by 4 red)
  =^  red  sea  (write-read-octs red sea 8)
  ::
  %+  expect-eq
  !>  'the lazy fox'
  !>  (to-txt red)
++  test-write-read-line
  =/  sea=bays
    (from-txt 'first line\0asecond line\0a')
  =/  red=bays
    (from-txt 'this is ')
  =.  red  (skip-by 8 red)
  =^  red  sea  (write-read-line red sea)
  ::
  ;:  weld
    %+  expect-eq
    !>  11
    !>  pos.sea
    ::
    %+  expect-eq
    !>  'this is first line\0a'
    !>  (to-txt red)
  ==
++  test-write-peek-byte
  =/  sea=bays
    (from-octs [2 0xcafe])
  =|  red=bays
  =.  red  (write-peek-byte red sea)
  ::
  %+  expect-eq
    !>  [1 0xfe]
    !>  (to-octs red)
++  test-write-peek-octs
  =/  sea=bays
    (from-txt 'lazy fox')
  =/  red=bays
    (from-txt 'the fox')
  =.  red  (write-peek-octs red sea 4)
  ::
  %+  expect-eq
    !>  'lazyfox'
    !>  (to-txt red)
++  test-write-peek-line
  =/  sea=bays
    (from-txt 'first line\0asecond line\0a')
  =/  red=bays
    (from-txt 'this is ')
  =.  red  (skip-by 8 red)
  =.  red  (write-peek-line red sea)
  ::
  %+  expect-eq
  !>  'this is first line\0a'
  !>  (to-txt red)
++  test-append-read-byte
  =/  sea=bays
    (from-octs [2 0xcafe])
  =/  red=bays
    (from-octs [1 0xba])
  =^  red  sea  (append-read-byte red sea)
  ::
  ;:  weld
    %+  expect-eq
    !>  1
    !>  pos.sea
    ::
    %+  expect-eq
    !>  0
    !>  pos.red
    ::
    %+  expect-eq
    !>  [2 0xfeba]
    !>  (to-octs red)
  ==
++  test-append-read-octs
  =/  sea=bays
    (from-txt 'lazy fox')
  =/  red=bays
    (from-txt 'the fox ')
  =^  red  sea  (append-read-octs red sea 8)
  ::
  ;:  weld
    %+  expect-eq
    !>  8
    !>  pos.sea
    ::
    %+  expect-eq
    !>  0
    !>  pos.red
    ::
    %+  expect-eq
    !>  'the fox lazy fox'
    !>  (to-txt red)
  ==
++  test-append-read-line
  =/  sea=bays
    (from-txt 'first line\0asecond line\0a')
  =/  red=bays
    (from-txt 'this is ')
  =^  red  sea  (append-read-line red sea)
  ::
  ;:  weld
    %+  expect-eq
    !>  11
    !>  pos.sea
    ::
    %+  expect-eq
    !>  0
    !>  pos.red
    ::
    %+  expect-eq
    !>  'this is first line\0a'
    !>  (to-txt red)
  ==
++  test-append-peek-byte
  =/  sea=bays
    (from-octs [2 0xcafe])
  =/  red=bays
    (from-octs [1 0xba])
  =.  red  (append-peek-byte red sea)
  ::
  ;:  weld
    %+  expect-eq
    !>  0
    !>  pos.sea
    ::
    %+  expect-eq
    !>  0
    !>  pos.red
    ::
    %+  expect-eq
    !>  [2 0xfeba]
    !>  (to-octs red)
  ==
++  test-append-peek-octs
  =/  sea=bays
    (from-txt 'lazy fox')
  =/  red=bays
    (from-txt 'the fox ')
  =.  red  (append-peek-octs red sea 8)
  ::
  ;:  weld
    %+  expect-eq
    !>  0
    !>  pos.sea
    ::
    %+  expect-eq
    !>  0
    !>  pos.red
    ::
    %+  expect-eq
    !>  'the fox lazy fox'
    !>  (to-txt red)
  ==
++  test-append-peek-line
  =/  sea=bays
    (from-txt 'first line\0asecond line\0a')
  =/  red=bays
    (from-txt 'this is ')
  =.  red  (append-peek-line red sea)
  ::
  ;:  weld
    %+  expect-eq
    !>  0 
    !>  pos.sea
    ::
    %+  expect-eq
    !>  0
    !>  pos.red
    ::
    %+  expect-eq
    !>  'this is first line\0a'
    !>  (to-txt red)
  ==
++  test-navigate-byte
  =/  sea=bays
    (from-octs [4 0xcafe.babe])
  ::
  ;:  weld
    %+  expect-eq
    !>  0xfe
    !>  %-  peek-byte
      (skip-byte (skip-byte sea))
    ::
    %+  expect-eq
    !>  0xca
    !>  (peek-byte (skip-by 3 sea))
    ::
    %+  expect-eq
    !>  0xba
    !>  %-  peek-byte
      (back-by 2 (skip-by 3 sea))
    ::
    %-  expect-fail
    |.  (skip-by 5 sea)
    ::
    %-  expect-fail
    |.  (back-by 1 sea)
  ==
++  test-navigate-line
  =/  sea=bays
    (from-txt '\0asecond line\0athird line\0a')
  ::
  ;:  weld
    =.  sea  (skip-line (skip-byte sea))
    %+  expect-eq
    !>  'third line'
    !>  (peek-line sea)
    ::
    =.  sea  (skip-by 4 sea)
    =.  sea  (rewind-line sea)
    %+  expect-eq
    !>  'second line'
    !>  (peek-line sea)
    ::
    =.  sea  (skip-by 4 (skip-line sea))
    =.  sea  (back-line sea)
    %+  expect-eq
    !>  ''
    !>  (peek-line sea)
    ::
  ==
++  test-find-and-seek-byte
  =/  sea=bays
    (from-octs [4 0xcafe.babe])
  ;:  weld
    %+  expect-eq
    !>  `2
    !>  (find-byte 0xfe sea)
    ::
    %+  expect-eq
    !>  `3
    !>  (find-byte 0xca sea)
    ::
    %+  expect-eq
    !>  ~
    !>  (find-byte 0xff sea)
    ::
    =^  idx  sea  (seek-byte 0xba sea)
    %+  expect-eq
    !>  1
    !>  pos.sea
  ==
  ++  test-extract
    =/  sea=bays
      (from-octs [4 0xcafe.babe])
    ;:  weld
      ::  extract odd bytes
      ::
      %+  expect-eq
      !>  ~[[1 0xba] [1 0xca]]
      !>  =<  -  %+  extract  sea
          |=  sea=bays
          [1 1]  :: [offset length]
      ::  extract even bytes
      ::
      %+  expect-eq
      !>  ~[[1 0xbe] [1 0xfe]]
      !>  =<  -  %+  extract  sea
          |=  sea=bays
          ?:  =(0 (mod pos.sea 2))
            [0 1]
          [1 0]
      ::  extract first 2 bytes
      ::
      %+  expect-eq
      !>  ~[[2 0xbabe]]
      !>  =<  -  %+  extract  sea
          |=  sea=bays
          ?:  =(0 pos.sea)
            [0 2]
          [0 0]
    ==
  ++  test-fuse-extract
    =/  sea=bays
      (from-octs [4 0xcafe.babe])
    ;:  weld
      ::
      %+  expect-eq
      !>  [2 0xcaba]
      !>  =<  -  %+  fuse-extract  sea
          |=  sea=bays
          [1 1]  :: [offset length]
      ::
      %+  expect-eq
      !>  [2 0xfebe]
      !>  =<  -  %+  fuse-extract  sea
          |=  sea=bays
          ?:  =(0 (mod pos.sea 2))
            [0 1]
          [1 0]
    ==
  ++  test-split
    =/  sea=bays
      (from-octs [4 0xcafe.babe])
    ;:  weld
      ::  split into byte chunks
      ::
      %+  expect-eq
      !>  ~[[1 0xbe] [1 0xba] [1 0xfe] [1 0xca]]
      !>  =<  -  %+  split  sea
          |=(sea=bays 1)
      ::  split by two bytes
      ::
      %+  expect-eq
      !>  ~[[2 0xbabe] [2 0xcafe]]
      !>  =<  -  %+  split  sea
          |=(sea=bays 2)
      ::  split by three bytes
      ::
      %+  expect-eq
      !>  ~[[3 0xfe.babe]]
      !>  =<  -  %+  split  sea
          |=  sea=bays
          ?:  (lth (in-size sea) 3)
            0
          3
    ==
--

