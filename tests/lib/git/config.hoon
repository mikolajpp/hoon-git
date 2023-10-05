/+  *test
/+  *git
|%
::
++  test-config-set-get
  =/  repo  *repository
  =.  repo  (put:~(config git repo) core/~ repositoryformatversion+u+0)
  =.  repo  (put:~(config git repo) core/~ bare+l+&)
  =.  repo  (put:~(config git repo) user/~ name+s+'Bilbo Baggins')
  =.  repo  (put:~(config git repo) user/~ email+s+'bilbo@shire.green')
  ::
  ;:  weld
  ::
  %+  expect-eq
  !>  u+0
  !>  (need (get:~(config git repo) core/~ %repositoryformatversion))
  ::
  %+  expect-eq
  !>  l+&
  !>  (need (get:~(config git repo) core/~ %bare))
  ::
  %+  expect-eq
  !>  s+'Bilbo Baggins'
  !>  (need (get:~(config git repo) user/~ %name))
  ::
  %+  expect-eq
  !>  s+'bilbo@shire.green'
  !>  (need (get:~(config git repo) user/~ %email))
  ==
++  test-default-config
  =/  repo  *repository
  =.  repo  (default:~(config git repo))
  ::
  ;:  weld
  ::
  %+  expect-eq
  !>  u+0
  !>  (need (get:~(config git repo) core/~ %repositoryformatversion))
  ::
  %+  expect-eq
  !>  l+&
  !>  (need (get:~(config git repo) core/~ %bare))
  ==
--
