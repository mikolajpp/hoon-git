/-  *git, *stream
/+  zlib, bys=stream
|%
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
    |=  a=@ud
    ^-  raw-object-type
    ?+  a  %invalid
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
  ++  crip
    |=  a=tape
    ^-  @t
    (rep 3 a)
  ::
  ++  parse
    |=  rob=raw-object
    ^-  object
    ?+  type.rob
      ~|  "Invalid object type {<type.rob>}"  !!
      %blob    rob
      %commit  (parse-commit rob)
      %tree    (parse-tree rob)
    ==
  ::
  ++  parse-commit
    |=  rob=raw-object
    ^-  object
    ::  XX handle mailmap globally
    ::
    ::  XX in places like this we need
    ::  to eventually parametrize the hash function somehow
    ::  (if we plan to support sha-256)
    ::
    =/  six  ;~(pose (shim '0' '9') (shim 'a' 'f'))
    =/  hax  (stun [40 40] six)
    =/  tree    ;~(pfix (jest 'tree ') hax)
    =/  parent  ;~(pfix (jest 'parent ') hax)
    =/  person
      ;~  plug
      ::  Name
      ::
      (star ;~(less gal prn))
      ::  Email
      ::
      (ifix [gal gar] (star ;~(less gar prn)))
      ==
    =/  zone
      ;~  plug
      ;~(pose (cold & lus) (cold | hep))
      (plus nud)
      ==
    =/  time  ;~(plug ;~(sfix dip:ag ace) zone)
    =/  author
      ;~  pfix  (jest 'author ')
      ;~(plug person ;~(pfix ace time))
      ==
    =/  committer
      ;~  pfix  (jest 'committer ')
      ;~(plug person ;~(pfix ace time))
      ==
    =/  eol  (just '\0a')
    =/  message  (star ;~(pose prn eol))
    =/  commit-rule
    ::  [tree-hash parent-hash [author-name author-email author-time]
      ;~  plug
        ;~(sfix ;~((glue eol) tree parent author committer) eol)
        ;~(pfix eol message)
      ==
    ::  XX is there a better way to handle this?
    =/  root-commit-rule
      ;~  plug
        ;~(sfix ;~((glue eol) tree author committer) eol)
        ;~(pfix eol message)
      ==
    =+  txt=(trip dat.byts.rob)
    =+  com=(rust txt commit-rule)
    ?~  com
      =+  com=(rust txt root-commit-rule)
      ?~  com
        ~|  "Failed to parse commit object"  !!
      commit+[[-<.u.com "" ->.u.com] +.u.com]
    commit+u.com
  ::
  ++  parse-tree
    |=  rob=raw-object
    ^-  object
    ::  XX better parsing of mode.
    ::  Is leading zero allowed in principle?
    ::
    =/  mode  (cook crip ;~(sfix (plus (shim '0' '9')) ace))
    =/  node  (cook crip (star ;~(less ace prn)))
    ::
    ::  Parsing tree objects is a little tricky.
    ::  Each entry has 20 bytes encoding of SHA-1.
    ::  This is not suitable for using parsers,
    ::  (it would @t constraints for valid UTF-8 bytes)
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
    ::  XX handle leading zeros in a hash
    ::
    =/  hax=@ta  (crip ((x-co:co 0) (rev 3 20 u.hek)))
    =/  ren  (scan txt ;~(plug mode node))
    =/  ent=tree-entry  [ren hax]
    $(tes [ent tes])
  ::
  :: Render a git object raw
  ::
  ++  make-raw
    |=  obe=object
    ^-  raw-object
    ?-  -.obe
      %blob  obe
      %tree  !!
      %commit  !!
    ==
  ::
  ::  SHA1-hash a raw git object
  ::
  ::  XX Improve performance by
  ::  using Sha1_Update
  ::
  ++  make-raw-hash-sha-1
    |=  rob=raw-object
    ^-  hash
    =/  len  (crip ((d-co:co 0) wid.byts.rob))
    ::  There must be a pattern for this
    =/  hed  (cat 3 (cat 3 type.rob ' ') len)
    =/  pak  (cat 3 hed (can 3 ~[[1 0x0] byts.rob]))
    ::  (can ~[type.object ' ' len 0x0 data.object])
    =/  saz  (met 3 pak)
    ::  XX is there any way to avoid rev?
    ::
    =/  hax  (sha-1l:sha [saz (rev 3 saz pak)])
    =/  haz  (crip ((x-co:co 0) hax))
    =/  dif  (sub 40 (met 3 haz))
    ::  Account for leading zeros
    ::
    ?:  (gth dif 0)
      sha-1+(add (lsh [3 dif] haz) (fil 3 dif '0'))
    sha-1+haz
  ::
  :: Hash a raw git object
  ::
  ++  make-hash-raw
    |=  [hat=hash-type rob=raw-object]
    ^-  hash
    ?-  hat
      %sha-1  (make-raw-hash-sha-1 rob)
      %sha-256  !!
    ==
  ::
  ::  Hash a git object
  ::
  ++  make-hash
    |=  [hat=hash-type obe=object]
    ^-  hash
    (make-hash-raw hat (make-raw obe))
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
    ::
    ::  Rules
    ::
    =/  sig-rule
      ;~(sfix (jest '# v2 git bundle') (just '\0a'))
    ::
    =/  oid-rule
      %+  cook  crip
      %+  stun  [40 40]
      ;~(pose (shim '0' '9') (shim 'a' 'f'))
    ::
    =/  comment-rule  ;~(pfix ace (star prn))
    ::
    =/  req-rule
      %+  ifix  [hep (just '\0a')]
      ;~(sfix oid-rule (punt comment-rule))
    ::
    =/  refname-elem
      (cook crip ;~(plug low (star ;~(pose low nud hep))))
    ::
    =/  refname-rule
      ;~  pose
        ;~(plug refname-elem (star ;~(pfix fas refname-elem)))
      ==
    ::
    =/  ref-rule
      ;~  sfix
        ;~(plug oid-rule ;~(pfix ace refname-rule))
        (just '\0a')
      ==
    ::
    ::  Parse signature
    =^  sig  sea  (read-line:bys sea)
    ?~  sig
      ~|  "Git bundle is corrupted: signature absent"  !!
    ?~  (rust u.sig sig-rule)
      ~|  "Git bundle is corrupted: invalid signature"  !!
    ::
    ::  Parse prerequisites
    ::
    =^  reqs=(list @ta)  sea
    %.  ~
    |=  reqs=(list @ta)
    =/  nex  (get-line:bys sea)
    ?~  -.nex
      ~|  "Git bundle is corrupted: invalid header"  !!
    =/  oid=(unit @ta)  (rust u.-.nex req-rule)
    ?~  oid
      :: ~&  "Failed to parse '{u.-.nex}'"
      [reqs sea]
    $(reqs [u.oid reqs], sea [+<.nex byts.+>.nex])
    ::
    ::  Parse references
    ::
    =^  refs=(list reference)  sea
    %.  ~
    |=  refs=(list reference)
    =/  nex  (get-line:bys sea)
    ?~  -.nex
      ~|  "Git bundle is corrupted: invalid header"  !!
    =/  ref=(unit [@ta path])  (rust u.-.nex ref-rule)
    ?~  ref
      :: ~&  "Failed to parse '{u.-.nex}'"
      [refs sea]
    $(refs [[+.u.ref -.u.ref] refs], sea [+<.nex byts.+>.nex])
    ::
    :: Parse newline indicating end of bundle header
    =^  lan  sea  (read-line:bys sea)
    ?~  lan
      ~|  "Git bundle is corrupted: header not terminated"  !!
    ?:  (gth (lent u.lan) 1)
      ~|  "Git bundle is corrupted: invalid header terminator"  !!
    :_  sea
    [%2 reqs refs]
  --
::
::  Repository
::
++  git
  |_  repo=repository
  +*  this  .
  ::
  ++  get
    |=  hax=hash
    ^-  (unit object)
    (~(get by objects.repo) +.hax)
  ::
  ++  got
    |=  hax=hash
    ^-  object
    (~(got by objects.repo) +.hax)
  ::
  ++  has
    |=  hax=hash
    ^-  ?
    (~(has by objects.repo) +.hax)
  ::
  ++  put
    |=  obe=object
    ^-  repository
    =/  hax=hash  (make-hash:obj default-hash obe)
    ?<  (has hax)
    :: XX Check repo compatibility with hax
    repo(objects (~(put by objects.repo) [+.hax obe]))
  ++  wyt
    |-
    ~(wyt by objects.repo)
  ::
  ++  put-raw
    |=  rob=raw-object
    ^-  repository
    =/  hax=hash  (make-hash-raw:obj %sha-1 rob)
    ?<  (has hax)
    repo(objects (~(put by objects.repo) [+.hax (parse:obj rob)]))
  ::
  :: XX Should a function like this
  :: be in the standard library?
  ::
  ++  match-key
    |=  [a=@ta b=@ta]
    ^-  ?
    ?:  =(a b)
      &
    |-
    ?:  |(=(0 a) =(0 b))
      &
    ?.  =((end 3 a) (end 3 b))
      |
    $(a (rsh 3 a), b (rsh 3 b))
  ::
  :: Find all keys matching the abbreviation
  ::
  ++  find-key
    |=  ken=@ta
    ^-  (list @ta)
    ::
    :: XX why does dispatching on non-empty set does not work?
    :: ?~  keys  followed by =/  heys  ~(tap in keys)
    :: results in mull-grow
    ::
    =/  keys=(list @ta)  ~(tap in ~(key by objects.repo))
    =|  heys=(list @ta)
    |-
    ?~  keys
      heys
    ?:  (match-key ken i.keys)
      $(keys t.keys, heys [i.keys heys])
    $(keys t.keys)
  ::
  ++  unbundle
    |=  bud=bundle
    ^-  repository
    ?>  =(2 version.header.bud)
    ::  Verify we have all required objects
    ::
    =+  mis=(turn reqs.header.bud |=(hax=@ta (has sha-1+hax)))
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
    ?.  (has [%sha-1 +.i.ref])
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
