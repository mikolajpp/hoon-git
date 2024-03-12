::
::  Unbundle a git repository
::
/+  zlib, stream
/+  libgit=git
|=  file=path
=/  repo  *repository:libgit
=/  bundle-base64=byts  (need (de:base64:mimes:html (snag 0 .^(wain %cx file))))
=+  sea=[0 bundle-base64]
=^  hed  sea  (read-header:bud:libgit sea)
:: =+  pos1=70.246
:: =+  pos2=67.219
=/  bundle=bundle:libgit  -:(read:bud:libgit [0 bundle-base64])
~&  header.bundle
~&  header.pack.bundle
=.  repo  (unbundle:git:libgit bundle)
repo
:: -:(read-object-type-size:pak:libgit [pos2 bundle-base64])
:: =^  rob  sea  (read-object:pak:libgit [pos1 bundle-base64])
:: `@ux`(need -:(read-bytes:stream 10 sea))
:: =^  [typ=raw-object-type:libgit size=@ud]  sea  (read-object-type-size:pak:libgit [pos1 bundle-base64])
:: ~&  obj+[typ size]
