/+  *test, *git, zlib
|%
++  test-load-pack
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
++  test-load-bundle
  =/  forest-bundle-raw  %-  need  %-  de:base64:mimes:html
  'IyB2MiBnaXQgYnVuZGxlCjBhNjEwMDVjODUwYjI4ZmViZWJmYmY5YTRkNjM2NzdkN2JhNTM2ZGUgcmVmcy9oZWFkcy9tYXN0ZXIKClBBQ0sAAAACAAAACZkOeJydjVsKwjAQAP9zivwLsml28wARKV4kj00bsI20Ua9vvYKfAzNM35hl9oMrg4OAziNRtkZ7U7RDRFJDZM4RKBKIZ9h47RIVKlMKAuZUbIygFcSSLULQySVED2wdWBFefW6bHOsjNjmGaarrLi/xh7d9rhufp+O/XqUynsxgHZE8gQMQqS1L7Z3/isW97qm9j3jlj+yHtYsvI4lF0JcMeJydjEEKwyAQRfeeYvaF4iiJCqUEb+LYSSI0EXTS89deofA2D97/0pgBnSGrZ49IzJjJhmQ80sTG59WY7GywE/mg0iV7bRDLmyrEtG3l7PCgny59L43v2/g7n4BzmGbjnLNw015rletxFBH+a6wijxjS4PXhU67GMFx2hrU27qK+oIo9kqUEeJwzNDAwMzFRCHJ1dPF11ctNYchLXen6Zp/f1vV7J2nMEHzS2nNdI8fEAAgUSopSU4sZpNnORuyZniG35llQ9BeTK1kTNWJPAgBpvxt0qwZ4nDM0MDAzMVFIyyzSK6koYeicsH9TEoPzR+0blVO/lk7bvoL9jJohREluYkFOKliR0KJVW5htuCekbZ32j+9LnXfKK/MWqKL8xGywEqZdafaKfvoT1v8u7t7v7tfAZLLrMACiwCnZpQJ4nDM0MDAzMVEIcnV08XXVy01hyEtd6fpmn9/W9XsnacwQfNLac10jBwDjrg6augJ4nHPMU0hMKUvNKyktSlXIBHIU0vKLUotLFHR1FZwyc5LyFZwS09Mz84q5ADg9DjC1Anic81RIzFVIVEjLLFIoKUpNVdCFM4sVEotSFUoSc3K4AN8sDAq8Anic81RIzFVIVMhNLMhJVSgpSk1V0FVIS8xLrlQozs9NVUjOyc9LVSiuLCotsOcCAEZKDuc/eJzzVEjMVUhUSMpMV8hPzOYCACMhBHCKf1JCLZ7qQ/wIzXq8tSr6hgWiQg=='
  =/  forest-bundle=bundle  -:(read:bud [0 forest-bundle-raw])
  ::
  ;:  weld
  %+  expect-eq
  !>(0xff)
  !>(0xff)
  ==
--
