/+  *test
/+  *git-hash
|%
++  test-hash-sha-1
  ;:  weld
    ::
    %+  expect-eq
    !>  %+  scan  "16312751ef9307c3fd1afbcb993cdc80464ba0f1"
          parse-hash-sha-1
    !>  %-  hash-txt-sha-1
        'the quick brown fox jumps over the lazy dog'
    ::
    %+  expect-eq
    !>  %+  print-short-hash  5
        %+  scan  "16312751ef9307c3fd1afbcb993cdc80464ba0f1"
          parse-hash-sha-1
    !>  "16312"
    ::
    %+  expect-eq
    !>  %+  print-short-hash  6
        %+  scan  "16312751ef9307c3fd1afbcb993cdc80464ba0f1"
          parse-hash-sha-1
    !>  "163127"
  ==
++  test-txt-to-hash
  ;:  weld
    %+  expect-eq
      !>  0xcafe.babe
      !>  (txt-to-hash 'cafebabe')
  ==
--
