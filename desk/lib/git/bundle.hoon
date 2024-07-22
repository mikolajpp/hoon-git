::
::::  Git bundle
  ::
/+  bs=bytestream
/+  *git-hash, *git-object, *git-refs, git-pack
|%
+$  bundle-header
  $:  version=$?(%2)
      hash=hash-algo
      need=(list hash)
      refs=(list [p=path q=hash])
  ==
+$  bundle  [header=bundle-header =pack:git-pack]
::
++  read
  |=  sea=bays:bs
  ^-  bundle
  =^  header  sea  (read-header sea)
  [header (read:git-pack sea)]
::
++  read-header
  |=  sea=bays:bs
  ^-  [bundle-header bays:bs]
  ::  Parse signature
  ::
  ~&  `@t`(cut 3 [0 20] q.octs.sea)
  =^  line  sea  (read-line-maybe:bs sea)
  ?~  line
    ~|  "Git bundle is corrupted: signature absent"  !!
  =/  signature
    (cold %2 (jest '# v2 git bundle'))
  =+  sig=(rust (trip u.line) signature)
  ?~  sig
    ~|  "Git bundle is corrupted: invalid signature {(trip u.line)}"  !!
  ::  Select hash algo and parser
  ::
  =/  [hal=hash-algo parse-hash=_parse-hash-sha-1]
    ?:  =(2 u.sig)
      [%sha-1 parse-hash-sha-1]
    !!
  ::  Parse prerequisites
  ::
  =^  reqs=(list hash)  sea
    =|  reqs=(list hash)
    |-
    =/  [line=(unit @t) red=bays:bs]  (read-line-maybe:bs sea)
    ?~  line
      ~|  "Git bundle is corrupted: invalid header"  !!
    =/  hash=(unit hash)
      %+  rust  (trip u.line)
      %+  ifix  [hep (just '\0a')]
      ;~  sfix
        parse-hash
        (punt ;~(pfix ace (star prn)))  :: optional comment
      ==
    ?~  hash
      [reqs sea]
    $(reqs [u.hash reqs], sea red)
  ::
  ::  Parse references
  ::
  =^  refs=(list (pair refname hash))  sea
    =|  refs=(list (pair refname hash))
    |-
    =/  [line=(unit @t) red=bays:bs]  (read-line-maybe:bs sea)
    ?~  line
      ~|  "Git bundle is corrupted: invalid header"  !!
    =/  ref=(unit [=hash =refname])
      %+  rust  (trip u.line)
      ;~  plug
        parse-hash-sha-1
        ;~(pfix ace parse-refname)
      ==
    ?~  ref
      [refs sea]
    $(refs [[refname.u.ref hash.u.ref] refs], sea red)
  :: Parse newline indicating end of bundle header
  ::
  =^  line  sea  (read-line-maybe:bs sea)
  ?~  line
    ~|  "Git bundle is corrupted: header not terminated"  !!
  ?:  (gth (met 3 u.line) 1)
    ~|  "Git bundle is corrupted: invalid header terminator"  !!
  :_  sea
  [u.sig hal reqs refs]
--
