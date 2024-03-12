::
::  Revision walking
::
::  Revision walker accepts a list of user supplied 
::  commits, some of which can be marked as uninteresting (dull).
::
::  Subsequently, the revision walker prepares its internal state 
::  for walking the revision tree.
::
::  API
::  =+  walk  (walk-over:revision repo)
::  (~(put-def revision walk) commit-hash)
::  =^  rev  walk  ~(get revision walk)
::  =^  rev  walk  ~(get revision walk)
::
/+  *git
|%
::  XX Why does it need manual structure mode?
::
+$  seed-mop  ((mop @ud (list (pair hash commit))) gth)
++  seed-on  ((on @ud (list (pair hash commit))) gth)
+$  rev-walk 
  $:  repo=repository
      ::  Seed for a walk: pushes and hides
      ::  - a push is an interesting commit
      ::  - a hide is a dull commit
      ::
      ::  For objects that were reached, 
      ::  the store will contain the commit. 
      ::  For objects that were added because 
      ::  they were parents, but have not been 
      ::  reached otherwise, the map will contain 
      ::  a null. This is useful during expansion
      ::  of the cliff set -- we mark grandparents cliff
      ::  only if the parent was stored as a full object.
      ::
      store=(map hash (unit commit))
      ::  Seeds to grow from
      ::
      seed=seed-mop
      seed-stack=(list (pair hash commit))
      ::  Walk limits
      ::
      cliff=(set hash)
      ::  Commits already processed
      ::
      done=(set hash)
      
  ==
--
|_  walk=rev-walk
::  Walk over revisions, growing the walk 
::  from the seed list
::
++  walk-revs
  |=  [repo=repository seed=(list [hash walk=?])]
  ^-  [(list [hash commit]) rev-walk]
  =.  walk  *rev-walk
  =.  repo.walk  repo
  (prepare seed)
++  put-unit-by-store
  |=  [=hash commit=(unit commit)]
  ^-  rev-walk
  walk(store (~(put by store.walk) hash commit))
::  Retrieve a commit from the walk
::  store. If it does not exist, 
::  reach out to the repository store, crash if not found.
::  The null commit means the object was 
::  added to the store as a hash only (partially).
::
++  got-unit-by-store
  |=  =hash
  ^-  [(unit commit) _walk]
  =+  obj=(~(get by store.walk) hash)
  ?^  obj
    [u.obj walk]
  =/  obj=object
    (got:~(store git repo.walk) hash)
  ?>  ?=(%commit -.obj)
  =+  commit=+.obj
  [`commit (put-unit-by-store hash `commit)]
::  Retrieve a commit from the walk
::  store. If it does not exist, 
::  reach out to the repository store.
::  If the commit exists but is partial, 
::  put the full object into the store and return it.
::
++  got-by-store
  |=  =hash
  ^-  [commit rev-walk]
  =+  obj=(~(get by store.walk) hash)
  ?:  &(?=(^ obj) ?=(^ u.obj))
    [u.u.obj walk]
  =/  obj=object
    (got:~(store git repo.walk) hash)
  ?>  ?=(%commit -.obj)
  =+  commit=+.obj
  [commit (put-unit-by-store hash `commit)]
++  put-on-seed
  |=  [=hash =commit]
  ^-  rev-walk
  ::  XX use a zipper
  ::
  =+  time=-.date.committer.header.commit
  =/  sits=(unit (list [^hash ^commit]))
    (get:seed-on seed.walk time)
  ?~  sits
    walk(seed (put:seed-on seed.walk time [[hash commit] ~]))
  ::  Guard against duplicates
  ::
  ?^  (find ~[[hash commit]] u.sits)
    walk
  walk(seed (put:seed-on seed.walk time [[hash commit] u.sits]))
++  pop-on-seed
  ^-  [[hash commit] rev-walk]
  =+  seed-stack=seed-stack.walk
  ?^  seed-stack
    =^  first  seed-stack.walk  seed-stack
    [first walk]
  =^  pop  seed.walk  (pop:seed-on seed.walk)
  =^  first  seed-stack.walk  val.head.pop
  [first walk]
++  mark-parents-cliff
  |=  =commit
  ^-  rev-walk
  =|  stack=(list hash)
  =+  parents=parents.header.commit
  =<
  ::  Mark parents of the commit as cliff, 
  ::  possibly adding grandparents to the stack
  ::
  =^  stack  cliff.walk
    |-
    ?~  parents
      [stack cliff.walk]
    =+  hash=i.parents
    =.  cliff.walk
      (~(put in cliff.walk) hash)
    =^  grands=(list ^hash)  walk  
      (mark-one-parent-cliff hash)
    %=  $
      parents  t.parents
      stack  (weld grands stack)
    ==
  |-
  ?~  stack
    walk
  =+  hash=i.stack
  =^  parents=(list ^hash)  walk  (mark-one-parent-cliff hash)
  $(stack (weld parents stack))
  ::
  |%
  ++  mark-one-parent-cliff
    |=  =hash
    ^-  [(list ^hash) rev-walk]
    ::  Do not jump off the cliff twice
    ::
    ?:  (~(has in cliff.walk) hash)
      [~ walk]
    :: ~&  mark-one-parent-cliff+hash
    =.  cliff.walk  (~(put in cliff.walk) hash)
    =^  mit  walk  (got-unit-by-store hash)
    ?~  mit
      [~ walk]
    ::  We have already got this commit,
    ::  add parents to the stack
    ::
    :_  walk
    parents.header.u.mit
  --
++  process-parents
  |=  [=hash =commit]
  ^-  rev-walk
  ::  Processing parents
  ::  (1) Check if the commit has been processed (ADD flag)
  ::  (2) For cliff commits that has already been parsed,
  ::      process each parent
  ::    (a) Mark the parent cliff
  ::    (b) Make it into a full object and mark 
  ::        grandparents cliff
  ::    (c) If the object has not yet been added to the list (!SEEN),
  ::        add it in time order.
  ::  (3) For interesting commits, process each parent
  ::    (a) If the parent is interesting, add it to 
  ::        the list in time order, if it=[hash commit] has not been SEEN yet.
  ::
  ::  XX use a zipper
  ::
  ?:  (~(has in done.walk) hash)
    walk
  =.  done.walk  (~(put in done.walk) hash)
  =+  parents=parents.header.commit
  ::  Cliff commit
  ::
  ?:  (~(has in cliff.walk) hash)
    |-
    ?~  parents
      walk
    =+  hash=i.parents
    =^  mit  walk  (got-by-store hash)
    =.  walk  (mark-parents-cliff mit)
    =.  walk  (put-on-seed hash mit)
    $(parents t.parents)
  |-
  ?~  parents
    walk
  =+  hash=i.parents
  =^  mit  walk  (got-by-store hash)
  =.  walk  (put-on-seed hash mit)
  $(parents t.parents)

++  prepare
  |=  seed=(list [hash walk=?])
  ^-  [(list [hash commit]) rev-walk]
  =.  walk
    |-
    ?~  seed 
      walk
    =+  hash=-.i.seed
    =+  cliff=!+.i.seed
    :: ~&  prepare-commit+[hash cliff]
    ::  XX 1. Here we have a zipper focused at commit
    ::
    =^  mit=commit  walk  (got-by-store hash)
    =.  walk  (put-on-seed hash mit)
    ::  XX 2. Here we use the zipper to update flags
    ::
    =?  walk  cliff
      =.  cliff.walk  (~(put in cliff.walk) hash)
      (mark-parents-cliff mit)
    $(seed t.seed)
  ::  Limit the list
  ::  (1) Pop the commit
  ::  (2) Handle max age (commit too old)
  ::  (3) Process parents
  ::  (4) Handle uninteresting commit
  ::  (5) Handle min age (commit too young)
  ::  (6) Discard the commit if too old (if desired)
  ::  (7) Push the commit onto the stack
  ::
  =|  commits=(list [hash commit])
  =^  commits  walk
    |-
    ::  XX typechecker goes haywire
    ::
    =+  seed=seed.walk
    ?~  seed
      [commits walk]
    =^  [=hash mit=commit]  walk  pop-on-seed
    :: ~&  pop-seed+[hash parents.header.mit]
    ::  XX Handle max age
    ::  XX This modifies the seed mop
    ::
    =.  walk  (process-parents hash mit)
    =?  walk  (~(has in cliff.walk) hash)
      (mark-parents-cliff mit)
    ::  XX Handle min age
    ::  XX Handle max age as filter
    $(commits [[hash mit] commits])
  :_  walk
  ::  XX Git probably uses cliff commits for something
  ::
  (flop (skip commits |=([=hash mit=*] (~(has in cliff.walk) hash))))
--
