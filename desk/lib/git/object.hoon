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
+$  commit  $+  git-commit
            $:  commit-header
                message=tape
            ==
+$  tree-entry  [name=@ta mode=@ta =hash]
+$  tree-dir  $+(git-tree (list tree-entry))
+$  object  $+  git-object
  $%  [%commit size=@ud =commit]
      [%tree size=@ud =tree-dir]
      [%blob size=@ud data=octs]
      [%tag size=@ud ~]
  ==
--
::  Git object core
::
|%
++  ud-as-type
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
      (as-octs:mimes:html (crip ((d-co:co 1) size.rob)))
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
++  blob-to-raw
  |=  blob=object
  ^-  raw-object
  ?>  ?=(%blob -.blob)
  [%blob size.blob data.blob]
++  tree-to-raw
  |=  [hal=hash-algo dir=object]
  ^-  raw-object
  :: XX This assertion makes raw-object face
  :: inaccessible: another compiler bug
  :: ?>  ?=(%tree -.object)
  ::
  ?>  ?=(%tree -.dir)
  =+  dir=tree-dir.dir
  =|  data=bays:bs
  |-
  ?~  dir
    [%tree size=(size:bs data) (to-octs:bs data)]
  =.  data  %+  append-octs:bs  data
    (as-octs:bs mode.i.dir)
  =.  data  %+  append-octs:bs  data
    [1 ' ']
  =.  data  %+  append-octs:bs  data
    (as-octs:bs name.i.dir)
  =.  data  (append-byte:bs data 0x0)
  =.  data  (append-hash data hal hash.i.dir)
  $(dir t.dir)
++  commit-to-raw
  |=  [hal=hash-algo commit=object]
  ^-  raw-object
  ?>  ?=(%commit -.commit)
  *raw-object
::
::  Convert git object to raw form
::
++  obj-to-raw
  |=  [hal=hash-algo obj=object]
  ^-  raw-object
  ?-  -.obj
    %blob    (blob-to-raw obj)
    %tree    (tree-to-raw hal obj)
    %commit  (commit-to-raw hal obj)
    %tag  !!
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
  |=  [hal=hash-algo obj=object]
  ^-  @ux
  (hash-raw hal (obj-to-raw hal obj))
::
++  print-hash
  |=  [hal=hash-algo =hash]
  ^-  tape
  ?-  hal
    %sha-1
      (print-hash-sha-1 hash)
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
  =/  sea=bays:bs  (from-octs:bs data.rob)
  ::  XX Is there a better pattern for
  ::  building a list of results?
  ::
  =+  hash-bytes=(hash-bytes hal)
  =/  tes=(list tree-entry)  ~
  |-
  ?.  (is-empty:bs sea)
    tree+[size.rob tes]
  =/  pin  (find-byte:bs 0x0 sea)
  ?~  pin  !!
  =^  tex=(unit octs)  sea
    (read-octs-until-maybe:bs u.pin sea)
  =.  sea  (skip-byte:bs sea)
  ?~  tex
    ~|  "Corrupted tree object: invalid tree entry"  !!
  =^  hash=(unit hash)  sea
    (read-hash-maybe hal sea)
  ?~  hash
    ~|  "Corrupted tree object: hash not found"  !!
  =+  (scan (trip q.u.tex) ;~(plug tree-mode:parse tree-node:parse))
  ::  [name mode hash]
  ::
  =/  ent=tree-entry  [+.- -.- u.hash]
  $(tes [ent tes])
++  parse
  |_  hal=hash-algo
  ++  hash
    ::  XX does this really evaluates at compile-time?
    ^~
    ?-  hal
       %sha-1  parse-hash-sha-1
       %sha-256  parse-hash-sha-256
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
  ++  tree-node  (cook crip (plus prn))
  --
--
