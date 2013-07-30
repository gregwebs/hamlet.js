# * Hamlet Html Templates for javascript. http://www.github.com/gregwebs/hamlet.js
# Re-uses some code from HTML Parser By John Resig (ejohn.org)
# * LICENSE: Mozilla Public License

###
 * template function is a modified form of micro-template
 * https://github.com/cho45/micro-template.js
 * (c) cho45 http://cho45.github.com/mit-license
###
`function template(id, data, options) {
  var me = arguments.callee;
  options = options || {}
  var result = me.cache[id] || (function () {
    var name = id
    var string = id
    if (/^[\w\-]+$/.test(id)) { string = me.get(id) } else { name = options.filename || 'String' }
    var debugInfo, lineNum = 1, line = "";

    var stringOrig = Hamlet.toHtml(string)
    // console.log( stringOrig )
    var stringInterpSubs = stringOrig
          .replace(Hamlet.templateSettings.beginInterpolate, '\x11')
          .replace(Hamlet.templateSettings.endInterpolate, '\x13')

    string = stringInterpSubs.
            replace(Hamlet.templateSettings.beginInterpolate, '\x11').replace(Hamlet.templateSettings.endInterpolate, '\x13').
            replace(/'(?![^\x11\x13]+?\x13)/g, '\\x27').
            replace(/^\s*|\s*$/g, '').
            replace(/([^\n]*)\n/g, function (_, line) { return line + "';\nthis.line='" + line + "';this.lineNum=" + (++lineNum) + ";this.ret += '\\n" }).
            // replace(Hamlet.templateSettings.interpolate, "' + ($1) + '") + 
            replace(/\x11raw(.+?)\x13/g, "' + ($1) + '").
            // note the use of '*'. '+' would be better, but it risks leaving behind \x11 & \x13
            replace(/\x11(.*?)\x13/g, function(_, htmlVar){
                return (htmlVar == 'content')
                       ? "' + (" + htmlVar + ") + '"
                       : "' + this.escapeHTML(" + htmlVar + ") + '"
              })
            // replace(/\x11(.+?)\x13/g, "'; $1; this.ret += '") +

    function mkFunctionBody(string){
      return (
        "try { " +
          (me.variable ?  "var " + me.variable + " = this.stash;" : "with (this.stash) { ") +
            "this.ret += '"  + string +
          "'; " + (me.variable ? "" : "}") + "return this.ret;" +
        (debugInfo = "'. previous line:\\n' + this.line + '\\n(on " + name + "' + ' line ' + this.lineNum + ')'; } ",
          "} catch (e) { throw 'TemplateError: ' + e + " + debugInfo
        ) +
        "//@ sourceURL=" + name + "\n" // source map
      ).replace(/this\.ret \+= '';/g, '');
    }

    var func
    try {
      func = new Function(mkFunctionBody(string));
    } catch (e) {
      var errorLine = "";
      var lines = (stringInterpSubs + "\n").split("\n")
      var lineLen = lines.length
      for (i=0; i < lineLen; i++){
        var js = (lines[i].replace(/\x11(.*?)\x13/g, "' + this.escapeHTML($1) + '"))
        try {
          new Function("'" + js + "'")
        } catch (e) {
          errorLine = lines[i]
          break;
        }
      }
      throw 'TemplateError: ' + e + ((!errorLine) ? "" : "\nline: " + errorLine)
    }
    var map  = { '&' : '&amp;', '<' : '&lt;', '>' : '&gt;', '\x22' : '&#x22;', '\x27' : '&#x27;' };
    var escapeHTML = function (string) { return (string||'').toString().replace(/[&<>\'\"]/g, function (_) { return map[_] }) };
    return function (stash) { return func.call(me.context = {
        escapeHTML: escapeHTML
      , content: options.content // the inner content when rendering a layout
      , line: ""
      , lineNum: 1
      , ret : ''
      , stash: stash
      }) };
  })();
  return data ? result(data) : result;
};

template.cache = {};
template.get = function (id) { return document.getElementById(id).innerHTML };

/**
 * Extended template function:
 *   requires: basic template() function
 *   provides:
 *     include(id)
 *     wrapper(id, function () {})
 */
function extended (id, data) {
  var fun = function (data) {
    data.include = function (name) {
      template.context.ret += template(name, template.context.stash);
    };

    data.wrapper = function (name, fun) {
      var current = template.context.ret;
      template.context.ret = '';
      fun.apply(template.context);
      var content = template.context.ret;
      var orig_content = template.context.stash.content;
      template.context.stash.content = content;
      template.context.ret = current + template(name, template.context.stash);
      template.context.stash.content = orig_content;
    };

    return template(id, data);
  };

  return data ? fun(data) : fun;
}

template.get = function (id) {
  var fun = extended.get;
  return fun ? fun(id) : document.getElementById(id).innerHTML;
};
this.template = template;
this.extended = extended;
`



Hamlet = extended
Hamlet.templateSettings = {
  interpolate     : /#\{([\s\S]+?)\}\}/g,
  beginInterpolate: /#\{/g
  endInterpolate  : /\}/g
  oldInterpolate  : /\{\{([\s\S]+?)\}\}/g,
}

Hamlet.toHtml = (html) ->
  content = []
  tag_stack = []
  last_tag_indent = 0
  needs_space = false

  delete_comment = (s) ->
    i = indexOf(s, '#')
    if !i? then s else
      sub = s.substring(0, i)
      if s[i+1] == "{" then sub + '#' + delete_comment(s.substring(i + 1)) else
        # let an html encoded entity pass through
        if s[i-1] != '&' then sub else
          sub + '#' + delete_comment(s.substring(i+1))

  push_innerHTML = (str) ->
    needs_space = true
    content.push(delete_comment(str))

  for line in html.split(/\n\r*/)
    pos = 0
    pos += 1 while line[pos] == ' '
    unindented = line.substring(pos)

    if unindented.length == 0
      content.push(' ')

    else if unindented[0] == '#' && unindented[1] != '{'

    else
      if pos <= last_tag_indent
        if tag_stack.length > 0 and pos == last_tag_indent
          [oldp, oldt] = tag_stack.pop()
          last_tag_indent = tag_stack[tag_stack.length - 1]?[0] || 0
          content.push("</#{oldt}>") unless (emptyTags[oldt])

        while tag_stack.length > 0 and pos < last_tag_indent
          needs_space = false
          [oldp, oldt] = tag_stack.pop()
          last_tag_indent = tag_stack[tag_stack.length - 1]?[0] || 0
          content.push("</#{oldt}>") unless (emptyTags[oldt])

        if tag_stack.length > 0 and pos == last_tag_indent
          [oldp, oldt] = tag_stack.pop()
          last_tag_indent = tag_stack[tag_stack.length - 1]?[0] || 0
          content.push("</#{oldt}>") unless (emptyTags[oldt])

      if unindented[0] == '>'
        unindented = unindented.substring(1)
        needs_space = false

      content.push("\n") if needs_space
      needs_space = false

      if unindented[0] != '<'
        push_innerHTML(unindented)

      else
        last_tag_indent = pos

        innerHTML = ""
        tag_portion = unindented.substring(1)
        ti = indexOf(unindented, '>')
        if ti?
          tag_portion = unindented.substring(1, ti)
          if tag_portion[tag_portion.length] == "/"
            tag_portion = tag_portion.substring(innerHTML.length - 1)
          innerHTML = unindented.substring(ti + 1)

        tag_attrs = ""
        id_attr = null
        class_attr = null
        tag_name = tag_portion
        si = indexOf(tag_portion, ' ')
        if si?
          tag_name = tag_portion.substring(0, si)
          tag_attrs = tag_portion.substring(si)

        [tag_name, ids...] = tag_name.split('#')
        unless ids.length == 0
          throw("found multiple ids: " + ids.join(',')) if ids.length > 1
          [id, classes...] = ids[0].split('.')
          unless classes.length == 0
            tag_name = tag_name + '.' + classes.join('.')
          id_attr = id

        [tag_name, classes...] = tag_name.split('.')
        unless classes.length == 0
          class_attr = classes

        tag_name = "div" if tag_name == ""

        # if emptyTags[tag_name]
        # content.push("<#{tag_name}/>")
        # else
        tag_stack.push([last_tag_indent, tag_name])
        close_tag = if (emptyTags[tag_name]) then "/>" else ">"

        if tag_attrs.length == 0 && !id_attr && (class_attr || []).length == 0
          content.push( "<#{tag_name}#{close_tag}")
        else
          attrs = parse_attrs(tag_attrs, class_attr)
          attrs.unshift ["id", id_attr] if id_attr
          content.push( "<#{tag_name} #{join_attrs(attrs)}#{close_tag}" )

        unless innerHTML.length == 0
          push_innerHTML(innerHTML)

    undefined

  while tag_stack.length > 0
    [oldp, oldt] = tag_stack.pop()
    content.push("</#{oldt}>") unless (emptyTags[oldt])

  content.join("")


indexOf = (str, substr) ->
  i = str.indexOf(substr)
  if i == -1 then null else i

attrMatch = /(?:\.|#)?([-A-Za-z0-9_]+)(?:\s*=\s*(?:(?:"((?:\\.|[^"])*)")|(?:'((?:\\.|[^'])*)')|([^>\s]+)))?/g
fillAttrs = {
  checked: true
  compact: true
  declare: true
  defer: true
  disabled: true
  ismap: true
  multiple: true
  nohref: true
  noresize: true
  noshade: true
  nowrap: true
  readonly: true
  selected: true
}
emptyTags = {
  area: true
  base: true
  basefont: true
  br: true
  col: true
  frame: true
  hr: true
  img: true
  input: true
  isindex: true
  link: true
  meta: true
  param: true
  embed: true
}

parse_attrs = (html, classes) ->
  attrs = []
  classes ||= []
  # TODO: more efficient function then replace? we don't need to replace
  html.replace attrMatch, (match, name) ->
    if match[0] == "."
      classes = classes.concat( name.split('.') )
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
    attrs.unshift(["class", classes.join(" ")])

  attrs

join_attrs = (attrs) ->
  (for attr in attrs
    attr[0] + '="' + attr[1] + '"'
  ).join(' ')

if exports
  exports.hamlet = Hamlet
