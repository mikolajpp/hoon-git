/+  *test, *zlib
|%
::
++  test-bit-stream
  =/  sea  (fill:of [3 0b10.0011.1111.1010])
  ;:  weld
  ::
  %+  expect-eq
  !>  0x0
  !>  (~(bits of sea) 0)
  ::
  %+  expect-eq
  !>  0x0
  !>  (~(bits of sea) 1)
  ::
  =.  sea  (~(need-bits of sea) 4)
  %+  expect-eq
  !>  0xa
  !>  (~(bits of sea) 4)
  ::
  =.  sea  (~(need-bits of sea) 4)
  =.  sea  (~(drop-bits of sea) 3)
  %+  expect-eq
  !>  0x1
  !>  (~(bits of sea) 1)
  ::
  =.  sea  (~(need-bits of sea) 4)
  =.  sea  (~(drop-bits of sea) 3)
  %+  expect-eq
  !>  0x1
  !>  (~(bits of sea) 1)
  ::
  =.  sea  (~(need-bits of sea) 12)
  =.  sea  (~(drop-bits of sea) 10)
  %+  expect-eq
  !>  0x0
  !>  (~(bits of sea) 2)
  ::
  =.  sea  (~(need-bits of sea) 24)
  =.  sea  (~(drop-bits of sea) 16)
  %+  expect-eq
  !>  0x0
  !>  (~(bits of sea) 8)
  ==
++  test-expand
  ;:  weld
  %+  expect-eq
  =/  pak  (need (de:base64:mimes:html 'eF4LyUhVKCzNTM5WSCrKL89TSMuvUMgqzS0oVsgvSy1SKAFK5yRWVYLEAVvzD+0='))
  =/  dat  'The quick brown fox jumps over the lazy fox'
  ~&  pak+pak
  =/  mak  (expand [0 pak])
  ~&  mak+mak
  !>  0xff
  !>  0xff
  ==
--
