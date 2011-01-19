{getFileSources} = require '../util'
{print} = require 'util'
{basename} = require 'path'

this.run = ->
  {argv} = process
  cmd = commands[argv[2]]
  if not cmd
    console.log "USAGE: #{basename argv[1]} COMMAND [ARGS...]"
    console.log "COMMAND is one of: #{(k for k of commands).join(', ')}"
    process.exit 0
  cmd argv[3..]

commands =

  tree: (args)->
    {computeCssTree, output} = require '../tree'
    pathExpr = args[0]
    sources = getFileSources(pathExpr)
    console.log "Examining #{sources.length} sources..."
    cssTree = computeCssTree(sources)
    console.log "Selector tree:"
    output(print, cssTree, sources)

  usage: (args)->
    {reportCssUsage} = require '../cssuse'
    sources = getFileSources args[0]
    cssSources = args[1..].reduce(((res, expr)->
      res.concat getFileSources(expr)), [])
    reportCssUsage(sources, cssSources)

