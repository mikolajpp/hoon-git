::
::::  Git pack
  ::
/-  spider
/+  bs=bytestream, zlib
/+  *git-hash, *git-object
=,  strand=strand:spider
|%
+$  pack-object-type  $?  object-type
                          %ofs-delta
                          %ref-delta
                      ==
+$  pack-object-header  [type=pack-object-type size=@ud]
+$  pack-object  $%  raw-object
                     [%ofs-delta pos=@ud base-offset=@ud =octs]
                     [%ref-delta pos=@ud =hash =octs]
                 ==
+$  pack-delta-object  $>(?(%ofs-delta %ref-delta) pack-object)

+$  pack-header  [version=%2 count=@ud]
::  Is it possible to extract comparison 
::  function from pack-index?
:: 
++  hash-cmp  gth
+$  pack-index   ((mop hash @ud) hash-cmp)
++  pack-on  ((on hash @ud) hash-cmp)
::  +pack-cache: store recently resolved objects
::
+$  pack-cache  [count=@ud store=(list (pair @ud raw-object))]
+$  pack  $:  =hash-algo
              count=@ud 
              index=pack-index 
              ::  Checksum position
              end-pos=@ud 
              stream=bays:bs
          ==
+$  store-raw-get  $-(hash (unit raw-object))
--
~%  %git-pack  ..part  ~
|%
++  read
  |=  sea=bays:bs
  ^-  pack
  (read-thin sea |=(* !!))
++  read-thin
  |=  [sea=bays:bs get=store-raw-get]
  ^-  pack
  :: ?>  (gte p.octs.sea (met 3 q.octs.sea))
  =+  start=pos.sea
  =^  header=pack-header  sea  (read-header sea)
  =+  beg-pos=pos.sea
  =^  [=pack miss=(list raw-object)]  
    sea  (index header sea get)
  ::  Verify integrity
  ::
  =+  end=pos.sea
  =^  hash  sea
    (read-octs-maybe:bs (pack-hash-bytes header) sea)
  ?~  hash 
    ~|  "Pack file is corrupted: no checksum found"  !!
  ?>  =(pos.sea p.octs.sea)
  =+  len=(sub end start)
  =+  check=(hash-octs-sha-1 len (rsh [3 start] q.octs.sea))
  ?>  =(q.u.hash check)
  ::  XX read-thin should return the list 
  ::  of missing objects instead of thickening the pack
  ::
  :: =+  pack=(insert-objects pack miss)
  pack(pos.stream beg-pos)
::
++  read-header
  |=  sea=bays:bs
  ^-  [pack-header bays:bs]
  =^  sig  sea  (read-octs-maybe:bs 4 sea)
  ?~  sig
    ~|  "Pack file is corrupted: no signature found"  !!
  ?.  =(q.u.sig 'PACK')
    ~|  "Pack file is corrupted: invalid signature {<`@t`q.u.sig>} ({<p.u.sig>} bytes)"  !!
  =^  version  sea  (read-octs-maybe:bs 4 sea)
  ?~  version
    ~|  "Pack file is corrupted: no version found"  !!
  =^  count  sea  (read-octs-maybe:bs 4 sea)
  ?~  count
    ~|  "Pack file is corrupted: no object count found"  !!
  =+  ver=(rev 3 4 q.u.version)
  =+  cot=(rev 3 4 q.u.count)
  ?>  ?=(%2 ver)
  :_  sea
  [ver cot]
++  insert-objects
  |=  [=pack list=(list raw-object)]
  ^-  ^pack
  ::  XX modify header to increase the count
  ::
  ::  Assemble object data
  ::
  ?~  list
    pack
  =+  start=pos.stream.pack
  =.  pos.stream.pack  end-pos.pack
  =.  pack
    ::  XX can the type system be improved to avoid this cast?
    ::
    %+  roll  `(^list raw-object)`list
      |=  [rob=raw-object =_pack]
      %=  pack
        stream
          %+  write-octs:bs  stream.pack
            (raw-to-octs rob)
        index
          =+  hash=(hash-raw %sha-1 rob)
          %^  put:pack-on  index.pack
            hash
          pos.stream.pack
        count  +(count.pack)
      ==
  =+  sea=stream.pack
  =+  end-pos=pos.sea
  =+  hash=(hash-octs-sha-1 octs.sea)
  =.  sea  (append-octs:bs sea [20 hash])
  pack(stream sea(pos start))
::
++  pack-hash-bytes
  |=  hed=pack-header
  ^-  @ud
  ?-  version.hed
    %2  20
  ==
++  pack-hash-algo
  |=  hed=pack-header
  ^-  hash-algo
  ?-  version.hed
    %2  %sha-1
  ==
:: 
::  Index a pack, returning index together 
::  with a list of objects missing from the pack.
::
++  index
  |=  $:  header=pack-header
          sea=bays:bs
          get=store-raw-get
      ==
  ^-  [[pack (list raw-object)] bays:bs]
  =+  start=pos.sea
  =|  count=@ud
  =/  step=@ud
    =-  ?:((gth - 0) - 1)
    (div count.header 10)
  =|  index=pack-index
  =+  cache-limit=10
  =|  cache=pack-cache
  =|  miss=(list raw-object)
  =^  [=_index =_miss]  sea
    |-
    ?.  (lth count count.header)
      :_  sea
      :_  miss
      index
    ?:  (is-empty:bs sea)
      ~|  "Expected {<count.header>} objects ({<count>} processed)"
        !!
    ~?  >  =(0 (mod count step))
      indexing-objects+"{<+(count)>}/{<count.header>}"
    =+  beg=pos.sea
    =^  pob=pack-object  sea  (read-pack-object sea)
    =/  [rob=raw-object miso=(unit raw-object)]
      (resolve-raw-object-miss pob index cache sea get)
    ::  cache resolved delta object
    ::
    =?  cache  ?=(pack-delta-object pob)
      =?  cache  =(count.cache cache-limit)
        ::  Shave off 5 latest objects
        ::
        =+  new=(sub count.cache 5)
        %=  cache
          count  new
          store  (scag new store.cache)
        ==
      %=  cache
        count  +(count.cache)
        store  [[beg rob] store.cache]
      ==
    =+  hash=(hash-raw (pack-hash-algo header) rob)
    ?:  (~(has by index) hash)
      ~|  "Object {<hash>} duplicated: indexed at {<(~(get by index) hash)>}"  !!
    %=  $
      index  (put:pack-on index hash beg)
      count  +(count)
      miss   ?~(miso miss [u.miso miss])
    ==
  :_  sea
  :_  miss
  :-  (pack-hash-algo header)
  [count.header index end-pos=pos.sea [start octs.sea]]
::
::  Resolve raw object, potentially obtaining 
::  a missing object base object through the get gate
::
++  resolve-raw-object-miss
  |=  $:  pob=pack-object 
          index=pack-index
          cache=pack-cache
          sea=bays:bs
          get=store-raw-get
      ==
  ^-  [raw-object (unit raw-object)]
  ?:  ?=(raw-object pob)
    [pob ~]
  (resolve-delta-object pob index cache sea get)
++  resolve-delta-object
  |=  $:  delta=pack-delta-object 
          index=pack-index
          cache=pack-cache
          sea=bays:bs
          get=store-raw-get
      ==
  ^-  [raw-object (unit raw-object)]
  ::  Generate chain of delta objects terminating 
  ::  at the first resolved object
  ::
  =/  chain=(lest pack-delta-object)
    ~[delta]
  =^  base=raw-object  chain
    |-
    =+  pob=i.chain
    =/  kob=pack-object
      ?-  -.pob
        %ofs-delta
          =+  pos=(sub pos.pob base-offset.pob)
          ::  cached raw object
          ::
          =*  store  store.cache
          =/  cob=(unit raw-object)
            |-  ?~  store  ~
            ?:  =(pos p.i.store)
              (some q.i.store)
            $(store t.store)
          ?^  cob
            u.cob
          =<(- (read-pack-object pos octs.sea))
        %ref-delta
          =/  pos=(unit @ud)
            (get:pack-on index hash.pob)
          ?~  pos
            (need (get hash.pob))
          ::  cached raw object
          ::
          =*  store  store.cache
          =/  cob=(unit raw-object)
            |-  ?~  store  ~
            ?:  =(pos p.i.store)
              (some q.i.store)
            $(store t.store)
          ?^  cob
            u.cob
          =<(- (read-pack-object u.pos octs.sea))
      ==
    ?:  ?=(pack-delta-object kob)
      $(chain [kob chain])
    [kob chain]
  =+  res=(resolve-delta-chain base chain sea)
  :: Is the base missing?
  ::
  ?.  (has:pack-on index (hash-raw %sha-1 base))
    [res `base]
  [res ~]
++  resolve-raw-object
  |=  $:  pob=pack-object 
          index=pack-index
          cache=pack-cache
          sea=bays:bs 
          get=store-raw-get
      ==
  ^-  raw-object
  -:(resolve-raw-object-miss pob index cache sea get)
::  Resolve a raw object from 
::  a base and a chain of delta objects
::
++  resolve-delta-chain
  |=  $:  base=raw-object 
          chain=(list pack-delta-object) 
          sea=bays:bs
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
::  Resolve delta object against
::  a base
::
++  expand-delta-object
  |=  [base=raw-object delta=pack-delta-object]
  ^-  raw-object
  =/  sea=bays:bs  (from-octs:bs octs.delta)
  ::  Read base and target sizes
  ::
  =^  biz=@ud  sea  (read-object-size sea)
  =^  siz=@ud  sea  (read-object-size sea)
  ::  Verify base size
  ::
  ?>  =(size.base biz)
  ::  Expanded object data
  ::
  =|  chunks=(list octs)
  ::  Process delta instructions
  ::  to resolve the object
  ::
  =<
  |-
  ?:  (is-empty:bs sea)
    ::  Verify target size
    ~?  (gth siz 10.000)
      expand-delta-object-chunks+(lent chunks)
    =/  data
      (can-octs:bs (flop chunks))
    =/  rob=raw-object
      [type.base p.data data]
    ?>  =(size.rob siz)
    rob
  ::  parse instruction: add or copy
  ::
  ::  XX is pinning efficient?
  =^  bat  sea  (read-byte:bs sea)
  ::  XX why is this needed?
  ?>  (lth pos.sea p.octs.sea)
  ?:  =(0x0 bat)
    ~|  "Resolve delta: hit reserved instruction 0x00"  !!
  =^  data  sea
    ?:  =(0 (dis bat 0x80))
      ::  Add data
      ::
      (add-data bat)
    ::  Copy data
    ::
    (copy-data bat)
  ::  XX this seems uneccessary?
  $(chunks [data chunks])
  ::
  |%
  ::
  ::  Add instruction
  ::  0xxxxxxx
  ::
  ++  add-data
    |=  bat=@uxD
    ^-  [octs bays:bs]
    =+  siz=(dis bat 0x7f)
    :: ~&  add-data+siz=siz
    (read-octs:bs siz sea)
  ::
  ::  Copy instruction
  ::  1xxxxxxx
  ::
  ++  copy-data
    |=  bat=@uxD
    ^-  [octs bays:bs]
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
      =^  tef  sea  (read-byte:bs sea)
      :_  sea
      tef

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
      =^  las  sea  (read-byte-maybe:bs sea)
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
    [size (cut 3 [offset size] q.data.base)]
  --
::
++  read-with-index
  |=  [=pack =hash]
  ^-  [pack-object bays:bs]
  =+  pin=(got:pack-on index.pack hash)
  (read-pack-object (seek-to:bs pin stream.pack))
++  read-pack-object
  |=  sea=bays:bs
  ^-  [pack-object bays:bs]
  =+  pos=pos.sea
  =^  [type=pack-object-type size=@ud]  sea
    (read-pack-object-header sea)
  ?+  type
    =^  data=octs  sea  (expand:zlib sea)
    ?.  =(p.data size)
      ~|  "Object is corrupted: size mismatch (stated {<size>}b uncompressed {<p.data>}b)"  !!
    :_  sea
    ::  XX parametrize by hash type
    ::
    [type size data]
  ::
  %ofs-delta  (read-object-ofs pos sea)
  ::
  %ref-delta  (read-object-ref pos sea)
  ::
  ==
::
++  read-object-ref
  |=  [pos=@ud sea=bays:bs]
  ^-  [pack-delta-object bays:bs]
  =^  =hash  sea  (read-hash sea)
  =^  =octs  sea  (expand:zlib sea)
  :_  sea
  [%ref-delta pos hash octs]
++  read-hash
  |=  sea=bays:bs
  ^-  [hash bays:bs]
  =^  octs  sea  (read-octs:bs 20 sea)
  :_  sea
  q:octs
++  read-object-ofs
  |=  [pos=@ud sea=bays:bs]
  ^-  [pack-delta-object bays:bs]
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
  |=  sea=bays:bs
  ^-  [@ud bays:bs]
  =+  fet=0
  ::  XX put a safety stop
  ::  to prevent infinite loop here
  ::  and at read-pack-object-header
  ::
  |-
  =^  bat  sea  (read-byte:bs sea)
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
++  read-pack-object-header
  |=  sea=bays:bs
  ^-  [pack-object-header bays:bs]
  =^  bat  sea  (read-byte:bs sea)
  =+  tap=(dis (rsh [2 1] bat) 0x7)
  =/  typ  (to-object-type tap)
  ?~  typ
    ~|  "Invalid pack object type {<tap>}"  !!
  ::  Decode object size
  ::
  =/  siz=@ud  (dis bat 0xf)
  ?:  =(0 (dis bat 0x80))
    :_  sea
    [u.typ siz]
  =^  tiz=@ud  sea  (read-object-size sea)
  =.  siz  (add (lsh [0 4] tiz) siz)
  :_  sea
  [u.typ siz]
::
++  read-object-size
  |=  sea=bays:bs
  ^-  [@ud bays:bs]
  =|  bits=@ud
  =|  size=@ud
  |-
  =^  bat  sea  (read-byte:bs sea)
  ?:  =(0 (dis bat 0x80))
    :_  sea
    (add size (lsh [0 bits] bat))
  %=  $
    size  (add size (lsh [0 bits] (dis bat 0x7f)))
    bits  (add bits 7)
  ==
::
++  to-object-type
  |=  ryt=@ud
  ^-  (unit pack-object-type)
  ::  XX A case rune
  ::  ?*  ryt  ~
  ::  1  `%commit
  ::  ...
  ::
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
--
::  
::  Pack interface
::
|_  pak=pack
++  get-raw
  |=  hax=hash
  ^-  (unit raw-object)
  =+  pin=(get:pack-on index.pak hax)
  ?~  pin
    ~
  =+  sea=(seek-to:bs u.pin stream.pak)
  =^  pob  sea  (read-pack-object sea)
  `(resolve-raw-object pob index.pak *pack-cache sea |=(* !!))
++  get-raw-thin
  |=  [hax=hash get=store-raw-get]
  ^-  (unit raw-object)
  =+  pin=(get:pack-on index.pak hax)
  ?~  pin
    ~
  =+  sea=(seek-to:bs u.pin stream.pak)
  =^  pob  sea  (read-pack-object sea)
  `(resolve-raw-object pob index.pak *pack-cache sea get)
++  get
  |=  hax=hash
  ^-  (unit object)
  =+  obe=(get-raw hax)
  ::  XX Why is this function called a bind?
  ::
  (bind obe (cury parse-raw hash-algo.pak))
++  get-header
  |=  hax=hash
  ^-  (unit object-header)
  =+  pin=(get:pack-on index.pak hax)
  ?~  pin
    ~
  =+  offset=u.pin
  |-
  =/  sea  (seek-to:bs offset stream.pak)
  =^  header=pack-object-header  sea
    (read-pack-object-header sea)
  ?:  ?=(object-header header)
    `header
  ?>  ?=(%ofs-delta type.header)
  $(offset (sub offset -:(read-offset sea)))
++  got-raw
  |=  hax=hash
  ^-  raw-object
  =+  pin=(get:pack-on index.pak hax)
  ?~  pin  !!
  =+  sea=(seek-to:bs u.pin stream.pak)
  =^  pob=pack-object  sea  (read-pack-object sea)
  (resolve-raw-object pob index.pak *pack-cache sea |=(* !!))
++  got
  |=  hax=hash
  ^-  object
  =+  obe=(got-raw hax)
  (parse-raw hash-algo.pak obe)
++  got-header
  |=  =hash
  ^-  object-header
  (need (get-header hash))
++  has
  |=  =hash
  ^-  ?
  (has:pack-on index.pak hash)
::
::  Find objects whose hashes match the 
::  key @a
::
++  find-by-key
  |=  a=@ta
  ^-  (list hash)
  =+  kex=(to-hex a)
  ::  All sizes in half-bytes
  =+  key=[(met 3 a) kex]
  ::  The matching keys are in the range a..a+1
  ::
  =+  len=(met 3 (crip ((x-co:co 0) +(kex))))
  =|  hey=(list @ux)
  =<  -  
  %^  (dip:pack-on _hey)  
    index.pak
  hey
    |=  [hey=(list @ux) item=[hash @ud]]
    ?.  (compare:pack-on -.item kex)
      [`+.item & hey]
    ?:  (match-key (key-size hash-algo.pak) key -.item)
      [`+.item & [-.item hey]]
    [`+.item | hey]
::  XX remove after moving out repository to its
::  own library
::
++  to-hex
  |=  a=@ta
  ^-  @ux
  (scan (trip a) parse-short-sha-1)
++  key-size  
  |=  hat=hash-algo
  ?-  hat
    %sha-1    40
    %sha-256  !!
  ==
++  match-key
  |=  [size=@ud a=octs b=@ux]
  ^-  ?
  ?:  =(a b)
    &
  ::  Size in half-bytes
  ::
  .=  q.a
  %+  cut  2
    :_  b
    [0 p.a]
--
