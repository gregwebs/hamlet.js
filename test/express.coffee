express = require('../hamlet').__express

assert = (equality, msg) ->
  unless equality
    console.log(msg)
    process.exit(1) if process && process.exit

handle = (err, result) ->
  if (err)
    throw new Error(err)
  expected = "<div><p>In the layout </p> </div>"
  assert(result == expected, "FAIL: expected: " + expected + "\ngot: " + result)

express('test/wrapped.hamlet', {}, handle)
