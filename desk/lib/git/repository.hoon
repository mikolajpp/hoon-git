::  Repository engine
::
::    +store  -- object store
::    +refs   -- references
::    +remote -- remotes
::    +config -- configuration
::
/+  *git, *git-refs, git-pack, git-bundle
|%
+$  object-store  $:  loose=(map hash object)
                      archive=(list pack:git-pack)
                  ==
+$  config-value  $%  [%l ?]
                      [%u @ud]
                      [%s @t]
                  ==
+$  config-key  [@tas (unit @t)]
::  XX does removing a remote in git
::  cause its references to disappear?
::
+$  remote  [url=@t =refs refspec=(list refspec)]
+$  ref-spec  @t
+$  repository
  $:  =hash-type
      =object-store
      =refs
      track=(map @t [remote=@tas merge=refname])
      remotes=(map @tas remote)
      config=(mip:libmip config-key @tas config-value)
  ==
--
::  XX Switch to using id=hash argument 
::  in gates
|_  repo=repository
+*  this  .
++  clone-from-bundle
  |=  =bundle:git-bundle
  ^-  repository
  ?^  need.header.bundle
    ~|  "Bundle contains prerequisites"  !!
  =.  repo  (add-pack:store pack.bundle)
  ?<  ?=(~ archive.object-store.repo)
  %=  repo
    refs
    %+  roll  refs.header.bundle
      ::  XX is there no way to write 
      ::  it compactly?
      |=  [ref=(pair path hash) =^refs]
      ?>  (has:store q.ref)
      (~(put of refs) ref)
  ==
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
::  XX The configuration does not belong in libgit. 
::  Configuration should affects user tooling by altering.
::  Settings which actually serve as data stores (remote, branch etc.)
::  should be part of the repository structure proper.
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
++  remote
  |%
  :: ++  fetch
  ::   |=  [remote-name=@tas =pack refs=(list reference)]
  ::   ^-  repository
    :: *repository
  ::   =+  remote=(got:~(phone git repo) remote-name)
  ::   ::  Update remote-tracking references
  ::   ::  XX This should only concern branches
  ::   ::  XX What would happen if we push an update 
  ::   ::  to a tag?
  ::   ::
  ::   =.  refs.remote
  ::   |-
  ::   ?~  refs
  ::     refs.remote
  ::   =+  ref=i.refs
  ::   =+  far=(get:~(refer git repo) -.ref)
  ::   ::  New reference
  ::   ::
  ::   ?~  far
  ::     ~&  fetch-new-ref+ref
  ::     %=  $
  ::       refs  t.refs
  ::       repo  (put:~(refer git repo) ref)
  ::     ==
  ::   ::  Existing reference, update
  ::   ::
  ::   ?:  =(u.far +.ref)
  ::     $(refs t.refs)
  ::   ~&  fetch-update-ref+[-.ref u.far '~>' +.ref]
  ::   %=  $
  ::     refs  t.refs
  ::     refs.remote  (~(put by refs.remote) ref)
  ::   ==
  ::   ::
  ::   %=  repo
  ::     remotes  (~(put by remotes.repo) remote-name remote)
  ::     archive.object-store  [pack archive.object-store.repo]
  ::   ==
  --
++  store
  |%
  ++  add-pack
    |=  =pack:git-pack
    ^-  repository
    ::  XX verify collisions with existing object in the archive?
    ::  XX verify repository integrity?
    ::
    repo(archive.object-store [pack archive.object-store.repo])
  :: :: ++  get
  :: ::   |=  haz=@ux
  :: ::   ^-  (unit object)
  :: ::   (~(get by object-store.repo) haz)
  :: :: ::
  ++  get
    |=  =hash
    ^-  (unit object)
    =+  loose=(~(get by loose.object-store.repo) hash)
    ?^  loose
      loose
    ::  XX use a loop, why traverse when 
    ::  obj has already been found?
    ::
    %+  roll  archive.object-store.repo
      |=  [=pack:git-pack obj=(unit object)]
      ?~  obj
        ::  XX  (~(get-with-size git-pack pack) hash)
        (~(get git-pack pack) hash)
      obj
  ++  got
    |=  =hash
    ^-  object
    (need (get hash))
  ++  get-header
    |=  =hash
    ^-  (unit object-header)
    =+  loose=(~(get by loose.object-store.repo) hash)
    ?^  loose
      `[-.u.loose size.u.loose]
    %+  roll  archive.object-store.repo
      |=  [=pack:git-pack obj=(unit object-header)]
      ?~  obj
        ::  XX  (~(get-with-size git-pack pack) hash)
        (~(get-header git-pack pack) hash)
      obj
  ++  got-header
    |=  =hash
    ^-  object-header
    (need (get-header hash))
  ++  get-archive
    |=  =hash
    ^-  (unit object)
    %+  roll  archive.object-store.repo
      |=  [=pack:git-pack obj=(unit object)]
      ?~  obj
        (~(get git-pack pack) hash)
      obj
  ++  get-raw
    |=  =hash
    ^-  (unit raw-object)
    =+  loose=(~(get by loose.object-store.repo) hash)
    ?^  loose
      (some (as-raw:obj u.loose))
    ::  XX use a loop, why traverse when 
    ::  obj has already been found?
    ::
    %+  roll  archive.object-store.repo
      |=  [=pack:git-pack obj=(unit raw-object)]
      ?~  obj
        ::  XX This is a workaround to retrieve objects 
        ::  from thin packs. Thin packs in the archive 
        ::  currently arise because we lack the ability
        ::  to create new packfiles from scratch. 
        ::  Once git-pack-objects is implemented, 
        ::  we can thicken received packs, at the risk 
        ::  of duplicating the objects. It seems 
        ::  that is how git does it. For instance, 
        ::  git-receive-pack will thicken each received pack, 
        ::  and finally run git-gc, which presumably will detect
        ::  duplicate objects. However, does not that mean 
        ::  if a 2GB file was modified, git will temporalily 
        ::  create a 2GB copy (thus using 4GB of space?)
        ::  As we keep everything in memory, this will not 
        ::  do for us -- we have to be smarter than git here.
        ::
        (~(get-raw-thin git-pack pack) hash get-raw)
      obj
  ++  has
    |=  =hash
    ^-  ?
    ?|  (~(has by loose.object-store.repo) hash)
        %+  lien  archive.object-store.repo
          |=(=pack:git-pack (~(has git-pack pack) hash))
    ==
  :: ::
  :: ++  put
  ::   |=  obe=object
  ::   ^-  repository
  ::   =/  haz=@ux  (hash:obj hash-type.repo obe)
  ::   ?<  (has haz)
  ::   repo(object-store (~(put by object-store.repo) [haz obe]))
  :: ++  wyt
  ::   |-
  ::   ~(wyt by object-store.repo)
  :: ::
  :: ++  put-raw
  ::   |=  rob=raw-object
  ::   ^-  repository
  ::   =/  haz=@ux  (hash-raw:obj hash-type.repo rob)
  ::   ?<  (has haz)
  ::   repo(object-store (~(put by object-store.repo) [haz (parse:obj hash-type.repo rob)]))
  ::
  ::  Check whether key a
  ::  is a shorthand of b
  ::
  ::  XX This could be done with
  ::  direct atom comparison
  ::
  ::  XX a is not really octs
  ::  'cafe' -> [4 0xcafe], which is wrong
  ::
  :: Find all keys matching the abbreviation. 
  :: Search in the object-store
  ::
  :: ++  find-key-in-store
  ::   |=  a=@ta
  ::   ^-  (list @ux)
  ::   ::
  ::   :: XX why does dispatching on non-empty set does not work?
  ::   :: ?~  keys  followed by =/  heys  ~(tap in keys)
  ::   :: results in mull-grow
  ::   ::
  ::   =+  key=[(met 3 a) (to-hex a)]
  ::   =/  kel=(list @ux)  ~(tap in ~(key by object-store.repo))
  ::   =|  hey=(list @ux)
  ::   |-
  ::   ?~  kel
  ::     hey
  ::   ?:  (match-key key i.kel)
  ::     $(kel t.kel, hey [i.kel hey])
  ::   $(kel t.kel)
  --
++  refs
  |%
  ++  has
    |=  =refname
    ^-  ?
    (~(has of refs.repo) refname)
  ++  got
    |=  =refname
    ^-  hash
    ::  XX With axal we have no way to tell
    ::  if an empty path has been stored. Does it matter?
    ::
    =+  fil=(~(get of refs.repo) refname)
    ?~  fil  !!
    ?@  u.fil
      u.fil
    $(refname refname.u.fil)
  ++  tap  (tap-prefix ~)
  ++  tap-prefix
    |=  prefix=refname
    %+  turn
      ~(tap of (~(dip of refs.repo) prefix))
    |=  [=refname =ref]
    ?@  ref
      [refname ref]
    [refname (got refname)]
  ++  tap-prefix-full
    |=  prefix=refname
    %+  turn
      ~(tap of (~(dip of refs.repo) prefix))
    |=  [=refname =ref]
    ?@  ref
      [(weld prefix refname) ref]
    [(weld prefix refname) (got refname)]
  ::  Accumulate product with a user 
  ::  supplied gate
  ::
  ++  rep
    |=  b=$-([[refname ref] *] *)
    (rep-prefix ~ b)
  ++  rep-prefix
    |*  $:  prefix=refname
            b=_=>(~ |=([[* *] *] +<+))
        ==
    ^+  +<+.b
    =+  axal=(~(dip of refs.repo) prefix)
    =/  =refname
      prefix
    |-
    ::  Accumulate from fil
    ::
    =?  +<+.b  ?=(^ fil.axal)
      :: =/  =hash
      ::   ?^  u.fil.axal
      ::     (got refname.u.fil.axal)
      ::   u.fil.axal
      (b [refname u.fil.axal] +<+.b)
    ::  Accumulate from subaxals
    ::
    =+  map=dir.axal
    |-
    ?~  map
      +<+.b
    =.  +<+.b
      %=  ^$
        axal  q.n.map
        refname  (snoc refname p.n.map)
      ==
    =.  +<+.b
      $(map l.map)
    $(map r.map)
  --
--
