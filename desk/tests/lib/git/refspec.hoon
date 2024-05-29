/+  *test
/+  *git-refspec
|%
++  parse-fetch  (curr scan (parse-refspec &))
++  parse-push   (curr scan (parse-refspec |))
++  test-map-refname
  ;:  weld
    ::
    %+  expect-eq
      !>  `/refs/remotes/origin/master
      !>  %+  map-refname
            (parse-fetch "refs/heads/*:refs/remotes/origin/*")
          /refs/heads/master
  ==
--
