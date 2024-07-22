/+  *test
/+  *git-hash
|%
++  test-parse-hash-sha-1
  ;:  weld
    ::
    %+  expect-eq
    !>  %+  scan  "16312751ef9307c3fd1afbcb993cdc80464ba0f1"
        parse-hash-sha-1
    !>  %-  hash-txt-sha-1
        'the quick brown fox jumps over the lazy dog'
    ::
    %+  expect-eq
    !>  %+  scan  "d9bf71cd4fa116691c5e17f4b0fe7778b25670ab"
        parse-hash-sha-1
    !>  (hash-txt-sha-1 'oak')

    ::
    %+  expect-eq
    !>  %+  print-short-hash  5
        %+  scan  "16312751ef9307c3fd1afbcb993cdc80464ba0f1"
        parse-hash-sha-1
    !>  '16312'
    ::
    %+  expect-eq
    !>  %+  print-short-hash  6
        %+  scan  "16312751ef9307c3fd1afbcb993cdc80464ba0f1"
        parse-hash-sha-1
    !>  '163127'
  ==
++  test-txt-to-hash
  ;:  weld
    %+  expect-eq
      !>  0xcafe.babe
      !>  (txt-to-hash ~.cafebabe)
    %+  expect-eq
      !>  0xb0.dfa9
      !>  (txt-to-hash ~.b0dfa9)
  ==
++  test-read-hash-sha-1
  =/  hash
    (txt-to-hash ~.16312751ef9307c3fd1afbcb993cdc80464ba0f1)
  =/  sea  %-  from-octs:bs
    [20 0xf1a0.4b46.80dc.3c99.cbfb.1afd.c307.93ef.5127.3116]
  %+  expect-eq
  !>  hash
  !>  -:(read-hash %sha-1 sea)
++  test-write-hash-sha-1
  =/  hash
    (txt-to-hash ~.16312751ef9307c3fd1afbcb993cdc80464ba0f1)
  =|  sea=bays:bs
  %+  expect-eq
  !>  [20 0xf1a0.4b46.80dc.3c99.cbfb.1afd.c307.93ef.5127.3116]
  !>  %-  to-octs:bs
      (write-hash sea %sha-1 hash)
++  test-append-hash-sha-1
  =/  hash
    (txt-to-hash ~.16312751ef9307c3fd1afbcb993cdc80464ba0f1)
  =|  sea=bays:bs
  %+  expect-eq
  !>  [20 0xf1a0.4b46.80dc.3c99.cbfb.1afd.c307.93ef.5127.3116]
  !>  %-  to-octs:bs
      (append-hash sea %sha-1 hash)
--
