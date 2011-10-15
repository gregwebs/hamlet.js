# Hamlet Html Templates for javascript

This loosely follows the original Haskell [Hamlet](http://www.yesodweb.com/book/templates) template language.
There are less features, including just a single #{} to eval javascript

## Functions exposed:
* Hamlet - compile the template and evaluate the javascript

For faster execution, first turn your template into regular html just once with
* HamletToHtml

Then execute the template with:
* HamletInterpolate - eval javascript from

# Testing

coffee -cb hamlet.coffee && node hamlet.js

Test cases are ported from [the Hamlet test suite](http://github.com/yesodweb/hamlet/hamlet/test/main.hs)
