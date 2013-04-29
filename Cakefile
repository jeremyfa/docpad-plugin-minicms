
{exec} = require 'child_process'

task 'build', 'Build project from src/*.coffee to out/*.js', ->
  exec 'rm -rf out', ->
      exec 'iced -I inline --compile --output out/ src/', (err, stdout, stderr) ->
        throw err if err
        console.log stdout + stderr
        exec 'cp -R src/static out/static', (err, stdout, stderr) ->
            throw err if err
            console.log stdout + stderr
