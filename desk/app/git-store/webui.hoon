::  
::  git web ui
::
::  XX separate this functionality to the %git-view agent
::
::  /git/repo - redirect to /about
::
::  /git/repo/about/[rev]
::    render README.md XX or README.udon
::
::  /git/repo/summary/[rev]
::    a combined view of activity on branches, tags, and commits
::
::  /git/repo/log/[rev]
::    recent commits
::
::  /git/repo/tree/[rev]
::    current tree
::
::  /git/repo/commit/[rev]
::    current commit
::
::  /git/repo/diff/[rev]
::    current diff
::
::  /git/repo/blob/[rev]/[path]
::    view file at path in the tree
::
::  if revision is unspecified, it defaults to the
::  latest revision on the default branch.
::
/+  server
/+  git=git-repository, *git-hash
::  XX encourage migration to readme.udon
::
/+  md=markdown
=,  html
|_  [=bowl:gall eyre-id=@ta]
++  view
  |=  [repo=repository:git =request-line:server]
  ^-  (list card:agent:gall)
  ?>  ?=([%git @t *] site.request-line)
  =+  repo-name=i.t.site.request-line
  ::
  ?+  t.t.site.request-line  !!
    ::  redirect / to /about
    ::
    ~  %+  give-simple-payload:app:server  eyre-id
       :_  ~  =-  [308 ~[['location' -]]]
              ;:((cury cat 3) repo-name '/' 'about')
    ::
    [%about ~]  (about repo request-line)
  ==
++  manx-as-octs
  |=  =manx
  %-  some
  %-  as-octt:mimes
  (en-xml manx)
++  about
  |=  [repo=repository:git =request-line:server]
  ^-  (list card:agent:gall)
  ?>  ?=([%git @t %about ~] site.request-line)
  =+  repo-name=i.t.site.request-line
  %+  give-simple-payload:app:server  eyre-id
  :-  [200 ~]
  ::  XX default branch should be saved in configuration on clone
  ::
  ::  (got-file repo /refs/heads/main /readme/umd)
  ::
  =/  hash  (got:~(refs git repo) /refs/heads/main)
  ::  XX got-commit, get-commit, etc.
  ::
  =/  obj  (got:~(store git repo) hash)
  ?>  ?=(%commit -.obj)
  =/  obj  (got:~(store git repo) tree.commit.obj)
  ?>  ?=(%tree -.obj)
  =+  dir=tree-dir.obj
  =/  readme=(unit ^hash)
    |-  ?~  dir  ~
    ?:  =(name.i.dir 'README.md')
      (some hash.i.dir)
    $(dir t.dir)
  =/  obj  (got:~(store git repo) (need readme))
  ?>  ?=(%blob -.obj)
  =/  readme-md  (scan (trip q.data.obj) markdown:de:md:md)
  %-  manx-as-octs
  ;body
    ;head
      ;meta(charset "utf-8");
      ;style:"{(trip default:style)}"
      ;style:"{(trip about:style)}"
    ==
    ;h1: About {(trip repo-name)} repository
    ;p: Current branch /refs/heads/master
    ;h2: README
    ;+  (sail-en:md:md readme-md)
    ;+  code:icon
    ;p: Hosted on {<our.bowl>}
  ==
++  style
  |%
  ++  default
    '''
    * {font-family: monospace;}
    '''
  ++  about  ''
  --
++  icon
  |%
  ++  icon-color  "black"
  ++  code
    ;svg
      ;path  
        =d  """
            M76.2222 106.854L103.111 69.8543C105.681 
            66.3184 105.611 61.5114 102.939 
            58.0518L74.9519 21.8112
            """ 
        =fill  "none"
        =stroke  icon-color
        =opacity  "1"
        =stroke-linecap  "butt" 
        =stroke-linejoin  "round" 
        =stroke-width  "3";
      ;path
        =d  """
            M52.871 21.8112L25.2117 58.2889C22.5706 
            61.772 22.5431 66.5795 25.144 
            70.0926L52.3653 106.861
            """
        =fill  "none" 
        =stroke  icon-color
        =opacity  "1" 
        =stroke  "#000000" 
        =stroke-linecap  "butt" 
        =stroke-linejoin  "round" 
        =stroke-width  "3";
    ==
  --
--
