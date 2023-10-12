/-  libstream=stream
/+  libmip=mip
|%
+$  hash-type
  $?  %sha-256
      %sha-1
  ==
+$  hash  @ux
::
+$  object-type
  $?  %commit
      %tree
      %blob
      %tag
  ==
+$  raw-object  [type=object-type =byts]
::
+$  person  [name=tape email=tape]
+$  commit-header  $:  tree=hash
                       parent=(list hash)
                       author=[person date=[@ud ? tape]]
                       commiter=[person date=[@ud ? tape]]
                   ==
+$  commit      $:  header=commit-header
                    message=tape
                ==
+$  tree-entry  [[mode=@ta node=@ta] =hash]
::
+$  object
  $%  [%blob =byts]
      [%commit commit]
      [%tree (list tree-entry)]
  ==
+$  config-value  $%  [%l ?]
                      [%u @ud]
                      [%s @t]
                  ==
::
::  XX in the byte stream library
::  we should only have a list of byts objects
::  References should be handled transparently
::  by indexing into the master store
::
::  [section (unit subsection)]
::
+$  raw-object-store  (map hash raw-object)
+$  object-store  (map hash object)
+$  config-key  [@tas (unit @t)]
+$  reference   [path hash]
::  XX  Consider renaming objects -> object-store
::
+$  repository
  $:  hash=hash-type
      objects=object-store
      refs=(map path hash)
      config=(mip:libmip config-key @tas config-value)
  ==
::
::  Pack file
::
+$  pack-object-type  $?  object-type
                          %ofs-delta
                          %ref-delta
                      ==
+$  pack-object  $%  raw-object
                     [%ofs-delta base=@ud offset=@ud =byts]
                     [%ref-delta =byts]
                 ==
+$  pack-delta-object  $>(?(%ofs-delta %ref-delta) pack-object)

+$  pack-header  [version=%2 count=@ud]
::  Pack index - a map from offset
::  in the sea to the object id
::
+$  pack-index   (map @ud hash)
+$  pack  [header=pack-header objects=(list (pair @ud pack-object))]
::
::  Git bundle
::
+$  bundle-header  [version=%2 hash=hash-type reqs=(list hash) refs=(list reference)]
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
