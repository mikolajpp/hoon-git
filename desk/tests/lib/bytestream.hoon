::
::  You can't NOT test!
::    ~winter-paches
::
/+  *test
/+  *bytestream
|%
++  test-rip-octs
  ;:  weld
    %+  expect-eq
    !>  ~
    !>  (rip-octs [0 0])
    ::
    %+  expect-eq
    !>  ~
    !>  (rip-octs [0 0xcafe])
    ::
    %+  expect-eq
    !>  ~[0xab]
    !>  (rip-octs [1 0xab])
    ::
    %+  expect-eq
    !>  ~[0xbe 0xba]
    !>  (rip-octs [2 0xcafe.babe])
    ::
    %+  expect-eq
    !>  ~[0xbe 0xba 0xfe 0xca]
    !>  (rip-octs [4 0xcafe.babe])
    ::
    %+  expect-eq
    !>  ~[0xbe 0xba 0xfe]
    !>  (rip-octs [3 0xcafe.babe])
    ::
    %+  expect-eq
    !>  ~[0xbe 0x0 0x0 0x0]
    !>  (rip-octs [4 0xbe])
  ==
++  test-cat-octs
  ;:  weld
    %+  expect-eq
    !>  [8 0xfade.bade.cafe.babe]
    !>  %+  cat-octs
        [4 0xcafe.babe]
        [4 0xfade.bade]
    ::
    %+  expect-eq
    !>  [6 0xfade.bade.babe]
    !>  %+  cat-octs
        [2 0xcafe.babe]
        [4 0xfade.bade]
    ::
    %+  expect-eq
    !>  [6 0xbade.cafe.babe]
    !>  %+  cat-octs
        [4 0xcafe.babe]
        [2 0xfade.bade]
    ::
    %+  expect-eq
    !>  [6 0xfade.bade.00be]
    !>  %+  cat-octs
        [2 0xbe]
        [4 0xfade.bade]
    ::
    %+  expect-eq
    !>  [6 0xbade.babe]
    !>  %+  cat-octs
        [2 0xcafe.babe]
        [4 0xbade]
    ::
    %+  expect-eq
    !>  [2 [0xcafe]]
    !>  (cat-octs [0 0] [2 0xcafe])
    ::
    %+  expect-eq
    !>  [2 [0xcafe]]
    !>  (cat-octs [2 0xcafe] [0 0])
    ::
    %+  expect-eq
    !>  [0 0]
    !>  (cat-octs [0 0] [0 0])
  ==
++  test-can-octs
  ;:  weld
    ::
    %+  expect-eq
    !>  [0 0]
    !>  (can-octs ~)
    ::
    %+  expect-eq
    !>  [8 0xfade.bade.cafe.babe]
    !>  %-  can-octs
      :~  [2 0xbabe]
          [1 0xfe]
          [3 0xba.deca]
          [2 0xfade]
      ==
    ::
    %+  expect-eq
    !>  [8 0xfade.bade.cafe.babe]
    !>  %-  can-octs
      :~  [1 0xbabe]
          [2 0xfeba]
          [2 0xba.deca]
          [3 0xfa.deba]
      ==
    ::
    %+  expect-eq
    !>  [8 0x0]
    !>  %-  can-octs
      :~  [6 0x0]
          [2 0x0]
      ==
    ::
    %+  expect-eq
    !>  [10 0xfade.bade.cafe.babe]
    !>  %-  can-octs
      :~  [1 0xbabe]
          [2 0xfeba]
          [2 0xba.deca]
          [5 0xfa.deba]
      ==
    ::
    %+  expect-eq
    !>  [8 0xde.cafe.babe]
    !>  %-  can-octs
      :~  [1 0xbabe]
          [2 0xfeba]
          [2 0xba.deca]
          [3 0x0]
      ==
  ==
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
  =/  sea=bays
    (from-octs [4 0xcafe.babe])
  ;:  weld
    ::
    %+  expect-eq
    !>  &
    !>  (is-empty (at-octs 2 [2 0xcafe]))
    ::
    %+  expect-eq
    !>  |
    !>  (is-empty (from-octs [2 0xcafe]))
    ::
    %+  expect-eq
    !>  4
    !>  (in-size sea)
    ::
    %+  expect-eq
    !>  0
    !>  (out-size sea)
    ::
    %+  expect-eq
    !>  1
    !>  (in-size (skip-by 3 sea))
    ::
    %+  expect-eq
    !>  3
    !>  (out-size (skip-by 3 sea))
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
    ::
    %-  expect-fail
    |.((read-byte sea))
  ==
++  test-read-octs
  =/  sea=bays
    (from-octs [4 0xcafe.babe])
  =/  tea=bays
    (from-octs [4 0xbabe])
  ;:  weld
    ::
    %+  expect-eq
    !>  [0 0]
    !>  -:(read-octs 0 sea)
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
    ::
    %+  expect-eq
    !>  :_  sea(pos 3)
        [3 0xfe.babe]
    !>  (read-octs-until 3 sea)
    ::
    %+  expect-eq
    !>  [3 0xfe.babe]
    !>  (peek-octs-until 3 sea)
    ::
    %+  expect-eq
    !>  :_  sea(pos 3)
        [1 0xfe]
    !>  (read-octs-until 3 (skip-by 2 sea))
    ::
    %+  expect-eq
    !>  [1 0xfe]
    !>  (peek-octs-until 3 (skip-by 2 sea))
    ::
    %+  expect-eq
    !>  :_  sea(pos 4)
        [3 0xca.feba]
    !>  (read-octs-end (skip-by 1 sea))
    ::
    %+  expect-eq
    !>  [3 0xbabe]
    !>  -:(read-octs 3 tea)
    ::
    %+  expect-eq
    !>  [4 0xbabe]
    !>  -:(read-octs 4 tea)
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
++  test-find-byte
  =/  sea=bays
    %-  skip-byte
    (from-octs [4 0xcafe.babe])
  ;:  weld
    %+  expect-eq
    !>  ~
    !>  (find-byte 0xbe sea)
    ::
    %+  expect-eq
    !>  `1
    !>  (find-byte 0xba sea)
    ::
    %+  expect-eq
    !>  `2
    !>  (find-byte 0xfe sea)
    ::
    %+  expect-eq
    !>  ~
    !>  (find-byte 0xff sea)
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
    (from-txt 'the quick fox')
  =.  sea  (append-txt sea ' jumped over')
  =.  sea  (append-txt sea ' the lazy dog')
  %+  expect-eq
  !>  'the quick fox jumped over the lazy dog'
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
++  test-skip-line
  =/  sea=bays
    (from-txt '\0athird line\0afourth line\0a')
  ;:  weld
    ::
    %+  expect-eq
    !>  ''
    !>  (peek-line sea)
    ::
    %+  expect-eq
    !>  'third line'
    !>  (peek-line (skip-line sea))
    ::
    %+  expect-eq
    !>  'fourth line'
    !>  (peek-line (skip-line (skip-byte sea)))
    ::
    %+  expect-eq
    !>  3
    !>  pos:(skip-line (from-octs (as-octs 'abc')))
  ==
++  test-find-seek-byte
  =/  sea=bays
    (from-octs [5 0xcafe.babe])
  =/  tea=bays
    (from-octs [2 0xcafe.babe])
  ;:  weld
    ::
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
    %+  expect-eq
    !>  `4
    !>  (find-byte 0x0 sea)
    ::
    =^  idx  sea  (seek-byte 0xba sea)
    %+  expect-eq
    !>  [`1 1]
    !>  [idx pos.sea]
    ::
    =^  idx  sea  (seek-byte 0x0 sea)
    %+  expect-eq
    !>  [`4 4]
    !>  [idx pos.sea]
    ::
    %+  expect-eq
    !>  ~
    !>  (find-byte 0xca tea)
    ::
    %+  expect-eq
    !>  ~
    !>  (find-byte 0xfe tea)
    ::
    =^  idx  tea  (seek-byte 0xfe tea)
    %+  expect-eq
    !>  [~ 0]
    !>  [idx pos.tea]
    
  ==
  ++  test-chunk
    =/  sea=bays
      (from-octs [8 0xcafe.babe.fade])
    =.  sea  (skip-by 2 sea)
    ::
    ;:  weld
      %+  expect-eq
      !>  ~[[2 0xbabe] [2 0xcafe] [2 0]] 
      !>  (chunk 2 sea)
      ::
      %+  expect-eq
      !>  ~[[3 0xfe.babe] [3 0xca]]
      !>  (chunk 3 sea)
      ::
      %+  expect-eq
      !>  ~
      !>  (chunk 0 sea)
    ==
  ++  test-extract
    =/  sea=bays
      (from-octs [6 0xcafe.babe])
    ;:  weld
      ::  extract odd bytes
      ::
      %+  expect-eq
      !>  ~[[1 0xba] [1 0xca] [1 0]]
      !>  =<  -  %+  extract  sea
          |=  sea=bays
          [1 1]  :: [offset length]
      ::  extract even bytes
      ::
      %+  expect-eq
      !>  ~[[1 0xbe] [1 0xfe] [1 0]]
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
      (from-octs [6 0xcafe.babe])
    ;:  weld
      ::
      %+  expect-eq
      !>  [3 0xcaba]
      !>  =<  -  %+  fuse-extract  sea
          |=  sea=bays
          [1 1]  :: [offset length]
      ::
      %+  expect-eq
      !>  [3 0xfebe]
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
++  test-bitstream
  =/  pea
    (bits-from-bays (from-octs [2 0b1101.0011.1101.1010]))
  ;:  weld
    ::
    %+  expect-eq
    !>  pea
    !>  (need-bits 0 pea)
    ::
    %+  expect-eq
    !>  pea
    !>  (drop-bits 0 pea)
    ::
    %+  expect-eq
    !>  8
    !>  num:(need-bits 8 pea)
    ::
    %+  expect-eq
    !>  8
    !>  num:(need-bits 3 pea)
    ::
    %+  expect-eq
    !>  0b0
    !>  (peek-bits 1 (need-bits 1 pea))
    ::
    %+  expect-eq
    !>  0b10
    !>  (peek-bits 2 (need-bits 2 pea))
    ::
    %+  expect-eq
    !>  0b10
    !>  (peek-bits 3 (need-bits 3 pea))
    ::
    %+  expect-eq
    !>  0b1101.1010
    !>  (peek-bits 8 (need-bits 8 pea))
    ::
    =.  pea  (need-bits 8 pea)
    =.  pea  (drop-bits 3 pea)
    %+  expect-eq
    !>  0b1.1011
    !>  (peek-bits 5 pea)
    ::
    =.  pea  (need-bits 8 pea)
    =.  pea  (drop-bits 7 pea)
    =.  pea  (need-bits 5 pea)
    =^  bits-1  pea  (read-bits 3 pea)
    =^  bits-2  pea  (read-bits 2 pea)
    %+  expect-eq
    !>  [0b111 0b0]
    !>  [bits-1 bits-2]
    ::
    =.  pea  (need-bits 10 pea)
    =.  pea  (byte-bits pea)
    %+  expect-eq
    !>  0b1101.1010
    !>  (peek-bits 8 pea)
  ==
--

