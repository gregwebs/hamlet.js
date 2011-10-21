# Hamlet Html Templates for javascript

Hamlet is just html without redundencies.
The big deal is that it uses your white space to automatically close tags.
You already properly indent your tags right?
Computers are supposed to automate things - lets have them close tags for us.

This is similar in concept to HAML. However, HAML abandons html syntax without justification. If we just apply significant white-space and a few other html-compatible shortcuts to regular HTML, we can get the benefit without the drawback. Designers that have used the Haskell version of Hamlet have really liked it.

I created this with client-side templating in mind, but it works server side with node.js

# Synatx

``` html
<.foo>
  <span#bar data-attr={{foo}}>baz # this is a comment
```

invoked with: `Hamlet(template, {foo:'f'})`.  generates:

``` html
<div class="foo"><span id="bar" data-attr="f">baz </span></div>
```

The library currently does not try to pretty print the resulting html, although it wouldn't be hard to do.
Note the mustache style interpolation `{{var}}`. I have never had the opportunity to use mustache templates - this was simply easier to implement than some alternatives. You can put any javascript you would like in the interpolation.

## Overview

It is just HTML! But redundancies are taken away

* quoting attributes is not required unless they have spaces
* Indentation is used to automatically close tags.

This loosely follows the original Haskell [Hamlet](http://www.yesodweb.com/book/templates) template language that I helped design. This implementation is simpler because it is invoked at runtime, just does a simple javascript eval, and has no concept of type insertion - this includes no html escaping.

## Usage

This uses the same style and code as the template function from underscore.js

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
When the template is compiled they are removed, not converted to html comments.
There is no support for html comments.

## White space

Using indentation does have some consequences with respect to white space. This library is designed to just do the right thing most of the time. This is a slightly different design from the original Haskell implementation of Hamlet.

If you want to have a space before a closing tag, use a comment sign `#` on the line to indicate where the end of the line is.

``` html
<b>spaces  # 2 spaces are included
```

``` html
<b>spaces  </b>
```

This library automatically adds white space *after* tags. If you do not want white space, you point it out with a `>` character, that you could think of as the end of the last tag, although you can still use it when separating content without tags onto different lines. You can also use a `>` if you want more than one space.

``` html
<p>
  <b>no space
  >none here either.
  >  Two spaces after a period is bad!
```

``` html
<p><b>no space</b>none here either.  Two spaces after a period is bad!</p>
```

## Limitations

I just created it - haven't used it much yet. I do have test cases, but let me know if you encounter any issues.
I still consider the interpolation and white space syntax experimental - let me know if you have better ideas.

# Development 

Requires coffeescript, although if you are only comfortable changing js I can easily port it to the coffeescript file.

# Testing

I wanted to run tests without the browser overhead, but I am using this on the client, not on node (I don't want to pollute it with package statements just for testing purposes). Maybe there is a better way? I came up with this though, which works fine:

    coffee -cb hamlet.coffee && coffee -cb test.coffee && cp hamlet.js runtests.js && cat test.js >> runtests.js && node runtests.js && echo "PASS" || echo "FAIL"

You could run the tests in a browser or on rhino though.

Test cases can be ported from [the Hamlet test suite](http://github.com/yesodweb/hamlet/hamlet/test/main.hs)
