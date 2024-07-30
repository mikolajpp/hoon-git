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
/+  git=git-repository, *git-hash, *git-object, *git-refs
/+  l=git-log
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
    ::  redirect / to /code
    ::
    ~  %+  give-simple-payload:app:server  eyre-id
       :_  ~  =-  [308 ~[['location' -]]]
              ;:((cury cat 3) repo-name '/' 'code')
    ::
    [%about ~]  (about repo request-line)
  ==
++  manx-as-octs
  |=  =manx
  %-  some
  %-  as-octt:mimes
  (en-xml manx)
++  cmp-txt
  |=  [a=@t b=@t]
  ^-  ?
  =+  len=(met 3 a)
  =+  lem=(met 3 b)
  =+  i=0
  |-
  ?:  (gte i len)
    &
  ?:  (gte i lem)
    |
  =+  c=(cut 3 [0 i] a)
  =+  d=(cut 3 [0 i] b)
  ?:  (lth c d)
    &
  ?:  (gth c d)
    |
  $(i +(i))
++  cmp-tree-entry
  |=  [a=tree-entry b=tree-entry]
  ^-  ?
  ?:  =((file-type a) (file-type b))
    (cmp-txt name.a name.b)
  ?:  (is-dir a)
    &
  ?:  (is-dir b)
    |
  ?:  (is-gitlink a)
    &
  ?:  (is-gitlink b)
    |
  (cmp-txt name.a name.b)
++  about
  |=  [repo=repository:git =request-line:server]
  ^-  (list card:agent:gall)
  ?>  ?=([%git @t %about ~] site.request-line)
  =+  repo-name=i.t.site.request-line
  %+  give-simple-payload:app:server  eyre-id
  :-  [200 ~]
  ::
  =/  branch  (need (resolve:~(refs git repo) head:refspace))
  =/  hash  (got:~(refs git repo) branch)
  =/  commit  (got-commit:~(store git repo) hash)
  =/  tree-dir  (got-tree:~(store git repo) tree.commit)
  =*  dir  tree-dir
  =/  readme-hash=(unit ^hash)
    |-  ?~  dir  ~
    :: XX switch to 'readme.udon'
    :: XX what about LICENSE? switch to license as well?
    ::
    ?:  ?|  =(name.i.dir 'README.md')
            =(name.i.dir 'readme.md')
        ==
      (some hash.i.dir)
    $(dir t.dir)
  =/  readme-octs=(unit octs)
    %+  biff  readme-hash
    get-blob:~(store git repo)
  =/  readme
    %+  bind  readme-octs
    ;:  corl
      sail-en:md:md
      (curr scan markdown:de:md:md)
      |=(=octs (trip q.octs))
    ==
  %-  manx-as-octs
  ;body
    ;head
      ;meta(charset "utf-8");
      ;style: {default:style}
      ;style: {about:style}
    ==
    ;header
      ;h1: {<our.bowl>} / {(trip repo-name)}
      ;h2: branch: {(spud branch)}
      ;nav
        ;a/"code": Code
        ;a/"commit": Commit
        ;a/"tree": Tree
        ;a/"refs": Refs
        ;a/"diff": Diff
      ==
    ==
    ;+  (~(tree-dir ui repo) dir hash)
    :: ;p: Current branch /refs/heads/master
    :: ;h2: README
    ;*  ?~(readme ~ ~[u.readme])
    :: ;+  code:icon
    :: ;p: Hosted on {<our.bowl>}
  ==
++  ui
  |_  repo=repository:git
  ++  tree-entry
    |=  entry=^tree-entry
    ^-  manx
    ;a/"tree/{(trip name.entry)}": {(trip name.entry)}
  ++  tree-dir
    |=  [dir=^tree-dir tip=hash]
    ^-  manx
    =/  dir  (sort dir cmp-tree-entry)
    ;table(class "tree-view")
      ;*  %+  turn  dir
          |=  entry=^tree-entry
          ^-  manx
          =/  [last-hash=hash last-commit=commit]
            %-  need
            (tree-path-last-modified:l repo tip ~[name.entry])
          =*  date  date.commit-time.last-commit
          =/  last-date  `@dr`(sub now.bowl date)
          ;tr  ;td  ;+  (tree-entry entry)
               ==
               ;td: {message.last-commit}
               ;td: {<last-date>}
          ==
    ==
  --
++  style
  |%
  ++  default
    ^~
    %-  trip
    '''
    * {font-family: monospace;}
    .navigation { display: flex; }
    header > nav {font-size: 2em;}
    header > nav > a {margin: 10px;}
    table.tree-view {font-size: 20px;}
    '''
  ++  about  
    ^~
    %-  trip
    ''
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
