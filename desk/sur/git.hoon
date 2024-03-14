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
                       parents=(list hash)
                       author=[person date=[@ud ? tape]]
                       committer=[person date=[@ud ? tape]]
                       sign=(unit signature)
                   ==
::  XX do not face the header
::
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
--
