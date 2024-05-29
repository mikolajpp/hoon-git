::
::  git cat - Display file content
::
::  XX cat should handle full git path syntax
::
/+  *git-cmd
|%
+$  args  =path
::
++  parse
  (parse-cmd-solo %cat ;~(pfix gap stap))
--
