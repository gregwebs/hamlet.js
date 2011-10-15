# * Hamlet Html Templates for javascript

This loosely follows the original Haskell [Hamlet](http://www.yesodweb.com/book/templates) template language.
There are less features right now, and just a single #{} interpolation for javascript

# Testing

coffee -cb hamlet.coffee && node hamlet.js

Test cases are ported from [the Hamlet test suite](http://github.com/yesodweb/hamlet/hamlet/test/main.hs)
