/+  *test, *git, zlib
|%
++  test-load-bundle
  =/  forest-bundle  'IyB2MiBnaXQgYnVuZGxlCjBhNjEwMDVjODUwYjI4ZmViZWJmYmY5YTRkNjM2NzdkN2JhNTM2ZGUgcmVmcy9oZWFkcy9tYXN0ZXIKClBBQ0sAAAACAAAACZkOeJydjVsKwjAQAP9zivwLsml28wARKV4kj00bsI20Ua9vvYKfAzNM35hl9oMrg4OAziNRtkZ7U7RDRFJDZM4RKBKIZ9h47RIVKlMKAuZUbIygFcSSLULQySVED2wdWBFefW6bHOsjNjmGaarrLi/xh7d9rhufp+O/XqUynsxgHZE8gQMQqS1L7Z3/isW97qm9j3jlj+yHtYsvI4lF0JcMeJydjEEKwyAQRfeeYvaF4iiJCqUEb+LYSSI0EXTS89deofA2D97/0pgBnSGrZ49IzJjJhmQ80sTG59WY7GywE/mg0iV7bRDLmyrEtG3l7PCgny59L43v2/g7n4BzmGbjnLNw015rletxFBH+a6wijxjS4PXhU67GMFx2hrU27qK+oIo9kqUEeJwzNDAwMzFRCHJ1dPF11ctNYchLXen6Zp/f1vV7J2nMEHzS2nNdI8fEAAgUSopSU4sZpNnORuyZniG35llQ9BeTK1kTNWJPAgBpvxt0qwZ4nDM0MDAzMVFIyyzSK6koYeicsH9TEoPzR+0blVO/lk7bvoL9jJohREluYkFOKliR0KJVW5htuCekbZ32j+9LnXfKK/MWqKL8xGywEqZdafaKfvoT1v8u7t7v7tfAZLLrMACiwCnZpQJ4nDM0MDAzMVEIcnV08XXVy01hyEtd6fpmn9/W9XsnacwQfNLac10jBwDjrg6augJ4nHPMU0hMKUvNKyktSlXIBHIU0vKLUotLFHR1FZwyc5LyFZwS09Mz84q5ADg9DjC1Anic81RIzFVIVEjLLFIoKUpNVdCFM4sVEotSFUoSc3K4AN8sDAq8Anic81RIzFVIVMhNLMhJVSgpSk1V0FVIS8xLrlQozs9NVUjOyc9LVSiuLCotsOcCAEZKDuc/eJzzVEjMVUhUSMpMV8hPzOYCACMhBHCKf1JCLZ7qQ/wIzXq8tSr6hgWiQg=='
  =/  forest-pack  (need (de:base64:mimes:html forest-bundle))
  ::
  ;:  weld
  %+  expect-eq
  ~&  (load:pak [0 forest-pack])
  !>(0xff)
  !>(0xff)
  ==
--
