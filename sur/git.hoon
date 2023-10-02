|%
+$  hash-type
  $?  %sha-1
      %sha-256
  ==
++  default-hash  %sha-1
+$  hash  [hash-type @ta]
::
:: libgit2/oid.h
::
+$  oid
  $:  [%sha-1 hash=@ta]
  ==
::
:: libgit2/types.h
::
+$  object-type
  $?  %any       :: -2
      %invalid   :: -1
      %commit    ::  1
      %tree      ::  2
      %blob      ::  3
      %tag       ::  4
                 ::  5 is reserved
      %ofs-delta ::  6
      %ref-delta ::  7
  ==
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
