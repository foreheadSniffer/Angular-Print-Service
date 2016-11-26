# Angular-Print-Service
Lightweight angular module that allows you to print element on the page. No jQuery needed.


[Demo](https://foreheadsniffer.github.io/Angular-Print-Service/example/)

## How to use

```javascript
angular.module('app', ['angularPrint'])
.controller('exampleController', ['AngularPrint', function(AngularPrint) {
	AngularPrint(document.getElementById('printable'))
}])
```

## Options
``` javascript
AngularPrint(element, options)
```
Service accepts options as additional second parameter

| Option        | Value         | Details                                           |
| :------------ |:-------------:| :------------------------------------------------:|
| debug         | true/**false**    | keep iframe after printing|
| importCSS      | **true**/false      |   import parent page css |
| importStyle | true/**false**      |    import style tags |
| printContainer | true/**false**      |    print outer container/$.selector |
| loadCSS | *String* of *Array of strings*      |    load an additional css file |
| pageTitle | *String*      |    add title to print page |
| removeInline |  true/**false**  |  remove all inline styles |
| printDelay |  *Number*, default: **333**  |  variable print delay, ms |
| header |  *String*  | prefix to html  |
| formValues | **true**/false   |  preserve input/form values |

```javascript
AngularPrint(document.getElementById('print'), {
      debug: true
      importCSS: true
      importStyle: true,
      loadCSS: "https://fonts.googleapis.com/css?family=PT+Serif",
      pageTitle: "Printing",
      removeInline: true,
      formValues: true
});
```
