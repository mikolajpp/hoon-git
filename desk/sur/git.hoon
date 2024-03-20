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
::  XX do not face the header
::
+$  commit      $:  commit-header
                    message=tape
                ==
+$  tree-entry  [[mode=@ta name=@ta] =hash]
+$  tree  (list tree-entry)
::
+$  object
  $%  [%blob size=@ud =octs]
      [%commit size=@ud =commit]
      [%tree size=@ud =tree]
  ==
--
