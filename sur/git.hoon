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
+$  signature  [%gpg @t]
+$  commit-header  $:  tree=hash
                       parent=(list hash)
                       author=[person date=[@ud ? tape]]
                       committer=[person date=[@ud ? tape]]
                       sign=(unit signature)
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
::  XX different comparison functions 
::  do not throw error!
+$  pack-index   ((mop hash @ud) lth)
++  pion  ((on hash @ud) lth)
+$  pack  [=hash-type index=pack-index data=stream:libstream]
::
+$  config-value  $%  [%l ?]
                      [%u @ud]
                      [%s @t]
                  ==
::
+$  object-store  $:  loose=(map hash object)
                      archive=(list pack)
                  ==
+$  config-key  [@tas (unit @t)]
::  XX make it [hash path]
::  as it is in Git formats
::
::  XX reference should just be a path
+$  reference  path
+$  refs  (map reference hash)
+$  remote  [url=@t =refs]
+$  ref-spec  @t
+$  trail-spec [remote=@tas =ref-spec]
::  XX repository is a type 
::  parametrized by the hash-type
::
+$  repository
  $:  =hash-type
      =object-store
      =refs
      trail=(map reference trail-spec)
      remotes=(map @tas remote)
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
      [%cat-file name=@tas hash=@ta]
      [%clone name=@tas url=@t]
      [%delete name=@tas]
      [%pull name=@tas remote=@tas]
      [%list ~]
      :: hash-object
      :: [%hash-object repository=(unit @tas) type=object-type data=@]
      :: cat-file
      :: [%cat-file repository=@tas hash=@ta]
  ==
--
