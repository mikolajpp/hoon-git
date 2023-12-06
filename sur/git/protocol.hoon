|%
++  agent  'hoon-git/0.1'
+$  caps  (map @ta (unit @t))
+$  pkt-line  $@  $?(%flush %delim %end)
                  [%data =octs]
+$  command  $?(%ls-refs %fetch)
+$  request  $:  cmd=command
                 caps=(list @t)
                 args=(list @t)
             ==
--
