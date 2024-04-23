/-  *git
|%
+$  refname  (list @t)
+$  ref  $@(hash [%symref =refname])
::  XX Can you use an axal with ref-path instead 
::  of path from the aura typesystem 
::  point of view?
::
+$  refs  (axal ref)
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
++  parse
  |%
  ::  Invalid characters
  ::  ':', '?', '[', '\', '^', '~', ' ', '/'
  ::
  ++  except
    ;~  pose
      col  wut
      sel  bas
      ket  sig
      ace  fas
    ==
  ++  char
    ;~  less
      except
      ;~(plug dot dot)  :: disallow ".."
      ;~(plug pat kel)  :: disallow "@{"
      prn
    ==
  ++  segment
    %+  cook  crip
    ;~  plug
      ;~  less
        dot  :: disallow initial '.'
        char
      ==
      (star char)
    ==
  ++  refname  
    %+  cook
      |=  =^refname
      ?>  (sane refname)
      refname
    ;~  less
      pat
      ;~(plug segment (star ;~(pfix fas segment)))
    ==
  ++  refname-ext  ;~(sfix refname (punt fas))
  ++  refspec
    %+  cook
      |=  [opt=(unit @t) src=(unit ^refname) dst=(unit ^refname)]
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
      (punt refname)
      ;~(pfix col (punt refname))
    ==
  --
++  sane
  |=  =refname
  ^-  ?
  ?~  refname  &
  =+  rear=(rear refname)
  =+  last=(cut 3 [(dec (met 3 rear)) 1] rear)
  ?:  =('.' last)
    |
  ::  XX handle pattern match: only one '*' is allowed
  ::
  &
++  sane-refspec
  |=  =refspec
  &
++  sane-refspec-push
  |=  =refspec
  &
--
