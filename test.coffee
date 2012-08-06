Hamlet = this.Hamlet
t = (a, b) =>
  h = Hamlet.toHtml(b).replace(/\n/g, " ")
  if a != h
    console.log("from:\n" + b + "\n\nnot equal:\n" + a + "\n" + h)
    process.exit(1) if process && process.exit

t('<div ng-controller="Controller" class="klass"></div>',
  "<.klass ng-controller=Controller>")
###
t("<div></div>", "<div>")
t('<span>%{foo}</span>', '<span>%{foo}')

t '<p class="foo"><div id="bar">baz </div></p>', """
<p .foo>
  <#bar>baz # this is a comment
"""

t '<p class="foo.bar"><div id="bar">baz</div></p>', """
<p class=foo.bar
  <#bar>baz
"""

t "<div>foo bar</div>", """
<div>
  foo
  bar
"""

t "<div>foo<span>bar</span></div>", """
<div>
  foo
  ><span>bar
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

t '<img></img><p>No close</p>', '''
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
  r = Hamlet('{{foo}} {{bar}}',
    foo : "a"
    bar : "b"
  )
  unless "a b" == r
    console.log("Fail: " + r)

interp()
###
