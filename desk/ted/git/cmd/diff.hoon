:: 
::  git diff src..dst
::
:: XX Is /% defunct?
:: /%  txt  %txt
/-  spider, git-cmd
/+  io=strandio, stream, *shoe
/+  git=git-repository, *git-refs, *git-refspec, git-pack
/+  *git-cmd, *git-cmd-parser-diff, git-http, git-clay
::  XX solve shadowing of git $tree
/+  *git
/=  txt  /mar/txt
::
=,  strand=strand:spider
^-  thread:spider
::
|=  arg=vase
=/  m  (strand ,vase)
^-  form:m
=/  [=sole-id =dir:git-cmd repo=(unit repository:git) =args =opts-map]
  !<((ted-args:git-cmd args) arg)
=+  opts=(get-opts opts-map)
?~  repo  (pure:m !>(~))
=+  repo=u.repo
=/  src=hash
  ?@  src.args
    %-  need
    (find-by-key:~(store git repo) src.args)
  %-  got:~(refs git repo)
  (scan (trip ref.src.args) parse-refname)
=/  dst=hash
  ?@  dst.args
    %-  need
    (find-by-key:~(store git repo) dst.args)
  %-  got:~(refs git repo)
  (scan (trip ref.dst.args) parse-refname)
:: ~&  src+src
:: ~&  dst+dst
=/  src-commit=commit
  =-  ?>(?=(%commit -.-) commit.-)
  (got:~(store git repo) src)
=/  dst-commit=commit
  =-  ?>(?=(%commit -.-) commit.-)
  (got:~(store git repo) dst)
=/  src-tree=tree
  =-  ?>(?=(%tree -.-) tree.-)
  (got:~(store git repo) tree.src-commit)
=/  dst-tree=tree
  =-  ?>(?=(%tree -.-) tree.-)
  (got:~(store git repo) tree.dst-commit)
:: ~&  src-tree
:: ~&  dst-tree
=/  diff  (flop (diff-tree repo dst-tree src-tree /))
::  Display diff
=>  |%
    ::  XX Do not print binary files!
    ::
    ++  plus-styl 
      [~ [~ `%g]]
    ++  min-styl
      [~ [~ `%r]]
    ++  print-txt
      |=  [txt=wain side=?]
      ^-  (list sole-effect)
      =/  styl
        ?:(side plus-styl min-styl)
      %+  turn  txt
      |=  line=@t
      ^-  sole-effect
      [%klr ~[[styl ~[line]]]]
    ++  print-file
      |=  [=path =hash side=?] 
      ^-  sole-effect
      =/  obj
        (got:~(store git repo) hash)
      ?>  ?=(%blob -.obj)
      =/  =wain  (mime:grab:txt /text/plain octs.obj)
      :-  %mor
      :-  [%txt "{<path>}:"]
      (print-txt wain side)
    ++  print-diff
      |=  [=path left=hash right=hash]
      ^-  sole-effect
      =/  left-obj  (got:~(store git repo) left)
      =/  right-obj  (got:~(store git repo) right)
      ?>  ?=(%blob -.left-obj)
      ?>  ?=(%blob -.right-obj)
      =/  lain=wain  (mime:grab:txt /text/plain octs.left-obj)
      =/  rain=wain  (mime:grab:txt /text/plain octs.right-obj)
      =/  diff
        (diff:~(grad txt lain) rain)
      :-  %mor
      :-  [%txt "{<path>}:"]
      ^-  (list sole-effect)
      =|  efes=(list sole-effect)
      =|  line=@ud
      |-
      ?~  diff  (flop efes)
      ::  Advance to line
      ::
      ?-  -.i.diff
        %&  $(line p.i.diff, diff t.diff)
        %|  
          %=  $
            efes
              :: ^-  (list sole-effect)
              =/  plus=sole-effect
                [%mor (print-txt p.i.diff &)]
              :: ~&  `wain`q.i.diff
              ::  XX Some insane bug??
              :: ~&  [%mor (print-txt p.i.diff &)])
              :: =/  plus=sole-effect
              :: =/  mine=sole-effect
              ::   [%mor (print-txt p.i.diff &)])
              [plus efes]
            diff  t.diff
          ==


      ==
    --
=/  efes=(list sole-effect)
  %+  turn  diff
  |=  [p=path q=hash r=hash]
  ^-  sole-effect
  =.  p  (flop p)
  ?:  =(0x0 q)
    (print-file p r |)
  ?:  =(0x0 r)
    (print-file p q &)
  (print-diff p q r)
;<  ~  bind:m  
  %+  poke-our:io   %git-cmd 
  [%noun !>([%shoe ~[sole-id] %sole [%mor (flop efes)]])]
(pure:m !>(~))
