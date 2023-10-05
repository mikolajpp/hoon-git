/+  libmip=mip
|%
+$  hash-type
  $?  %sha-1
      %sha-256
  ==
++  default-hash  %sha-1
+$  oid
  $:  [%sha-1 hash=@ta]
  ==
+$  hash  [hash-type @ta]
::
+$  raw-object-type
  $?  %invalid
      %commit    ::  1
      %tree      ::  2
      %blob      ::  3
      %tag       ::  4
                 ::  5 is reserved
      %ofs-delta ::  6
      %ref-delta ::  7
  ==
+$  raw-object  [type=raw-object-type =byts]
+$  object-type  ?(%blob %commit %tree)
+$  object
  $%
      [%blob =byts]
      [%commit commit]
      [%tree (list tree-entry)]
  ==
+$  person  [name=tape email=tape]
+$  commit-header  $:  tree=tape
                       parent=tape
                       author=[person date=[@ud ? tape]]
                       commiter=[person date=[@ud ? tape]]
                   ==
+$  commit      $:  header=commit-header
                    message=tape
                ==
+$  tree-entry  [[mode=@ta node=@ta] hash=@ta]
+$  config-value  $%
                  [%l ?]
                  [%u @ud]
                  [%s @t]
                  ==
::
::  Pack file
::
+$  pack-header  [version=@ud count=@ud]
+$  pack  [header=pack-header objects=(list raw-object)]
::
::  XX in the byte stream library
::  we should only have a list of byts objects
::  References should be handled transparently
::  by indexing into the master store
::
+$  raw-pack-object  [=object-type =byts]
::  [section (unit subsection)]
::
+$  config-key  [@tas (unit @t)]
+$  reference   [path hash=@ta]
+$  repository
  $:  objects=(map @ta object)
      refs=(map path @ta)
      config=(mip:libmip config-key @tas config-value)
  ==
::
::  Git bundle
::
+$  bundle-header  [version=%2 reqs=(list @ta) refs=(list reference)]
+$  bundle  [header=bundle-header =pack]
::
+$  command
  $%  :: init
      [%init name=@tas]
      :: List repositories
      [%ls ~]
      :: hash-object
      [%hash-object repository=(unit @tas) type=object-type data=@]
      :: cat-file
      [%cat-file repository=@tas hash=@ta]
  ==
--
