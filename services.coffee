angular.module 'Goose'
.directive 'vedAccreditationForm', ['$http', ($http) ->
  scope: true
  link: (scope, element, attr) ->
    scope.eventSlug = attr.vedAccreditationFormEventSlug
    scope.send = () ->
      if scope.rules
        $http.post "/scripts/events/#{scope.eventSlug}/request_accreditations", { attributes: scope.attributes }
        .then (response) ->
          console.log response
          scope.currentTab += 1

]
.directive 'smoothScroll', ['$log', '$timeout', '$window', ($log, $timeout, $window) ->
#  May the Math be with you
  easing = (t, b, c, d) ->
    t /= d/2;
    if (t < 1)
      return c/2*t*t + b
    t-=1
    return -c/2 * (t*(t-2) - 1) + b

  elmYPosition = (eID) ->
    elm = document.getElementById(eID)
    if elm
      y = elm.offsetTop
      node = elm
      while node.offsetParent and node.offsetParent isnt document.body
        node = node.offsetParent
        y += node.offsetTop
      return y
    0
  requestAnimFrame = (() ->
    return  window.requestAnimationFrame || window.webkitRequestAnimationFrame ||
        window.mozRequestAnimationFrame || (callback) -> window.setTimeout(callback, 1000 / 60)
  )()

  scrollTo = (element, offset, callback, duration = 500) ->
    to = elmYPosition(element) - offset
    move = (amount) ->
      document.documentElement.scrollTop = amount
      document.body.parentNode.scrollTop = amount
      document.body.scrollTop = amount

    position = () ->
      return document.documentElement.scrollTop || document.body.parentNode.scrollTop || document.body.scrollTop

    start = position()
    change = to - start
    currentTime = 0
    increment = 20

    animateScroll = () ->

      currentTime += increment;
      val = easing(currentTime, start, change, duration);
      move(val)
      if (currentTime < duration)
        requestAnimFrame(animateScroll)
      else
        if (callback && typeof(callback) == 'function')
          callback()

    animateScroll()

  restrict: 'A'
  link: (scope, element, attr) ->
    element.bind 'click', ->
      if attr.target
        offset = attr.offset or 30
        scrollTo(attr.target, offset, null, 1000)
      else
        $log.warn 'Smooth scroll: no target specified'
]

# NUM2STR FILTER
.filter 'num2str', ()->
  return (n, text_forms)->
    n2 = Math.abs(n) % 100
    n1 = n % 10
    if (n2 > 10 && n2 < 20)
      return "#{n} #{text_forms[2]}"
    if (n1 > 1 && n1 < 5)
      return "#{n} #{text_forms[1]}"
    if (n1 == 1)
      return "#{n} #{text_forms[0]}"
    return "#{n} #{text_forms[2]}"

# SEARCH FACTORY
.factory 'Search', ['$http', '$httpParamSerializer', ($http, $httpParamSerializer)->
  find: (params, page='index') ->
    $http.get("/scripts/pages/#{page}?#{$httpParamSerializer(params)}")

]

# PRINT FACTORY

.factory 'Print', ['$timeout', ($timeout) ->
  print: (node, options = {}) ->

    defaults =
#      show the iframe for debugging
      debug: false
#    import parent page css
      importCSS: true
#    import style tags
      importStyle: false
#    print outer container/$.selector
      printContainer: false
#    load an additional css file - load multiple stylesheets with an array []
      loadCSS: ""
#    add title to print page
      pageTitle: ""
#    remove all inline styles
      removeInline: false
#    variable print delay
      printDelay: 333
#    prefix to html
      header: null
#    preserve input/form values
      formValues: true
#    html doctype
      doctypeString: '<!DOCTYPE html>'

    opt = angular.extend({}, defaults, options)
    $element = angular.element(node)
    strFrameName = "printThis-" + (new Date()).getTime()

    if (window.location.hostname != document.domain && navigator.userAgent.match(/msie/i))
      # Ugly IE hacks due to IE not inheriting document.domain from parent
      # checks if document.domain is set by comparing the host name against document.domain
      iframeSrc = "javascript:document.write(\"<head><script>document.domain=\\\" #{document.domain}\\\";</script></head><body></body>\")"
      printI = document.createElement('iframe')
      printI.name = "printIframe"
      printI.id = strFrameName
      printI.className = "MSIE"
      document.body.appendChild(printI)
      printI.src = iframeSrc

    else
      #other browsers inherit document.domain, and IE works if document.domain is not explicitly set
      $frame = angular.element("<iframe id='" + strFrameName + "' name='printIframe' />")
      angular.element(document.body).append($frame)

    $iframe = angular.element(document.getElementById(strFrameName))

    #show frame if in debug mode
    if (!opt.debug)
      $iframe.css(
        position: "absolute"
        width: "0px"
        height: "0px"
        left: "-600px"
        top: "-600px"
      )
    #$iframe.ready() and $iframe.load were inconsistent between browsers
    $timeout(() ->
      #Add doctype to fix the style difference between printing and render
      setDocType = ($iframe, doctype) ->
        win = $iframe[0]
        win = win.contentWindow || win.contentDocument || win
        doc = win.document || win.contentDocument || win
        doc.open()
        doc.write(doctype)
        doc.close()
      if (opt.doctypeString)
        setDocType($iframe,opt.doctypeString)
      $doc = $iframe.contents()
      $head = $doc.find("head")
      $body = $doc.find("body")
      #add base tag to ensure elements use the parent domain
      $head.append('<base href="' + document.location.protocol + '//' + document.location.host + '">')

#      TODO translate into coffee+angular
#      if (opt.importCSS) $("link[rel=stylesheet]").each(function() {
#        var href = $(this).attr("href");
#        if (href) {
#        var media = $(this).attr("media") || "all";
#          $head.append("<link type='text/css' rel='stylesheet' href='" + href + "' media='" + media + "'>")
#        }
#      });

      #add title of the page
      if (opt.pageTitle)
        $head.append("<title>" + opt.pageTitle + "</title>")

      #    TODO import additional stylesheet(s)
      #    if (opt.loadCSS) {
      #      if( $.isArray(opt.loadCSS)) {
      #        jQuery.each(opt.loadCSS, function(index, value) {
      #          $head.append("<link type='text/css' rel='stylesheet' href='" + this + "'>");
      #        });
      #      } else {
      #        $head.append("<link type='text/css' rel='stylesheet' href='" + opt.loadCSS + "'>");
      #      }
      #    }

      #print header
      if (opt.header)
        $body.append(opt.header)
      #grab $.selector as container
      if (opt.printContainer)
        $body.append($element.parent().clone())
      #otherwise just print interior elements of container
      else
        angular.forEach($element, (value) ->
          $body.append(angular.element(value).html())
        )

      #capture form/field values
      $timeout(() ->
        if ($iframe.hasClass("MSIE"))
          #check if the iframe was created with the ugly hack
          #and perform another ugly hack out of neccessity
          window.frames["printIframe"].focus();
          $head.append("<script>  window.print(); </script>");
        else
#         proper method
          if (document.queryCommandSupported("print"))
            $iframe[0].contentWindow.document.execCommand("print", false, null);
          else
            $iframe[0].contentWindow.focus();
            $iframe[0].contentWindow.print();


#        remove iframe after print
        if (!opt.debug)
            setTimeout(() ->
              $iframe.remove()
            ,1000)
      , opt.printDelay)
    , 333)
]