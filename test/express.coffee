express = require('../hamlet').__express

handle = (err, str) ->
  console.log(err)
  console.log(str)

express('test/wrapped.hamlet', {}, handle) # == "<div><p>In the layout</p>\n</div>") 
