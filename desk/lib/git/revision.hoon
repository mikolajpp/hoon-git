::
::  Revision walking
::  Revision walker accepts a list of user supplied 
::  commits, some of which can be marked as dull.
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
/+  *git, git=git-repository
|%
::  XX Why does it need manual structure mode?
::
+$  seed-mop  ((mop @ud (list (pair hash commit))) gth)
++  seed-on  ((on @ud (list (pair hash commit))) gth)
+$  rev-walk 
  $:  repo=repository:git
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
      ::  of the dull set -- we mark grandparents dull
      ::  only if the parent was stored as a full object.
      ::
      store=(map hash (unit commit))
      ::  Seeds to grow from
      ::
      seed=seed-mop
      seed-stack=(list (pair hash commit))
      ::  Walk limits
      ::
      dull=(set hash)
      ::  Commits already processed
      ::
      done=(set hash)
      
  ==
--
|_  state=rev-walk
::  Walk over revisions, growing the walk 
::  from the seed list
::  
++  walk
  |=  [repo=repository:git want=(list hash) exclude=(list hash)]
  ^-  (list (pair hash commit))
  =.  repo.state  repo
  ::  XX prepare should also use want/exclude lists
  ::
  =/  seed=(list [hash ?])
    %+  weld
    (turn want |=(a=hash [a &]))
    (turn exclude |=(a=hash [a |]))
  (prepare seed)
::  XX Shouldn't this just be named put-by-store?
::
++  put-unit-by-store
  |=  [=hash commit=(unit commit)]
  ^-  rev-walk
  state(store (~(put by store.state) hash commit))
::  Retrieve a commit from the walk
::  store. If it does not exist, 
::  reach out to the repository store, crash if not found.
::  The null commit means the object was 
::  added to the store as a hash only (partially).
::
++  got-unit-by-store
  |=  =hash
  ^-  [(unit commit) rev-walk]
  =+  obj=(~(get by store.state) hash)
  ?^  obj
    [u.obj state]
  =/  obj=object
    (got:~(store git repo.state) hash)
  ?>  ?=(%commit -.obj)
  [`commit.obj (put-unit-by-store hash `commit.obj)]
::  Retrieve a commit from the walk
::  store. If it does not exist, 
::  reach out to the repository store.
::  If the commit exists but is partial, 
::  put the full object into the store and return it.
::
++  got-by-store
  |=  =hash
  ^-  [commit rev-walk]
  =+  obj=(~(get by store.state) hash)
  ?:  &(?=(^ obj) ?=(^ u.obj))
    [u.u.obj state]
  =/  obj=object
    (got:~(store git repo.state) hash)
  ?>  ?=(%commit -.obj)
  [commit.obj (put-unit-by-store hash `commit.obj)]
++  put-on-seed
  |=  [=hash =commit]
  ^-  rev-walk
  ::  XX use a zipper
  ::
  =+  time=-.date.committer.commit
  =/  sits=(unit (list [^hash ^commit]))
    (get:seed-on seed.state time)
  ?~  sits
    state(seed (put:seed-on seed.state time [[hash commit] ~]))
  ::  Guard against duplicates
  ::
  ?^  (find ~[[hash commit]] u.sits)
    state
  state(seed (put:seed-on seed.state time [[hash commit] u.sits]))
++  pop-on-seed
  ^-  [[hash commit] rev-walk]
  =+  seed-stack=seed-stack.state
  ?^  seed-stack
    =^  first  seed-stack.state  seed-stack
    [first state]
  =^  pop  seed.state  (pop:seed-on seed.state)
  =^  first  seed-stack.state  val.head.pop
  [first state]
++  mark-parents-dull
  |=  =commit
  ^-  rev-walk
  =|  stack=(list hash)
  =+  parents=parents.commit
  =<
  ::  Mark parents of the commit as dull, 
  ::  possibly adding grandparents to the stack
  ::
  =^  stack  dull.state
    |-
    ?~  parents
      [stack dull.state]
    =+  hash=i.parents
    =.  dull.state
      (~(put in dull.state) hash)
    =^  grands=(list ^hash)  state  
      (mark-one-parent-dull hash)
    %=  $
      parents  t.parents
      stack  (weld grands stack)
    ==
  |-
  ?~  stack
    state
  =+  hash=i.stack
  =^  parents=(list ^hash)  state  (mark-one-parent-dull hash)
  $(stack (weld parents stack))
  ::
  |%
  ++  mark-one-parent-dull
    |=  =hash
    ^-  [(list ^hash) rev-walk]
    ::  Do not jump off the dull twice
    ::
    ?:  (~(has in dull.state) hash)
      [~ state]
    :: ~&  mark-one-parent-dull+hash
    =.  dull.state  (~(put in dull.state) hash)
    =^  mit  state  (got-unit-by-store hash)
    ?~  mit
      [~ state]
    ::  We have already got this commit,
    ::  add parents to the stack
    ::
    :_  state
    parents.u.mit
  --
++  process-parents
  |=  [=hash =commit]
  ^-  rev-walk
  ::  Processing parents
  ::  (1) Check if the commit has been processed (ADD flag)
  ::  (2) For dull commits that has already been parsed,
  ::      process each parent
  ::    (a) Mark the parent dull
  ::    (b) Make it into a full object and mark 
  ::        grandparents dull
  ::    (c) If the object has not yet been added to the list (!SEEN),
  ::        add it in time order.
  ::  (3) For interesting commits, process each parent
  ::    (a) If the parent is interesting, add it to 
  ::        the list in time order, if it=[hash commit] has not been SEEN yet.
  ::
  ::  XX use a zipper
  ::
  ?:  (~(has in done.state) hash)
    state
  =.  done.state  (~(put in done.state) hash)
  =+  parents=parents.commit
  ::  dull commit
  ::
  ?:  (~(has in dull.state) hash)
    |-
    ?~  parents
      state
    =+  hash=i.parents
    =^  mit  state  (got-by-store hash)
    =.  state  (mark-parents-dull mit)
    =.  state  (put-on-seed hash mit)
    $(parents t.parents)
  |-
  ?~  parents
    state
  =+  hash=i.parents
  =^  mit  state  (got-by-store hash)
  =.  state  (put-on-seed hash mit)
  $(parents t.parents)
::  XX Make (list (pair [hash commit] ?))
::  the standard output of revision state. 
::  The flag indicates whether to state over the commit (&) 
::  or it is a dull object. 
::
++  prepare
  |=  seed=(list [hash walk=?])
  ^-  (list [hash commit])
  =.  state
    |-
    ?~  seed 
      state
    =+  hash=-.i.seed
    =+  dull=!+.i.seed
    :: ~&  prepare-commit+[hash dull]
    ::  XX 1. Here we have a zipper focused at commit
    ::
    =^  mit=commit  state  (got-by-store hash)
    =.  state  (put-on-seed hash mit)
    ::  XX 2. Here we use the zipper to update flags
    ::
    =?  state  dull
      =.  dull.state  (~(put in dull.state) hash)
      (mark-parents-dull mit)
    $(seed t.seed)
  ::  Limit the list
  ::  (1) Pop the commit
  ::  (2) Handle max age (commit too old)
  ::  (3) Process parents
  ::  (4) Handle dull commit
  ::  (5) Handle min age (commit too young)
  ::  (6) Discard the commit if too old (if desired)
  ::  (7) Push the commit onto the stack
  ::
  =|  commits=(list [hash commit])
  =^  commits  state
    |-
    ::  XX typechecker goes haywire
    ::
    =+  seed=seed.state
    ?~  seed
      [commits state]
    =^  [=hash mit=commit]  state  pop-on-seed
    :: ~&  pop-seed+[hash parents.mit]
    ::  XX Handle max age
    ::  XX This modifies the seed mop
    ::
    =.  state  (process-parents hash mit)
    =?  state  (~(has in dull.state) hash)
      (mark-parents-dull mit)
    ::  XX Handle min age
    ::  XX Handle max age as filter
    $(commits [[hash mit] commits])
  ::  XX Git shows dull commits when requested with arguments
  ::
  (flop (skip commits |=([=hash mit=*] (~(has in dull.state) hash))))
--
