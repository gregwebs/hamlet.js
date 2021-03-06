// Generated by CoffeeScript 1.6.3
/*
 * template function is a modified form of micro-template
 * https://github.com/cho45/micro-template.js
 * (c) cho45 http://cho45.github.com/mit-license
*/

function template(id, data, options) {
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
;
var Hamlet, attrMatch, emptyTags, fillAttrs, indexOf, join_attrs, parse_attrs,
  __slice = [].slice;

Hamlet = extended;

Hamlet.templateSettings = {
  interpolate: /#\{([\s\S]+?)\}\}/g,
  beginInterpolate: /#\{/g,
  endInterpolate: /\}/g,
  oldInterpolate: /\{\{([\s\S]+?)\}\}/g
};

Hamlet.toHtml = function(html) {
  var attrs, class_attr, classes, close_tag, content, delete_comment, id, id_attr, ids, innerHTML, last_tag_indent, line, needs_space, oldp, oldt, pos, push_innerHTML, si, tag_attrs, tag_name, tag_portion, tag_stack, ti, unindented, _i, _len, _ref, _ref1, _ref10, _ref2, _ref3, _ref4, _ref5, _ref6, _ref7, _ref8, _ref9;
  content = [];
  tag_stack = [];
  last_tag_indent = 0;
  needs_space = false;
  delete_comment = function(s) {
    var i, sub;
    i = indexOf(s, '#');
    if (i == null) {
      return s;
    } else {
      sub = s.substring(0, i);
      if (s[i + 1] === "{") {
        return sub + '#' + delete_comment(s.substring(i + 1));
      } else {
        if (s[i - 1] !== '&') {
          return sub;
        } else {
          return sub + '#' + delete_comment(s.substring(i + 1));
        }
      }
    }
  };
  push_innerHTML = function(str) {
    needs_space = true;
    return content.push(delete_comment(str));
  };
  _ref = html.split(/\n\r*/);
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    line = _ref[_i];
    pos = 0;
    while (line[pos] === ' ') {
      pos += 1;
    }
    unindented = line.substring(pos);
    if (unindented.length === 0) {
      content.push(' ');
    } else if (unindented[0] === '#' && unindented[1] !== '{') {

    } else {
      if (pos <= last_tag_indent) {
        if (tag_stack.length > 0 && pos === last_tag_indent) {
          _ref1 = tag_stack.pop(), oldp = _ref1[0], oldt = _ref1[1];
          last_tag_indent = ((_ref2 = tag_stack[tag_stack.length - 1]) != null ? _ref2[0] : void 0) || 0;
          if (!emptyTags[oldt]) {
            content.push("</" + oldt + ">");
          }
        }
        while (tag_stack.length > 0 && pos < last_tag_indent) {
          needs_space = false;
          _ref3 = tag_stack.pop(), oldp = _ref3[0], oldt = _ref3[1];
          last_tag_indent = ((_ref4 = tag_stack[tag_stack.length - 1]) != null ? _ref4[0] : void 0) || 0;
          if (!emptyTags[oldt]) {
            content.push("</" + oldt + ">");
          }
        }
        if (tag_stack.length > 0 && pos === last_tag_indent) {
          _ref5 = tag_stack.pop(), oldp = _ref5[0], oldt = _ref5[1];
          last_tag_indent = ((_ref6 = tag_stack[tag_stack.length - 1]) != null ? _ref6[0] : void 0) || 0;
          if (!emptyTags[oldt]) {
            content.push("</" + oldt + ">");
          }
        }
      }
      if (unindented[0] === '>') {
        unindented = unindented.substring(1);
        needs_space = false;
      }
      if (needs_space) {
        content.push("\n");
      }
      needs_space = false;
      if (unindented[0] !== '<') {
        push_innerHTML(unindented);
      } else {
        last_tag_indent = pos;
        innerHTML = "";
        tag_portion = unindented.substring(1);
        ti = indexOf(unindented, '>');
        if (ti != null) {
          tag_portion = unindented.substring(1, ti);
          if (tag_portion[tag_portion.length] === "/") {
            tag_portion = tag_portion.substring(innerHTML.length - 1);
          }
          innerHTML = unindented.substring(ti + 1);
        }
        tag_attrs = "";
        id_attr = null;
        class_attr = null;
        tag_name = tag_portion;
        si = indexOf(tag_portion, ' ');
        if (si != null) {
          tag_name = tag_portion.substring(0, si);
          tag_attrs = tag_portion.substring(si);
        }
        _ref7 = tag_name.split('#'), tag_name = _ref7[0], ids = 2 <= _ref7.length ? __slice.call(_ref7, 1) : [];
        if (ids.length !== 0) {
          if (ids.length > 1) {
            throw "found multiple ids: " + ids.join(',');
          }
          _ref8 = ids[0].split('.'), id = _ref8[0], classes = 2 <= _ref8.length ? __slice.call(_ref8, 1) : [];
          if (classes.length !== 0) {
            tag_name = tag_name + '.' + classes.join('.');
          }
          id_attr = id;
        }
        _ref9 = tag_name.split('.'), tag_name = _ref9[0], classes = 2 <= _ref9.length ? __slice.call(_ref9, 1) : [];
        if (classes.length !== 0) {
          class_attr = classes;
        }
        if (tag_name === "") {
          tag_name = "div";
        }
        tag_stack.push([last_tag_indent, tag_name]);
        close_tag = emptyTags[tag_name] ? "/>" : ">";
        if (tag_attrs.length === 0 && !id_attr && (class_attr || []).length === 0) {
          content.push("<" + tag_name + close_tag);
        } else {
          attrs = parse_attrs(tag_attrs, class_attr);
          if (id_attr) {
            attrs.unshift(["id", id_attr]);
          }
          content.push("<" + tag_name + " " + (join_attrs(attrs)) + close_tag);
        }
        if (innerHTML.length !== 0) {
          push_innerHTML(innerHTML);
        }
      }
    }
    void 0;
  }
  while (tag_stack.length > 0) {
    _ref10 = tag_stack.pop(), oldp = _ref10[0], oldt = _ref10[1];
    if (!emptyTags[oldt]) {
      content.push("</" + oldt + ">");
    }
  }
  return content.join("");
};

indexOf = function(str, substr) {
  var i;
  i = str.indexOf(substr);
  if (i === -1) {
    return null;
  } else {
    return i;
  }
};

attrMatch = /(?:\.|#)?([-A-Za-z0-9_]+)(?:\s*=\s*(?:(?:"((?:\\.|[^"])*)")|(?:'((?:\\.|[^'])*)')|([^>\s]+)))?/g;

fillAttrs = {
  checked: true,
  compact: true,
  declare: true,
  defer: true,
  disabled: true,
  ismap: true,
  multiple: true,
  nohref: true,
  noresize: true,
  noshade: true,
  nowrap: true,
  readonly: true,
  selected: true
};

emptyTags = {
  area: true,
  base: true,
  basefont: true,
  br: true,
  col: true,
  frame: true,
  hr: true,
  img: true,
  input: true,
  isindex: true,
  link: true,
  meta: true,
  param: true,
  embed: true
};

parse_attrs = function(html, classes) {
  var attrs;
  attrs = [];
  classes || (classes = []);
  html.replace(attrMatch, function(match, name) {
    var val, value;
    if (match[0] === ".") {
      classes = classes.concat(name.split('.'));
    } else {
      value = match[0] === "#" ? (val = name, name = "id", val) : arguments[2] || arguments[3] || arguments[4] || (fillAttrs[name] ? name : "");
      if (name === "class") {
        classes.push(value);
      } else {
        attrs.push([name, value.replace(/(^|[^\\])"/g, '$1\\\"')]);
      }
    }
  });
  if (classes.length > 0) {
    attrs.unshift(["class", classes.join(" ")]);
  }
  return attrs;
};

join_attrs = function(attrs) {
  var attr;
  return ((function() {
    var _i, _len, _results;
    _results = [];
    for (_i = 0, _len = attrs.length; _i < _len; _i++) {
      attr = attrs[_i];
      _results.push(attr[0] + '="' + attr[1] + '"');
    }
    return _results;
  })()).join(' ');
};

if (exports) {
  exports.hamlet = Hamlet;
}
