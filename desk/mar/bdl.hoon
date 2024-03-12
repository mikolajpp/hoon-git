::
:::: Git bundle mark 
  ::
/?  310
/+  git-bundle
!:
|_  =bundle:git-bundle
++  grab  
  |%
  ++  noun  bundle:git-bundle
  ++  mime  
    |=  m=(pair mite octs) 
    ^-  bundle:git-bundle 
    =<(- (read:git-bundle 0+q.m))
  --
++  grow  
  |%
  ::  XX implement bundle saving
  ::
  ++  mime  ^-(^mime [/text/plain *octs])
  --
++  grad  %noun
--
