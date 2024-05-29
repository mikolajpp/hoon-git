/+  *test
/+  *git-refs
|%
++  parse  (curr scan parse-refname)
++  test-has-pattern
  ;:  weld
    %+  expect-eq
      !>  (has-pattern (parse "a/b/c"))
      !>  |
    %+  expect-eq
      !>  (has-pattern (parse "a/b/*"))
      !>  &
    %+  expect-eq
      !>  (has-pattern (parse "a/b/c*"))
      !>  &
    %+  expect-eq
      !>  (has-pattern (parse "a/b*/c"))
      !>  &
  ==
++  test-pattern-to-prefix
  ;:  weld
    ::
    %+  expect-eq
    !>  `refname`/a/b/c
    !>  (pattern-to-prefix (parse "a/b/c"))
    ::
    %+  expect-eq
    !>  `refname`/a/b
    !>  (pattern-to-prefix (parse "a/b/*"))
    ::
    %+  expect-eq
    !>  `refname`/a/b/cat
    !>  (pattern-to-prefix (parse "a/b/cat*"))
  ==
--
