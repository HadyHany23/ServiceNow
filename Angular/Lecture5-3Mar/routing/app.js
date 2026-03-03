var app = angular.module("myApp", ["ngRoute"]);

app.config(function ($routeProvider) {
  $routeProvider
    .when("/users", {
      templateUrl: "views/users.html",
      controller: "UserController",
    })
    .when("/userdetails/:id", {
      templateUrl: "views/userDetails.html",
      controller: "UserDetailsController",
    })
    .when("/about", { templateUrl: "views/about.html" })
    .otherwise({ redirectTo: "/users" });
});
