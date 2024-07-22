::
::  git ls
::
::  Show available repositories
::
/+  *git-cmd
|%
+$  args  %~
++  parse
  (parse-cmd-solo %ls (easy ~))
--
