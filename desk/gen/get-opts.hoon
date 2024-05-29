::
:: +get-opts - convert an options vase to get opts function 
:: that accepts an options map and returns filled options structure
::
/-  *git-cmd
/+  *git-cmd-clone
=/  map=opts-map
  (malt `(list option)`~[[%quiet [%f ~]] [%origin [%t 'myorigin']]])
~&  map
|=  a=@
=<  ^-  opts  ((get-opts `type`-:!>(*opts) *opts) map)
|%
++  get-opts
  |*  [typ=type opts=*]
  :: ^-  $-(options-map -.vase)
  ::  Should generate Hoon AST and compile it
  ::
  =|  face=term
  =/  lops=(list (trel @tas hoon hoon))
    |-
    ~&  [-.typ typ]
    :: ~&  iter+-.typ
    ^-  (list [@tas hoon hoon])
    ?+  -.typ  ~
      %hold  
        $(typ ~(repo ut typ))
      %cell
        %+  weld  $(typ p.typ)
        ?:  ?=(%cell -.q.typ)
          $(typ q.typ)
        $(typ q.typ)
      ::  opt=val
      %face
        ?^  p.typ  !!
        $(face p.typ, typ q.typ)
      %hint
        =/  get=hoon
          (ream (crip "opt=(~(get by opts-map) {<face>})"))
        ~&  q.p.typ
        ?>  ?=(%know -.q.p.typ)
        =/  set=hoon
          %-  ream  %-  crip
          """
          ?>  ?=($>(%t opt-value) u.opt)
          (scan (trip p.u.opt) parse-{<p.q.p.typ>})
          """
        [face get set]~
      %atom
        =/  get=hoon
          (ream (crip "opt=(~(get by opts-map) {<face>})"))
        =/  set=hoon
          ?:  ?=(%f p.typ)
            ^~  (ream '&')
          ?:  ?=(%ud p.typ)
            %-  ream
            ^~
            ::  XX where is vim highlight?
            '''
            ?>  ?=($>(%ud opt-value) u.opt)
            p.u.opt
            '''
          ?:  =(%t (cut 3 [0 1] p.typ))
            ^~  %-  ream  %-  crip
            """
            ?>  ?=($>(%t opt-value) u.opt)
            p.u.opt
            """
          ~_  "Unsupported option atom type {<p.typ>}"  !!
        [face get set]~
    ==
  ::  XX a rune to get the type of the bunt 
  ::  of the mold: !$  spec  -->  -:!>(*spec)
  ::  
  ::  Results in compiled nock
  ::
  =+  subject=.
  =;  [=type =nock]
    =/  gate=$-(opts-map _opts)
      !<  $-(opts-map _opts)  [type .*(subject nock)]
    :: *$-(opts-map _opts)
    gate
  ::   :: [type .*(. nock)]
  ::  XX Types are not in scope !
  %+  ~(mint ut -:!>(subject))  %noun
  ^-  hoon  
  ::  XX is there a way to mix hoon code and AST?
  ::  |=  =opts-map
  ::  XX Idea: another version of ream, +seam, to specify incomplete 
  ::  AST nodes, so that we could do 
  ::  (seam '|=  =opts-map') and have it generate
  ::  %brts  [%bcts %opts-map %like ~[%opts-map] ~]
  ::  And be used like
  ::  :-  (seam '|=  =opts-map')
  ::  :-  (seam '^-  opts')
  ::  ...
  ::  In Hoon metaprogramming
  ::
  ::  
  :: !,  *hoon
  :: |=  =opts-map
  :: ^+  opts
  :: *_opts
  =;  =hoon
    ~&  hoon 
    hoon
  :: |=  =opts-map
  :+  %brts  [%bcts %opts-map %like ~[%opts-map] ~]
  :: ::  =|  =opts
  :+  %tsbr  [%bcts %opts %bccb wing/~[%opts]]
  ^-  hoon
  |-
  ?~  lops  [%wing ~[%opts]]
  ::  XX !, should admin one-argument form 
  ::  with *hoon as a default
  :: :^  %wthp  [%wing ~[%lops]]  [%wing ~[%opts]]

  ::  =+  opt=(~(get by opts-map) %option)
  :: :+  %tsls  q.i.lops
  :: ::  =?  option.opts  ?=(^ opt)
  :: ::    set
  :: :-  %tswt  :^  [%wing ~[p.i.lops]]  !,(*hoon ?=(^ opt))
  ::   r.i.lops
  $(lops t.lops)
--
