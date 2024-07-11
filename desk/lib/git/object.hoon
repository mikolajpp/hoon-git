::
::::  Git objects
  ::
/+  bs=bytestream
/+  *git-hash
|%
::
+$  object-type
  $?  %commit
      %tree
      %blob
      %tag
  ==
+$  object-header  [type=object-type size=@ud]
+$  raw-object  [type=object-type size=@ud data=octs]
::
+$  commit-person  [name=tape email=tape]
+$  commit-time  [date=@da zone=(pair ? @dr)]
+$  commit-signature  $%  [%gpg @t]
               ==
+$  commit-header  $:  tree=hash
                       parents=(list hash)
                       ::
                       author=commit-person
                       author-time=commit-time
                       ::
                       committer=commit-person
                       =commit-time
                       ::
                       sign=(unit commit-signature)
                   ==
+$  commit  $+  commit
            $:  commit-header
                message=tape
            ==
::  XX refactor to [mode name hash]
::
+$  tree-entry  [[mode=@ta name=@ta] =hash]
+$  tree-dir  (list tree-entry)
:: ++  git-tree  tree
::  XX refactor objects so  fields are readily accessible
::  XX are sizes here really necessary?
::
+$  object
  $%  [%blob size=@ud =octs]
      [%commit size=@ud =commit]
      [%tree size=@ud tree=tree-dir]
  ==
--
::
::  Git object core
::
|%
++  as-type
  |=  tid=@ud
  ^-  (unit object-type)
  ?+  tid  ~
    %1  `%commit
    %2  `%tree
    %3  `%blob
    %4  `%tag
  ==
++  raw-to-octs
  |=  rob=raw-object
  ^-  octs
  %-  can-octs:bs
  :~  (as-octs:mimes:html type.rob)
      [1 ' ']
      (as-octs:mimes:html (scot %ud size.rob))
      [1 0x0]
      data.rob
  ==
::  Size of the data payload
::
++  raw-size
  |=  rob=raw-object
  ^-  @ud
  p.data.rob
::
++  raw-data
  |=  rob=raw-object
  ^-  octs
  data.rob
::
::  Convert git object to raw form
::
++  as-raw 
  |=  obe=object
  ^-  raw-object
  ?-  -.obe
    %blob    !!
    %tree    !!
    %commit  !!
  ==
::
::  sha-1 hash a raw git object
::
::  XX Improve performance by
::  exposing Sha1_Update in zuse
::
++  hash-raw-sha-1
  |=  rob=raw-object
  ^-  @ux
  :: =/  len  (crip ((d-co:co 1) p.octs.data.rob))
  :: ::  There must be a pattern for this
  :: =/  hed  (cat 3 (cat 3 type.rob ' ') len)
  :: =/  dat  (add hed (lsh [3 +((met 3 hed))] q.octs.data.rob))
  :: =/  dat  (cat 3 hed (can 3 ~[[1 0x0] octs.data.rob]))
  :: ::  (can ~[type.object ' ' len 0x0 data.object])
  :: =/  wid  (add +((met 3 hed)) p.octs.data.rob)
  :: XX is there a way to avoid rev?
  (hash-octs-sha-1 (raw-to-octs rob))
::
::  Hash raw git object
::
++  hash-raw
  |=  [hal=hash-algo rob=raw-object]
  ^-  @ux
  ?-  hal
    %sha-1  (hash-raw-sha-1 rob)
    %sha-256  !!
  ==
::
::  Hash a git object
::
++  hash-obj
  |=  [hal=hash-algo obe=object]
  ^-  @ux
  (hash-raw hal (as-raw obe))
::
++  print-hash
  |=  [hal=hash-algo =hash]
  ^-  tape
  ?-  hal
    %sha-1
      (print-sha-1 hash)
    ::
    %sha-256  !!
  ==
++  raw-from-octs
  |=  =octs
  ^-  raw-object
  ::  Parse header
  ::
  =/  pin  (find-byte:bs 0x0 (from-octs:bs octs))
  ?~  pin 
    ~|  "Object is corrupted: no header terminator found"  !!
  =/  txt  (trip (cut 3 [0 u.pin] q.octs))
  :: [type len]
  ::
  =/  hed  (rust txt ;~(plug sym ;~(pfix ace dip:ag)))
  ?~  hed
    ~|  "Object is corrupted: invalid header"  !!
  =+  [type=@tas size=@ud]=u.hed
  ?.  =(size (sub p.octs +(u.pin)))
    ~|  "Object is corrupted: incorrect object length"  !!
  =/  type=object-type
  :: XX Can we somehow cast @tas to type?
    ?+  type  ~|  "Object corrupted: unknown type {<type>}"  !!
        %blob    %blob
        %commit  %commit
        %tree    %tree
        %tag  !!
    ==
  =/  sea=bays:bs  (from-octs:bs octs)
  =/  data
    (peek-octs-end:bs (seek-to:bs +(u.pin) sea))
  [type size data]
++  parse-raw
  |=  [hal=hash-algo rob=raw-object]
  ^-  object
  ?-  type.rob
    %blob    (parse-blob hal rob)
    %commit  (parse-commit hal rob)
    %tree    (parse-tree hal rob)
    %tag     !!
  ==
++  parse-blob
    |=  [hal=hash-algo rob=raw-object]
    ^-  object
    (~(blob parse hal) rob)
::  XX conform commit parser to git
++  parse-commit
  ::  XX looks like another compiler bug.
  ::  Below crashes with no error 
  :: |=  rob=$>(%commit raw-object)
  |=  [hal=hash-algo rob=raw-object]
  ^-  object
  ?>  ?=(%commit type.rob)
  =+  txt=(trip q:(raw-data rob))
  =+  com=(~(commit parse hal) [[1 1] txt])
  ?~  q.com
    ~&  txt
    ~|  "Failed to parse commit object: syntax error {<p.com>} in {txt}"  !!
  commit+[size.rob p.u.q.com]
::
++  parse-tree
  :: |=  rob=$>(%tree raw-object)
  |=  [hal=hash-algo rob=raw-object]
  ^-  object
  ?>  ?=(%tree type.rob)
  ::  XX better parsing of mode.
  ::  Is leading zero allowed in principle?
  ::
  =/  sea=bays:bs  (from-octs:bs data.rob)
  ::  XX Is there a better pattern for
  ::  building a list of results?
  ::
  =+  hash-bytes=(hash-bytes hal)
  =/  tes=(list tree-entry)  ~
  |-
  ?.  (lth pos.sea p.octs.sea)
    tree+[size.rob tes]
  =/  pin  (find-byte:bs 0x0 sea)
  ?~  pin  !!
  =^  tex=(unit octs)  sea  
    (read-octs-maybe:bs (sub u.pin pos.sea) sea)
  ?~  tex
    ~|  "Corrupted tree object: malformed tree entry"  !!
  =/  txt  (trip q.u.tex)
  =.  sea  (skip-byte:bs sea)
  =^  hek=(unit octs)  sea  
    (read-octs-maybe:bs hash-bytes sea)
  ?~  hek
    ~|  "Corrupted tree object: malformed hash"  !!
  =+  haz=q.u.hek
  =/  ren  (scan txt ;~(plug tree-mode:parse tree-node:parse))
  =/  ent=tree-entry  [ren haz]
  $(tes [ent tes])
++  parse
  |_  hal=hash-algo
  ++  hash
    ::  XX does this really evaluates at compile-time?
    ^~
    ?-  hal
       %sha-1  parse-sha-1
       %sha-256  parse-sha-256
    ==
  ++  blob
    |=  rob=raw-object
    ^-  object
    ?>  ?=(%blob type.rob)
    blob+[size.rob data.rob]
  ++  eol  (just '\0a')
  ::  Commit rules
  ::
  ++  tree  ;~(pfix (jest 'tree ') hash)
  ++  parent  ;~(pfix (jest 'parent ') hash)
  ++  person
    ;~  plug
    ::  Name
    ::
    ;~(sfix (star ;~(less ;~(plug ace gal) prn)) ;~(plug ace gal))
    ::  Email
    ::
    ;~(sfix (star ;~(less gar prn)) gar)
    ==
  ++  zone
    %+  cook
      |=  [s=? hor=@ud min=@ud]
      ^-  (pair ? @dr)
      :-  s
      `@dr`(add (mul hor ~h1) (mul min ~m1))
    ;~  plug
      :: sign
      ;~(pose (cold %& lus) (cold %| hep))
      :: hours
      (bass 10 ;~(plug sid:ab sid:ab (easy ~)))
      :: minutes
      (bass 10 ;~(plug sid:ab sid:ab (easy ~)))
    ==
  ++  date
    %+  cook
      |=  sec=@ud
      ^-  @da
      (add ~1970.1.1 (mul ~s1 sec))
    dip:ag
  ++  time  
    :: XX This breaks parsing
    :: ^-  $-(nail (like commit-time))
    ;~(plug date ;~(pfix ace zone))
  ++  message  (star ;~(pose prn eol))
  ++  gpg-header-begin
    ;~  pose
      (jest '-----BEGIN PGP SIGNATURE-----')
      (jest '-----BEGIN PGP MESSAGE-----')
    ==
  ++  gpg-header-end
    ;~  pose
      (jest '-----END PGP SIGNATURE-----')
      (jest '-----END PGP MESSAGE-----')
    ==
  ++  commit-signature
    ;~  pfix
      ;~  plug
        (jest 'gpgsig')
        ace
        gpg-header-begin
      ==
      ;~  sfix
        (stag %gpg (cook crip (plus ;~(less hep ;~(pose prn gah)))))
        ::  XX make this parser robust
        ;~(plug gpg-header-end ;~(less prn (star gah)))
      ==
    ==
  ++  commit
    ;~  plug
      ;~  plug
        ;~(sfix tree eol)
        (star ;~(sfix parent eol))
        ;~(pfix (jest 'author ') person)
        ;~(pfix ace ;~(sfix time eol))
        ;~(pfix (jest 'committer ') person)
        ;~(pfix ace ;~(sfix time eol))
        (punt commit-signature)
      ==
      ;~(pfix (star gah) message)
    ==
  ::  Tree rules
  ::
  ++  tree-mode  (cook crip ;~(sfix (plus (shim '0' '9')) ace))
  ++  tree-node  (cook crip (star ;~(less ace prn)))
  ::
  --
::  These are useless when inspecting objects. 
::  Could the type-checker be improved to somehow inline
::  these?
::
:: ++  is-blob
::   |=  obj=object
::   ?=(%commit -.obj)
:: ++  is-tree
::   |=  obj=object
::   ?=(%tree -.obj)
:: ++  is-commit
::   |=  obj=object
::   ?=(%commit -.obj)
--
