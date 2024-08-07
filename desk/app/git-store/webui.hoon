::  
::  git web ui
::
::  XX separate this functionality to the %git-view agent
::
::  /git/repo - redirect to /code
::
::  [rev] is either a hash or a refname.
::
::  /git/repo/code/[rev]
::    default view: render file listing and README.udon
::
::  /git/repo/summary
::    a combined view of activity on branches, tags, and commits
::
::  /git/repo/log/[rev]
::    recent commits
::
::  /git/repo/tree/[rev]
::    tree at .rev

::  /git/repo/blob/[rev]
::    blob at .rev

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
/+  l=git-log, t=git-tree, r=git-revision
::  XX encourage migration to readme.udon
::
/+  md=markdown
|%  +$  route  $:  base=@ta
                   repo-name=@ta
                   page=@ta
                   =ref
                   dir=path
                   ext=(unit @t)
               ==
--
::
=,  html
::  XX Should include the route
|_  [=bowl:gall eyre-id=@ta]
++  view
  |=  [repo=repository:git =request-line:server]
  ^-  (list card:agent:gall)
  ?>  ?=([%git @t *] site.request-line)
  ~&  site.request-line
  =+  repo-name=i.t.site.request-line
  =*  page-route  t.t.site.request-line
  =*  ext  ext.request-line
  =*  args  args.request-line
  ::  redirect / to /tree
  ::
  ?:  ?=(~ page-route)
    %+  give-simple-payload:app:server  eyre-id
    :_  ~  =-  [308 ~[['location' -] ['cache-control' 'no-cache']]]
           ;:((cury cat 3) repo-name '/' 'tree')
  ?.  ?=([@ta *] page-route)  !!
  =*  page  i.page-route
  =*  path  t.page-route
  ::  Extract reference and dir
  ::  
  =/  [=ref dir=^path]
    ::  default branch at HEAD
    ::
    ?:  ?=(~ path)
      :_  ~
      symref+(need (resolve:~(refs git repo) ['HEAD' ~]))
    ?>  ?=([@t *] path)
    ::  possible hash
    ::
    ?:  =((hash-size hash-algo.repo) (met 3 i.path))
      =/  hash  %+  rust  (trip i.path)
                (parse-hash hash-algo.repo)
      ?^  hash
        :_  t.path
        u.hash
      =/  [=refname dir=^path ref=(unit ref)]
        (pit-of:t refs.repo (weld /refs/heads path))
      ?>  ?=(^ ref)
      :_  dir
      [%symref refname]
    =/  [=refname dir=^path ref=(unit ref)]
      (pit-of:t refs.repo (weld /refs/heads path))
    ?>  ?=(^ ref)
    :_  dir
    [%symref refname]
  ?+  page  !!
    %commits  (view-commits repo-name repo ref dir ext args)
    %commit  (view-commit repo-name repo ref)
    ::
    %tree  (view-tree repo-name repo ref dir ext)
    ::
    %refs  (view-refs repo-name repo ref)
  ==
++  manx-as-octs
  |=  =manx
  %-  some
  %-  as-octt:mimes
  %+  weld  "<!DOCTYPE html>\0a"
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
::  /repo/tree/branch/dir
::
++  view-tree 
  |=  [repo-name=@ta repo=repository:git =ref dir=path ext=(unit @t)]
  ^-  (list card:agent:gall)
  %+  give-simple-payload:app:server  eyre-id
  :-  [200 ~[['cache-control' 'no-cache']]]
  ~&  [dir ext]
  =?  dir  &(?=(^ dir) ?=(^ ext))
    =/  fir  (flop dir)
    ?~  fir  !!
    (flop [;:((cury cat 3) i.fir '.' u.ext) t.fir])
  =|  =route
  =.  route
    %=  route
      base  'git'
      repo-name  repo-name
      page  %tree
      ref  ref
      dir  dir
      ext  ext
    ==
  =*  ui  ~(. ^ui repo route)
  ::  Extract reference and directory
  ::
  =/  commit-hash  
    ?@  ref  
      ref
    (got:~(refs git repo) refname.ref)
  =/  commit  (got-commit:~(store git repo) commit-hash)
  =/  object-hash
    ~&  dir
    (need (tree-path-hash:t repo tree.commit dir))
  =/  obj  (got:~(store git repo) object-hash)
  %-  manx-as-octs
  ;html
    ;+  head:ui
    ;body
      ;+  header:ui
      ;+  (navigation:ui %tree)
      ;main
        ;div#content
          ;+  ?+  -.obj  !!
                %tree  (el-tree-dir:ui commit-hash tree-dir.obj)
                %blob  (el-tree-blob:ui commit-hash data.obj)
              ==
        ==
      ==
    ==
  ==
  :: =/  readme-hash=(unit ^hash)
  ::   |-  ?~  tree-dir  ~
  ::   :: XX switch to 'readme.udon'
  ::   :: XX what about LICENSE? switch to license as well?
  ::   ::
  ::   ?:  ?|  =(name.i.tree-dir 'README.md')
  ::           =(name.i.tree-dir 'readme.md')
  ::       ==
  ::     (some hash.i.tree-dir)
  ::   $(tree-dir t.tree-dir)
  :: =/  readme-octs=(unit octs)
  ::   %+  biff  readme-hash
  ::   get-blob:~(store git repo)
  :: =/  readme
  ::   %+  bind  readme-octs
  ::   ;:  corl
  ::     sail-en:md:md
  ::     (curr scan markdown:de:md:md)
  ::     |=(=octs (trip q.octs))
  ::   ==
++  view-commits
  |=  $:  repo-name=@ta 
          repo=repository:git 
          =ref 
          dir=path 
          ext=(unit @t)
          args=(list [key=@t value=@t])
      ==
  ^-  (list card:agent:gall)
  %+  give-simple-payload:app:server  eyre-id
  :-  [200 ~[['cache-control' 'no-cache']]]
  =|  =route
  =.  route
    %=  route
      base  'git'
      repo-name  repo-name
      page  %commits
      ref  ref
      dir  dir
      ext  ext
    ==
  =*  ui  ~(. ^ui repo route)
  ::  Get reference and directory
  ::
  =/  commit-hash  
    ?@  ref  
      ref
    (got:~(refs git repo) refname.ref)
  ::  Get commit list range
  ::
  ?>  ?=([(pair @t @t) (pair @t @t) ~] args)
  =/  start=@ud  (slav %ud q.i.args)
  =/  end=@ud  (slav %ud q.i.t.args)
  =/  step  (sub end start)
  ~&  commits+[start=start end=end]
  =/  walk  (walk:r repo ~[commit-hash] ~)
  =.  walk
    |-
    ?:  =(start 0)
      walk
    $(walk +:~(step r walk), start (dec start))
  %-  manx-as-octs
  ;html
    ;+  head:ui
    ;body
      ;+  header:ui
      ;+  (navigation:ui %commits)
      ;ol
        ;*  =|  commits=(list manx)
            =+  i=start
            |-
            ^-  (list manx)
            ?:  =(i end)
              (flop commits)
            =^  step  walk  ~(step r walk)
            ?~  step  (flop commits)
            %=  $
              i  +(i)
              commits
                :_  commits
                ;li  ;+  (el-commit-item:ui u.step)
                ==
            ==
      ==
      ;+  =/  query-next
            "start={<(add start step)>}&end={<(add end step)>}"
          ?:  =(0 start)
          ;div
            ;nav
              ;a/"{to:route:ui}?{query-next}": Next
            ==
          ==
          =/  query-prev
            "start={<(sub start step)>}&end={<(sub end step)>}"
          ;div
            ;nav
              ;a/"{to:route:ui}?{query-prev}": Prev
              ;a/"{to:route:ui}?{query-next}": Next
            ==
          ==
    ==
  ==
++  view-commit
  |=  $:  repo-name=@ta 
          repo=repository:git 
          =ref 
      ==
  ^-  (list card:agent:gall)
  %+  give-simple-payload:app:server  eyre-id
  :-  [200 ~[['cache-control' 'no-cache']]]
  =|  =route
  =.  route
    %=  route
      base  'git'
      repo-name  repo-name
      page  %commit
      ref  ref
    ==
  =*  hal  hash-algo.repo
  =*  ui  ~(. ^ui repo route)
  ::  Get reference and directory
  ::
  =/  commit-hash  
    ?@  ref  
      ref
    (got:~(refs git repo) refname.ref)
  =/  commit
    (got-commit:~(store git repo) commit-hash)
  ::  Get commit list range
  ::
  %-  manx-as-octs
  ;html
    ;+  head:ui
    ;body
      ;+  header:ui
      ;+  (navigation:ui %commits)
      ;+  (el-commit:ui commit-hash commit)
    ==
  ==
++  view-refs
  |=  $:  repo-name=@ta 
          repo=repository:git 
          =ref
      ==
  ^-  (list card:agent:gall)
  %+  give-simple-payload:app:server  eyre-id
  :-  [200 ~[['cache-control' 'no-cache']]]
  =|  =route
  =.  route
    %=  route
      base  'git'
      repo-name  repo-name
      page  %refs
      ref  ref
    ==
  =*  hal  hash-algo.repo
  =*  ui  ~(. ^ui repo route)
  ::  Get reference and directory
  ::
  %-  manx-as-octs
  ;html
    ;+  head:ui
    ;body
      ;+  header:ui
      ;+  (navigation:ui %refs)
      ;h1: Branches
      ;ul
        ;*  %+  turn  (tap-prefix:~(refs git repo) /refs/heads)
            |=  [=refname =hash]
            ~&  [refname hash]
            ;p
              ; {(trip (print-refname refname))}
              ;+  =-  ~&(- -)  (el-short-commit-hash:ui hash)
            ==
      ==
      ;h1: Tags
      ;ul
        ;*  %+  turn  (tap-prefix:~(refs git repo) /refs/tags)
            |=  [=refname =hash]
            ~&  [refname hash]
            ;p
              ; {(trip (print-refname refname))}
              ;+  =-  ~&(- -)  (el-short-commit-hash:ui hash)
            ==
      ==
    ==
  ==

++  ui
  |_  [repo=repository:git =route]
  +*  hal  hash-algo.repo
  ++  route
    |%
    ++  ext-path
      ^-  tape
      ?~  ext.^route  ""
      (trip u.ext.^route)
    ++  dir-path
      ^-  tape
      "{(spud dir.^route)}{ext-path}"
    ++  ref-path
      |=  =ref
      ^-  tape
      ?@  ref
        (print-hash hash-algo.repo ref)
      ::  Strip /refs/heads or /tags
      =/  =path
        ?:  ?=([%refs %heads *] refname.ref)
          t.t.refname.ref
        ?:  ?=([%tags *] refname.ref)
          t.refname.ref
        ::  Access to forbidden namespace
        !!
      (tail (spud path))
    ++  to
      =,  ^route
      %+  weld
        "/{(trip base)}/{(trip repo-name)}/{(trip page)}/"
      ?~  dir
        "{(ref-path ref)}"
      "{(ref-path ref)}{dir-path}"
    ++  to-page
      |=  page=@ta
      =,  ^route
      "/{(trip base)}/{(trip repo-name)}/{(trip ^page)}"
    ++  to-page-with-ref
      |=  page=@ta
      =,  ^route
      %+  weld
        "/{(trip base)}/{(trip repo-name)}/{(trip ^page)}/"
      "{(ref-path ref)}"
    ++  to-page-with-ref-dir
      |=  page=@ta
      =,  ^route
      %+  weld
        "/{(trip base)}/{(trip repo-name)}/{(trip ^page)}/"
      "{(ref-path ref)}{dir-path}"
    ++  to-page-ref
      |=  [page=@ta =ref]
      =,  ^route
      %+  weld
        "/{(trip base)}/{(trip repo-name)}/{(trip ^page)}/"
      "{(ref-path ^ref)}"
    ++  to-page-ref-with-dir
      |=  [page=@ta =ref]
      =,  ^route
      %+  weld
        "/{(trip base)}/{(trip repo-name)}/{(trip ^page)}/"
      "{(ref-path ^ref)}{dir-path}"
    ++  to-page-ref-dir
      |=  [page=@ta =ref dir=path]
      =,  ^route
      %+  weld
        "/{(trip base)}/{(trip repo-name)}/{(trip ^page)}/"
      "{(ref-path ^ref)}{(spud ^dir)}"
    --
  ++  head
    ^-  manx
    ;head
      ;meta(charset "utf-8");
      ;style: {reset:style}
      ;style: {default:style}
      ;style: {code:style}
    ==
  ++  header
    ^-  manx
    =*  ref  ref.^route
    =*  repo-name  repo-name.^route
    ;header
      ;h1
        ;a/"/git/{(trip repo-name)}": {<our.bowl>} / {(trip repo-name)}
      ==
      :: ;+  ?@  ref
      ::       ;h2: commit: {(print-hash hash-algo.repo ref)}
      ::     =/  branch  (need (resolve:~(refs git repo) refname.ref))
      ::     ;h2: branch: {(spud branch)}
    ==
  ++  navigation
    |=  page=@tas
    ;nav
      ;a  =class  ?:(=(page %tree) "select" "")
          =href  "{(to-page-with-ref:route %tree)}"
        ; Code
      ==
      ;a  =class  ?:(=(page %commits) "select" "")
          =href  "{(to-page:route %commits)}?start=0&end=10"
        ; Commits
      ==
      ;a  =class  ?:(=(page %refs) "select" "")
          =href  "{(to-page-with-ref:route %refs)}"
        ; Refs
      ==
    ==
  ++  print-reference
    |=  =ref
    ^-  tape
    ?@  ref
      (print-hash hash-algo.repo ref)
    (spud refname.ref)
  ++  el-tree-entry
    |=  [dir=? entry=tree-entry]
    ^-  manx
    ?:  dir
      ;a/"{to:route}/{(trip name.entry)}": {(trip name.entry)}/
    ;a/"{to:route}/{(trip name.entry)}": {(trip name.entry)}
  ++  print-ago-date
    |=  [now=@da before=@da]
    ^-  tape
    =/  now  (yore now)
    =/  before  (yore before)
    ?:  !=(y.now y.before)
      =/  year  (sub y.now y.before)
      ?:  (gth year 1)
        "{<year>} year ago"
      "last year"
    ?:  !=(m.now m.before)
      =/  month  (sub m.now m.before)
      ?:  (gth month 1)
        "{<month>} months ago"
      "last month"
    =/  time=@dr  (sub ^now ^before)
    =/  =tarp  (yell time)
    ?:  (gte d.tarp 7)
      =+  week=(div d.tarp 7)
      ?:  (gth week 1)
        "{<week>} weeks ago"
      "last week"
    ?:  (gte d.tarp 1)
      ?:  (gth d.tarp 1)
        "{<d.tarp>} days ago"
      "yesterday"
    ?:  (gth h.tarp 0)
      ?:  (gth h.tarp 1)
        "{<h.tarp>} hours ago"
      "{<h.tarp>} hour ago"
    ?:  (gth m.tarp 0)
      ?:  (gth m.tarp 1)
        "{<m.tarp>} minutes ago"
      "{<m.tarp>} minute ago"
    ?:  (gth s.tarp 0)
      ?:  (gth s.tarp 1)
        "{<s.tarp>} seconds ago"
      "{<s.tarp>} second ago"
    "now"
  ++  el-tree-dir
    |=  [tip=hash =tree-dir]
    ^-  manx
    =/  tree-dir  (sort tree-dir cmp-tree-entry)
    ;table(class "tree-view")
      ;colgroup
        ;col.tree-entry;
        ;col.message;
        ;col.date;
      ==
      ;*  %+  turn  tree-dir
          |=  entry=tree-entry
          ^-  manx
          =/  [last-hash=hash last-commit=commit]
            %-  need
            (tree-path-last-modified:l repo tip (weld dir.^route ~[name.entry]))
          =*  last-date  date.commit-time.last-commit
          ;tr  ;td.tree-entry  ;+  (el-tree-entry (is-dir entry) entry)
               ==
               ;td.message: {message.last-commit}
               ;td.date: {(print-ago-date now.bowl last-date)}
          ==
    ==
  ++  el-tree-blob
    |=  [tip=hash data=octs]
    ^-  manx
    =/  [last-hash=hash last-commit=commit]
      %-  need
      (tree-path-last-modified:l repo tip dir.^route)
    =*  last-date  date.commit-time.last-commit
    ;content.blob
      ;p: {(spud dir.^route)}
      ;p.last-change: Last modified: {(print-ago-date now.bowl last-date)}
      ;hr;
      ;pre: {(trip q.data)}
    ==
  ++  el-commit-item
    |=  [=hash =commit]
    ^-  manx
    ;div.commit-item
      :: XX only show first line
      ;+  =/  message  
            =/  vex
              %-  (star ;~(less (just '\0a') prn))
              [[1 1] message.commit]
            ?~  q.vex  !!
            p.u.q.vex
          ;h1: {message}
      ;+  (el-short-commit-hash hash)
      ;p: {name.author.commit} committed on {(print-date date.commit-time.commit)}
      ;hr;
    ==
    ++  print-date
      |=  date=@da
      ^-  tape
      =/  =^date  (yore date)
      "{((d-co:co 0) y.date)}.{<m.date>}.{<d.t.date>}"
    ++  print-person
      |=  who=commit-person
      ^-  tape
      "{name.who} <{email.who}>"
    ++  el-short-commit-hash
      |=  =hash
      ^-  manx
      =/  label  (trip (print-short-hash 7 hash))
      ::  XX unify return type with +print-short-hash
      ::
      ;a/"{(to-page-ref:route %commit hash)}"
        =style  "text-decoration:underline; display:inline-block;"
        ; {label}
      ==
    ++  el-commit
      |=  [=hash =commit]
      ^-  manx
      =/  [msg-header=tape msg-body=tape]
        %+  scan  message.commit
        ;~  plug
          (star ;~(less (just '\0a') prn))
          (star ;~(pose (just '\0a') prn))
        ==
      ;div.commit
        ;h1: {msg-header}
        ;pre: {msg-body}
        ;div.committer
          ;*  ?:  =(author.commit committer.commit)
                ;=
                  ;p
                    ; Committed by {(print-person committer.commit)}
                    ; on {(print-date date.commit-time.commit)}
                  ==
                ==
              ;=
                ;p
                  ; Committed by {(print-person committer.commit)}
                  ; on {(print-date date.commit-time.commit)}
                ==
                ;p: Author {(print-person author.commit)}
              ==
              :: ==
          ;+  ?~  parents.commit
                ;p(style "font-style:italic;"): No parents
              ?:  ?=(~ t.parents.commit)
                ;p
                  =style  "font-style:italic;"
                  ; 1 parent
                  ;+  (el-short-commit-hash i.parents.commit)
                ==
              ;p
                =style  "font-style:italic;"
                ; {<(lent parents.commit)>} parents
                ;*  ^-  marl  %+  turn  parents.commit
                    |=  =^hash
                    (el-short-commit-hash hash)
              ==
        ==
      ==
  --
++  style
  |%
  ++  reset
    ^~
    %-  trip
    '''
    * { margin: 0; padding: 0;}
    body { line-height: 1.5; height: 1vh;} 
    '''
  ++  default
    ^~
    %-  trip
    '''
    @import url('https://fonts.googleapis.com/css2?family=Rubik:ital,wght@0,300..900;1,300..900&display=swap');
    body {
      padding-left: 30px;
      padding-top: 30px;

      display: grid;
      grid-template-columns: 100%;
      grid-template-rows: 
        [header] 40px [navigation] 50px [content];
      
      font-family: Helvetica;
    }
    h1 {
      font-size: 25px;
    }
    a {
      text-decoration: none;
      color: black;
    }
    a:hover {
      color: grey;
    }
    body > header {
      grid-row: header;
      font-size: 10px;
    }
    body > nav {
      grid-row: navigation;

      display: flex;
      justify-content: flex-start;
    }
    header a, header a:visited {
      text-decoration: none;
      color: black;
    }
    header a:hover {
      color: grey;
    }
    nav {
      margin-bottom: 20px;
    }
    nav > a {
      margin-right: 20px;
    }
    nav > a, nav > a:visited {
      text-decoration: none;
      color: black;
      font-size: 23px;
    }
    nav a.select {
      border-bottom: solid 3px orange;
      border-radius: 1px;
      font-weight: bold;
    }
    nav a:hover { 
      color: grey;
    }
    body > div#status {
      grid-row: status;
    }
    body > div#content {
      grid-row: content;
    }
    table.tree-view {
      padding: 5px;
      border: solid 1px black;
      border-radius: 4px;
      table-layout: fixed;
      margin-top: 20px;
      width: 800px;
    }
    table.tree-view td { 
      padding: 0px 10px;
      white-space: nowrap;
      overflow: hidden;
    }
    table.tree-view td.message {
      text-overflow: ellipsis;
      width: 400px;
    }
    table.tree-view {
      a { text-decoration: none; color: black; }
      a:visited { color: black; }
      a:hover { color: gray; text-decoration: underline; }
    }
    li > div.commit-item {
      margin-bottom: 10px; 
      padding: 5px;
      h1 {font-size: 25px; font-weight: normal;}

      a {
        text-decoration: underline;
      }
    }
    li { list-style-type: none; }
    content.blob {
      p.last-change {
        font-size: 15px;
      }
      h1 {
        font-size: 20px;
      }
    }
    div.commit {
      h1 { font-size: 20px }
        
    }
    '''
  ++  code 
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
