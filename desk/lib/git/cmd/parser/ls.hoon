::
::  git ls
::
::  Show available repositories
::  XX It seems there is a serious problem with clay:
::  when both /lib/git/cmd/parser/hoon and /bi/git/cmd/parser/...
::  exists, the import does not work
/+  git-cmd-parser
|%
+$  args  %~
++  parse
  (cmd-solo:parse:git-cmd-parser %ls (easy ~))
--
