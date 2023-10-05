/+  *test, *git, zlib
|%
++  test-unbundle
  =/  forest-bundle-raw  %-  need  %-  de:base64:mimes:html
  'IyB2MiBnaXQgYnVuZGxlCjIwNzU1NDA3N2M1OGJmMzUzNmIxNjNkNTIwZjFkOTE1ZTg4N2MyZGMgcmVmcy9oZWFkcy9tYXN0ZXIKMGE2MTAwNWM4NTBiMjhmZWJlYmZiZjlhNGQ2MzY3N2Q3YmE1MzZkZSByZWZzL3RhZ3MvZmlyc3QtdHJlZXMKClBBQ0sAAAACAAAADZ8OeJydjVtqwzAQAP91iv0vlJU2ehhKKblBjrArrWxBbBVZvn/TK+RzYIaZQxUEkRI5SbY6pErBRs2OI5IUzJiVCi3M1fzy0GMCcrCIPieP4lJVUalSF76VQCHGEoU9haKGr7n1Aff2lA53Xtd2nPAl//hzbm3o5/r6H99gw+IXb5118IEJ0eS+721OfSs2j0vP2foBLP2aUNuA+XJP8wfa3EmKmQ54nJ2NWwrCMBAA/3OK/AuyaXbzABEpXiSPTRuwjbRRr2+9gp8DM0zfmGX2gyuDg4DOI1G2RntTtENEUkNkzhEoEohn2HjtEhUqUwoC5lRsjKAVxJItQtDJJUQPbB1YEV59bpsc6yM2OYZpqusuL/GHt32uG5+n479epTKezGAdkTyBAxCpLUvtnf+Kxb3uqb2PeOWP7Ie1iy8jiUXQlwx4nJ2MQQrDIBBF955i9oXiKIkKpQRv4thJIjQRdNLz116h8DYP3v/SmAGdIatnj0jMmMmGZDzSxMbn1ZjsbLAT+aDSJXttEMubKsS0beXs8KCfLn0vje/b+DufgHOYZuOcs3DTXmuV63EUEf5rrCKPGNLg9eFTrsYwXHaGtTbuor6gij2SpQR4nDM0MDAzMVEIcnV08XXVy01hyEtd6fpmn9/W9XsnacwQfNLac10jx8QACBRKilJTixn07fbcOFMk3rmR+8GKW46tZy+sc9MDAHcUHFOrBnicMzQwMDMxUUjLLNIrqShhmOS8cMefDLOKqk0r6kSV5/b/fPNB2xCiJDexICcVrEho0aotzDbcE9K2TvvH96XOO+WVeQtUUX5iNlgJ0640e0U//Qnrfxd373f3a2Ay2XUYAMEJKkalBHicMzQwMDMxUQhydXTxddXLTWHIS13p+maf39b1eydpzBB80tpzXSPHxAAIFEqKUlOLGaTZzkbsmZ4ht+ZZUPQXkytZEzViTwIAab8bdKsGeJwzNDAwMzFRSMss0iupKGHonLB/UxKD80ftG5VTv5ZO276C/YyaIURJbmJBTipYkdCiVVuYbbgnpG2d9o/vS513yivzFqii/MRssBKmXWn2in76E9b/Lu7e7+7XwGSy6zAAosAp2aUCeJwzNDAwMzFRCHJ1dPF11ctNYchLXen6Zp/f1vV7J2nMEHzS2nNdIwcA464OmroCeJxzzFNITClLzSspLUpVyARyFNLyi1KLSxR0dRWcMnOS8hWcEtPTM/OKuQA4PQ4wvQN4nPNUSMxVSFRIyyxSKClKTVXQhTOLFRKLUhVKEnNy9BScSksUMvLLwTyIcEZqpT0XAGhMFC+8Anic81RIzFVIVMhNLMhJVSgpSk1V0FVIS8xLrlQozs9NVUjOyc9LVSiuLCotsOcCAEZKDuc/eJzzVEjMVUhUSMpMV8hPzOYCACMhBHC1Anic81RIzFVIVEjLLFIoKUpNVdCFM4sVEotSFUoSc3K4AN8sDApdzFMhVSc7KjerMHRQEoeep94i+g=='
  =/  forest-bundle=bundle  -:(read:bud [0 forest-bundle-raw])
  =/  repo  (default:~(config git *repository))
  =.  repo  (~(unbundle git repo) forest-bundle)
  ;:  weld
  ::
  %+  expect-eq
  !>  13
  !>  ~(wyt git repo)
  ::
  %+  expect-eq
  !>  ~[~.0a61005c850b28febebfbf9a4d63677d7ba536de]
  !>  (~(find-key git repo) ~.0a610)
  ::
  %+  expect-eq
  !>  ~[~.41416ff404dcf7bb0310bfd740a3c8c4490e7807]
  !>  (~(find-key git repo) ~.4141)
  ::
  %+  expect-eq
  !>  ~[~.6e65a945ecbe4eb5afbd92289811e4858cd7286c]
  !>  (~(find-key git repo) ~.6e65)
  ::
  ~&  ~(tap by refs.repo)
  %+  expect-eq
  !>  :~
      [/refs/heads/master ~.207554077c58bf3536b163d520f1d915e887c2dc]
      [/refs/tags/first-trees ~.0a61005c850b28febebfbf9a4d63677d7ba536de]
      ==
  !>  ~(tap by refs.repo)
  ==
--
