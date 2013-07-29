Hamlet = require('../lib/hamlet').hamlet

t = (a, b) =>
  h = Hamlet.toHtml(b).replace(/\n/g, " ")
  if a != h
    console.log("FAIL: from:\n" + b + "\n\nnot equal:\n" + a + "\n" + h)
    process.exit(1) if process && process.exit

# class shortcut and class attribute
t '<div class="guide-entry {{zebra(episode)}}"></div>', """
<.guide-entry class="{{zebra(episode)}}">
"""

# id and class shortcut next to tag with no spaces
t '<a id="btn" class="watchlist" href="#">Add to Favorites</a>', """
<a#btn.watchlist href="#">
  Add to Favorites
"""

# class shortcut next to tag with no spaces
t '<a class="btn-watchlist" href="#">Add to Favorites</a>', """
<a.btn-watchlist href="#">
  Add to Favorites
"""

# multiple classes
t '<div class="foo bar"></div>', """
<.foo.bar>
"""

# dot in class field
t '<p class="foo.bar"><div id="bar">baz</div></p>', """
<p class=foo.bar
  <#bar>baz
"""

# id shortcut next to tag with no spaces
t '<a id="btn-watchlist" href="#">Add to Favorites</a>', """
<a#btn-watchlist href="#">
  Add to Favorites
"""

# basic tests
t("<div></div>", "<div>")
t('<span>%{foo}</span>', '<span>%{foo}')


# multiple tags at same level
t('<div class="actions bottom-row"><a class="like" href="#">Like</a></div><div class="likes bottom-row"><a class="likes" href="#">387 people</a> like this</a></div>',"""
<div class="actions bottom-row">
    <a class="like" href="#">Like
<div class="likes bottom-row">
    <a class="likes" href="#">387 people</a> like this
""")

# html entities
t('<a class="open-post" href="{{fb_item_link(feed)}}" target="blank">&#8599;</a>',
    '<a class="open-post" href="{{fb_item_link(feed)}}" target="blank">&#8599;'
)

# dashed attribute
t('<div class="klass" ng-controller="Controller"></div>',
  "<.klass ng-controller=Controller>")

# id & class shortcuts
t '<p class="foo"><div id="bar">baz </div></p>', """
<p .foo>
  <#bar>baz # this is a comment
"""

# multiple lines of text
t "<div>foo bar</div>", """
<div>
  foo
  bar
"""

# tag spacing lines of text - this doesn't seem correct really :)
t "<ul><li><a>foo</a> <a>foo2</a></li><li><a>bar</a></li></ul>", """
<ul>
  <li>
    <a>foo
    <a>foo2
  <li>
    <a>
      bar
"""

t '<p>You are logged in as <i>Greg</i> <b>Weber</b>, <a href="/logout">logout</a>.</p><p>Multi line paragraph.</p>', """
<p>You are logged in as
  <i>Greg
  <b>Weber
  >,
  <a href="/logout">logout
  >.
><p>Multi
  line
  paragraph.
"""

t '<i>No</i><b>Space</b>', '''
  <i>No
  ><b>Space
'''

t '<p>No close bracket</p> <p>No close</p>', '''
  <p
    No close bracket
  <p
    No close
'''

t '<img/><p>No close</p>', '''
  <img
  <p
    No close
'''

t '<p><b>no space</b>none here either.  Two spaces after a period is bad!</p>', '''
<p>
  <b>no space
  >none here either.
  >  Two spaces after a period is bad!
'''

assert = (equality, msg) ->
  unless equality
    console.log(msg)
    process.exit(1) if process && process.exit

interp = (tpl, result, vars) ->
  r = Hamlet(tpl, vars)
  assert(result == r, "FAIL: expected: " + result + "\ngot: " + r)

tpl = """
<p>para
  <span>\#{foo} \#{bar}
"""

interp tpl, "<p>para\n<span>a b</span></p>", {
    foo : "a"
    bar : "b"
  }

interp "<p>\#{fn('bar')}", "<p>baz</p>", {fn:() => 'baz' }
interp "<p>\#{ }", "<p></p>", {}
interp "<p>\#{}", "<p></p>", {}



assertException = (ex_str, triggersEx) ->
  try
    triggersEx()
    assert(false, "expected an exception")
  catch ex
    assert(ex.toString() == ex_str.toString(), "expected:\n" + ex.toString() + "\nunexpected exception:\n" + ex.toString())

tpl = """
<p>text1
<p>text2
<p>text3
<p>text4
<div>
  <p>\#{ 1;2 }
    <span>bar
<p>text5
<p>text6
<p>text7
<p>text8
"""

ex_str = """
TemplateError: SyntaxError: Unexpected token ;
line: <div><p>#{ 1;2 }
"""

# for some reason strings are not ==
# assertException(ex_str, () => interp tpl, "<p></p>", {})

ex_str = """
TemplateError: ReferenceError: doesnotexist is not defined. previous line:
<p>text1</p>
(on String line 2)
"""
tpl = """
<p>text1
<p>\#{ doesnotexist() }
<p>text2
<p>text3
"""
assertException(ex_str, () => interp tpl, "<p>text</p>\n<p></p>", {})


tpl = """
layout test/layout.hamlet
<p>
  In the layout
"""
assert(Hamlet.render(tpl) == "<div><p>In the layout</p>\n</div>") 
