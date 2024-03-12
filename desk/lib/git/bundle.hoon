::
::::  Git bundle
  ::
/+  stream
/+  *git
|%
+$  bundle-header  
  $:  version=%2 
      hash=hash-type 
      need=(list hash) 
      refs=(list (pair path hash))
  ==
+$  bundle  [header=bundle-header =pack]
::
++  read
  |=  sea=stream:stream
  ^-  [bundle stream:stream]
  =^  hed  sea  (read-header sea)
  =^  pack-file  sea  (read:pak sea)
  =+  pak=(index:pak pack-file)
  :_  sea
  [hed pak]
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
  =/  [hat=hash-type hax=_parser-sha-1]
    ?:  =(2 u.sig)
      [%sha-1 parser-sha-1]
    !!
  =<
  ::  Parse prerequisites
  ::
  =^  reqs=(list hash)  sea
    =|  reqs=(list hash)
    |-
    =+  [line red]=(read-line:stream sea)
    ?~  line 
      ~|  "Git bundle is corrupted: invalid header"  !!
    =/  hash=(unit hash)  (rust (trip q.u.line) required)
    ?~  hash 
      [reqs sea]
    $(reqs [u.hash reqs], sea red)
  ::
  ::  Parse references
  ::
  =^  refs=(list (pair path hash))  sea
    =|  refs=(list (pair path hash))
    |-
    =+  [line red]=(read-line:stream sea)
    ?~  line 
      ~|  "Git bundle is corrupted: invalid header"  !!
    =/  ref  (rust (trip q.u.line) ;~(sfix parser-ref (just '\0a')))
    ?~  ref
      [refs sea]
    $(refs [u.ref refs], sea red)
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
  ::  XX unify parsing across different 
  ::  library components (/+  git-parser ?)
  ::
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
++  clone
  |=  =bundle
  ^-  repository
  ?^  need.header.bundle
    ~|  "Bundle contains prerequisites"  !!
  =|  repo=repository
  =.  repo  (add-pack:~(store git repo) pack.bundle)
  ?<  ?=(~ archive.object-store.repo)
  %=  repo
    refs
    %+  roll  refs.header.bundle
      ::  XX is there no way to write 
      ::  it compactly?
      |=  [ref=(pair path hash) =refs]
      ?>  (has:~(store git repo) q.ref)
      (~(put of refs) ref)
  ==
--
