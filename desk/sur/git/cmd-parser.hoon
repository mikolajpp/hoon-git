/+  *git
|%
+$  opt-kind  ?(%f %t %ud)
+$  opt-value  $%  [%f ~]
                   [%t p=@t]
                   [%ud p=@ud]
               ==
+$  opt-value-list  $%  [%t p=(list @t)]
                        [%ud p=(list @ud)]
                    ==
+$  opt-name  @ta
+$  option  [opt-name opt-value]
::  XX support repeated option. 
::  This should result in a list of opt-values under 
::  the given key
+$  opts-map  (map opt-name opt-value)
--
