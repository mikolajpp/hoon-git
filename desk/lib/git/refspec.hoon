/**
 * A struct refspec_item holds the parsed interpretation of a refspec.  If it
 * will force updates (starts with a '+'), force is true.  If it is a pattern
 * (sides end with '*') pattern is true.  If it is a negative refspec, (starts
 * with '^'), negative is true.  src and dest are the two sides (including '*'
 * characters if present); if there is only one side, it is src, and dst is
 * NULL; if sides exist but are empty (i.e., the refspec either starts or ends
 * with ':'), the corresponding side is "".
 *
 * remote_find_tracking(), given a remote and a struct refspec_item with either src
 * or dst filled out, will fill out the other such that the result is in the
 * "fetch" specification for the remote (note that this evaluates patterns and
 * returns a single result).
 */
|%
--

