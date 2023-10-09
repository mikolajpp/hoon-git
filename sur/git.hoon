/+  libmip=mip
|%
+$  hash-type
  $?  %sha-256
      %sha-1
  ==
+$  hash  [hash-type @ux]
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
+$  commit-header  $:  tree=@ux
                       parent=@ux
                       author=[person date=[@ud ? tape]]
                       commiter=[person date=[@ud ? tape]]
                   ==
+$  commit      $:  header=commit-header
                    message=tape
                ==
+$  tree-entry  [[mode=@ta node=@ta] hash=@ux]
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
+$  reference   [path @ux]
+$  repository
  $:  hash=hash-type
      objects=(map @ux object)
      refs=(map path @ux)
      config=(mip:libmip config-key @tas config-value)
  ==
::
::  Git bundle
::
+$  bundle-header  [version=%2 hash=hash-type reqs=(list @ux) refs=(list reference)]
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
