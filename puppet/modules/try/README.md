This module provides a "try" wrapper around common resource types.

For example:

    try::file {
      '/path/to/file':
        ensure => 'link',
        target => $target;
    }

This will work just like `file`, but will silently fail if `$target` is undefined or the file does not exist.

So far, only `file` type with symlinks works.
