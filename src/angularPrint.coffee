angular.module 'angularPrint', []
.service 'AngularPrint', ['$timeout', ($timeout) ->
  (node, options = {}) ->
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
    strFrameName = "printingAt-" + (new Date()).getTime()

    if (window.location.hostname != document.domain && navigator.userAgent.match(/msie/i))
#     Ugly IE hacks due to IE not inheriting document.domain from parent
#     checks if document.domain is set by comparing the host name against document.domain
      iframeSrc = "javascript:document.write(\"<head><script>document.domain=\\\" #{document.domain}\\\";</script></head><body></body>\")"
      printI = document.createElement('iframe')
      printI.name = "printIframe"
      printI.id = strFrameName
      printI.className = "MSIE"
      document.body.appendChild(printI)
      printI.src = iframeSrc

    else
#     other browsers inherit document.domain, and IE works if document.domain is not explicitly set
      $frame = angular.element("<iframe id='" + strFrameName + "' name='printIframe' />")
      angular.element(document.body).append($frame)

    $iframe = angular.element(document.getElementById(strFrameName))

#   show frame if in debug mode
    if (!opt.debug)
      $iframe.css(
        position: "absolute"
        width: "0px"
        height: "0px"
        left: "-600px"
        top: "-600px"
      )
#   $iframe.ready() and $iframe.load were inconsistent between browsers
    $timeout(() ->
#     Add doctype to fix the style difference between printing and render
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
#     add base tag to ensure elements use the parent domain
      $head.append("<base href='#{document.location.protocol}//#{document.location.host}/#{document.location.pathname}'>")

#     add title of the page
      if (opt.pageTitle)
        $head.append("<title>" + opt.pageTitle + "</title>")


#     import stylesheets
#     TODO import additional stylesheet(s)
      if (opt.importCSS) 
        angular.forEach document.querySelectorAll("link[rel=stylesheet]"), (elem) ->
          href = angular.element(elem).attr("href")
          if (href)
              media = angular.element(elem).attr("media") || "all";
              $head.append("<link type='text/css' rel='stylesheet' href='" + href + "' media='" + media + "'>")
            
#     import style tags
      if (opt.importStyle) 
        angular.forEach document.querySelectorAll("style"), (elem) ->
          $head.append angular.element(elem).clone()


#     import additional stylesheet(s)
      if (opt.loadCSS) 
        if angular.isArray(opt.loadCSS)
          angular.forEach opt.loadCSS, (href) ->
            $head.append("<link type='text/css' rel='stylesheet' href='#{href}'>")
        else
          $head.append("<link type='text/css' rel='stylesheet' href='#{opt.loadCSS}'>")
        
#     print header
      if (opt.header)
        $body.append(opt.header)
#     grab $.selector as container
      if (opt.printContainer)
        $body.append($element.parent().clone())
#     otherwise just print interior elements of container
      else
        angular.forEach $element, (value) ->
          $body.append(angular.element(value).html())

      if (opt.formValues)
#       loop through inputs
        $input = $element.find('input')
        if ($input.length) 
          angular.forEach $input, (elem)->
            $this = angular.element elem
            $name = $this.attr('name')
            $checker = elem.type && (elem.type.toLowerCase() == 'checkbox' || elem.type.toLowerCase() == 'radio')
            $iframeInput = angular.element $doc[0].querySelector('input[name="' + $name + '"]')
            $value = $this.val()
            # TODO: Refactor with switch/when statement
            if (!$checker)
              $iframeInput.val($value)
            else if elem.checked
              if elem.type && elem.type.toLowerCase() == 'checkbox'
                $iframeInput.attr('checked', 'checked');
              else if elem.type && elem.type.toLowerCase() == 'radio'
                $doc.find('input[name="' + $name + '"][value=' + $value + ']').attr('checked', 'checked');
        
#       loop through selects
        $select = $element.find('select')
        if ($select.length)
            angular.forEach $select, (select) ->
              $this = angular.element(select)
              $name = $this.attr('name')
              $value = $this.val()
              angular.element($doc[0].querySelector('select[name="' + $name + '"]')).val($value)

#       loop through textareas
        $textarea = $element.find('textarea')
        if ($textarea.length)
            angular.forEach $textarea, (textarea) ->
              $this = angular.element(textarea)
              $name = $this.attr('name')
              $value = $this.val()
              angular.element($doc[0].querySelector('textarea[name="' + $name + '"]')).val($value)
    
#     remove inline styles
      if (opt.removeInline)
        angular.forEach $doc[0].querySelectorAll('body *[style]'), (elem) ->
          angular.element(elem).removeAttr('style')

      $timeout(() ->
        if ($iframe.hasClass("MSIE"))
#         check if the iframe was created with the ugly hack
#         and perform another ugly hack out of neccessity
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
              # resolving time
              $iframe.remove()
            ,1000)
      , opt.printDelay)
    , 333)
]
