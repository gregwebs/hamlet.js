t = (a, b) =>
  h = Hamlet.toHtml(b).replace(/\n/g, " ")
  if a != h
    console.log("from:\n" + b + "\n\nnot equal:\n" + a + "\n" + h)
    process.exit(1) if process && process.exit

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

t '<p>You are logged in as <i>Michael</i> <b>Snoyman</b>, <a href="/logout">logout</a>.</p><p>Multi line paragraph.</p>', """
<p>You are logged in as
  <i>Michael
  <b>Snoyman
  >,
  <a href="/logout">logout
  >.
><p>Multi
  line
  paragraph.
"""

interp = =>
  r = Hamlet('{{foo}} {{bar}}',
    foo : "a"
    bar : "b"
  )
  unless "a b" == r
    console.log("Fail: " + r)

interp()
