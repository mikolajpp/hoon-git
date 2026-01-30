# Hoon-git
Hoon-git is a suite of libraries and agents (urbit microservices) which enable
your urbit node to function both as a git client and a git server.

It consists of several components:
1. `%git-store` agent - implements git server functionality
2. `%git-cmd` agent - implement minimal git cli: clone and manage repositories with a faithful
git cli interface.
3. `/lib/git.hoon` - hoon git library providing low-level support for git objects, packfiles and basic
commit graph traversal.
4. `/lib/bytestream.hoon` - hoon library for processing bytestrings using a monadic interface.

For efficient operation, some library functions need to be accelerated in the
runtime with corresponding C jets. As of 409K, some of these jets have been merged in
vere. This enables cloning of small-sized repositories, but for better performance a custom runtime
is required at present. (This is primarily caused by the poor behavior of the runtime's garbage collector. It is likely to improve if road hints for running hoon computations 
in a nested memory context are made available.)

# Demo
Hoon-git achieves self-hosting. Watch it clone its own repository, and then
serve it from the %git-store git server over http.
[![asciicast](https://asciinema.org/a/RbWGBBqiCVp9gV3e.svg)](https://asciinema.org/a/RbWGBBqiCVp9gV3e)

# Talk at Lake Summit 2024

Watch the talk about the project given by the author at the Lake Summit 2024: [link](https://www.youtube.com/watch?v=uPWJNQbqht4)
[Demo](https://youtu.be/uPWJNQbqht4?t=931) begins at `14:50`.

You will learn, among other things, just how big git codebase is (spoiler: it is quite big!),
what it took to reimplement git in Hoon from scratch, and how memory techniques handed down to us
from antiquity helped the whole enterprise!


# Acknowledgements

This project received funding from the Urbit Foundation.
Neal E. Davis [@sigilante](https://github.com/sigilante) was the grant mentor.
