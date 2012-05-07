fs = require 'fs'
path = require 'path'
glob = require 'glob'


getFilePaths = (expr, results=[], recurseFrom=null)->
  if expr.indexOf('*') is -1 and fs.statSync(expr).isFile()
    return [expr]

  if expr.indexOf('**') > -1
    [recurseFrom, expr] = expr.split(/\*\*./) # + sep

  for fpath in glob.sync(path.join(recurseFrom, expr))
    results.push(fpath)

  if recurseFrom
    for fname in fs.readdirSync(recurseFrom)
      fpath = path.join(recurseFrom, fname)
      if fs.statSync(fpath).isDirectory()
        getFilePaths(expr, results, fpath)

  results

this.getFilePaths = getFilePaths


this.getFileSources = (expr)->
  new FileSource(fpath) for fpath in getFilePaths(expr)


class FileSource
  constructor: (@path)->
  read: (encoding='utf-8')-> fs.readFileSync(@path, encoding)


