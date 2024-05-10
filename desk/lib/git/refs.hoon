/+  *git-hash
|%
+$  refname  $+(refname (list @t))
+$  ref  $@(hash [%symref =refname])
::  XX Can you use an axal with ref-path instead 
::  of path from the aura typesystem 
::  point of view?
::
+$  refs  $+(git-refs (axal ref))
--
|%
++  parse-refname  refname:parse
++  parse-refname-ext  refname-ext:parse
::
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
--
