var attrMatch, emptyTags, fillAttrs, interp, join_attrs, makeMap, parse_attrs, t;
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
this.Hamlet = function(html) {
  return this.HamletInterpolate(this.HamletToHtml(html));
};
this.HamletInterpolate = function(html) {
  return html.replace(/#\{(.*)\}/, function(match, js) {
    return eval(js);
  });
};
this.HamletToHtml = function(html) {
  var content, innerHTML, last_indent, line, oldp, oldt, pos, si, tag_attrs, tag_name, tag_portion, tag_stack, ti, unindented, _i, _len, _ref, _ref2, _ref3;
  content = [];
  tag_stack = [];
  last_indent = 0;
  _ref = html.split(/[\n\r]+/);
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    line = _ref[_i];
    pos = 0;
    while (line[pos] === ' ') {
      pos += 1;
    }
    unindented = line.substring(pos);
    if (unindented[0] !== '<') {
      content.push(unindented);
    } else {
      if (pos <= last_indent) {
        while (tag_stack.length > 0 && (!oldp || pos < oldp)) {
          _ref2 = tag_stack.pop(), oldp = _ref2[0], oldt = _ref2[1];
          content.push("</" + oldt + ">");
        }
      }
      innerHTML = "";
      tag_portion = unindented.substring(1);
      if ((ti = unindented.indexOf('>')) !== -1) {
        tag_portion = unindented.substring(1, ti);
        if (tag_portion[tag_portion.length] === "/") {
          tag_portion = tag_portion.substring(innerHTML.length - 1);
        }
        innerHTML = unindented.substring(ti + 1);
      }
      tag_attrs = "";
      tag_name = tag_portion;
      if ((si = tag_portion.indexOf(' ')) !== -1) {
        tag_name = tag_portion.substring(0, si);
        tag_attrs = tag_portion.substring(si);
      }
      if (tag_name[0] === '#') {
        tag_attrs = "id=" + tag_name.substring(1) + tag_attrs;
        tag_name = "div";
      }
      if (tag_name[0] === '.') {
        tag_attrs = "class=" + tag_name.substring(1) + tag_attrs;
        tag_name = "div";
      }
      if (emptyTags[tag_name]) {
        content.push("<" + tag_name + "/>");
      } else {
        tag_stack.push([pos, tag_name]);
        if (tag_attrs.length === 0) {
          content.push("<" + tag_name + ">");
        } else {
          content.push(("<" + tag_name) + join_attrs(parse_attrs(tag_attrs)) + ">");
        }
        if (innerHTML.length !== 0) {
          content.push(innerHTML);
        }
      }
    }
    last_indent = pos;
  }
  while (tag_stack.length > 0) {
    _ref3 = tag_stack.pop(), oldp = _ref3[0], oldt = _ref3[1];
    content.push("</" + oldt + ">");
  }
  return content.join("");
};
makeMap = function(str) {
  var i, items, obj, _i, _len;
  obj = {};
  items = str.split(",");
  for (_i = 0, _len = items.length; _i < _len; _i++) {
    i = items[_i];
    obj[items[i]] = true;
  }
  return obj;
};
attrMatch = /(?:\.|#)?([-A-Za-z0-9_]+)(?:\s*=\s*(?:(?:"((?:\\.|[^"])*)")|(?:'((?:\\.|[^'])*)')|([^>\s]+)))?/g;
fillAttrs = makeMap("checked,compact,declare,defer,disabled,ismap,multiple,nohref,noresize,noshade,nowrap,readonly,selected");
emptyTags = makeMap("area,base,basefont,br,col,frame,hr,img,input,isindex,link,meta,param,embed");
parse_attrs = function(html) {
  var attrs, classes;
  attrs = [];
  classes = [];
  html.replace(attrMatch, function(match, name) {
    var val, value;
    if (match[0] === ".") {
      classes.push(name);
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
    attrs.push(["class", classes.join(" ")]);
  }
  return attrs;
};
join_attrs = function(attrs) {
  var attr, _i, _len, _results;
  _results = [];
  for (_i = 0, _len = attrs.length; _i < _len; _i++) {
    attr = attrs[_i];
    _results.push(" " + attr[0] + '="' + attr[1] + '"');
  }
  return _results;
};
t = __bind(function(a, b) {
  var h;
  h = this.HamletToHtml(b);
  if (a !== h) {
    return console.log("from:\n" + b + "\n\nnot equal:\n" + a + "\n" + h);
  }
}, this);
t("<div></div>", "<div>");
t('<span>#{foo}</span>', '<span>#{foo}');
t("<p class=\"foo\"><div id=\"bar\">baz</div></p>", "<p .foo>\n  <#bar>baz");
t('<p class="foo.bar"><div id="bar">baz</div></p>', "<p class=foo.bar\n  <#bar>baz");
interp = __bind(function() {
  var foo, itp;
  foo = "bar";
  itp = this.Hamlet("" + foo);
  console.log(itp);
  if ("bar" !== itp) {
    return console.log(itp);
  }
}, this);
interp();