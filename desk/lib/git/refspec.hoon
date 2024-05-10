/+  *git-refs
|%
+$  refspec
  $:  force=_|
      exclude=_|
      pattern=_|
      hash=_|
      ::
      src=(unit refname)
      dst=(unit refname)
  ==
--
|%
++  sane-refspec
  |=  =refspec
  &
++  sane-refspec-push
  |=  =refspec
  &
++  parse-refspec  refspec:parse
++  parse
  |%
  ++  refspec
    %+  cook
      |=  [opt=(unit @t) src=(unit refname) dst=(unit refname)]
      ^-  ^refspec
      =/  force=?
        ?&(?=(^ opt) =('+' u.opt))
      =/  exclude=?
        ?&(?=(^ opt) =('^' u.opt))
      :: Negative refspecs only allow source, 
      :: which must be present.
      ::
      ?<  ?&  exclude
              ?|(?=(^ dst) ?=(~ src))
          ==
      :: XX handle hash
      :: XX detect patterns
      ::
      =|  refspec=^refspec
      %=  refspec
        force  force
        exclude  exclude
        src  src
        dst  dst
      ==
    ;~  plug
      (punt ;~(pose lus ket))  :: force '+', or exclude '^'
      (punt parse-refname)
      ;~(pfix col (punt parse-refname))
    ==
  --
--
