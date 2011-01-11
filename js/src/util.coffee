fs = require 'fs'
path = require 'path'


getFilePaths = (dir, suffix, fpaths=[])->
  if fs.statSync(dir).isFile()
    return [dir]
  for fname in fs.readdirSync(dir)
    fpath = path.join(dir, fname)
    file = fs.statSync(fpath)
    if file.isDirectory()
      getFilePaths(fpath, suffix, fpaths)
    else if fpath[fpath.length-suffix.length ... fpath.length] == suffix
      fpaths.push fpath
  fpaths

this.getFilePaths = getFilePaths


this.getFileSources = (dir, suffix)->
  new FileSource(fpath) for fpath in getFilePaths(dir, suffix)


class FileSource
  constructor: (@path)->
  read: (encoding='utf-8')-> fs.readFileSync(@path, encoding)


