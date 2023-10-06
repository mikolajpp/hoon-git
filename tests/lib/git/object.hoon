/+  *test, *git, zlib
|%
::  XX In the future cords with \00 bytes
::  will likely be invalid, were atom sanity
::  be enforced
++  test-parse-raw
  ;:  weld
  ::
  =/  dat  'blob 3\00oak'
  =/  rob  (parse-raw:obj dat)
  %+  expect-eq
  !>  [%blob [3 'oak']]
  !>  (parse:obj rob)
  ::
  =/  dat  'blob 3\00fir'
  =/  rob  (parse-raw:obj dat)
  %+  expect-eq
  !>  [%blob [3 'fir']]
  !>  (parse:obj rob)
  ::
  =/  dat  'blob 5\00maple'
  =/  rob  (parse-raw:obj dat)
  %+  expect-eq
  !>  [%blob [5 'maple']]
  !>  (parse:obj rob)
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
  =/  rob  (parse-raw:obj dat)
  %+  expect-eq
  !>  :-  %commit
    :-
    :*  tree="d928f280a489455d76396f38444512beedb05b50"
        parent="41416ff404dcf7bb0310bfd740a3c8c4490e7807"
        author=[["Bilbo Baggins" "bilbo@shire.green"] [1.695.627.855 & "0800"]]
        commiter=[["Bilbo Baggins" "bilbo@shire.green"] [1.695.627.855 & "0800"]]
    ==
    "Discover new trees\0a"
  !>  (parse:obj rob)
  ::
  =/  dat  %-  need  %-  de:base64:mimes:html
  'dHJlZSA2OQAxMDA2NDQgUkVBRE1FLm1kAG5lqUXsvk61r72SKJgR5IWM1yhsNDAwMDAgdHJlZXMAGwbNWLyXaB6s5lJb9DTUapEoXck='
  =/  rob  (parse-raw:obj q.dat)
  %+  expect-eq
  !>  :-  %tree
      :~
      :-  [mode=~.40000 node=~.trees]  ~.1b06cd58bc97681eace6525bf434d46a91285dc9
      :-  [mode=~.100644 node='README.md']  ~.6e65a945ecbe4eb5afbd92289811e4858cd7286c
      ==
  !>  (parse:obj rob)
  ==
--
