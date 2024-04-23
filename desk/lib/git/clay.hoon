::
::  Git-clay interface
::
/+  *git, *git-refs, git=git-repository
=,  clay
|%
::
::  Export the tree at reference and directory from the repository
::  as soba, to be instantiated into a clay desk
::
++  as-namespace
  |=  [repo=repository:git =refname dir=path]
  ^-  (list [path page])
  =/  obj 
    %-  got:~(store git repo)
      (got:~(refs git repo) refname)
  ?>  ?=(%commit -.obj)
  =+  commit=commit.obj
  =/  obj
    ::  XX do not put face on commit elements
    ::
    (got:~(store git repo) tree.commit)
  ?>  ?=(%tree -.obj)
  =+  tree=tree.obj
  ::  Descend to directory
  ::
  =.  tree
    |-
    ?~  dir
      tree
    =/  idx=(unit @ud)
      ::  XX Add +seek to list arms to return the value instead 
      ::  of index
      ::
      %+  find  [i.dir]~
      %+  turn  tree
        |=(=tree-entry name.tree-entry)
    =+  entry=(snag (need idx) tree)
    %=  $
      dir  t.dir
      tree
        =+  obj=(got:~(store git repo) hash.entry)
        ?>  ?=(%tree -.obj)
        tree.obj
    ==
  =|  =path
  =|  nase=(list [^path page])
  |-
  ?~  tree
    nase
  =+  entry=(got:~(store git repo) hash.i.tree)
  ?+  -.entry  !!
    %tree  
      ~&  nase-tree+path
      %=  $
        tree  t.tree
        nase  $(tree tree.entry, path [name.i.tree path])
      ==
    %blob
      ~&  blob-name+name.i.tree
      =/  [name=@ta ext=@ta]
        %+  scan  (trip name.i.tree) 
          %+  cook
            |=([a=tape b=tape] [(crip a) (crip b)])
          ;~(plug (plus ;~(less dot prn)) ;~(pfix dot (plus prn)))
      =+  path=[ext name path]
      ~&  nase-blob+path
      ::  All we have is mime /text/plain octs. 
      ::  They need to be converted to whatever is the mark.
      ::  However, for this we need scry!
      ::  Alternatively, we should grab all /mar files, 
      ::  build them on the fly, and use them for conversion, 
      ::  which is what clay would do, it seems.
      ::
      =/  =page
        [%mime /text/plain octs.entry]
      $(tree t.tree, nase [[(flop path) page] nase])
  ==
--
