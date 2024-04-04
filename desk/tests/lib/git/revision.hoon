/+  *test
/+  revision=git-revision, git-bundle, git=git-repository
::  Load test repository
::  Putting this on top result in u3R->ski.gul assertion 
::  fail in pkg/noun/manage.c:1312
:: =/  repo=repository:git
::   %-  clone:git-bundle
::     .^(bundle:git-bundle %cx /~dev/git/247/tests/lib/git/narnia/bdl)
:: ?<  ?=(~ archive.object-store.repo)
::
|%
++  to-hash-list
  |=  taps=(list tape)
  (turn taps |=(t=tape (scan t parser-sha-1:git)))
++  to-hash-list-walk
  |=  taps=(list tape)
  (turn taps |=(t=tape [(scan t parser-sha-1:git) &]))
++  to-hash-list-walk-with
  |=  taps=(list [tape ?])
  (turn taps |=([t=tape w=?] [(scan t parser-sha-1:git) w]))
++  test-walk-sort-time
  =/  repo=repository:git
    %-  clone-from-bundle:git
      .^(bundle:git-bundle %cx /~dev/git/2/tests/lib/git/narnia/bdl)
  ?<  ?=(~ archive.object-store.repo)
  ;:  weld
  ::  git rev-list master
  ::
  =/  want=(list hash:git)
      %-  to-hash-list
      :~
        "5dbb9f4e4fb73618c956c25c55363d0a06c05a2c"
      ==
  =/  commits=(list hash:git)
    %-  to-hash-list
    :~
      "5dbb9f4e4fb73618c956c25c55363d0a06c05a2c"
      "92a70cfcd68d1ce5bf1a066fce4c5a6d3fd6a7cf"
      "5a6036155584b0d56a758cc74cd2db4d94ceeec7"
      "a133b01323001c919f15212b177eae4ac03d7c61"
      "5842e636f795883ef9d5ee4b48b05579e29744cf"
      "cb4fb2000a2a71ff32e1539a42eb1e35ac40493c"
      "5d8844751a8f53b291fa13e9cda4b392e7e1c26e"
      "ca07f7fc0bca9973a2a41e68c590df01a786d41e"
      "738dddea4068c5319c3214763fce9a8639be8795"
      "35c416b48dc8828f9e9a010d3d49fb2f08e88d31"
      "c3dde4452b6aabe7724bd870d45f11c2b3a46aa0"
      "b6052d7a4c29787e5b9335a7a5d8449b96888328"
      "c3b15884747aed2af6c23f7527cf93c31a5ee586"
    ==
  %+  expect-eq
    !>  commits
    !>  (turn (walk:revision repo want ~) head)
  ::  git rev-list master ^cb4fb
  ::
  =/  want
      %-  to-hash-list
      :~
        "5dbb9f4e4fb73618c956c25c55363d0a06c05a2c"
      ==
  =/  exclude
      %-  to-hash-list
      :~
        "cb4fb2000a2a71ff32e1539a42eb1e35ac40493c"
      ==
  =/  commits=(list hash:git)
    %-  to-hash-list
    :~
      "5dbb9f4e4fb73618c956c25c55363d0a06c05a2c"
      "92a70cfcd68d1ce5bf1a066fce4c5a6d3fd6a7cf"
      "5a6036155584b0d56a758cc74cd2db4d94ceeec7"
      "a133b01323001c919f15212b177eae4ac03d7c61"
      "5842e636f795883ef9d5ee4b48b05579e29744cf"
      "5d8844751a8f53b291fa13e9cda4b392e7e1c26e"
      "ca07f7fc0bca9973a2a41e68c590df01a786d41e"
      "35c416b48dc8828f9e9a010d3d49fb2f08e88d31"
    ==
  %+  expect-eq
    !>  commits
    !>  (turn (walk:revision repo want exclude) head)
  ==
--
