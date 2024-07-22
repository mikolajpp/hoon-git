/+  *test, *git-object, bs=bytestream, z=zlib
::
=+  hal=%sha-1
|%
++  test-parse-blob
  ;:  weld
  ::
  =/  dat  (as-octs:bs 'blob 3\00oak')
  =/  rob  (raw-from-octs dat)
  %+  expect-eq
  !>  :-  (txt-to-hash ~.9d880478c6219bb84e97ed6a092ce46c5ccedc60)
      [%blob size=3 (as-octs:bs 'oak')]
  !>  =/  obj  (parse-raw hal rob)
      :_  obj
      (hash-obj hal obj)
  ::
  =/  dat  (as-octs:bs 'blob 3\00fir')
  =/  rob  (raw-from-octs dat)
  %+  expect-eq
  !>  :-  (txt-to-hash ~.96b0461a6d7a15b2710c23a7fb0a4b442763a193)
      [%blob size=3 (as-octs:bs 'fir')]
  !>  =/  obj  (parse-raw hal rob)
      :_  obj
      (hash-obj hal obj)
  ::
  =/  dat  (as-octs:bs 'blob 5\00maple')
  =/  rob  (raw-from-octs dat)
  %+  expect-eq
  !>  :-  (txt-to-hash ~.2d8bbedc1fb46b86d8bcff50b6c491c330237bd8)
      [%blob size=5 (as-octs:bs 'maple')]
  !>  =/  obj  (parse-raw hal rob)
      :_  obj
      (hash-obj hal obj)
  ==
++  test-parse-tree
  ;:  weld
  ::
  =/  dat  %-  need
      (de:base64:mimes:html 'dHJlZSAzNwAxMDA2NDQgUkVBRE1FLm1kAL95WRuOpepZ7+j9i+LgSvK2czrM')
  =/  rob  (raw-from-octs dat)
  %+  expect-eq
  !>  :-  (txt-to-hash ~.47a237559adb6f5ca41621c8afcfcdb24ad4eadf)
      :-  %tree  :-  size=37
      :~  :-  name='README.md'
          :-  mode=~.100644
          (txt-to-hash ~.bf79591b8ea5ea59efe8fd8be2e04af2b6733acc)
      ==
  !>  =/  obj  (parse-raw hal rob)
      :_  obj
      (hash-obj hal obj)
  ::
  ==
--
