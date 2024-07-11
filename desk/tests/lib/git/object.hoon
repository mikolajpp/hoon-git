/+  *test, *git, zlib
::
=/  hash-algo  %sha-1
|%
++  test-parse-blob
  ;:  weld
  ::
  =/  dat  'blob 3\00oak'
  =/  rob  (parse-raw:obj [(met 3 dat) dat])
  %+  expect-eq
  !>  [%blob [3 'oak']]
  !>  (parse:obj hat rob)
  ::
  =/  dat  'blob 3\00fir'
  =/  rob  (parse-raw:obj [(met 3 dat) dat])
  %+  expect-eq
  !>  [%blob [3 'fir']]
  !>  (parse:obj hat rob)
  ::
  =/  dat  'blob 5\00maple'
  =/  rob  (parse-raw:obj [(met 3 dat) dat])
  %+  expect-eq
  !>  [%blob [5 'maple']]
  !>  (parse:obj hat rob)
  ==
++  test-parse-commit
  ;:  weld
  ::
  =/  dat
  %-  crip:obj  %+  weld  "commit 233\00"
  """
  tree d928f280a489455d76396f38444512beedb05b50
  parent 41416ff404dcf7bb0310bfd740a3c8c4490e7807
  author Bilbo Baggins <bilbo@shire.green> 1695627855 +0800
  committer Bilbo Baggins <bilbo@shire.green> 1695627855 +0800

  Discover new trees\0a
  """
  =/  octs  [(met 3 dat) dat]
  =/  rob  (parse-raw:obj octs)
  %+  expect-eq
  !>  :-  %commit
    :-
    :*  tree=0xd928.f280.a489.455d.7639.6f38.4445.12be.edb0.5b50
        parent=~[0x4141.6ff4.04dc.f7bb.0310.bfd7.40a3.c8c4.490e.7807]
        author=[["Bilbo Baggins" "bilbo@shire.green"] [1.695.627.855 & "0800"]]
        commiter=[["Bilbo Baggins" "bilbo@shire.green"] [1.695.627.855 & "0800"]]
    ==
    "Discover new trees\0a"
  !>  (parse:obj hat rob)
  ::
  =/  dat  %-  need  %-  de:base64:mimes:html
  'dHJlZSA2OQAxMDA2NDQgUkVBRE1FLm1kAG5lqUXsvk61r72SKJgR5IWM1yhsNDAwMDAgdHJlZXMAGwbNWLyXaB6s5lJb9DTUapEoXck='
  =/  rob  (parse-raw:obj dat)
  %+  expect-eq
  !>  :-  %tree
      :~
      :-  [mode=~.40000 node=~.trees]  0x1b06.cd58.bc97.681e.ace6.525b.f434.d46a.9128.5dc9
      :-  [mode=~.100644 node='README.md']  0x6e65.a945.ecbe.4eb5.afbd.9228.9811.e485.8cd7.286c
      ==
  !>  (parse:obj hat rob)
  ==
--
