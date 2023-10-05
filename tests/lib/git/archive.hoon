/+  *test, *git, zlib
|%
++  test-read-pack
  =/  forest-pack-raw  %-  need  %-  de:base64:mimes:html
  'UEFDSwAAAAIAAAAJmQ54nJ2NWwrCMBAA/3OK/AuyaXbzABEpXiSPTRuwjbRRr2+9gp8DM0zfmGX2gyuDg4DOI1G2RntTtENEUkNkzhEoEohn2HjtEhUqUwoC5lRsjKAVxJItQtDJJUQPbB1YEV59bpsc6yM2OYZpqusuL/GHt32uG5+n479epTKezGAdkTyBAxCpLUvtnf+Kxb3uqb2PeOWP7Ie1iy8jiUXQlwx4nJ2MQQrDIBBF955i9oXiKIkKpQRv4thJIjQRdNLz116h8DYP3v/SmAGdIatnj0jMmMmGZDzSxMbn1ZjsbLAT+aDSJXttEMubKsS0beXs8KCfLn0vje/b+DufgHOYZuOcs3DTXmuV63EUEf5rrCKPGNLg9eFTrsYwXHaGtTbuor6gij2SpQR4nDM0MDAzMVEIcnV08XXVy01hyEtd6fpmn9/W9XsnacwQfNLac10jx8QACBRKilJTixmk2c5G7JmeIbfmWVD0F5MrWRM1Yk8CAGm/G3SrBnicMzQwMDMxUUjLLNIrqShh6Jywf1MSg/NH7RuVU7+WTtu+gv2MmiFESW5iQU4qWJHQolVbmG24J6RtnfaP70udd8or8xaoovzEbLASpl1p9op++hPW/y7u3u/u18BksuswAKLAKdmlAnicMzQwMDMxUQhydXTxddXLTWHIS13p+maf39b1eydpzBB80tpzXSMHAOOuDpq6Anicc8xTSEwpS80rKS1KVcgEchTS8otSi0sUdHUVnDJzkvIVnBLT0zPzirkAOD0OMLUCeJzzVEjMVUhUSMssUigpSk1V0IUzixUSi1IVShJzcrgA3ywMCrwCeJzzVEjMVUhUyE0syElVKClKTVXQVUhLzEuuVCjOz01VSM7Jz0tVKK4sKi2w5wIARkoO5z94nPNUSMxVSFRIykxXyE/M5gIAIyEEcIp/UkItnupD/AjNery1KvqGBaJC'
  =/  forest-pack=pack  -:(read:pak [0 forest-pack-raw])
  ;:  weld
  ::
  %+  expect-eq
  !>  version.header.forest-pack
  !>  2
  ::
  %+  expect-eq
  !>  count.header.forest-pack
  !>  9
  ==
++  test-read-bundle
  =/  forest-bundle-raw  %-  need  %-  de:base64:mimes:html
  'IyB2MiBnaXQgYnVuZGxlCjIwNzU1NDA3N2M1OGJmMzUzNmIxNjNkNTIwZjFkOTE1ZTg4N2MyZGMgcmVmcy9oZWFkcy9tYXN0ZXIKMGE2MTAwNWM4NTBiMjhmZWJlYmZiZjlhNGQ2MzY3N2Q3YmE1MzZkZSByZWZzL3RhZ3MvZmlyc3QtdHJlZXMKClBBQ0sAAAACAAAADZ8OeJydjVtqwzAQAP91iv0vlJU2ehhKKblBjrArrWxBbBVZvn/TK+RzYIaZQxUEkRI5SbY6pErBRs2OI5IUzJiVCi3M1fzy0GMCcrCIPieP4lJVUalSF76VQCHGEoU9haKGr7n1Aff2lA53Xtd2nPAl//hzbm3o5/r6H99gw+IXb5118IEJ0eS+721OfSs2j0vP2foBLP2aUNuA+XJP8wfa3EmKmQ54nJ2NWwrCMBAA/3OK/AuyaXbzABEpXiSPTRuwjbRRr2+9gp8DM0zfmGX2gyuDg4DOI1G2RntTtENEUkNkzhEoEohn2HjtEhUqUwoC5lRsjKAVxJItQtDJJUQPbB1YEV59bpsc6yM2OYZpqusuL/GHt32uG5+n479epTKezGAdkTyBAxCpLUvtnf+Kxb3uqb2PeOWP7Ie1iy8jiUXQlwx4nJ2MQQrDIBBF955i9oXiKIkKpQRv4thJIjQRdNLz116h8DYP3v/SmAGdIatnj0jMmMmGZDzSxMbn1ZjsbLAT+aDSJXttEMubKsS0beXs8KCfLn0vje/b+DufgHOYZuOcs3DTXmuV63EUEf5rrCKPGNLg9eFTrsYwXHaGtTbuor6gij2SpQR4nDM0MDAzMVEIcnV08XXVy01hyEtd6fpmn9/W9XsnacwQfNLac10jx8QACBRKilJTixn07fbcOFMk3rmR+8GKW46tZy+sc9MDAHcUHFOrBnicMzQwMDMxUUjLLNIrqShhmOS8cMefDLOKqk0r6kSV5/b/fPNB2xCiJDexICcVrEho0aotzDbcE9K2TvvH96XOO+WVeQtUUX5iNlgJ0640e0U//Qnrfxd373f3a2Ay2XUYAMEJKkalBHicMzQwMDMxUQhydXTxddXLTWHIS13p+maf39b1eydpzBB80tpzXSPHxAAIFEqKUlOLGaTZzkbsmZ4ht+ZZUPQXkytZEzViTwIAab8bdKsGeJwzNDAwMzFRSMss0iupKGHonLB/UxKD80ftG5VTv5ZO276C/YyaIURJbmJBTipYkdCiVVuYbbgnpG2d9o/vS513yivzFqii/MRssBKmXWn2in76E9b/Lu7e7+7XwGSy6zAAosAp2aUCeJwzNDAwMzFRCHJ1dPF11ctNYchLXen6Zp/f1vV7J2nMEHzS2nNdIwcA464OmroCeJxzzFNITClLzSspLUpVyARyFNLyi1KLSxR0dRWcMnOS8hWcEtPTM/OKuQA4PQ4wvQN4nPNUSMxVSFRIyyxSKClKTVXQhTOLFRKLUhVKEnNy9BScSksUMvLLwTyIcEZqpT0XAGhMFC+8Anic81RIzFVIVMhNLMhJVSgpSk1V0FVIS8xLrlQozs9NVUjOyc9LVSiuLCotsOcCAEZKDuc/eJzzVEjMVUhUSMpMV8hPzOYCACMhBHC1Anic81RIzFVIVEjLLFIoKUpNVdCFM4sVEotSFUoSc3K4AN8sDApdzFMhVSc7KjerMHRQEoeep94i+g=='
  =/  forest-bundle=bundle  -:(read:bud [0 forest-bundle-raw])
  ~&  forest-bundle
  ::
  ;:  weld
  %+  expect-eq
  !>(0xff)
  !>(0xff)
  ==
--
