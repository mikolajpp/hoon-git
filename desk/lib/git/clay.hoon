::
::  Git-clay interface
::
/+  *git-object, *git-refs, git=git-repository
=,  clay
|%
::  Export the tree at :refname and directory
::  as soba, to be instantiated into a clay desk
::
++  as-soba
  |=  [repo=repository:git =refname dir=path]
  ^-  soba
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
  =|  =soba  ::  (list [path miso])
  |-
  ?~  tree
    soba
  =+  entry=(got:~(store git repo) hash.i.tree)
  ?+  -.entry  !!
    %tree  
      %=  $
        tree  t.tree
        soba  $(tree tree.entry, path [name.i.tree path])
      ==
    %blob
      =/  file=(unit [name=@ta ext=@ta])
        %+  rust  (trip name.i.tree) 
          %+  cook
            |=([a=tape b=tape] [(crip a) (crip b)])
          ;~(plug (plus ;~(less dot prn)) ;~(pfix dot (plus prn)))
      ?~  file
        $(tree t.tree)
      =+  path=[ext.u.file name.u.file path]
      ::  XX make sure loose objects do not have the header 
      ::
      =/  miso 
        [%ins %mime !>([/text/plain octs.entry])]
      $(tree t.tree, soba [[(flop path) miso] soba])
  ==
  :: ~&  "Exporting {<refname>} to clay, found tree {<tree.commit>}"
  :: *soba
--
