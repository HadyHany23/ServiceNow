app.controller(
  "UserDetailsController",
  function ($scope, $routeParams, UserService) {
    $scope.userId = $routeParams.id;

    UserService.getUserId($scope.userId)
      .then(function (response) {
        $scope.user = response.data[0];
      })
      .catch(function (error) {
        console.log("Error loading users", error);
      });
  },
);
