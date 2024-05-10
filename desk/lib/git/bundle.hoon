::
::::  Git bundle
  ::
/+  stream
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
  |=  sea=stream:stream
  ^-  bundle
  =^  header  sea  (read-header sea)
  [header (read:git-pack sea)]
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
  ::  Select hash algo and parser
  ::
  =/  [hal=hash-algo parse-hash=_parse-sha-1]
    ?:  =(2 u.sig)
      [%sha-1 parse-sha-1]
    !!
  ::  Parse prerequisites
  ::
  =^  reqs=(list hash)  sea
    =|  reqs=(list hash)
    |-
    =+  [line red]=(read-line:stream sea)
    ?~  line 
      ~|  "Git bundle is corrupted: invalid header"  !!
    =/  hash=(unit hash)  
      %+  rust  (trip q.u.line)
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
    =+  [line red]=(read-line:stream sea)
    ?~  line 
      ~|  "Git bundle is corrupted: invalid header"  !!
    =/  ref=(unit [=hash =refname])
      %+  rust  (trip q.u.line)
      ;~  sfix
        ;~  plug
          parse-sha-1
          ;~(pfix ace parse-refname)
        ==
        (just '\0a')
      ==
    ?~  ref
      [refs sea]
    $(refs [[refname.u.ref hash.u.ref] refs], sea red)
  :: Parse newline indicating end of bundle header
  ::
  =^  line=(unit octs)  sea  (read-line:stream sea)
  ?~  line
    ~|  "Git bundle is corrupted: header not terminated"  !!
  ?:  (gth p.u.line 1)
    ~|  "Git bundle is corrupted: invalid header terminator"  !!
  :_  sea
  [u.sig hal reqs refs]
--
