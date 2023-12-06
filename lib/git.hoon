/-  *git
/+  zlib, stream
~%  %git  ..part  ~
::  
::  Git core
::
::  +obj -- object
::  +pak -- packfile
::  +bud -- bundle
::
::  XX  move bundle to a separate library, 
::  as it is not an integral part of git. 
::
|%
::
::  Object
::
++  obj
  |%
  ++  hax-sha-1  (bass 16 (stun [40 40] six:ab))
  ++  hax-sha-256  !!
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
  ++  parse-raw
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
    ?.  =(+.u.hed (sub p.octs +(u.pin)))
      ~|  "Object is corrupted: incorrect object length"  !!
    =/  typ=object-type
    :: XX Can we somehow cast?
      ?+  -.u.hed  ~|  "Unknown object type {<-.u.hed>}"  !!
          %blob    %blob
          %commit  %commit
          %tree    %tree
      ==
    [typ [+(u.pin) octs]]
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
  ++  parse
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
      ?>  ?=(%blob -.rob)
      =+  len=(sub p.octs.data.rob pos.data.rob)
      :+  %blob
      len
      (cut 3 [pos.data.rob len] q.octs.data.rob)
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
             %sha-1    hax-sha-1
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
      ?>  ?=(%commit -.rob)
      =+  txt=(trip q:(raw-data:obj rob))
      =+  com=(commit [[1 1] txt])
      ?~  q.com
        ~|  "Failed to parse commit object: syntax error {<p.com>} in {txt}"  !!
      commit+p.u.q.com
    ::
    ++  parse-tree
      :: |=  rob=$>(%tree raw-object)
      |=  rob=raw-object
      ^-  object
      ?>  ?=(%tree -.rob)
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
        tree+tes
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
  ++  rare
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
    (sha-1l:sha p.octs (rev 3 p.octs q.octs))
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
    ?-  hat
      %sha-1
      ((x-co:co 40) (rev 3 20 haz))
      ::
      %sha-256  !!
    ==
  --
::
::  Packfile
::
++  pak
  ~%  %pak  ..pak  ~
  |%
  ++  read
    |=  sea=stream:stream
    ^-  [pack-file stream:stream]
    ::  Record the base offset
    ::
    =^  hed  sea  (read-header sea)
    =/  hash-bytes=@ud
      ?-  version.hed
        %2  20  ::  sha-1
      ==
    ::  XX We simply pass the sea to avoid copying
    ::  huge atoms. 
    ::
    :_  sea
    [hed sea]
    ::  Read objects
    ::
    :: ~&  pack+"Pack file contains {<count.hed>} objects"
    :: =|  lob=(list (pair @ud pack-object))
    :: =^  lob  sea
    :: ::
    :: !.
    :: |-
    :: ?:  =(0 count.hed)
    ::   :_  sea
    ::   lob
    ::  Record object offset
    ::
    :: =/  fet=@ud  pos.sea
    :: =^  kob=pack-object  sea  (read-object sea)
    :: %=  $
    ::   count.hed  (dec count.hed)
    ::   lob  [[fet kob] lob]
    :: ==
    :: :: XX verify pack integrity
    :: :: XX parametrize by hash type
    :: ::
    :: =^  hax  sea  (read-bytes:stream hash-bytes sea)
    :: ?~  hax
    ::   ~|  "Pack file is corrupted: no checksum found"  !!
    :: :_  sea
    :: [hed (flop lob)]
  ::
  ++  read-header
    |=  sea=stream:stream
    ^-  [pack-header stream:stream]
    =^  sig  sea  (read-bytes:stream 4 sea)
    ?~  sig
      ~|  "Pack file is corrupted: no signature found"  !!
    ?.  =(q.u.sig 'PACK')
      ~|  "Pack file is corrupted: invalid signature {<`@t`q.u.sig>} ({<p.u.sig>} bytes)"  !!
    =^  version  sea  (read-bytes:stream 4 sea)
    ?~  version
      ~|  "Pack file is corrupted: no version found"  !!
    =^  count  sea  (read-bytes:stream 4 sea)
    ?~  count
      ~|  "Pack file is corrupted: no object count found"  !!
    =+  ver=(rev 3 4 q.u.version)
    =+  cot=(rev 3 4 q.u.count)
    ?>  ?=(%2 ver)
    :_  sea
    [ver cot]
  ::
  ++  pack-hash-bytes
    |=  hed=pack-header
    ^-  @ud
    ?-  version.hed
      %2  20
    ==
  ++  pack-hash-type
    |=  hed=pack-header
    ^-  hash-type
    ?-  version.hed
      %2  %sha-1
    ==
  ::
  ++  index
    |=  =pack-file
    ^-  pack
    =*  sea  data.pack-file
    =+  pos=pos.sea
    =|  count=@ud
    =|  index=pack-index
    =.  index
    !.
    |-
    ?.  (lth count count.header.pack-file)
      index
    ?:  (is-dry:stream sea)
      ~|  "Expected {<count.header.pack-file>} objects ({<count>} processed)"
        !!
    ~&  pack-index+"{<+(count)>}/{<count.header.pack-file>}"
    =+  start=pos.sea
    :: ~&  pack-offset+start
    =^  kob=pack-object  sea  (read-pack-object sea)
    =/  rob=raw-object
      ?:  ?=(raw-object kob)
        kob
      (resolve-delta-object kob sea)
    =+  hax=(hash-raw:obj (pack-hash-type header.pack-file) rob)
    :: ~&  hax
    ?:  (~(has by index) hax)
      ~&  rob
      ~|  "Object {<hax>} duplicated: indexed at {<(~(get by index) hax)>}"  !!
    %=  $
      index  (~(put by index) [hax pos])
      count  +(count)
    ==
    :: XX verify pack integrity
    :: XX parametrize by hash type
    ::
    =^  hax  sea  
      (read-bytes:stream (pack-hash-bytes header.pack-file) sea)
    ?~  hax
      ~|  "Pack file is corrupted: no checksum found"  !!
    ~&  pack-checksum+`@ux`q:(need hax)
    [index [pos octs.sea]]
  ::
  ++  resolve-delta-object
    |=  [delta=pack-delta-object sea=stream:stream]
    ^-  raw-object
    ::  XX  handle ref-delta
    ?>  ?=(%ofs-delta -.delta)
    ::  Generate chain of delta objects terminating 
    ::  at the first encountered non-delta object
    ::
    ::  XX introduce cache (map pos raw-object)
    ::  storing certain number of recently resolved objects
    ::
    =/  chain=(lest pack-delta-object)
      ~[delta]
    =^  base=raw-object  chain
    |-
    :: ~&  i.chain
    ::  XX is there a better way?
    ::  use a lest?
    ::
    ?~  chain  !!
    ?>  ?=(%ofs-delta -.i.chain)
    =/  kob=pack-object  
      =<  -
      %+  read-pack-object
        (sub pos.i.chain base-offset.i.chain)
        octs.sea
    ?:  ?=(pack-delta-object kob)
      $(chain [kob chain])
    [kob chain]
    ::
    :: ~&  delta-chain+(lent chain)
    ::
    (resolve-delta-chain base chain sea)
  ::  Resolve a raw object from 
  ::  a base and a chain of delta objects
  ::
  ++  resolve-delta-chain
    |=  $:  base=raw-object 
            chain=(list pack-delta-object) 
            sea=stream:stream
        ==
    ^-  raw-object
    ::  resolved object data
    ::
    |-
    ?~  chain
      base
    =+  delta=i.chain
    %=  $
      chain  t.chain
      base  (expand-delta-object base delta)
    ==
  ::  Resolve a delta object against
  ::  a base
  ::
  ++  expand-delta-object
    ~/  %expand-delta-object
    |=  [base=raw-object delta=pack-delta-object]
    ^-  raw-object
    ?>  ?=(%ofs-delta -.delta)
    =/  sea=stream:stream  0+octs.delta
    ::  Read base and target sizes
    ::
    =^  biz=@ud  sea  (read-object-size sea)
    =^  siz=@ud  sea  (read-object-size sea)
    ::  Verify base size
    ::
    ?>  =((raw-size:obj base) biz)
    ::  Expanded object data
    ::
    =|  red=stream:stream
    ::  Process delta instructions
    ::  to resolve the object
    ::
    =<
    |-
    ?:  (is-dry:stream sea)
      ::  Verify target size
      =+  rob=[type.base 0+octs.red]
      ?>  =((raw-size:obj rob) siz)
      rob
      :: (parse-raw:obj octs.red)
    =^  byt  sea  (read-byte:stream sea)
    =+  bat=(need byt)
    ::  XX why is this needed?
    ?>  (lth pos.sea p.octs.sea)
    :: ~&  delta-op+[pos.sea p.octs.sea `@ux`bat]
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
      ^-  [stream:stream stream:stream]
      =+  siz=(dis bat 0x7f)
      (append-read-bytes:stream siz red sea)
    ::
    ::  Copy data instruction
    ::  1xxxxxxx
    ::
    ++  copy-data
      |=  bat=@uxD
      ^-  [stream:stream stream:stream]
      =+  ind=0
      =+  mak=0x1
      ::  Retrieve offset
      ::
      ::  XX this looks quite convoluted
      ::  -- try to rewrite.
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
        =^  tef  sea  (read-byte:stream sea)
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
        =^  las  sea  (read-byte:stream sea)
        :_  sea
        (need las)
      :: ~&  [ind mak sal size]
      %=  $
        ind  +(ind)
        mak  (lsh [0 1] mak)
        size  (add size (lsh [3 ind] sal))
      ==
      :: ~&  copy-data+[size=size offset=offset]
      :_  sea
      =<  -
      %^  append-get-bytes:stream  
        size
        red
        [offset octs.data.base]
    --
  ::
  ++  read-pack-object
    |=  sea=stream:stream
    ^-  [pack-object stream:stream]
    =/  [[typ=pack-object-type size=@ud] red=stream:stream]
      (read-object-type-size sea)
    :: ~&  read-pack-object+pos.sea
    :: ~&  read-pack-object+[typ size]
    ?+  typ
      ::
      ::  XX
      ::  sea could be very large (hundreds of MB)
      ::  is modifying whole sea efficient?
      ::
      ::  It  seems it should be, since the big atom 
      ::  is not modified, only the position pointer 
      ::  is changed.
      ::
      ::  XX  byts v octs
      =^  data=octs  sea  (expand:zlib red)
      ?.  =(p.data size)
        ~|  "Object is corrupted: size mismatch (stated {<size>}b uncompressed {<p.data>}b)"  !!
      :_  sea
      ::  XX parametrize by hash type
      ::
      [typ 0+data]
    ::
    %ofs-delta  (read-object-ofs pos.sea red)
    ::
    %ref-delta  !!
    ::
    ==
  ::
  ++  read-object-ofs
    |=  [pos=@ud sea=stream:stream]
    ^-  [pack-object stream:stream]
    =^  base-offset=@ud  sea  (read-offset sea)
    ::  XX this check could be wrong
    ::  the stream position might
    ::  not be relative to the beginning of the packfile, 
    ::  but, for instance, to a bundle file. 
    ::
    ?<  |(=(0 base-offset) (gte base-offset pos))
    =^  dat  sea  (expand:zlib sea)
    :_  sea
    [%ofs-delta pos base-offset dat]
  ::
  ++  read-offset
    |=  sea=stream:stream
    ^-  [@ud stream:stream]
    =+  fet=0
    ::  XX put a safety stop
    ::  to prevent infinite loop here
    ::  and at read-object-type-size
    ::
    |-
    ::  XX introduce unsafe read-byte?
    =^  bat  sea  (read-byte:stream sea)
    ?~  bat  !!
    =+  tef=(add (lsh [0 7] fet) (dis 0x7f u.bat))
    ?:  =(0 (dis 0x80 u.bat))
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
    |=  sea=stream:stream
    ^-  [[pack-object-type @ud] stream:stream]
    =^  bat  sea  (read-byte:stream sea)
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
    |=  sea=stream:stream
    ^-  [@ud stream:stream]
    =|  bits=@ud
    =|  size=@ud
    |-
    =^  bat  sea  (read-byte:stream sea)
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
      ::  5 is reserved
      %6  `%ofs-delta
      %7  `%ref-delta
    ==
  ::
  ++  is-delta
    |=  kob=pack-object
    ^-  ?
    ?=(?(%ofs-delta %ref-delta) -.kob)
  ::
  ++  is-raw
    |=  kob=pack-object
    ^-  ?
    !(is-delta kob)
  :: ++  object-size
  ::   |=  [qad=@ux sel=(list @ux)]
  ::   ^-  @ud
  ::   =/  sez  0
  ::   =/  size=@ud
  ::   |-
  ::   ?~  sel
  ::     sez
  ::   $(sel +:sel, sez (add (lsh [0 7] sez) -:sel))
  ::   ::
  ::   :: ~&  [qad `@ux`size]
  ::   (add (lsh [2 1] size) qad)
  --
::
::  Bundle
::
++  bud
  |%
  ++  read
    |=  sea=stream:stream
    ^-  [bundle stream:stream]
    =^  hed  sea  (read-header:bud sea)
    =^  pack-file  sea  (read:pak sea)
    =+  pak=(index:pak pack-file)
    :_  sea
    [header=hed pak]
  ::
  ++  read-header
    |=  sea=stream:stream
    ^-  [bundle-header stream:stream]
    ::  Parse signature
    ::
    =^  line  sea  (read-line:stream sea)
    ?~  line
      ~|  "Git bundle is corrupted: signature absent"  !!
    =/  signature
      ;~(sfix (cold %2 (jest '# v2 git bundle')) (just '\0a'))
    =+  sig=(rust (trip q.u.line) signature)
    ?~  sig
      ~|  "Git bundle is corrupted: invalid signature"  !!
    ::  Choose hash type and parser
    ::
    =/  [hat=hash-type hax=_hax-sha-1:obj]
      ?:  ?=(%2 u.sig)
        [%sha-1 hax-sha-1:obj]
      !!
    ::  Compose with parsers
    ::
    =<
    ::  Parse prerequisites
    ::
    =^  reqs=(list hash)  sea
    %.  ~
    |=  reqs=(list hash)
    =+  [line red]=(read-line:stream sea)
    ?~  line 
      ~|  "Git bundle is corrupted: invalid header"  !!
    =/  hax=(unit hash)  (rust (trip q.u.line) required)
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
    =+  [line red]=(read-line:stream sea)
    ?~  line 
      ~|  "Git bundle is corrupted: invalid header"  !!
    =/  ref=(unit [hash path])  (rust (trip q.u.line) reference)
    ?~  ref
      :: ~&  "Failed to parse '{u.-.nex}'"
      [refs sea]
    $(refs [[+.u.ref -.u.ref] refs], sea red)
    :: Parse newline indicating end of bundle header
    ::
    =^  line  sea  (read-line:stream sea)
    ?~  line
      ~|  "Git bundle is corrupted: header not terminated"  !!
    ?:  (gth p.u.line 1)
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
::  Repository engine
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
    =/  haz=@ux  (hash:obj hash-type.repo obe)
    ?<  (has haz)
    repo(objects (~(put by objects.repo) [haz obe]))
  ++  wyt
    |-
    ~(wyt by objects.repo)
  ::
  ++  put-raw
    |=  rob=raw-object
    ^-  repository
    =/  haz=@ux  (hash-raw:obj hash-type.repo rob)
    ?<  (has haz)
    repo(objects (~(put by objects.repo) [haz (parse:obj hash-type.repo rob)]))
  ::
  ::
  ::  Key size in half-bytes
  ::
  ++  key-size  ?-  hash-type.repo
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
    |=  [a=octs b=@ux]
    ^-  ?
    ?:  =(a b)
      &
    ::  Size in half-bytes
    ::
    .=  q.a
    %+  cut  2
      :_  b
      [(sub key-size p.a) p.a]
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
    *repository
    :: ?>  =(2 version.header.bud)
    :: ::  Verify we have all required objects
    :: ::
    :: ::  XX Can we get hash.repo+hax syntax to work?
    :: ::
    :: =+  mis=(turn reqs.header.bud |=(haz=@ux (has haz)))
    :: ?:  (gth (lent mis) 0)
    ::   ~|  "Bundle can not be unpacked, missing prerequisites {<mis>}"  !!
    :: ::  Unpack and merge
    :: ::
    :: =+  ros=(index pack.bud)
    :: ::  XX  Load objects
    :: ::
    :: =.  objects.repo
    ::   %-  ~(uni by objects.repo)
    ::   %-  ~(run by ros)
    ::   |=(rob=raw-object (parse:obj hash-type.repo rob))
    :: ::  Read and verify references
    :: ::
    :: =+  ref=refs.header.bud
    :: =.  repo
    :: |-
    :: ?~  ref
    ::   repo
    :: ?.  (has +.i.ref)
    ::   ~|  "Bundle contains reference to unknown object {<+.i.ref>}"  !!
    :: $(refs.repo (~(put by refs.repo) i.ref), ref t.ref)
    :: ::
    :: repo
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
