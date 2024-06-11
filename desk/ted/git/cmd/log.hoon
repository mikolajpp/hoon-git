:: 
::  git [-n <number>] [branch]
::
/-  spider
/-  *git, git-cmd
/+  io=strandio, stream, *shoe
/+  git=git-repository, *git-refs, *git-refspec, git-pack
/+  *git-cmd, *git-cmd-parser-log, git-http, git-clay
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
=/  =refname
  ?:  =(~. raw-refname.args)
    branch.dir
  (scan (trip raw-refname.args) parse-refname)
=/  refs=(list ^refname)  
  (expand-ref-prefix refname)
=/  dir=^refname
  |-
  ?~  refs
    ~|  "Reference {(trip (print-refname refname))} not found"  !!
  ?:  (has:~(refs git repo) i.refs)
    i.refs
  $(refs t.refs)
=/  =hash  (got:~(refs git repo) dir)
::  XX pass sole-id to threads to allow printing
::
=>  |%
    ++  print-person
      |=  person=commit-person
      ^-  @t
      %-  crip
      "{name.person} <{email.person}>"
    ++  print-time
      |=  time=commit-time
      ^-  @t
      %+  rap  3
      :~  (crip "{<date.time>} ")
          ?:(p.zone.time '+' '-')
          (crip "{<`@dr`q.zone.time>}")
      ==
    ++  hash-styl
      [~ [~ `%y]]
    ++  print-commit
      |=  [=^hash =commit]
      ^-  sole-effect
      ::  XX How does git handle newlines in commit messages?
      ::
      =/  tel=(list sole-effect)
        %+  scan  message.commit
        %+  ifix  =-([- -] (star (just '\0a')))
        %-  star
        ;~  pose
          %+  stag  %txt
          %+  cook
            |=  txt=tape
            (weld "    " txt)
          ;~(sfix (plus prn) (punt (just '\0a')))
          (cold [%txt ""] (just '\0a'))
        ==
      :-  %mor
      ^-  (list sole-effect)
      ::  XX Surely, there must be a better way
      ::  to print things to terminal...
      ::  XX And why does %txt take a tape, while %klr takes 
      ::  cords?
      ::
      ;:  welp
        :~  [%klr ~[[hash-styl ~[(crip "commit {(print-sha-1 hash)}")]]]]
            [%klr ~[(cat 3 'Author: ' (print-person author.commit))]]
            [%klr ~[(cat 3 'Date:   ' (print-time commit-time.commit))]]
        ==
        `(list sole-effect)`~[[%txt ""]]
        tel
        `(list sole-effect)`~[[%txt ""]]
      ==
    --
=+  count=number.opts
=|  fecs=(list sole-effect)
=.  fecs
  |-
  ?~  =(count 0)  fecs
  =+  obj=(got:~(store git repo) hash)
  ?>  ?=(%commit -.obj)
  ::  XX Can a thread access the name of invoking entity?
  ::
  ?~  parents.commit.obj  fecs
  %=  $
    count  (dec count)
    hash  i.parents.commit.obj
    fecs  :_(fecs (print-commit hash commit.obj))
  ==
;<  ~  bind:m  
  %+  poke-our:io   %git-cmd 
  [%noun !>([%shoe ~[sole-id] %sole [%mor (flop fecs)]])]
(pure:m !>(~))
