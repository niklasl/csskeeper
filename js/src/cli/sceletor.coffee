#!/usr/bin/env coffee
{print} = require 'util'
{computeCssTree, output} = require '../tree'
{getFileSources} = require '../util'

this.run = ->
  [dir, suffix] = process.argv[2..]
  sources = getFileSources(dir, suffix)
  output(print, computeCssTree(sources), sources)

