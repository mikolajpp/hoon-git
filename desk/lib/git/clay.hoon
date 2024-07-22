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
  =+  tree-dir=tree-dir.obj
  ::  Descend to directory
  ::
  =.  tree-dir
    |-
    ?~  dir
      tree-dir
    =/  idx=(unit @ud)
      ::  XX Add +seek to list arms to return the value instead
      ::  of index
      ::
      %+  find  [i.dir]~
      %+  turn  tree-dir
        |=(=tree-entry name.tree-entry)
    =+  entry=(snag (need idx) tree-dir)
    %=  $
      dir  t.dir
      tree-dir
        =+  obj=(got:~(store git repo) hash.entry)
        ?>  ?=(%tree -.obj)
        tree-dir.obj
    ==
  =|  =path
  =|  =soba  ::  (list [path miso])
  |-
  ?~  tree-dir
    soba
  =+  entry=(got:~(store git repo) hash.i.tree-dir)
  ?+  -.entry  !!
    %tree
      %=  $
        tree-dir  t.tree-dir
        soba  $(tree-dir tree-dir.entry, path [name.i.tree-dir path])
      ==
    %blob
      =/  file=(unit [name=@ta ext=@ta])
        %+  rust  (trip name.i.tree-dir)
          %+  cook
            |=([a=tape b=tape] [(crip a) (crip b)])
          ;~(plug (plus ;~(less dot prn)) ;~(pfix dot (plus prn)))
      ?~  file
        $(tree-dir t.tree-dir)
      =+  path=[ext.u.file name.u.file path]
      ::  XX make sure loose objects do not have the header
      ::
      =/  miso
        [%ins %mime !>([/text/plain data.entry])]
      $(tree-dir t.tree-dir, soba [[(flop path) miso] soba])
  ==
  :: ~&  "Exporting {<refname>} to clay, found tree {<tree.commit>}"
  :: *soba
--
