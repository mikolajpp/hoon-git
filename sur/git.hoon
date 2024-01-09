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
+$  repository
  $:  =hash-type
      =object-store
      archive=(list pack)
      refs=(map path hash)
      config=(mip:libmip config-key @tas config-value)
  ==
::
::  Bundle
::
+$  bundle-header  [version=%2 hash=hash-type reqs=(list hash) refs=(list reference)]
+$  bundle  [header=bundle-header =pack]
::
::  Agent commands
::
+$  command
  $%  [%init name=@tas]
      [%clone name=@tas url=@t]
      [%list ~]
      [%delete name=@tas]
      :: hash-object
      :: [%hash-object repository=(unit @tas) type=object-type data=@]
      :: cat-file
      :: [%cat-file repository=@tas hash=@ta]
  ==
--
