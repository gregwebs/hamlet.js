var fs = require('fs')

/**
 * Strip any UTF-8 BOM off of the start of `str`, if it exists.
 *
 * @param {String} str
 * @return {String}
 * @api private
 */

function stripBOM(str){
  return 0xFEFF == str.charCodeAt(0)
    ? str.substring(1)
    : str;
}


/**
 * Compile a `Function` representation of the given hamlet `str`.
 *
 * Options:
 *
 *   - `filename` filename required for `include` / `extends` and caching
 *   - `content` inner content when rendering a layout
 *
 * @param {String} str
 * @param {Options} str
 * @return {Function}
 * @api public
 */

exports.compile = function(str, options){
  var options = options || {}
  return template(stripBOM(String(str)), undefined, options)
};

/**
 * Template function cache.
 */

exports.cache = {};


/**
 * Render the given `str` of jade and invoke
 * the callback `fn(err, str)`.
 *
 * Options:
 *
 *   - `cache` enable template caching
 *   - `filename` filename required for `include` / `extends` and caching
 *
 * @param {String} str
 * @param {Object|Function} options or fn
 * @param {Function} fn
 * @api public
 */
exports.render = function(str, options, fn){
  // swap args
  if ('function' == typeof options) {
    fn = options, options = {};
  }

  // cache requires .filename
  if (options.cache && !options.filename) {
    return fn(new Error('the "filename" option is required for caching'));
  }

  try {
    var m = str.match(/^\s*layout\s*(\S*)/)
    var layout = m && m[1]
    if (layout) { str = str.substring(m[0].length) }

    var path = options.filename;
    var tmpl = options.cache
      ? exports.cache[path] || (exports.cache[path] = exports.compile(str, options))
      : exports.compile(str, options);

    if (layout){
      options.content = tmpl(options)
      exports.renderFile(m[1], options, fn)
    } else {
      if (fn) { fn(null, tmpl(options)); } else { return tmpl(options); }
    }
  } catch (err) {
    if (fn) { fn(err); } else { throw err }
  }
};

/**
 * Render a Hamlet file at the given `path` and callback `fn(err, str)`.
 *
 * @param {String} path
 * @param {Object|Function} options or callback
 * @param {Function} fn
 * @api public
 */
exports.renderFile = function(path, options, fn){
  var key = path + ':string';

  if ('function' == typeof options) {
    fn = options, options = {}; 
  }

  try {
    options.filename = path;
    var str = options.cache
      ? exports.cache[key] || (exports.cache[key] = fs.readFileSync(path, 'utf8'))
      : fs.readFileSync(path, 'utf8');
    exports.render(str, options, fn);
  } catch (err) {
    fn(err);
  }
};

/**
 * Express support.
 */
exports.__express = exports.renderFile;
