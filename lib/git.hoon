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
  ++  type
    |=  ryt=@ud
    ^-  (unit object-type)
    ?+  ryt  ~
      %1  `%commit
      %2  `%tree
      %3  `%blob
      %4  `%tag
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
    =/  typ=object-type
    :: XX Can we somehow cast?
      ?+  -.u.hed  ~|  "Unknown object type {<-.u.hed>}"  !!
          %blob    %blob
          %commit  %commit
          %tree    %tree
      ==
    =/  data=@  (cut 3 [+(pin) +.u.hed] dat)
    [typ [+.u.hed data]]
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
    ?-  type.rob
      %blob    rob
      %commit  (parse-commit rob)
      %tree    (parse-tree rob)
      %tag     !!
    ==
    |%
    ++  hash-bytes  ?-  hat
                    %sha-1  20
                    %sha-256  !!
                    ==
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
        ;~  sfix
          ;~  plug
            ;~(sfix tree eol)
            (star ;~(sfix parent eol))
            ;~(sfix author eol)
            committer
          ==
          eol
        ==
        ;~(pfix eol message)
      ==
      :: ;~  sfix
      ::   ;~  (glue eol)
      ::     tree
      ::     (star ;~(sfix parent eol))
      ::     author
      ::     committer
      ::   ==
      ::   eol
      :: ==
      :: ;~(pfix eol message)
      :: ==
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
      |=  rob=[%commit =byts]
      ^-  object
      =+  txt=(trip dat.byts.rob)
      =+  com=(commit [[1 1] txt])
      ?~  q.com
        ~|  "Failed to parse commit object: syntax error {<p.com>} in {txt}"  !!
      commit+p.u.q.com
    ::
    ++  parse-tree
      |=  rob=[%tree =byts]
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
      ::  XX parametrize by hash type
      ::
      =^  hek  sea  (read-bytes:bys hash-bytes [+(pos.sea) byts.sea])
      ?~  hek
        ~|  "Corrupted tree object: malformed hash"  !!
      ::  XX parametrize by hash type
      ::
      =/  haz=@ux  (rev 3 hash-bytes u.hek)
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
    =/  len  (crip ((d-co:co 1) wid.byts.rob))
    ::  There must be a pattern for this
    =/  hed  (cat 3 (cat 3 type.rob ' ') len)
    =/  dat  (cat 3 hed (can 3 ~[[1 0x0] byts.rob]))
    ::  (can ~[type.object ' ' len 0x0 data.object])
    =/  wid  (add +((met 3 hed)) wid.byts.rob)
    ::  XX is there a way to avoid rev?
    ::
    (hash-byts-sha-1 [wid dat])
  ::
  ::  Hash raw bytes
  ::
  ++  hash-byts-sha-1
    |=  =byts
    (sha-1l:sha wid.byts (rev 3 wid.byts dat.byts))
  ::
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
    (hash-raw hat (rare obe))
  ::
  ++  print-hash
    |=  [hat=hash-type haz=hash]
    ^-  tape
    ::  XX use hash type
    ::
    ((x-co:co 40) (rev 3 20 haz))
  ::
  --
++  pak
  |%
  ++  read
    |=  sea=stream
    ^-  [pack stream]
    ::  Record the base offset
    ::
    =^  hed  sea  (read-header sea)
    =/  hash-bytes=@ud
      ?-  version.hed
        %2  20  ::  sha-1
      ==
    ::  Read objects
    ::
    ~&  pack+"Pack file contains {<count.hed>} objects"
    =|  lob=(list (pair @ud pack-object))
    =^  lob  sea
    ::
    |-
    ?:  =(0 count.hed)
      :_  sea
      lob
    ::  Record object offset
    ::
    =/  fet=@ud  pos.sea
    =^  kob=pack-object  sea  (read-object sea)
    %=  $
      count.hed  (dec count.hed)
      lob  [[fet kob] lob]
    ==
    :: XX verify pack integrity
    :: XX parametrize by hash type
    ::
    =^  hax  sea  (read-bytes:bys hash-bytes sea)
    ?~  hax
      ~|  "Pack file is corrupted: no checksum found"  !!
    :_  sea
    ::  XX How to efficiently avoid the flop?
    ::  Objects need to processed head first
    ::
    [hed (flop lob)]
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
    =+  ver=(rev 3 4 u.version)
    =+  cot=(rev 3 4 u.count)
    ?>  ?=(%2 ver)
    :_  sea
    [ver cot]
  ::
  ++  read-object
    |=  sea=stream
    ^-  [pack-object stream]
    ::  XX something is wrong
    ::  with the faced tuple spec mode.
    ::  :- does not work here.
    =/  [[typ=pack-object-type size=@ud] red=stream]
      (read-object-type-size sea)
    ?+  typ
      ::  XX With the future stream library
      ::  use the references to the sea
      ::  and benchmark vs direct copy
      ::
      =^  dat  sea  (expand:zlib red)
      ?.  =(wid.dat size)
        ~|  "Object is corrupted: size mismatch (stated {<size>}b uncompressed {<wid.dat>}b)"  !!
      :_  sea
      [typ dat]
    ::
    %ofs-delta
    (read-object-ofs pos.sea red)
    ::
    %ref-delta  !!
    ::
    ==
  ::
  ++  read-object-ofs
    |=  [base=@ud sea=stream]
    ^-  [pack-object stream]
    =^  offset=@ud  sea  (read-offset sea)
    ::  XX this check is wrong:
    ::  the stream position might
    ::  not be relative to the beginning of the packfile.
    ::
    ?<  |(=(0 offset) (gte offset base))
    =^  dat  sea  (expand:zlib sea)
    :_  sea
    [%ofs-delta base offset dat]
  ::
  ++  read-offset
    |=  sea=stream
    ^-  [@ud stream]
    =+  fet=0
    ::  XX put a safety stop
    ::  to prevent infinite loop here
    ::  and at read-object-type-size
    ::
    |-
    =^  bay  sea  (read-bytes:bys 1 sea)
    =+  bat=(need bay)
    =+  tef=(add (lsh [0 7] fet) (dis 0x7f bat))
    ?:  =(0 (dis 0x80 bat))
      :_  sea
      tef
    ::  XX find out why we need to increase
    ::  offset by one as we go. Is the offset from
    ::  the beginning of the %ofs-delta object *data*?
    ::
    $(fet +(tef))
  ::  XX This can be just computed
  ::  in a single loop
  ::
  ++  read-object-type-size
    |=  sea=stream
    ^-  [[pack-object-type @ud] stream]
    =^  bat  sea  (read-bytes:bys 1 sea)
    ?~  bat  !!
    =+  tap=(dis (rsh [2 1] u.bat) 0x7)
    =/  typ  (object-type tap)
    ?~  typ
      ~|  "Invalid pack object type {<tap>}"  !!
    ::  Decode object size
    ::
    =/  siz=@ud  (dis u.bat 0xf)
    ?:  =(0 (dis u.bat 0x80))
      :_  sea
      [u.typ siz]
    =^  tiz=@ud  sea  (read-object-size sea)
    =.  siz  (add (lsh [0 4] tiz) siz)
    :_  sea
    [u.typ siz]
  ::
  ++  read-object-size
    |=  sea=stream
    ^-  [@ud stream]
    =|  bits=@ud
    =|  size=@ud
    |-
    =^  bat  sea  (read-bytes:bys 1 sea)
    ?~  bat  !!
    ?:  =(0 (dis u.bat 0x80))
      :_  sea
      (add size (lsh [0 bits] u.bat))
    %=  $
      size  (add size (lsh [0 bits] (dis u.bat 0x7f)))
      bits  (add bits 7)
    ==
  ::
  ++  object-type
    |=  ryt=@ud
    ^-  (unit pack-object-type)
    ?+  ryt  ~
      %1  `%commit
      %2  `%tree
      %3  `%blob
      %4  `%tag
      ::
      %6  `%ofs-delta
      %7  `%ref-delta
    ==
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
  ++  read-length-bytes
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
  ::
  ++  is-delta
    |=  kob=pack-object
    ^-  ?
    ?=(?(%ofs-delta %ref-delta) -.kob)
  --
::
++  bud
  |%
  ++  read
    |=  sea=stream
    ^-  [bundle stream]
    =^  hed  sea  (read-header:bud sea)
    ~&  pack-base+pos.sea
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
    =^  reqs=(list hash)  sea
    %.  ~
    |=  reqs=(list hash)
    =+  [nex red]=(read-line:bys sea)
    ?~  nex
      ~|  "Git bundle is corrupted: invalid header"  !!
    =/  hax=(unit hash)  (rust u.nex required)
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
    =/  ref=(unit [hash path])  (rust u.nex reference)
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
    ::  XX parametrize by hash type
    ::
    ~&  put-raw+haz
    ?<  (has haz)
    repo(objects (~(put by objects.repo) [haz (parse:obj hash.repo rob)]))
  ::
  ::
  ::  Key size in half-bytes
  ::
  ++  key-size  ?-  hash.repo
                  %sha-1    40
                  %sha-256  !!
                ==
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
    ::  Unpack and merge
    ::
    =+  ros=(unpack pack.bud)
    ::  XX  Load objects
    ::
    =.  objects.repo
      %-  ~(uni by objects.repo)
      %-  ~(run by ros)
      |=(rob=raw-object (parse:obj hash.repo rob))
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
  ::  Unpack a pack
  ::
  ++  unpack
    |=  =pack
    ^-  raw-object-store
    =|  ros=raw-object-store
    =|  dex=pack-index
    =+  lob=objects.pack
    ::
    =<
    ::
    !:
    |-
    ::  XX verify object count
    ?~  lob
      ros
    =/  rob=raw-object
    ::  XX the lob usage is not readable
    ::
    ?:  ?=(pack-delta-object +.i.lob)
      ::  Resolve delta object
      ::
      (resolve-delta i.lob)
      ::
    +.i.lob
    =+  haz=(hash-raw:obj hash.repo rob)
    ?:  (~(has by ros) haz)
      ~|  "Pack is invalid: object {<haz>} duplicated"  !!
    ::
    %=  $
      ros  (~(put by ros) haz rob)
      dex  (~(put by dex) -.i.lob haz)
      lob  t.lob
    ==
    ::
    |%
    ::
    ++  resolve-base
      |=  [pos=@ud kob=pack-delta-object]
      ^-  hash
      ?>  ?=(%ofs-delta -.kob)
      =+  haz=(~(get by dex) (sub pos offset.kob))
      ?~  haz
        ~|  "Unable to resolve delta: requested base object at {<pos>}: base={<base>}, offset={<offset.kob>}"  !!
      u.haz
    ::
    ++  resolve-delta
      |=  [pos=@ud kob=pack-delta-object]
      ^-  raw-object
      ?>  ?=(%ofs-delta -.kob)
      =+  haz=(resolve-base pos kob)
      ::  XX only works for self-contained packs
      ::  In general we also need to lookup the repository
      ::
      =+  rob=(~(got by ros) haz)
      =/  sea=stream:libstream  [0 byts.kob]
      ::  Read base and target sizes
      ::
      =^  biz  sea  (read-object-size:pak sea)
      =^  siz  sea  (read-object-size:pak sea)
      :: ~&  base-sz+biz
      :: ~&  target-sz+siz
      :: ~&  sea-stream+[pos.sea wid.byts.sea]
      ?>  =(wid.byts.rob biz)
      ::  New object data
      ::
      =|  red=stream
      ::  Process delta instructions
      ::  to resolve the object
      ::
      =<
      |-
      ?:  (is-dry:bys sea)
        [type.rob byts.red]
      =^  byt  sea  (read-bytes:bys 1 sea)
      =+  bat=(need byt)
      ?>  (lth pos.sea wid.byts.sea)
      :: ~&  delta-op+[pos.sea wid.byts.sea `@ux`bat]
      ?:  =(0x0 bat)
        ~|  "Resolve delta: hit reserved instruction 0x00"  !!
      =^  red  sea
        ?:  =(0 (dis bat 0x80))
          ::  Add data
          ::
          (add-data bat)
        ::  Copy data
        ::
        (copy-data bat)
      $(red red)
      ::
      |%
      ::
      ::  Add data instruction
      ::  0xxxxxxx
      ::
      ++  add-data
        |=  bat=@uxD
        ^-  [stream stream]
        :: ~&  resolve-add-data+`@ub`bat
        =+  siz=(dis bat 0x7f)
        ::  XX ideally red should be mutated in one
        ::  place for performance
        ::
        :: ~&  resolve-add-sz-bytes+siz
        (append-read-bytes:bys siz red sea)
      ::
      ::  Copy data instruction
      ::  1xxxxxxx
      ::
      ++  copy-data
        |=  bat=@uxD
        ^-  [stream stream]
        =+  ind=0
        =+  mak=0x1
        :: ~&  copy-data+bat
        ::  Retrieve offset
        ::
        =|  offset=@ud
        =^  offset  sea
        |-
        ?:  (gth mak 0x8)
          :_  sea
          offset
        =^  fet=@uxD  sea
          ?:  =(0 (dis bat mak))
            ::  XX remove sea here and
            ::  we get failure, but not nest
            ::  fail
            :_  sea
            0x0
          =^  tef  sea  (read-bytes:bys 1 sea)
          ?~  tef
            ~|  "Stream exhausted"  !!
          :_  sea
          u.tef
        %=  $
          ind  +(ind)
          mak  (lsh [0 1] mak)
          offset  (add offset (lsh [3 ind] fet))
        ==
        ::  Retrieve size
        ::
        =+  ind=0
        =+  mak=0x10
        =|  size=@ud
        =^  size  sea
        |-
        ?:  (gth mak 0x40)
          :_  sea
          ?:  =(0 size)
            `@ud`0x1.0000
          size
        =^  sal=@uxD  sea
          ?:  =(0 (dis bat mak))
            :_  sea
            0x0
          =^  las  sea  (read-bytes:bys 1 sea)
          :_  sea
          (need las)
        :: ~&  [ind mak sal size]
        %=  $
          ind  +(ind)
          mak  (lsh [0 1] mak)
          size  (add size (lsh [3 ind] sal))
        ==
        :_  sea
        -:(append-get-bytes:bys size red [offset byts.rob])
      --
    --
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
