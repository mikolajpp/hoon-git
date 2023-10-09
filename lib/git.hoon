/-  *git, *stream
/+  zlib, bys=stream
|%
::
++  hax-sha-1  (bass 16 (stun [40 40] six:ab))
++  hax-sha-256  !!
::
::  Object
::
++  obj
  |%
  ::
  ++  is-loose
    |=  typ=raw-object-type
    ^-   ?
    ?+  typ    |
      %commit  &
      %tree    &
      %blob    &
      %tag     &
    ==
  ::
  ++  type
    |=  ryt=@ud
    ^-  raw-object-type
    ?+  ryt  %invalid
      %1  %commit
      %2  %tree
      %3  %blob
      %4  %tag
      :: 5 is reserved
      %6  %ofs-delta
      %7  %ref-delta
    ==
  ::
  :: Parse raw git object
  ::
  :: XX should accept byts
  ::
  ++  parse-raw
    |=  dat=@
    ^-  raw-object
    =/  len  (met 3 dat)
    ::  Parse header
    ::
    =/  pin  (find-byte:bys 0x0 [0 len dat])
    ?.  (lth pin len)
      ~|  "Object is corrupted: no header terminator found"  !!
    =/  txt  (trip (cut 3 [0 pin] dat))
    :: [type len]
    ::
    =/  hed  (rust txt ;~(plug sym ;~(pfix ace dip:ag)))
    ?~  hed
      ~|  "Object is corrupted: invalid header"  !!
    ?.  =(+.u.hed (sub len +(pin)))
      ~|  "Object is corrupted: incorrect object length"  !!
    =/  type=raw-object-type
    :: XX Can we somehow cast?
    ?+  -.u.hed  %invalid
        %blob    %blob
        %commit  %commit
        %tree    %tree
      ==
    =/  data=@  (cut 3 [+(pin) +.u.hed] dat)
    [type [+.u.hed data]]
  ::  XX custom crip to handle null bytes properly
  ::  this is probably a bug
  ::
  ++  crip
    |=  a=tape
    ^-  @t
    (rep 3 a)
  ::
  ++  parse
    |=  [hat=hash-type rob=raw-object]
    ^-  object
    =<
    ?+  type.rob
      ~|  "Invalid object type {<type.rob>}"  !!
      %blob    rob
      %commit  (parse-commit rob)
      %tree    (parse-tree rob)
    ==
    |%
    ::
    ::  Parsers
    ::
    ++  eol  (just '\0a')
    ++  hax  ?-  hat
             %sha-1  hax-sha-1
             %sha-256  hax-sha-256
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
    ++  commit
      ;~  plug
        ;~(sfix ;~((glue eol) tree parent author committer) eol)
        ;~(pfix eol message)
      ==
    ::  XX is there a better way to handle a commit without a parent?
    ::
    ++  root-commit
      ;~  plug
        ;~(sfix ;~((glue eol) tree author committer) eol)
        ;~(pfix eol message)
      ==
    ::  Tree rules
    ::
    ++  mode  (cook crip ;~(sfix (plus (shim '0' '9')) ace))
    ++  node  (cook crip (star ;~(less ace prn)))
    ::
    ++  parse-commit
      |=  rob=raw-object
      ^-  object
      ::  XX in places like this we need
      ::  to eventually parametrize the hash function somehow
      ::  (if we plan to support sha-256)
      ::
      =+  txt=(trip dat.byts.rob)
      =+  com=(rust txt commit)
      ?~  com
        =+  com=(rust txt root-commit)
        ?~  com
          ~|  "Failed to parse commit object"  !!
        commit+[[-<.u.com 0x0 ->.u.com] +.u.com]
      commit+u.com
    ::
    ++  parse-tree
      |=  rob=raw-object
      ^-  object
      ::  XX better parsing of mode.
      ::  Is leading zero allowed in principle?
      ::
      =/  sea=stream  [0 byts.rob]
      ::  XX Is there a better pattern for
      ::  building a list of results?
      =/  tes=(list tree-entry)  ~
      |-
      ?.  (lth pos.sea wid.byts.sea)
        tree+tes
      =/  pin  (find-byte:bys 0x0 sea)
      =^  tex  sea  (read-bytes:bys (sub pin pos.sea) sea)
      ?~  tex
        ~|  "Corrupted tree object: malformed tree entry"  !!
      =/  txt  (trip u.tex)
      =^  hek  sea  (read-bytes:bys 20 [+(pos.sea) byts.sea])
      ?~  hek
        ~|  "Corrupted tree object: malformed hash"  !!
      ::
      =/  haz=@ux  (rev 3 20 u.hek)
      =/  ren  (scan txt ;~(plug mode node))
      =/  ent=tree-entry  [ren haz]
      $(tes [ent tes])
    --
  ::
  :: Render a git object raw
  ::
  ++  rare
    |=  obe=object
    ^-  raw-object
    ?-  -.obe
      %blob  obe
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
    =/  len  (crip ((d-co:co 0) wid.byts.rob))
    ::  There must be a pattern for this
    =/  hed  (cat 3 (cat 3 type.rob ' ') len)
    =/  pak  (cat 3 hed (can 3 ~[[1 0x0] byts.rob]))
    ::  (can ~[type.object ' ' len 0x0 data.object])
    =/  saz  (met 3 pak)
    ::  XX is there any way to avoid rev?
    ::
    =/  haz  (sha-1l:sha [saz (rev 3 saz pak)])
    haz
  ::
  :: Hash a raw git object
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
    (hash-raw hat (rare obe))
  --
++  pak
  |%
  ++  read
    |=  sea=stream
    ^-  [pack stream]
    =^  hed  sea  (read-header sea)
    ::  Read objects
    ::
    :: ~&  pack+"Pack file contains {<count.hed>} objects"
    =/  lob=(list raw-object)  ~
    =^  lob  sea
    |-
    ?:  =(0 count.hed)
      :_  sea
      lob
    =^  rob  sea  (read-object sea)
    :: ~&  sea-read+[pos.sea wid.byts.sea]
    $(lob [rob lob], count.hed (dec count.hed))
    :: XX verify pack integrity
    :: XX handle leading zeros
    =^  hax  sea  (read-bytes:bys 20 sea)
    ?~  hax
      ~|  "Pack file is corrupted: no checksum found"  !!
    :_  sea
    [hed lob]
  ::
  ++  read-header
    |=  sea=stream
    ^-  [pack-header stream]
    =^  sig  sea  (read-bytes:bys 4 sea)
    ?~  sig
      ~|  "Pack file is corrupted: no signature found"  !!
    ?.  =(u.sig 'PACK')
      ~|  "Pack file is corrupted: invalid signature {<u.sig>}"  !!
    =^  version  sea  (read-bytes:bys 4 sea)
    ?~  version
      ~|  "Pack file is corrupted: no version found"  !!
    =^  count  sea  (read-bytes:bys 4 sea)
    ?~  count
      ~|  "Pack file is corrupted: no object count found"  !!
    :_  sea
    [(rev 3 4 u.version) (rev 3 4 u.count)]
  ::
  ++  read-object
    |=  sea=stream
    ^-  [raw-object stream]
    =^  [typ=raw-object-type size=@ud]  sea  (read-object-type-size sea)
    ::  XX With the future stream library
    ::  use the references to the sea
    ::  and benchmark vs direct copy
    ::
    =^  dat  sea  (expand:zlib sea)
    ?.  =(wid.dat size)
      ~|  "Object is corrupted: size mismatch (stated {<size>}b uncompressed {<wid.dat>}b)"  !!
    :_  sea
    [typ dat]
  ::
  ++  read-object-type-size
    |=  sea=stream
    ^-  [[raw-object-type @ud] stream]
    =^  bat  sea  (read-bytes:bys 1 sea)
    ?~  bat  !!
    =/  type  (type:obj (dis (rsh [2 1] u.bat) 0x7))
    ?:  =(type %invalid)  !!
    ::  Decode object size
    ::
    =/  qad  (dis u.bat 0xf)
    ?:  =(0 (dis u.bat 0x80))
      :_  sea
      [type qad]
    =^  sel=(list @ux)  sea  (read-object-length sea)
    =/  size  (object-size qad sel)
    :_  sea
    [type size]
  ::
  ++  object-size
    |=  [qad=@ux sel=(list @ux)]
    ^-  @ud
    =/  sez  0
    =/  size=@ud
    |-
    ?~  sel
      sez
    $(sel +:sel, sez (add (lsh [0 7] sez) -:sel))
    ::
    :: ~&  [qad `@ux`size]
    (add (lsh [2 1] size) qad)
  ::
  ++  read-object-length
    |=  sea=stream
    ^-  [(list @ux) stream]
    =/  sel=(list @ux)  ~
    |-
    =^  nes  sea  (read-bytes:bys 1 sea)
    ?~  nes  !!
    =/  val  (dis u.nes 0x7f)
    ?:  =(0 (dis u.nes 0x80))
      :_  sea
      [val sel]
    $(sel [val sel])
  --
::
++  bud
  |%
  ++  read
    |=  sea=stream
    ^-  [bundle stream]
    =^  hed  sea  (read-header:bud sea)
    =^  pak  sea  (read:pak sea)
    :_  sea
    [header=hed pak]
  ::
  ++  read-header
    |=  sea=stream
    ^-  [bundle-header stream]
    ::  Parse signature
    ::
    =^  nex  sea  (read-line:bys sea)
    ?~  nex
      ~|  "Git bundle is corrupted: signature absent"  !!
    =/  signature
      ;~(sfix (cold %2 (jest '# v2 git bundle')) (just '\0a'))
    =+  sig=(rust u.nex signature)
    ?~  sig
      ~|  "Git bundle is corrupted: invalid signature"  !!
    ::  Choose hash type and parser
    ::
    =/  [hat=hash-type hax=_hax-sha-1]
      ?:  ?=(%2 u.sig)
        [%sha-1 hax-sha-1]
      !!
    ::  Compose with parsers
    ::
    =<
    ::  Parse prerequisites
    ::
    =^  reqs=(list @ux)  sea
    %.  ~
    |=  reqs=(list @ux)
    =+  [nex red]=(read-line:bys sea)
    ?~  nex
      ~|  "Git bundle is corrupted: invalid header"  !!
    =/  hax=(unit @ux)  (rust u.nex required)
    ?~  hax
      :: ~&  "Failed to parse '{u.-.nex}'"
      [reqs sea]
    $(reqs [u.hax reqs], sea red)
    ::
    ::  Parse references
    ::
    =^  refs=(list ^reference)  sea
    %.  ~
    |=  refs=(list ^reference)
    =+  [nex red]=(read-line:bys sea)
    ?~  nex
      ~|  "Git bundle is corrupted: invalid header"  !!
    =/  ref=(unit [@ux path])  (rust u.nex reference)
    ?~  ref
      :: ~&  "Failed to parse '{u.-.nex}'"
      [refs sea]
    $(refs [[+.u.ref -.u.ref] refs], sea red)
    :: Parse newline indicating end of bundle header
    ::
    =^  nex  sea  (read-line:bys sea)
    ?~  nex
      ~|  "Git bundle is corrupted: header not terminated"  !!
    ?:  (gth (lent u.nex) 1)
      ~|  "Git bundle is corrupted: invalid header terminator"  !!
    :_  sea
    [u.sig hat reqs refs]
    ::
    ::  Parsers
    ::
    |%
    ++  comment  ;~(pfix ace (star prn))
    ++  required
      %+  ifix  [hep (just '\0a')]
      ;~(sfix hax (punt comment))
    ++  segment
      (cook crip ;~(plug low (star ;~(pose low nud hep))))
    ++  paf
      ;~  pose
        ;~(plug segment (star ;~(pfix fas segment)))
      ==
    ++  reference
      ;~  sfix
        ;~(plug hax ;~(pfix ace paf))
        (just '\0a')
      ==
    --
  --
::
::  Repository
::
++  git
  |_  repo=repository
  +*  this  .
  ::
  ::  XX validate hash type?
  ::
  ++  get
    |=  haz=@ux
    ^-  (unit object)
    (~(get by objects.repo) haz)
  ::
  ++  got
    |=  haz=@ux
    ^-  object
    (~(got by objects.repo) haz)
  ::
  ++  has
    |=  haz=@ux
    ^-  ?
    (~(has by objects.repo) haz)
  ::
  ++  put
    |=  obe=object
    ^-  repository
    =/  haz=@ux  (hash:obj hash.repo obe)
    ?<  (has haz)
    repo(objects (~(put by objects.repo) [haz obe]))
  ++  wyt
    |-
    ~(wyt by objects.repo)
  ::
  ++  put-raw
    |=  rob=raw-object
    ^-  repository
    =/  haz=@ux  (hash-raw:obj hash.repo rob)
    ?<  (has haz)
    repo(objects (~(put by objects.repo) [haz (parse:obj hash.repo rob)]))
  ::
  ::  Key size in half-bytes
  ::
  ::  Why does ?= not work here?
  ::
  ++  key-size  ?:  =(hash.repo %sha-1)  40
                  !!
  ::
  ::  Check whether key a
  ::  is a shorthand of b
  ::
  ::  XX This could be done with
  ::  direct atom comparison
  ::
  ++  match-key
    |=  [a=byts b=@ux]
    ^-  ?
    ?:  =(a b)
      &
    ::  Size in half-bytes
    ::
    .=  dat.a
    %+  cut  2
      :_  b
      [(sub key-size wid.a) wid.a]
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
  ::
  :: Find all keys matching the abbreviation
  ::
  ++  find-key
    |=  a=@ta
    ^-  (list @ux)
    ::
    :: XX why does dispatching on non-empty set does not work?
    :: ?~  keys  followed by =/  heys  ~(tap in keys)
    :: results in mull-grow
    ::
    =+  key=[(met 3 a) (to-hex a)]
    =/  kel=(list @ux)  ~(tap in ~(key by objects.repo))
    =|  hey=(list @ux)
    |-
    ?~  kel
      hey
    ?:  (match-key key i.kel)
      $(kel t.kel, hey [i.kel hey])
    $(kel t.kel)
  ::
  ++  unbundle
    |=  bud=bundle
    ^-  repository
    ?>  =(2 version.header.bud)
    ::  Verify we have all required objects
    ::
    ::  XX Can we get hash.repo+hax syntax to work?
    ::
    =+  mis=(turn reqs.header.bud |=(haz=@ux (has haz)))
    ?:  (gth (lent mis) 0)
      ~|  "Bundle can not be unpacked, missing prerequisites {<mis>}"  !!
    ::  Read objects
    ::
    =+  bos=objects.pack.bud
    =.  repo
    |-
    ?~  bos
      repo
    $(repo (put-raw i.bos), bos t.bos)
    ::  Read and verify references
    ::
    =+  ref=refs.header.bud
    =.  repo
    |-
    ?~  ref
      repo
    ?.  (has +.i.ref)
      ~|  "Bundle contains reference to unknown object {<+.i.ref>}"  !!
    $(refs.repo (~(put by refs.repo) i.ref), ref t.ref)
    ::
    repo
  ::
  ::  This is a configuration store mirroring the one from Git.
  ::  Configuration variables are grouped into sections with an optional
  ::  subsection. Thus core/~ corresponds to [core], while remote/origin
  ::  to [remote "origin"].
  ::  Configuration variables can be loobean ?, integer @ud, or string @t.
  ::
  ::  XX Think whether it would be better to have a typed configuration
  ::  store. The advantage of the current approach is that a new tool
  ::  can introduce a configuration variable without the need to
  ::  alter and recompile libgit itself.
  ::
  ++  config
    |%
    ::
    ++  get
      |=  [key=config-key var=@tas]
      ^-  (unit config-value)
      (~(get bi:libmip config.repo) key var)
    ::
    ++  put
      |=  [key=config-key var=@tas val=config-value]
      ^-  repository
      repo(config (~(put bi:libmip config.repo) key var val))
    ::
    ++  default
    |.
    ^-  repository
    =.  repo  (put core/~ repositoryformatversion+u+0)
    =.  repo  (put core/~ bare+l+&)
    repo
    --
  --
--
