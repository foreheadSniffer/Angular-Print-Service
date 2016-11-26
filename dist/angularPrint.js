angular.module('angularPrint', []).service('AngularPrint', [
  '$timeout', function($timeout) {
    return function(node, options) {
      var $element, $frame, $iframe, defaults, iframeSrc, opt, printI, strFrameName;
      if (options == null) {
        options = {};
      }
      defaults = {
        debug: false,
        importCSS: true,
        importStyle: false,
        printContainer: false,
        loadCSS: "",
        pageTitle: "",
        removeInline: false,
        printDelay: 333,
        header: null,
        formValues: true,
        doctypeString: '<!DOCTYPE html>'
      };
      opt = angular.extend({}, defaults, options);
      $element = angular.element(node);
      strFrameName = "printingAt-" + (new Date()).getTime();
      if (window.location.hostname !== document.domain && navigator.userAgent.match(/msie/i)) {
        iframeSrc = "javascript:document.write(\"<head><script>document.domain=\\\" " + document.domain + "\\\";</script></head><body></body>\")";
        printI = document.createElement('iframe');
        printI.name = "printIframe";
        printI.id = strFrameName;
        printI.className = "MSIE";
        document.body.appendChild(printI);
        printI.src = iframeSrc;
      } else {
        $frame = angular.element("<iframe id='" + strFrameName + "' name='printIframe' />");
        angular.element(document.body).append($frame);
      }
      $iframe = angular.element(document.getElementById(strFrameName));
      if (!opt.debug) {
        $iframe.css({
          position: "absolute",
          width: "0px",
          height: "0px",
          left: "-600px",
          top: "-600px"
        });
      }
      return $timeout(function() {
        var $body, $doc, $head, $input, $select, $textarea, setDocType;
        setDocType = function($iframe, doctype) {
          var doc, win;
          win = $iframe[0];
          win = win.contentWindow || win.contentDocument || win;
          doc = win.document || win.contentDocument || win;
          doc.open();
          doc.write(doctype);
          return doc.close();
        };
        if (opt.doctypeString) {
          setDocType($iframe, opt.doctypeString);
        }
        $doc = $iframe.contents();
        $head = $doc.find("head");
        $body = $doc.find("body");
        $head.append("<base href='" + document.location.protocol + "//" + document.location.host + "/" + document.location.pathname + "'>");
        if (opt.pageTitle) {
          $head.append("<title>" + opt.pageTitle + "</title>");
        }
        if (opt.importCSS) {
          angular.forEach(document.querySelectorAll("link[rel=stylesheet]"), function(elem) {
            var href, media;
            href = angular.element(elem).attr("href");
            if (href) {
              media = angular.element(elem).attr("media") || "all";
              return $head.append("<link type='text/css' rel='stylesheet' href='" + href + "' media='" + media + "'>");
            }
          });
        }
        if (opt.importStyle) {
          angular.forEach(document.querySelectorAll("style"), function(elem) {
            return $head.append(angular.element(elem).clone());
          });
        }
        if (opt.loadCSS) {
          if (angular.isArray(opt.loadCSS)) {
            angular.forEach(opt.loadCSS, function(href) {
              return $head.append("<link type='text/css' rel='stylesheet' href='" + href + "'>");
            });
          } else {
            $head.append("<link type='text/css' rel='stylesheet' href='" + opt.loadCSS + "'>");
          }
        }
        if (opt.header) {
          $body.append(opt.header);
        }
        if (opt.printContainer) {
          $body.append($element.parent().clone());
        } else {
          angular.forEach($element, function(value) {
            return $body.append(angular.element(value).html());
          });
        }
        if (opt.formValues) {
          $input = $element.find('input');
          if ($input.length) {
            angular.forEach($input, function(elem) {
              var $checker, $iframeInput, $name, $this, $value;
              $this = angular.element(elem);
              $name = $this.attr('name');
              $checker = elem.type && (elem.type.toLowerCase() === 'checkbox' || elem.type.toLowerCase() === 'radio');
              $iframeInput = angular.element($doc[0].querySelector('input[name="' + $name + '"]'));
              $value = $this.val();
              if (!$checker) {
                return $iframeInput.val($value);
              } else if (elem.checked) {
                if (elem.type && elem.type.toLowerCase() === 'checkbox') {
                  return $iframeInput.attr('checked', 'checked');
                } else if (elem.type && elem.type.toLowerCase() === 'radio') {
                  return $doc.find('input[name="' + $name + '"][value=' + $value + ']').attr('checked', 'checked');
                }
              }
            });
          }
          $select = $element.find('select');
          if ($select.length) {
            angular.forEach($select, function(select) {
              var $name, $this, $value;
              $this = angular.element(select);
              $name = $this.attr('name');
              $value = $this.val();
              return angular.element($doc[0].querySelector('select[name="' + $name + '"]')).val($value);
            });
          }
          $textarea = $element.find('textarea');
          if ($textarea.length) {
            angular.forEach($textarea, function(textarea) {
              var $name, $this, $value;
              $this = angular.element(textarea);
              $name = $this.attr('name');
              $value = $this.val();
              return angular.element($doc[0].querySelector('textarea[name="' + $name + '"]')).val($value);
            });
          }
        }
        if (opt.removeInline) {
          angular.forEach($doc[0].querySelectorAll('body *[style]'), function(elem) {
            return angular.element(elem).removeAttr('style');
          });
        }
        return $timeout(function() {
          if ($iframe.hasClass("MSIE")) {
            window.frames["printIframe"].focus();
            $head.append("<script>  window.print(); </script>");
          } else {
            if (document.queryCommandSupported("print")) {
              $iframe[0].contentWindow.document.execCommand("print", false, null);
            } else {
              $iframe[0].contentWindow.focus();
              $iframe[0].contentWindow.print();
            }
          }
          if (!opt.debug) {
            return setTimeout(function() {
              return $iframe.remove();
            }, 1000);
          }
        }, opt.printDelay);
      }, 333);
    };
  }
]);
