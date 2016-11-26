angular.module('app', ['angularPrint'])
.controller('exampleController', ['AngularPrint', function(AngularPrint) {
	this.selectDiv = function(selector) {
		var printable = document.querySelector(selector)
		AngularPrint(printable)
	}	
}])