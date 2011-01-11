
{spawn, exec} = require 'child_process'

SRC = 'js/src'
LIB = 'js/lib'


build = (cb)->
  console.log "Coffee compiling..."
  exec "rm -rf #{LIB} && coffee -c -l -b -o #{LIB} #{SRC}", (err, out)-> cb err

task 'build', "compile coffee to js", -> build onErrorExit


task 'watch', "continously compile coffee to js", ->
  cmd = spawn "coffee", ["-cw", "-o", LIB, SRC]
  cmd.stdout.on "data", (data)-> process.stdout.write data
  cmd.on "error", onErrorExit


onErrorExit = (err)->
  if err
    process.stdout.write "#{err.stack}\n"
    process.exit -1


