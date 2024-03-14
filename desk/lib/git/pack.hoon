::
::::  Git pack
  ::
/+  *git, stream
~%  %git-pack  ..part  ~
|%
:: Below does not work, unless object-type
:: is in the same file.
:: +$  pack-object-type  $?  object-type
::                           %ofs-delta
::                           %ref-delta
::                       ==
+$  pack-object-type  $?  %commit
                          %tree
                          %blob
                          %tag
                          %ofs-delta
                          %ref-delta
                      ==
+$  pack-object  $%  raw-object
                     [%ofs-delta pos=@ud base-offset=@ud =octs]
                     [%ref-delta =octs]
                 ==
+$  pack-delta-object  $>(?(%ofs-delta %ref-delta) pack-object)

+$  pack-header  [version=%2 count=@ud]
::  XX different comparison functions 
::  do not throw error!
::  Is it possible to extract comparison 
::  function from pack-index?
::
+$  pack-index   ((mop hash @ud) lth)
++  pack-on  ((on hash @ud) lth)
+$  pack  [=hash-type index=pack-index data=stream:libstream]
::
++  read
  |=  sea=stream:stream
  ^-  pack
  ?>  (gte p.octs.sea (met 3 q.octs.sea))
  =^  header=pack-header  sea  (read-header sea)
  (index header sea)
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
  |=  [header=pack-header sea=stream:stream]
  ^-  pack
  =+  pos=pos.sea
  =|  count=@ud
  =|  index=pack-index
  =.  index
    |-
    ?.  (lth count count.header)
      index
    ?:  (is-dry:stream sea)
      ~|  "Expected {<count.header>} objects ({<count>} processed)"
        !!
    ~?  &(=(0 (mod count 10.000)) (gth count 0))
      pack-index+"{<+(count)>}/{<count.header>}"
    =+  beg=pos.sea
    =^  pob=pack-object  sea  (read-pack-object sea)
    =/  rob=raw-object
      (resolve-object pob sea)
    =+  hax=(hash-raw:obj (pack-hash-type header) rob)
    ?>  (gte p.octs.data.rob (met 3 q.octs.data.rob))
    ?:  (~(has by index) hax)
      ~|  "Object {<hax>} duplicated: indexed at {<(~(get by index) hax)>}"  !!
    %=  $
      index  (put:pack-on index hax beg)
      count  +(count)
    ==
  :: XX verify pack integrity
  :: XX parametrize by hash type
  ::
  =^  hax  sea  
    (read-bytes:stream (pack-hash-bytes header) sea)
  ?~  hax
    ~|  "Pack file is corrupted: no checksum found"  !!
  :: ~&  pack-checksum+`@ux`q:(need hax)
  :-  (pack-hash-type header)
  [index [pos octs.sea]]
::
++  resolve-object
  |=  [pob=pack-object sea=stream:stream]
  ^-  raw-object
  ?:  ?=(raw-object pob)
    pob
  (resolve-delta-object pob sea)
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
    ?>  ?=(%ofs-delta -.i.chain)
    =/  kob=pack-object  
      =<  -
      %+  read-pack-object
        (sub pos.i.chain base-offset.i.chain)
        octs.sea
    ?:  ?=(pack-delta-object kob)
      $(chain [kob chain])
    [kob chain]
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
    base   (expand-delta-object base delta)
  ==
::  Resolve a delta object against
::  a base
::
++  expand-delta-object
  ~/  %expand-delta-object
  !:
  |=  [base=raw-object delta=pack-delta-object]
  ^-  raw-object
  ?>  ?=(%ofs-delta -.delta)
  =/  sea=stream:stream  0+octs.delta
  ::  Read base and target sizes
  ::
  =^  biz=@ud  sea  (read-object-size sea)
  =^  siz=@ud  sea  (read-object-size sea)
  :: ~&  expand-to+[type=type.base biz siz]
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
    :: ~&  add-data+siz=siz
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
  =+  pos=pos.sea
  =^  [typ=pack-object-type size=@ud]  sea
    (read-object-type-size sea)
  ?+  typ
    =^  data=octs  sea  (expand:zlib sea)
    ?.  =(p.data size)
      ~|  "Object is corrupted: size mismatch (stated {<size>}b uncompressed {<p.data>}b)"  !!
    :_  sea
    ::  XX parametrize by hash type
    ::
    [typ 0+data]
  ::
  %ofs-delta  (read-object-ofs pos sea)
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
++  get-raw
  |=  [=pack hax=hash]
  ^-  (unit raw-object)
  =+  pin=(get:pack-on index.pack hax)
  ?~  pin
    ~
  =+  sea=[u.pin octs.data.pack]
  =^  pob  sea  (read-pack-object sea)
  `(resolve-object pob sea)
++  get
  |=  [=pack hax=hash]
  ^-  (unit object)
  =+  obe=(get-raw pack hax)
  ::  XX Why is this function called a bind?
  ::
  (bind obe (cury parse-raw:obj hash-type.pack))
++  got-raw
  |=  [=pack hax=hash]
  ^-  raw-object
  =+  pin=(get:pack-on index.pack hax)
  ?~  pin  !!
  =+  sea=[u.pin octs.data.pack]
  =^  pob  sea  (read-pack-object sea)
  (resolve-object pob sea)
++  got
  |=  [=pack hax=hash]
  ^-  object
  =+  obe=(got-raw pack hax)
  (parse-raw:obj hash-type.pack obe)
++  has
  |=  [=pack =hash]
  ^-  ?
  (has:pack-on index.pack hash)
::
::  Find objects whose hashes match the 
::  key @a
::
++  find-by-key
  |=  [=pack a=@ta]
  ^-  (list hash)
  =+  kex=(to-hex a)
  =+  key=[(met 3 a) kex]
  ::  The matching keys are in the range a..a+1
  ::
  =+  len=(met 3 (crip ((x-co:co 0) +(kex))))
  =+  fen=(sub (key-size hash-type.pack) len)
  =+  end=(lsh [2 fen] +(kex))
  =|  hey=(list @ux)
  =<  -  
  %^  (dip:pack-on _hey)  
    index.pack
  hey
    |=  [hey=(list @ux) item=[hash @ud]]
    ?.  (compare:pack-on -.item end)
      [`+.item & hey]
    ?:  (match-key (key-size hash-type.pack) key -.item)
      [`+.item & [-.item hey]]
    [`+.item | hey]
::  XX remove after moving out repository to its
::  own library
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
--
