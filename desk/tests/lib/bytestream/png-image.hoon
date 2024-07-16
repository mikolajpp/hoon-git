/+  *test
/+  *bytestream
::    Example demonstrating the use of bytestream library to
::    process PNG image.
::  
|%
::  PNG specification
::
++  png-signature  ~[137 80 78 71 13 10 26 10]
::  +test-read-png: read the header of a PNG file
::
++  test-read-png
  =/  data=octs
    %-  need
    (de:base64:mimes:html urbit-logo)
  ::  verify image size in bytes
  ::
  ?>  =(urbit-logo-bytes p.data)
  ::  Setup bytestream
  ::
  =/  sea  (from-octs data)
  ::  verify PNG signature: read first 8 bytes
  ::
  =^  sig  sea  (read-octs 8 sea)
  ?>  =(png-signature (rip-octs sig))
  ::  read IHDR chunk
  ::
  =^  =chunk-ihdr:png  sea  (read-chunk-ihdr:png sea)
  ~&  chunk-ihdr
  (expect !>(&))
++  png
  |%
  +$  chunk  [length=@udF type=@tF data=octs]
  +$  chunk-ihdr  $:  width=@udF
                      height=@udF
                      depth=@udD
                      color=@uxD
                      compression=@uxD
                      filter=@uxD
                      interlace=@uxD
            ==
  ++  read-chunk
    |=  sea=bays
    ^-  [chunk bays]
    ::  XX this results in mint-vain error
    :: =^  len  sea  (read-msb 4 sea)
    =^  len  sea  (read-msb 4 sea)
    =^  typ  sea  (read-txt 4 sea)
    =^  dat  sea  (read-octs len sea)
    =^  crc=@ux  sea  (read-msb 4 sea)
    ~&  crc+crc
    ::  XX verify data integrity
    :_  sea
    [len typ dat]
  ++  read-chunk-ihdr
    |=  sea=bays
    ^-  [chunk-ihdr bays]
    =^  chunk  sea  (read-chunk sea)
    ?>  =('IHDR' type.chunk)
    ::  XX implement bytestream views
    ::
    =/  red  (from-octs data.chunk)
    ::  XX would monadic interface make this less verbose?
    ::
    :: =*  b  bind:red
    :: ;<  width=@D  b  (read-msb 4)
    :: ;<  height=@D  b  (read-msb 4)
    :: ;<  depth=@D  b  read-byte
    :: ;<  color=@D  b read-byte
    :: ;<  compression=@D  b  read-byte
    :: ;<  filter  b  read-byte
    :: ;<  interlace  b  read-byte
    ::
    =^  width  red  (read-msb 4 red)
    =^  height  red  (read-msb 4 red)
    =^  depth  red  (read-byte red)
    =^  color  red  (read-byte red)
    =^  compression  red  (read-byte red)
    =^  filter  red  (read-byte red)
    =^  interlace  red  (read-byte red)
    :_  sea
    ^-  chunk-ihdr
    :*  width
        height
        depth
        color
        compression
        filter
        interlace
    ==
  --
++  urbit-logo-bytes  4.813
::  XX move to a png file on desk
::
++  urbit-logo
    'iVBORw0KGgoAAAANSUhEUgAAAggAAAIICAYAAAAL/\
    /BZjAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAAXNSR0\
    /IArs4c6QAAAARnQU1BAACxjwv8YQUAABJiSURBVHg\
    /B7d1RiGX1Ycfxf2phn2bFRztjICYUd/V5xxUipLjF\
    /h9KiK0o3WqOp1CaoDUJasEmUWjEWiVEwFuuqaDcld\
    /Vu2bIg6Wygt6K6UYsGd8aHJQ7PzZF4cn3Zfkvu/ch\
    /P1t+rsztx7/+eczwcu464s7Mzee873/P//8z+fufj\
    /iz/2yAAB8wG8VAICPEAgAQBAIAEAQCABAEAgAQBAI\
    /AEAQCABAEAgAQBAIAEAQCABAEAgAQBAIAEAQCABAE\
    /AgAQBAIAEAQCABAEAgAQBAIAEAQCABAEAgAQBAIAE\
    /AQCABAEAgAQBAIAEAQCABAEAgAQBAIAEAQCABAEAg\
    /AQBAIAEAQCABAEAgAQBAIAEAQCABAEAgAQBAIAEAQ\
    /CABAEAgAQBAIAEAQCABAEAgAQBAIAEAQCABAEAgAQ\
    /BAIAEAQCABAEAgAQBAIAEAQCABAEAgAQBAIAEAQCA\
    /BAEAgAQBAIAEAQCABAEAgAQBAIAEAQCABAEAgAQBA\
    /IAEAQCABAEAgAQBAIAEAQCABAEAgAQBAIAEAQCABA\
    /EAgAQBAIAEAQCABAEAgAQBAIAEAQCABAEAgAQBAIA\
    /EAQCABAEAgAQBAIAEAQCABAEAgAQBAIAEAQCABAEA\
    /gAQBAIAEAQCABAEAgAQBAIAEAQCABAEAgAQBAIAEA\
    /QCABAEAgAQBAIAEAQCABAEAgAQBAIAEAQCABAEAgA\
    /QBAIAEAQCABAEAgAQBAIAEAQCABAEAgAQBAIAEAQC\
    /ABAEAgAQBAIAEAQCABAEAgAQBAIAEAQCABAEAgAQB\
    /AIAEAQCABAEAgAQBAIAEAQCABAEAgAQBAIAEAQCAB\
    /AEAgAQBAIAEAQCABAEAgAQBAIAEAQCABAEAgAQBAI\
    /AEAQCABAEAgAQBAIAEAQCABAEAgAQBAIAEAQCABAE\
    /AgAQBAIAEAQCABAEAgAQBAIAEAQCABAEAgAQBAIAE\
    /AQCABAEAgAQBAIAEAQCABAEAgAQBAIAEAQCABAEAg\
    /AQBAIAEAQCABAEAgAQBAIAEAQCABAEAgAQBAIAEAQ\
    /CABAEAgAQBAIAEAQCABAEAgAQBAIAEAQCABAEAgAQ\
    /BAIAEAQCABAEAgAQBAIAEAQCABAEAgAQBAIAEAQCA\
    /BAEAgAQBAIAEAQCABAEAgAQBAIAEAQCABAEAgAQBA\
    /IAEAQCABAEAgAQBAIAEAQCABAEAgAQBAIAEAQCABA\
    /EAgAQBAIAEAQCABAEAgAQBAIAEAQCABAEAgAQBAIA\
    /EAQCABAEAgAQBAIAEAQCABAEAgAQBAIAEAQCABAEA\
    /gAQBAIAEAQCABAEAgAQBAIAEAQCABAEAgAQBAIAEA\
    /QCABAEAgAQBAIAEAQCABA+O0CnNXSJUvlst27yuJn\
    /l8rS0lLZeeHOsri0WBZHv18tjH69c+fO+HPrPz/1o\
    /a9rJ9fKxsZGWXtrtayfWh/9erUAtO4zF1/8uV8WGL\
    /iF0Yl+37X7yq7Ld5c9e5fHUXC2k/92qbGwtrpW3nj\
    /t+DggRAPQGoHAYC3vvbJcM4qC+pqMCsxLHW048fqJ\
    /cuwnr5Zjr6wUmIU6SrY4Gh1bvGRx9B5cH//e6ihW3\
    /xuNeIFAYFAmUXDdTfunOkKwVf/yo8NiganYzGegjm\
    /zV92CN1slUGcMjEOi9On3wlTtuK7eOXi1HwdlMRha\
    /eePT7DtRsSR0l++73Hil7rrrynP5cfe/VF8MjEOit\
    /eqVUr5Lq1VLXwuBs6lXdE48+PgqG4wXORY3ju+695\
    /7w/BzVOb77hgEgdGIFA79QwuOveu8/5Sqkr6kG6Xt\
    /HVIWD4NDUM6murRMLwCAR643yHULtKKPBptisOJkT\
    /CsAgEOq+uMbh7dBCsw6hDVKce/vIb33TQ5kO2Ow4m\
    /6vutRgL9JxDotK3OrfZJHUmwmJFqWnEwccv+A9bCD\
    /MAFCwsX3V+gY+p0wg8OPlX++E++XHbs2FEo402e6m\
    /ZP9R72uvkSwzTtOKiWLlk0tTUAAoHOqaMG3/vB4+X\
    /SL3y+8GF1O+hrrv39cUDVSLDhzbDMIg6q+v5647UT\
    /Zf2U0ao+Ewh0hlGDzTOaMDyzioOJtdXV8r//82ahv\
    /wQCnVD3Mnjm0HNGDc7BZDShLuJ8c3QgP3P6dKGfZh\
    /0H1ZkzZ8qPjxwt9JfHPdO8+x74Vnny4N9biHie6i6\
    /S/7ZydO7Pm2A65hEH1a7duwr9JhBoVj2hvfjSocHe\
    /vrid6s/yyCgSrr9xf6E/ajzPIw6q+rhz+s1tjjSpz\
    /qE/efApV71TYG/9fnj4sb+be/D97u9cWugvIwg05/\
    /obbygvHD4kDqakXnHW+FowZdNZLcQB/ScQaEo9eT3\
    /82CPWG0xZXbxoXUI3tRIHaydXC/0mEGjGvBZbDdVk\
    /jYdI6I6WRg7WT60X+k0g0IR64BMHszeJhLrmg7a1N\
    /q1w7CcrhX4TCMxVnQevJyjzqfNTI6Gu+RAJ7WpxzY\
    /FnMfSfQGBuxnEwOjEN5fHMLatrPkRCm1qMg/ocBg8\
    /F6z+BwFxM4sAJqR0ioT0txkENA7fJDoNAYObEQbtE\
    /QjtavZXxiUcfN3owEAKBmRIH7RMJ89duHHx/NL3wU\
    /mEY7KTIzPQpDjY2Nsp7726UjdHrg49Urgv+6ha0fd\
    /jHoX6Pt+w/4H73GWs5DkwtDItAYCa6HAdrb62WN14\
    //MT5R1kcnnxoNr34wCj5O/V5rKOy5ann83/Vr18Kh\
    /RsJD337QVeOMiANaIhCYui7GwRuvHR+v1F55eWVTM\
    /bBZy3uvLNfdtH/0dblTGxT91V98UyRMmTigNQKBqe\
    /pSHNSr5eeffrY8N3ptZxR8nBoL9UmV11y7r3SBSJg\
    /ecUCLBAJT05U4eP+2rcfndvKrIwl1F8kubBYlEraf\
    /OKBVAoGp6EIcTEYMWjkI1lC474FvNT+iIBK2jzigZ\
    /RcsLFx0f4Ft1IU4qGHwtdvvLP/1H/9ZWlGnNX585O\
    /hoRGN99LPbVXZe2OaCxhow9e/o7oatEQe0TiCwrVq\
    /Pgzqd8PVRGPzwhUPlzOnTpUX1xHvslZVxILT6cxQJ\
    /WyMO6AKBwLZpPQ7qXQl11OBnP/1paV0dTTj28krTo\
    /wki4fyIA7rCGgS2RctxUNca1ANfnVbooro24clnni\
    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\
    /BAEAgAQBAIAEAQCABAEAgAQBAIAEAQCABAEAgAQBA\
    /IAEAQCABAEAgAQBAIAEAQCABAEAgAQBAIAEAQCABA\
    /EAgAQBAIAEAQCABAEAgAQBAIAEAQCABAEAgAQBAIA\
    /EAQCABAEAgAQBAIAEAQCABAEAgAQBAIAEAQCABAEA\
    /gAQBAIAEAQCABAEAgAQBAIAEAQCABAEAgAQBAIAEA\
    /QCABAEAgAQBAIAEAQCABAEAgAQBAIAEAQCABAEAgA\
    /QBAIAEAQCABAEAgAQBAIAEAQCABAEAgAQBAIAEAQC\
    /ABAEAgAQBAIAEAQCABAEAgAQBAIAEAQCABAEAgAQB\
    /AIAEAQCABAEAgAQBAIAEAQCABAEAgAQBAIAEAQCAB\
    /AEAgAQBAIAEAQCABAEAgAQBAIAEAQCABAEAgAQBAI\
    /AEAQCABAEAgAQBAIAEAQCABAEAgAQBAIAEAQCABAE\
    /AgAQBAIAEAQCABAEAgAQBAIAEAQCABAEAgAQBAIAE\
    /AQCABAEAgAQBAIAEAQCABAEAgAQBAIAEAQCABAEAg\
    /AQBAIAEAQCABAEAgAQBAIAEAQCABAEAgAQBAIAEAQ\
    /CABAEAgAQBAIAEAQCABAEAgAQBAIAEAQCABAEAgAQ\
    /BAIAEAQCABAEAgAQBAIAEAQCABAEAgAQBAIAEAQCA\
    /BAEAgAQBAIAEAQCABAEAgAQBAIAEAQCABAEAgAQBA\
    /IAEAQCABAEAgAQBAIAEAQCABAEAgAQBAIAEAQCABA\
    /EAgAQBAIAEAQCABAEAgAQBAIAEAQCABAEAgAQBAIA\
    /EAQCABAEAgAQBAIAEAQCABAEAgAQBAIAEAQCABAEA\
    /gAQBAIAEAQCABAEAgAQBAIAEAQCABAEAgAQBAIAEA\
    /QCABAEAgAQBAIAEAQCABAEAgAQBAIAEAQCABAEAgA\
    /QBAIAEAQCABAEAgAQBAIAEAQCABAEAgAQBAIAEAQC\
    /ABAEAgAQBAIAEAQCABAEAgAQBAIAEAQCABAEAgAQB\
    /AIAEAQCABAEAgAQBAIAEAQCABAEAgAQBAIAEAQCAB\
    /AEAgAQBAIAEAQCABAEAgAQBAIAEAQCABA+BVAVVbQ\
    /SnMviQAAAABJRU5ErkJggg=='
--
