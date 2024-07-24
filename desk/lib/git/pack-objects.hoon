::
::
::::  Git object packer
  ::
/+  bs=bytestream
/+  *git-hash, *git-object
/+  git=git-repository, git-revision, git-pack
|%
++  version  2
::  As we walk over objects, we need to keep
::  track if we have seen the object already,
::  and whether it is dull.
::
+$  flag  ?(%seen %dull)
+$  walk-store  (map hash (set flag))
+$  brick-object
  $:  id=hash
      object-header
      offset=@ud
      ::  Name hint hash
      name-hash=@ux
      delta=hash
      delta-child=hash
      delta-sibling=hash
  ==
+$  store  (map hash brick-object)
+$  state  $:  =walk-store
               =store
               brick-list=(list [@ud brick-object])
               count=@ud
           ==
--
=|  state
=*  state  -
|_  repo=repository:git
++  has-flag
  |=  [=hash =flag]
  ^-  ?
  (~(has in (~(got by walk-store) hash)) flag)
++  has-any-flag
  |=  [=hash test=(list flag)]
  ^-  ?
  =+  flags=(~(get by walk-store) hash)
  ?~  flags
    |
  ?=(^ (~(int in u.flags) (silt test)))
++  put-flag
  |=  [=hash =flag]
  ^-  ^walk-store
  =+  flags=(~(get by walk-store) hash)
  (~(put by walk-store) hash (~(put in ?~(flags ~ u.flags)) flag))
++  mark-blob-dull
  |=  =hash
  ^-  ^walk-store
  ::  Use zipper
  ::
  ?:  (has-flag hash %dull)
    walk-store
  (put-flag hash %dull)
++  mark-tree-dull
  |=  =hash
  ^-  ^walk-store
  ?:  (has-flag hash %dull)
    walk-store
  =.  walk-store  (put-flag hash %dull)
  =+  obj=(got:~(store git repo) hash)
  ?>  ?=(%tree -.obj)
  =+  dir=tree-dir.obj
  ::
  |-  ?~  dir  walk-store
  =+  obj=(got:~(store git repo) hash)
  %=  $  dir  t.dir
    walk-store
    ?-  -.obj
      %commit  walk-store
      %tree  (mark-tree-dull hash.i.dir)
      ::  It is a submodule or something unknown, skip it
      ::
      %blob  (mark-blob-dull hash.i.dir)
      %tag  !!
    ==
  ==
++  object-type-as-ud
  |=  type=pack-object-type:git-pack
  ^-  @ud
  ?-  type
    %commit  1
    %tree    2
    %blob    3
    %tag     4
    ::  5 is reserved
    %ofs-delta  6
    %ref-delta  7
  ==
++  brick-cmp
  |=  [[ia=@ud a=brick-object] [ib=@ud b=brick-object]]
  ^-  ?
  =+  ta=(object-type-as-ud type.a)
  =+  tb=(object-type-as-ud type.b)
  ::  First, order by type (delta, tag, blob, tree, commit)
  ::  Second, order by size, greater object first
  ::  XX Third, order by name hint hash
  ::  Fourth, order by recency, newest first
  ::
  ?:  (gth ta tb)
    &
  ?:  (lth ta tb)
    |
  ?:  (gth size.a size.b)
    &
  ?:  (lth size.a size.b)
    |
  ?:  (gth name-hash.a name-hash.b)
    &
  ?:  (lth name-hash.a name-hash.b)
    |
  ?:  (lth ia ib)
    &
  |
::  Create a sortable number from the last sixteen
::  non-whitespace characters
::
++  hash-name
  ::  XX implement jet
  :: ~/  %hash-name
  |=  name=@t
  ^-  @ux
  ?:  =(0 name)
    0x0
  =|  hash=@ux
  =+  len=(met 3 name)
  =+  i=0
  |-
  ?.  (lth i len)
    hash
  =/  c=@uxD  (cut 3 [0 i] name)
  ::  XX implement isspace
  ?:  =(c ' ')
    $
  $(i +(i), hash (end [3 4] (add (rsh [2 1] hash) (lsh [3 3] c))))
++  insert-object
  |=  [=hash name=@t]
  ^-  ^state
  ::  XX use zipper
  ::  XX (~(pat by store) hash obj) :: put if it does not exist
  ::
  ?:  (~(has by store) hash)
    state
  ~&  insert-object+[hash name]
  =+  header=(got-header:~(store git repo) hash)
  =|  brick=brick-object
  =.  brick
    %=  brick
      id    hash
      type  type.header
      size  size.header
      name-hash  (hash-name name)
    ==
  %=  state
    store  (~(put by store) hash brick)
    brick-list  [[count brick] brick-list]
    count  +(count)
  ==
++  insert-tree
  =|  name=@t
  |=  [=hash dir=tree-dir]
  ^-  ^state
  ?:  (~(has by store) hash)
    ~&  insert-tree-have+hash
    state
  ~&  insert-tree+hash
  =.  state  (insert-object hash '')
  ::
  |-  ?~  dir  state
  =+  obj=(got:~(store git repo) hash.i.dir)
  =+  name=(cat 3 name name.i.dir)
  %=  $  dir  t.dir
    state
    ?-  -.obj
      %blob  (insert-object hash.i.dir name)
      %tree  ^$(name name, hash hash.i.dir, dir tree-dir.obj)
      %commit  state
      %tag  !!
    ==
  ==
++  insert-commit
  |=  [=hash =commit]
  ^-  ^state
  ~&  insert-commit+hash
  =.  state  (insert-object hash '')
  ::  XX (got-tree:~(store git repo) tree.commit)
  =+  obj=(got:~(store git repo) tree.commit)
  ~&  tree.commit
  ?>  ?=(%tree -.obj)
  (insert-tree tree.commit tree-dir.obj)
++  find-deltas
  |=  brick-list=(list [@ud brick-object])
  ^-  (list [@ud brick-object])
  ::  XX This is useful when actually
  ::  finding deltas
  :: =+  delta-list=(sort brick-list brick-cmp)
  ::  If the object is delta in the pack:
  ::  (1) Get the chain of delta objects
  ::  (2) Resolve the base and compress it
  ::  (3) Uncompress each delta, compress it and write
  ::  it to the pack as REF_DELTA object
  ::
  =|  pack-list=(list [@ud brick-object])
  =|  rev-index=(map @ud hash)
  |-  ?~  brick-list  pack-list
  =+  brick=i.brick-list
  $(brick-list t.brick-list)
  :: ?.  ?&  ?=(^ archive.object-store.repo)
  ::         (has:p i.archive.object-store.repo id.brick)
  ::     ==
  ::   ~&  find-deltas-loose+id.brick  !!
  :: ~&  find-deltas-packed+id.brick
  :: =+  pack=i.archive.object-store.repo
  :: =/  [pob=pack-object:^pack pin=@ud]
  ::   =+  pin=(got:p-on:^pack index.pack id.brick)
  ::   :_  pin
  ::   -:(read-pack-object:^pack [pin octs.data.pack])
  :: ::  Already resolved, write as is
  :: ::
  :: ?.  ?=(pack-delta-object:^pack pob)
  ::   =/  =octs
  ::     %+  cat-octs:bs
  ::       (write-type-size:^pack type.pob size.pob)
  ::       (compress:zlib octs.data.pob)
  ::   $(brick-list t.brick-list)
++  pack-objects
  |=  [want=(list hash) exclude=(list hash)]
  ^-  octs
  ::  Prepare packbuilder
  ::  (1) Walk over the exclude list, mark all trees and blobs as dull
  ::  (2) Perform a revision walk
  ::  (3) For each commit that we have not seen and which is not a
  ::  dull commit, insert it to the packbuilder.
  ::
  ::  (1)
  =.  walk-store
    |-  ?~  exclude  walk-store
    =+  hash=i.exclude
    ::  XX Use caching
    ::
    =+  obj=(got:~(store git repo) hash)
    ?>  ?=(%commit -.obj)
    %=  $
      exclude  t.exclude
      walk-store  (mark-tree-dull tree.commit.obj)
    ==
  :: (2) & (3)
  =+  commits=(walk:git-revision repo want exclude)
  ~&  pack-objects-walk+"Inserting {<(lent commits)>} commits"
  =.  state
    |-  ?~  commits  state
    =+  hash=-.i.commits
    =+  commit=+.i.commits
    ?:  (has-any-flag hash ~[%seen %dull])
      $(commits t.commits)
    =.  walk-store  (put-flag hash %seen)
    =.  state  (insert-commit hash commit)
    $(commits t.commits)
  ::  Prepare deltas
  ::
  ::  Sort by type, size, name hash and recency
  ::
  =.  brick-list  (flop brick-list)
  ~&  pack-objects-brick-count+count
  =+  pack-list=(find-deltas brick-list)
  =|  sea=bays:bs
  ::  Write header
  ::
  =.  sea  (write-txt:bs sea 'PACK')
  =.  sea  (append-octs:bs sea (as-byts:bs [4 version]))
  =.  sea  (append-octs:bs sea (as-byts:bs [4 count]))
  data.sea
++  write-packs
  |=  archive=(list pack:git-pack)
  ^-  octs
  ~&  write-no-packs+(lent archive)
  =/  count=@ud
    %+  roll  archive
      |=  [=pack:git-pack c=@ud]
      (add count.pack c)
  ~&  write-pack-objects+count
  =|  sea=bays:bs
  =.  sea  (write-txt:bs sea 'PACK')
  =.  sea  (write-octs:bs sea (as-byts:bs [4 version]))
  ~&  count
  =.  sea  (write-octs:bs sea (as-byts:bs [4 count]))
  ~&  `@ux`q.data.sea
  ::  XX This could have terrible memory complexity
  ::  We really want to operate on a single copy
  ::  of sea
  ::
  =.  sea  %+  reel  archive
    |=  [=pack:git-pack =_sea]
    %+  write-octs:bs  sea
      ~&  pack-size+(size:bs stream.pack)
      ::  Discard hash
      :-  (sub end-pos.pack pos.stream.pack)
      ::  Discard header
      (rsh [3 pos.stream.pack] (to-atom:bs stream.pack))
  =+  hash=(hash-octs-sha-1 (to-octs:bs sea))
  ::  XX parametrize by hash algo
  ::
  =.  sea  (write-hash sea %sha-1 hash)
  data.sea
--
