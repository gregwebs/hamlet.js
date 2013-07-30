// Generated by CoffeeScript 1.6.3
var assert, express, handle;

express = require('../hamlet').__express;

assert = function(equality, msg) {
  if (!equality) {
    console.log(msg);
    if (process && process.exit) {
      return process.exit(1);
    }
  }
};

handle = function(err, result) {
  var expected;
  if (err) {
    throw new Error(err);
  }
  expected = "<div><p>In the layout </p> </div>";
  return assert(result === expected, "FAIL: expected: " + expected + "\ngot: " + result);
};

express('test/wrapped.hamlet', {}, handle);
