# Hamlet Html Templates for javascript

Hamlet is just html without redundancies.
The big deal is that it uses your white space to automatically close tags.
You already properly indent your tags right?
Computers are supposed to automate things - lets have them close tags for us.

This is similar in concept to HAML. However, HAML abandons html syntax without justification. If we just apply significant white-space and a few other html-compatible shortcuts to regular HTML, we can get the benefit without the drawback. Designers that have used the Haskell version of Hamlet have really liked it.

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

This loosely follows the original Haskell [Hamlet](http://www.yesodweb.com/book/templates) template language that I helped design. This implementation is simpler because it is invoked at runtime, just does a simple javascript eval, and has no concept of type insertion - this includes no html escaping.

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
## Don't tell anyone :)

,  the '>' character is optional if there is no inner content on that line. There can still can be inner content on the next line. I don't tout this because some of those used to html don't find it aesthetically pleasing. But don't let anyone tell you that HAML has one less character :)

## Limitations

I just created it - haven't used it much yet. I do have test cases, but let me know if you encounter any issues.
I still consider the interpolation and white space syntax experimental - let me know if you have better ideas.

# Development 

Requires Coffeescript, although if you are only comfortable changing js I can easily port it to the Coffeescript file.

## Testing

I wanted to run tests without the browser overhead. Probably there is a better way, but I came up with this which works fine:

    coffee -cb hamlet.coffee && coffee -cb test.coffee && cp hamlet.js runtests.js && cat test.js >> runtests.js && node runtests.js && echo "PASS" || echo "FAIL"

You could run the tests in a browser or elsewhere though.
Note it requires coffee: `npm install coffee-script && ln -s node_modules/coffee-script/bin/coffee coffee`

Test cases can be ported from [the Hamlet test suite](http://github.com/yesodweb/hamlet/hamlet/test/main.hs)

# TODO

* Add conditional attribute syntax

    <p :isRed:style="color:red">
    <input type=checkbox :isChecked:checked>
