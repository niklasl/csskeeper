jsdom = require 'jsdom'
cssom = require 'cssom'
jquery = require('jquery')
{size} = require 'underscore'


basename = (path)-> path.match(/[^/]+$/)[0]

#this.computeCssUsage

this.reportCssUsage = (sources, cssSources, log=console.log)->
  cssSheets = []

  for source in cssSources
    stylesheet = cssom.parse source.read()
    unusedSelectors = {}
    cssSheets.push
      name: basename(source.path)
      path: source.path
      stylesheet: stylesheet
      unusedSelectors: unusedSelectors
      used: false
    for rule in stylesheet.cssRules
      for selector in rule.selectorText.split(/,/)
        unusedSelectors[selector] = false

  log "Using local CSS files: #{(cs.name for cs in cssSheets).join(', ')}"

  for source in sources
    log "Using source: <#{source.path}>"
    data = source.read()
    window = jsdom.jsdom(data, null).createWindow()
    $ = jquery.create(window)
    cssNameRefs = []
    $('link[rel=stylesheet]').each(-> cssNameRefs.push basename $(@).attr('href'))

    for cssSheet in cssSheets
      if basename(cssSheet.path) not in cssNameRefs
        continue
      cssSheet.used = true
      unusedSelectors = cssSheet.unusedSelectors
      log "Checking selectors in #{cssSheet.name} (#{size(unusedSelectors)} remaining)"
      for sel of unusedSelectors
        try
          if $(sel).length
            log "  matched: #{sel} (#{$(sel).length} items)"
            delete unusedSelectors[sel]
        catch e
          if e.indexOf("Syntax error") > -1
            # .. unsupported pseudo-element in selector, e.g. :link, :hover, :content, :after..
            # TODO: filter at collect time instead? (and bookkeep fixed?)
            delete unusedSelectors[sel]
            fixedRule = sel.replace(/:\w+/g, "")
            if not $(fixedRule).length
              unusedSelectors[fixedRule] = false
          else
            log "  #{e} [for selector '#{sel}']"

  log()
  for cssSheet in cssSheets
    if not cssSheet.used
      log "Unused CSS: #{cssSheet.name}"
      continue
    log "#{size(cssSheet.unusedSelectors)} unused CSS selectors in #{cssSheet.name}:"
    for sel of cssSheet.unusedSelectors
      log "  #{sel.trim()}"
    log()

  log "Done!"


