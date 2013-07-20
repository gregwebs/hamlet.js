# Hamlet Html Templates for javascript

Hamlet is just html without redundancies.
The big deal is that it uses your white space to automatically close tags.
You already properly indent your tags right?
Computers are supposed to automate things - lets have them close tags for us.

This is similar in concept to HAML or jade. However, HAML and jade abandons html syntax without justification. If we just apply significant white-space and a few other html-compatible shortcuts to regular HTML, we can get the benefit without the drawback. Designers that have used the Haskell version of Hamlet have really liked it.

I created this with client-side templates in mind, but it works server side with node.js

# Syntax

``` html
<body>
    <p>Some paragraph.
    <ul>
        <li>Item 1
        <li>Item 2
```

That hamlet is equivalent to:

``` html
<body>
  <p>Some paragraph.</p>
  <ul>
    <li>Item 1</li>
    <li>Item 2</li>
  </ul>
</body>
```

Lets show some interpolation and CSS shortcuts:

``` html
<.foo>
  <span#bar data-attr={{foo}}>baz # this is a comment
```

That template invoked with: `Hamlet(template, {foo:'f'})`.  generates:

``` html
<div class="foo"><span id="bar" data-attr="f">baz </span></div>
```

The library currently does not try to pretty print the resulting html, although it wouldn't be hard to do.
Note the mustache style interpolation `{{var}}`. I have never had the opportunity to use mustache templates - this was simply easier to implement than some alternatives. You can put any javascript you would like in the interpolation.

## Overview

It is just HTML! But redundancies are taken away

* quoting attributes is not required unless they have spaces
* Indentation is used to automatically close tags.

This loosely follows the original Haskell [Hamlet](http://www.yesodweb.com/book/templates) template language that I helped design. This implementation is simpler because it is invoked at runtime, just does a simple javascript eval, and has no concept of type insertion - this includes no html escaping. There is a [fork of this library](https://github.com/ajnsit/hamlet.js) that uses Haskell Hamlet style interpolation.

## Usage

This uses the same style and code as the template function from underscore.js

``` js
rendered_html = Hamlet(template, object)
```

or

``` js
pre_compiled_template = Hamlet(template)
rendered_html = pre_compiled_template(object)
```

Or you can avoid all variable assertion and just expand hamlet with:

``` js
Hamlet.toHtml('<p>') // "<p></p>"
```

## class/id shortcuts

The CSS-based shortcuts are originally taken from the HAML markup language.
A '#' indicates an id, and a '.' indicates a class. You can add as many classes this way as you like.

## Comments

Comments begin with a '#' character.
When the template is compiled they are removed, not converted to html comments.
There is no support for html comments.

## White space

Using indentation does have some consequences with respect to white space. This library is designed to just do the right thing most of the time. This is a slightly different design from the original Haskell implementation of Hamlet.

A closing tag is placed immediately after the tag contents. If you want to have a space before a closing tag, use a comment sign `#` on the line to indicate where the end of the line is.

``` html
<b>spaces  # 2 spaces are included
```

``` html
<b>spaces  </b>
```

White space is automatically added *after* tags with inner text. If you have multiple lines of inner text without tags (not a common use case) they will also get a space added. If you do not want white space, you point it out with a `>` character, that you could think of as the end of the last tag, although you can still use it when separating content without tags onto different lines. You can also use a `>` if you want more than one space.

``` html
<p>
  <b>no space
  >none here either.
  >  Two spaces after a period is bad!
```

``` html
<p><b>no space</b>none here either.  Two spaces after a period is bad!</p>
```

## Closing bracket

currently  the '>' character is optional if there is no inner text on the same line. In the future this will be changed to be required so that tag attributes can span multiple lines.

## Limitations

Hamlet just uses a simple eval interpolation.
This works well for me on an AngularJS project where AngularJS is actually doing the templating.
You might be able to use Hamlet to pre-process for another templating system.

# Development 

Requires Coffeescript, although if you are only comfortable changing js I can easily port it to the Coffeescript file.

## Testing

The test suite is pretty good now. I create a test case for every issue I notice.

I wanted to run tests without the browser overhead. Probably there is a better way, but I came up with this which works fine:

    coffee -cb hamlet.coffee && coffee -cb test.coffee && cp hamlet.js runtests.js && cat test.js >> runtests.js && node runtests.js && echo "PASS" || echo "FAIL"

You could run the tests in a browser or elsewhere though.
Note it requires coffee

    npm install coffee-script && ln -s node_modules/coffee-script/bin/coffee coffee

Test cases can be ported from [the Hamlet test suite](http://github.com/yesodweb/hamlet/hamlet/test/main.hs)


## Converting from jade

If there are no variables interpreted in your jade, you can compile it down to html

    > jade.compile('test(attr="val") text', {debug:false, compileDebug:false, pretty:true, client:true})()
    '\n<test a="val">wtf</test>'

TODO: If there are variables, is there a way to set every variable value to `{{variable}}` ?

## Converting from html

One of the great things about Hamlet is that for a small amount of HTML, you can just delete the closing tags.

There is a Haskell tool `html2hamlet` (install Haskell, then cabal install html2hamlet)

    ❯ echo '\n<test a="val">text</test>' | ./cabal-dev/bin/html2hamlet
    !!!
    <test a="val">
      text

