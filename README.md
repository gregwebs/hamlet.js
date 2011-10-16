# Hamlet Html Templates for javascript

This loosely follows the original Haskell [Hamlet](http://www.yesodweb.com/book/templates) template language.

# Synatx

``` coffeescript
Hamlet("""
<.foo>
  <span#bar data-attr={{foo}}>baz # this is a comment
""", {foo:'f'})
```

generates:

``` html
<div class="foo"><span id="bar" data-attr="f">baz </span></div>
```

The library does not try to pretty print the resulting html, although it wouldn't be hard to do.
Note the mustache style interpolation `{{var}}`. I am not a huge fan of that, but it was easier to implement than some alternatives.

## Overview

It is just HTML! But redundancies are taken away
* quoting attributes is not required unless they have spaces
* Indentation is used to automatically close tags.

The second point is wonderful - you already properly indent your tags right?
Let the computer type your closing tags for you.

## class/id shortcuts

This css-based shortcut is originally taken from the HAML markup language.
a '#' indicates an id, and a '.' indicates a class

## Comments

Comments begin with a '#' character.
They are dropped, not converted to html comments.
There is no support for html comments.

## White space

Using indentation does have some consequences with respect to white space.
Not that this is necessarily bad, but it is at least different.

In the original Hamlet language you must use an explicit notation to add white space.
This library uses one similar technique - if you want to have a space within a tag, use a comment on the line.

``` html
<b>space!  # 2 spaces are included
<b>space!  </b>
```

An imporant difference is that this library automatically adds white space after tags.
If you don't want white space, you point it out with a '>' character.
This idea is loosly based on "whitespace alligators" from HAML.

``` html
<p>
  <b>no space
  >none here either
```

``` html
<p><b>no space</b>none here either</p>
```

## Functions exposed:

* Hamlet - compile the template and evaluate the javascript

For faster execution, first turn your template into regular html just once with

* HamletToHtml

Then execute the template with:

* HamletInterpolate - eval javascript from

# Testing

coffee -cb hamlet.coffee && node hamlet.js

Test cases are ported from [the Hamlet test suite](http://github.com/yesodweb/hamlet/hamlet/test/main.hs)
