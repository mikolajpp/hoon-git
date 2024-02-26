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
+$  reference  path
::  This should be a mop. 
::  Otherwise how are we going to efficiently 
::  search for a tag?
::
+$  refs  (map reference hash)
+$  remote  [url=@t =refs]
+$  ref-spec  @t
+$  trail-spec  [remote=@tas =ref-spec]
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
--
