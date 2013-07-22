Hamlet = require('../lib/hamlet').hamlet

t = (a, b) =>
  h = Hamlet.toHtml(b).replace(/\n/g, " ")
  if a != h
    console.log("from:\n" + b + "\n\nnot equal:\n" + a + "\n" + h)
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

interp = =>
  tpl = """
<p>para
  <span>\#{foo} \#{bar}
"""

  r = Hamlet(tpl, {
    foo : "a"
    bar : "b"
  })
  unless "<p>para <span>a b</span></p>" == r
    console.log("Fail: " + r)
    process.exit(1) if process && process.exit

interp()
###
