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
+$  raw-object  [type=object-type data=stream:libstream]
::
+$  person  [name=tape email=tape]
+$  commit-header  $:  tree=hash
                       parent=(list hash)
                       author=[person date=[@ud ? tape]]
                       committer=[person date=[@ud ? tape]]
                   ==
+$  commit      $:  header=commit-header
                    message=tape
                ==
+$  tree-entry  [[mode=@ta node=@ta] =hash]
::
+$  object
  $%  [%blob =octs]
      [%commit commit]
      [%tree (list tree-entry)]
  ==
+$  config-value  $%  [%l ?]
                      [%u @ud]
                      [%s @t]
                  ==
::
+$  raw-object-store  (map hash raw-object)
+$  object-store  (map hash object)
+$  config-key  [@tas (unit @t)]
::  XX make it [hash path]
::  as it is in Git formats
::
+$  reference   [path hash]
::  XX  Consider renaming objects -> object-store
::
+$  repository
  $:  =hash-type
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
                     [%ofs-delta pos=@ud base-offset=@ud =octs]
                     [%ref-delta =octs]
                 ==
+$  pack-delta-object  $>(?(%ofs-delta %ref-delta) pack-object)

+$  pack-header  [version=%2 count=@ud]
+$  pack-file    [header=pack-header data=stream:libstream]
::
+$  pack-index   (map hash @ud)
+$  pack  [index=pack-index data=stream:libstream]
::
::  Bundle
::
+$  bundle-header  [version=%2 hash=hash-type reqs=(list hash) refs=(list reference)]
+$  bundle  [header=bundle-header =pack]
::
::  Network protocol
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
