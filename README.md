# Hamlet Html Templates for javascript

Hamlet is just html without redundencies.
The big deal is that it uses your white space to automatically close tags.
You already properly indent your tags right?
Computers are supposed to autmoate things - lets have them close tags for us.

# Synatx

This example uses a coffeescript multi-line string, but should otherwise look like javascript.

``` html
<.foo>
  <span#bar data-attr={{foo}}>baz # this is a comment
```

invoked with: `Hamlet(template, {foo:'f'})`.  generates:

``` html
<div class="foo"><span id="bar" data-attr="f">baz </span></div>
```

The library does not try to pretty print the resulting html, although it wouldn't be hard to do.
Note the mustache style interpolation `{{var}}`.
I am not a huge fan of that, but it was easier to implement than some alternatives.

## Overview

This loosely follows the original Haskell [Hamlet](http://www.yesodweb.com/book/templates) template language that I helped design.

It is just HTML! But redundancies are taken away
* quoting attributes is not required unless they have spaces
* Indentation is used to automatically close tags.

## Usage

This re-uses _.template from underscore.js

``` js
rendered = Hamlet(template, object)
```

or

``` js
pre_compiled_template = Hamlet(template)
rendered = pre_compiled_template(object) 
```

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

## Limitations

I haven't used this much yet. Let me know if any bugs, I do have test cases.
I still consider the interpolation and white space syntax experimental.
Let me know if you have better ideas.

# Testing

I wanted to run tests without the browser overhead, but I am using this on the client, not on node. I came up with this:

coffee -cb hamlet.coffee && coffee -cb test.coffee && cp hamlet.js runtests.js && cat test.js >> runtests.js && node runtests.js && echo "PASS" || echo "FAIL"

Test cases are ported from [the Hamlet test suite](http://github.com/yesodweb/hamlet/hamlet/test/main.hs)
