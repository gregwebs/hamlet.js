# * Hamlet Html Templates for javascript. http://www.yesodweb.com/book/templates
# Re-uses some code from HTML Parser By John Resig (ejohn.org)
# * LICENSE: Mozilla Public License
#
# TODO:
# * html comments

this.Hamlet = (html) ->
  this.HamletInterpolate( this.HamletToHtml(html) )

this.HamletInterpolate = (html) ->
  html.replace /#\{(.*)\}/, (match, js) -> eval(js)

this.HamletToHtml = (html) ->
  content = []
  tag_stack = []
  last_indent = 0

  for line in html.split(/[\n\r]+/)
    pos = 0
    pos += 1 while line[pos] == ' '
    unindented = line.substring(pos)

    if unindented[0] != '<'
      content.push(unindented)

    else
      if pos <= last_indent
        while tag_stack.length > 0 and (!oldp or pos < oldp)
          [oldp, oldt] = tag_stack.pop()
          content.push("</#{oldt}>")

      innerHTML = ""
      tag_portion = unindented.substring(1)
      if (ti = unindented.indexOf('>')) != -1
        tag_portion = unindented.substring(1, ti)
        if tag_portion[tag_portion.length] == "/"
          tag_portion = tag_portion.substring(innerHTML.length - 1)
        innerHTML = unindented.substring(ti + 1)

      tag_attrs = ""
      tag_name = tag_portion
      if (si = tag_portion.indexOf(' ')) != -1
        tag_name = tag_portion.substring(0, si)
        tag_attrs = tag_portion.substring(si)

      if tag_name[0] == '#'
        tag_attrs = "id=" + tag_name.substring(1) + tag_attrs
        tag_name = "div"
      if tag_name[0] == '.'
        tag_attrs = "class=" + tag_name.substring(1) + tag_attrs
        tag_name = "div"

      if emptyTags[tag_name]
        content.push("<#{tag_name}/>")
      else
        tag_stack.push([pos, tag_name])

        if tag_attrs.length == 0
          content.push( "<#{tag_name}>")
        else
          content.push( "<#{tag_name}" +
            join_attrs(parse_attrs(tag_attrs)) + ">"
          )

        content.push(innerHTML) unless innerHTML.length == 0

    last_indent = pos

  while tag_stack.length > 0
    [oldp, oldt] = tag_stack.pop()
    content.push("</#{oldt}>")

  content.join("")


makeMap = (str) ->
    obj = {}
    items = str.split(",")
    for i in items
        obj[ items[i] ] = true
    return obj

attrMatch = /(?:\.|#)?([-A-Za-z0-9_]+)(?:\s*=\s*(?:(?:"((?:\\.|[^"])*)")|(?:'((?:\\.|[^'])*)')|([^>\s]+)))?/g
fillAttrs = makeMap("checked,compact,declare,defer,disabled,ismap,multiple,nohref,noresize,noshade,nowrap,readonly,selected")

emptyTags = makeMap("area,base,basefont,br,col,frame,hr,img,input,isindex,link,meta,param,embed")

parse_attrs = (html) ->
  attrs = []
  classes = []
  # TODO: more efficient function then replace? we don't need to replace
  html.replace attrMatch, (match, name) ->
    if match[0] == "."
      classes.push( name )
    else
      value = if match[0] == "#"
        val = name
        name = "id"
        val
      else
        arguments[2] || arguments[3] || arguments[4] ||
          if fillAttrs[name]
            name
          else
            ""
      if name == "class"
        classes.push( value )
      else
        attrs.push([name,
          value.replace(/(^|[^\\])"/g, '$1\\\"')
        ])
    return

  if classes.length > 0
    attrs.push(["class", classes.join(" ")])

  attrs

join_attrs = (attrs) ->
  for attr in attrs
    " " + attr[0] + '="' + attr[1] + '"'


# tests

t = (a, b) =>
  h = this.HamletToHtml(b)
  if a != h
    console.log("from:\n" + b + "\n\nnot equal:\n" + a + "\n" + h)

t("<div></div>", "<div>")
t('<span>#{foo}</span>', '<span>#{foo}')

t "<p class=\"foo\"><div id=\"bar\">baz</div></p>", """
<p .foo>
  <#bar>baz
"""

t '<p class="foo.bar"><div id="bar">baz</div></p>', """
<p class=foo.bar
  <#bar>baz
"""

interp = =>
  foo = "bar"
  itp = @Hamlet("#{foo}")
  unless "bar" == itp
    console.log(itp)

interp()
