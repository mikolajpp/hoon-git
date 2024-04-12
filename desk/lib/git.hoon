::
::::  Git core
  ::
/-  *git
/+  zlib, stream
~%  %git  ..part  ~
|%
::  
::  Utility functions
::
++  key-size  
  |=  hat=hash-type
  ?-  hat
    %sha-1    40
    %sha-256  !!
  ==
++  match-key
  |=  [kes=@ud a=octs b=@ux]
  ^-  ?
  ?:  =(a b)
    &
  ::  Size in half-bytes
  ::
  .=  q.a
  %+  cut  2
    :_  b
    [(sub kes p.a) p.a]
::
++  to-hex
  |=  a=@ta
  =+  hex=0x0
  |-
  ?:  =(a 0)
    hex
  =+  dit=(end [3 1] a)
  =/  val=@ux
  ?:  (gth dit '9')
    (add (sub dit 'a') 10)
  (sub dit '0')
  $(a (rsh [3 1] a), hex (add (lsh [2 1] hex) val))
::  XX conform to git-check-ref-format
::
::  XX rename to parse-sha-1
::
++  parser-sha-1  %+  cook  |=(h=@ (rev 3 20 h))
                  (bass 16 (stun [40 40] six:ab))
++  parser-sha-256  !!
++  parser-segment  (cook crip (plus ;~(less fas prn)))
++  parser-path
  ;~  pose
    ;~(plug (jest 'HEAD') (easy ~))
    ;~(plug parser-segment (star ;~(pfix fas parser-segment)))
  ==
++  parser-path-ext  ;~(sfix parser-path (punt fas))
++  parser-ref
  %+  cook 
    |=([=hash =path] [path hash])
    ;~(plug parser-sha-1 ;~(pfix ace parser-path))
++  print-sha-1
  |=  =hash
  ^-  tape
  ((x-co:co 40) (rev 3 20 hash))
::
::  Object
::
++  obj
  |%
  ::
  ++  type
    |=  tip=@ud
    ^-  (unit object-type)
    ?+  tip  ~
      %1  `%commit
      %2  `%tree
      %3  `%blob
      %4  `%tag
    ==
  ::
  :: Parse a raw git object
  ::
  ++  parse-octs
    |=  =octs
    ^-  raw-object
    ::  Parse header
    ::
    =+  pin=(find-byte:stream 0x0 0+octs)
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
    [type size [+(u.pin) octs]]
  ++  as-octs
    |=  rob=raw-object
    ^-  octs
    ::  XX will not work of data is a slice
    ?>  =(0 pos.data.rob)
    ;:  cat-octs:stream
      (as-octs:mimes:html type.rob)
      [1 ' ']
      (as-octs:mimes:html (scot %ud size.rob))
      [1 0x0]
      octs.data.rob
    ==
  ::  Size of the data payload
  ::
  ++  raw-size
    |=  rob=raw-object
    ^-  @ud
    (sub p.octs.data.rob pos.data.rob)
  ::
  ++  raw-data
    |=  rob=raw-object
    ^-  octs
    :-  (raw-size rob)
    %^  cut  3
      [pos.data.rob (raw-size rob)]
    q.octs.data.rob
  ::  XX custom crip to handle null bytes properly
  ::  this is probably a bug
  ::
  ++  crip
    |=  a=tape
    ^-  @t
    (rep 3 a)
  ::
  ++  parse-raw
    |=  [hat=hash-type rob=raw-object]
    ^-  object
    =<
    ?-  type.rob
      %blob    (parse-blob rob)
      %commit  (parse-commit rob)
      %tree    (parse-tree rob)
      %tag     !!
    ==
    ::  XX reorganize
    |%
    ++  parse-blob
      |=  rob=raw-object
      ^-  object
      ?>  ?=(%blob type.rob)
      =+  len=(sub p.octs.data.rob pos.data.rob)
      =+  data=(cut 3 [pos.data.rob len] q.octs.data.rob)
      blob+[size.rob [len data]]
    ::
    ++  hash-bytes  ?-  hat
                    %sha-1  20
                    %sha-256  !!
                    ==
    ::
    ::  Parsers
    ::
    ++  eol  (just '\0a')
    ++  hax  ?-  hat
             %sha-1    parser-sha-1
             %sha-256  parser-sha-256
             ==
    ::  Commit rules
    ::
    ++  tree  ;~(pfix (jest 'tree ') hax)
    ++  parent  ;~(pfix (jest 'parent ') hax)
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
      ;~  plug
      ;~(pose (cold & lus) (cold | hep))
      (plus nud)
      ==
    ++  time  ;~(plug ;~(sfix dip:ag ace) zone)
    ++  author
      ;~  pfix  (jest 'author ')
      ;~(plug person ;~(pfix ace time))
      ==
    ++  committer
      ;~  pfix  (jest 'committer ')
      ;~(plug person ;~(pfix ace time))
      ==
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
          ;~(sfix author eol)
          committer
          (punt ;~(pfix eol commit-signature))
        ==
        message
      ==
    ::  Tree rules
    ::
    ++  mode  (cook crip ;~(sfix (plus (shim '0' '9')) ace))
    ++  node  (cook crip (star ;~(less ace prn)))
    ::
    ++  parse-commit
      ::  XX looks like another compiler bug.
      ::  Below crashes with no error 
      :: |=  rob=$>(%commit raw-object)
      |=  rob=raw-object
      ^-  object
      ?>  ?=(%commit type.rob)
      =+  txt=(trip q:(raw-data:obj rob))
      =+  com=(commit [[1 1] txt])
      ?~  q.com
        ~&  txt
        ~|  "Failed to parse commit object: syntax error {<p.com>} in {txt}"  !!
      commit+[size.rob p.u.q.com]
    ::
    ++  parse-tree
      :: |=  rob=$>(%tree raw-object)
      |=  rob=raw-object
      ^-  object
      ?>  ?=(%tree type.rob)
      ::  XX better parsing of mode.
      ::  Is leading zero allowed in principle?
      ::
      =/  sea=stream:stream  data.rob
      ::  XX Is there a better pattern for
      ::  building a list of results?
      ::
      =/  tes=(list tree-entry)  ~
      |-
      ?.  (lth pos.sea p.octs.sea)
        tree+[size.rob tes]
      =+  pin=(find-byte:stream 0x0 sea)
      ?~  pin  !!
      =^  tex  sea  (read-bytes:stream (sub u.pin pos.sea) sea)
      ?~  tex
        ~|  "Corrupted tree object: malformed tree entry"  !!
      =/  txt  (trip q.u.tex)
      ::  XX parametrize by hash type
      ::
      =^  hek  sea  (read-bytes:stream hash-bytes [+(pos.sea) octs.sea])
      ?~  hek
        ~|  "Corrupted tree object: malformed hash"  !!
      ::  XX parametrize by hash type
      ::
      =/  haz=@ux  (rev 3 hash-bytes q.u.hek)
      =/  ren  (scan txt ;~(plug mode node))
      =/  ent=tree-entry  [ren haz]
      $(tes [ent tes])
    --
  ::
  :: Render a git object raw
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
    =/  len  (crip ((d-co:co 1) p.octs.data.rob))
    ::  There must be a pattern for this
    =/  hed  (cat 3 (cat 3 type.rob ' ') len)
    =/  dat  (add hed (lsh [3 +((met 3 hed))] q.octs.data.rob))
    =/  dat  (cat 3 hed (can 3 ~[[1 0x0] octs.data.rob]))
    ::  (can ~[type.object ' ' len 0x0 data.object])
    =/  wid  (add +((met 3 hed)) p.octs.data.rob)
    :: XX is there a way to avoid rev?
    (hash-octs-sha-1 [wid dat])
  ::
  ::  Hash raw bytes
  ::
  ++  hash-octs-sha-1
    |=  =octs
    ^-  @ux
    (rev 3 20 (sha-1l:sha p.octs (rev 3 p.octs q.octs)))
  ::
  ::  Hash a raw git object
  ::
  ++  hash-raw
    |=  [hat=hash-type rob=raw-object]
    ^-  @ux
    ?-  hat
      %sha-1  (hash-raw-sha-1 rob)
      %sha-256  !!
    ==
  ::
  ::  Hash a git object
  ::
  ++  hash
    |=  [hat=hash-type obe=object]
    ^-  @ux
    (hash-raw hat (as-raw obe))
  ::
  ++  print-hash
    |=  [hat=hash-type haz=hash]
    ^-  tape
    ?-  hat
      %sha-1
      ((x-co:co 40) (rev 3 20 haz))
      ::
      %sha-256  !!
    ==
  ::  These are useless when inspecting objects. 
  ::  Could the type-checker be improved to somehow inline
  ::  these?
  ::
  ++  is-blob
    |=  obj=object
    ?=(%commit -.obj)
  ++  is-tree
    |=  obj=object
    ?=(%tree -.obj)
  ++  is-commit
    |=  obj=object
    ?=(%commit -.obj)
  --
--
