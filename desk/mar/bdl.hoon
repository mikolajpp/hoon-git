::
:::: Git bundle mark 
  ::
/?  310
/+  bs=bytestream
/+  git-bundle
!:
|_  =bundle:git-bundle
++  grab  
  |%
  ++  noun  bundle:git-bundle
  ++  mime  
    |=  m=(pair mite octs) 
    ^-  bundle:git-bundle 
    (read:git-bundle (from-octs:bs q.m))
  --
++  grow  
  |%
  ::  XX implement bundle saving
  ::
  ++  mime  ^-(^mime [/text/plain *octs])
  --
++  grad  %noun
--
