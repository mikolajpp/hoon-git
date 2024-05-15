::  XX This does not look nice.
::  Should we seperate out the molds in /lib?
/+  *git
|%
+$  opt-kind  ?(%f %t %ud)
+$  opt-value  $%  [%f ~]
                   [%t @t]
                   [%ud @ud]
               ==
+$  opt-name  @tas
+$  option  [opt-name opt-value]
+$  command  $+  git-command
  $%  [%ls %~]
      [%cd name=@ta]
      [%lock %~]
      ::
      [%cat-file cat-file-args]
      [%clone clone-args] 
      [%diff diff-args]
      [%fetch fetch-args]
      [%log log-args]
      [%merge merge-args]
      [%pull pull-args]
  ==
+$  cmd-and-opts  [command (list option)]
+$  cat-file-args
  $:  obj=ref
  ==
+$  clone-args
  $:  url=@t
      desk=(unit @tas)
  ==
+$  diff-args  ~
+$  fetch-args  ~
+$  log-args  ~
+$  merge-args  ~
+$  pull-args  ~
--
