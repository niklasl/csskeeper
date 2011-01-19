{filter, find, size} = require 'underscore'
jsdom = require 'jsdom'


DEFAULT_ID_SKIP_PATTERN = /[-_]\w*\d+\w*/
DEFAULT_GEN_ID_TOKEN = "-GEN_ID"


class NodeItem

  constructor: (@selector, @parent=null)->
    @sources = {}
    @children = []
    if @parent
      parent.children.push this

  add: (source, selector)->
    nodeItem = find(@children, (it)-> it.selector == selector) \
               ? new NodeItem(selector, this)
    nodeItem.sources[source.path] = source
    nodeItem


this.computeCssTree = (sources, idSkipPattern=DEFAULT_ID_SKIP_PATTERN, genIdToken=DEFAULT_GEN_ID_TOKEN)->
  idMasher = (id)-> id = id.replace idSkipPattern, genIdToken if idSkipPattern
  rootItem = new NodeItem
  for source in sources
    data = source.read()
    window = jsdom.jsdom(data, null).createWindow()
    root = find(window.document.childNodes, (node)-> node.nodeType == 1)
    buildItemPathTree(source, root, rootItem, idMasher)
  rootItem

buildItemPathTree = (source, node, parentItem, idMasher=null)->
  selector = node.tagName.toLowerCase()
  id = node.getAttribute('id')
  if id
    id = idMasher(id) if idMasher
    selector += "##{id}"

  classNames = node.getAttribute('class')
  if classNames
    selector += ('.'+s for s in classNames.split(/\s+/) when s).join("")

  current = parentItem.add(source, selector)
  for node in filter(node.childNodes, (node)-> node.nodeType == 1)
    buildItemPathTree(source, node, current, idMasher)
  return


this.output = output = (write, nodeItem, sources, indent=2, level=0, parentRatio=0)->
  if nodeItem.selector
    note = ""
    ratio = size(nodeItem.sources) / sources.length
    if ratio < 1.0 and ratio != parentRatio
      note = " /* in #{Math.round(ratio*100)}% */"
    write (' ' for i in [0...indent*level]).join('')
    write nodeItem.selector + note
    write "\n"
  else
    level = -1
  for it in nodeItem.children
    output(write, it, sources, indent, level+1, ratio)


