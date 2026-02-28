var app = angular.module("myApp", []);
app.controller("myCtrl", function ($scope) {
  console.log($scope.firstName);
  $scope.customeShow = function () {
    console.log("Button Clicked");
    $scope.result = "Welcome: " + $scope.email;
    alert($scope.email);
  };
});
