/-  *git
|%
::
:: libgit2/odb.h
::
+$  raw-object  [type=object-type data=@]
+$  tree-entry  [mode=@ filename=@t =hash]
+$  object
  $%
      [%blob data=@]
      [%tree (list tree-entry)]
  ==
:: 
:: Object
::
++  obj
  |%
  ++  is-loose 
    |=  typ=object-type
    ^-   ?
    ?+  typ    |
      %commit  &
      %tree    &
      %blob    &
      %tag     &
    ==
  ::
  :: Parse raw git object 
  ::
  ++  parse-raw
    |=  dat=@
    ^-  raw-object
    =<
    =/  len  (met 3 dat)
    ::  Parse header
    ::
    =/  pin  (find-bit 0x0 dat)
    ?.  (lth pin len)
      invalid+0x1
    =/  txt  (trip (cut 3 [0 pin] dat))
    :: [type len]
    ::
    =/  her  (rust txt ;~(plug sym ;~(pfix ace dip:ag)))
    ?~  her
      invalid+0x2
    ?.  (lth +.u.her len)
      invalid+0x3
    =/  type=object-type
      ?+  -.u.her  %invalid
        %blob  %blob
        %commit  %commit
        %tree  %tree
      ==
    =/  data=@  (cut 3 [+(pin) len] dat)
    [type data]
    ::
    |%
    ++  find-bit
      |=  [bat=@ dat=@]
      =/  pin  0
      |-
      =/  bit  (cut 3 [pin 1] dat)
      ?:  =(0x0 bit)
        pin 
      $(pin +(pin))
    --
  ::
  ::
  :: Render a git object as a raw blob
  ::
  ++  make-raw
    |=  obe=object
    ^-  raw-object
    ?-  -.obe 
      %blob  [%blob data.obe]
      %tree  !!
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
    =/  len  (crip ((d-co:co 0) (met 3 data.rob)))
    :: There must be a pattern for this 
    =/  hed  (cat 3 (cat 3 type.rob ' ') len)
    =/  pak  (cat 3 hed (can 3 ~[[1 0x0] [(met 3 data.rob) data.rob]]))
    ::  (can ~[type.object ' ' len 0x0 data.object])
    =/  saz  (met 3 pak)    
    =/  hax  (sha-1l:sha [saz (rev 3 saz pak)])
    sha-1+(crip ((x-co:co 0) hax))
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
::
::  PACK file
::
+$  stream  [pos=@ =byts]
++  pak
  |%
  ++  load
    |=  sea=stream
    =<
    :: 
    ::  Rules
    ::
    =/  sig-rule
      ;~(sfix (jest '# v2 git bundle') (just '\0a'))
    ::
    =/  oid-rule
      %+  stun  [40 40]
      ;~(pose (shim '0' '9') (shim 'a' 'f'))
    ::
    =/  comment-rule  ;~(pfix ace (star prn))
    ::
    =/  req-rule
      %+  ifix  [hep (just '\0a')]
      ;~(plug oid-rule (punt comment-rule))
    ::
    =/  refname-elem
      ;~(plug low (star ;~(pose low nud hep)))
    ::
    =/  refname-rule
      ;~  pose 
        (cook |=(a=@ ~[(trip a)]) (jest 'HEAD'))
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
    =^  sig  sea  (read-line sea)
    ?~  sig
      ~|  "Git bundle is corrupted: signature absent"  !!
    ?~  (rust u.sig sig-rule)
      ~|  "Git bundle is corrupted: invalid signature"  !!
    ~&  signature+sig
    ::
    ::  Parse prerequisites
    ::
    =^  reqs=(list @t)  sea
    %.  ~
    |=  reqs=(list @t)
    =/  nex  (get-line sea)
    ?~  -.nex
      ~|  "Git bundle is corrupted: invalid header"  !!
    =/  oid=(unit [tape (unit tape)])  (rust u.-.nex req-rule)
    ?~  oid
      :: ~&  "Failed to parse '{u.-.nex}'"
      [reqs sea]
    $(reqs -.u.oid, sea [+<.nex byts.+>.nex])
    ::
    ::  Parse references
    ::
    =^  refs=(list [oid=tape refname=(list tape)])  sea
    %.  ~
    |=  refs=(list [tape (list tape)])
    =/  nex  (get-line sea)
    ?~  -.nex
      ~|  "Git bundle is corrupted: invalid header"  !!
    =/  ref=(unit [tape (list tape)])  (rust u.-.nex ref-rule)
    ?~  ref 
      :: ~&  "Failed to parse '{u.-.nex}'"
      [refs sea]
    $(refs [u.ref refs], sea [+<.nex byts.+>.nex])
    ::
    :: Parse newline indicating end of bundle header
    =^  lan  sea  (read-line sea)
    ?~  lan
      ~|  "Git bundle is corrupted: header not terminated"  !!
    ?:  (gth (lent u.lan) 1)
      ~|  "Git bundle is corrupted: invalid header terminator"  !!

    ~&  reqs+reqs
    ~&  refs+refs
    0xff
    ::
    |%
    ::
    ++  get-line 
      |=  sea=stream
      ^-  [(unit tape) @ud stream]
      =/  i  pos.sea
      |-
      ?:  (gte i wid.byts.sea)
        [~ [pos.sea sea]]
      ?:  =('\0a' (get-char i sea))
        :_  [pos=+(i) sea=sea]
          lan=`(get-string [pos.sea i] sea)
      $(i +(i))
    ::
    ++  read-line
      |=  sea=stream
      ^-  [(unit tape) stream]
      =/  nex  (get-line sea)
      :_  [+<.nex byts.+>.nex]
        -.nex
    ::
    ++  get-char
      |=  [i=@ sea=stream]
      ^-  @t
      (cut 3 [i 1] dat.byts.sea)
    ::
    ::  Get a [-.ran +.ran] substring
    ::
    ++  get-string 
      |=  [ran=[@ud @ud] sea=stream]
      ^-  tape
      (trip (cut 3 [-.ran +((sub +.ran -.ran))] dat.byts.sea))
    --
  --
:: 
::  Git repository
::
+$  repository
  $:  objects=(map @ta object)
      refs=~
      config=~
  ==
::
::  Repository engine
::
++  go 
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
  ++  put
    |=  obe=object
    ^-  repository
    =/  hax  (make-hash:obj default-hash obe)
      :: XX Check repo compatibility with hax
      repo(objects (~(put by objects.repo) [+.hax obe]))
  --
--
