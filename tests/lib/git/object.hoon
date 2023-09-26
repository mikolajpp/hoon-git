/+  *test, *git
|%
++  test-parse-raw
  ;:  weld
  ::
  %+  expect-eq
  !>  [%blob 'oak']
  =/  dat  (need (de:base64:mimes:html 'YmxvYiAzAG9haw=='))
  !>  (parse-raw:of q.dat)
  ::
  %+  expect-eq
  !>  [%blob 'fir']
  =/  dat  (need (de:base64:mimes:html 'YmxvYiAzAGZpcg=='))
  !>  (parse-raw:of q.dat)
  ::
  %+  expect-eq
  !>  [%blob 'maple']
  =/  dat  (need (de:base64:mimes:html 'YmxvYiA1AG1hcGxl'))
  !>  (parse-raw:of q.dat)
  ==
--
:: Dumping object 9d880478c6219bb84e97ed6a092ce46c5ccedc60
:: Raw content:  b'YmxvYiAzAG9haw=='
:: Content:  b'oak'

:: Dumping object 96b0461a6d7a15b2710c23a7fb0a4b442763a193
:: Raw content:  b'YmxvYiAzAGZpcg=='
:: Content:  b'fir'

:: Dumping object 2d8bbedc1fb46b86d8bcff50b6c491c330237bd8
:: Raw content:  b'YmxvYiA1AG1hcGxl'
:: Content:  b'maple'
