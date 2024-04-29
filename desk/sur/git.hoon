/-  libstream=stream
/+  libmip=mip
|%
::  XX rename to hash-algo
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
+$  object-header  [type=object-type size=@ud]
+$  raw-object  [type=object-type size=@ud data=stream:libstream]
::
+$  person  [name=tape email=tape]
+$  signature  [%gpg @t]
+$  commit-header  $:  tree=hash
                       parents=(list hash)
                       author=[person date=[@ud ? tape]]
                       committer=[person date=[@ud ? tape]]
                       sign=(unit signature)
                   ==
+$  commit  $+  commit
            $:  commit-header
                message=tape
            ==
::  XX refactor to [mode name hash]
::
+$  tree-entry  [[mode=@ta name=@ta] =hash]
+$  tree  $+(tree (list tree-entry))
::  XX refactor objects so that fields are readily accessible
::  XX are sizes here really necessary?
::
+$  object
  $%  [%blob size=@ud =octs]
      [%commit size=@ud =commit]
      [%tree size=@ud =tree]
  ==
--
