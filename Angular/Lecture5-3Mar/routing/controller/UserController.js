app.controller("UserController", function($scope, UserService){

    $scope.users = [];
    $scope.newUser = {};
    $scope.isEdit = false;
    $scope.loading = false;

    // LOAD USERS
    $scope.loadUsers = function(){
        $scope.loading = true;

        UserService.getUsers()
        .then(function(response){
            $scope.users = response.data;
        })
        .catch(function(error){
            console.log("Error loading users", error);
        })
        .finally(function(){
            $scope.loading = false;
        });
    };

    $scope.loadUsers();


    // ADD
    $scope.addUser = function(){
        UserService.createUser($scope.newUser)
        .then(function(){
            $scope.loadUsers();
            $scope.newUser = {};
        })
        .catch(function(error){
            console.log("Error creating user", error);
        });
    };


    // EDIT
    $scope.editUser = function(user){
        $scope.isEdit = true;
        $scope.newUser = angular.copy(user);
    };


    // UPDATE
    $scope.updateUser = function(){
        UserService.updateUser($scope.newUser)
        .then(function(){
            $scope.loadUsers();
            $scope.newUser = {};
            $scope.isEdit = false;
        })
        .catch(function(error){
            console.log("Error updating user", error);
        });
    };


    // DELETE
    $scope.deleteUser = function(id){
        if(!confirm("Are you sure?")) return;

        UserService.deleteUser(id)
        .then(function(){
            $scope.loadUsers();
        })
        .catch(function(error){
            console.log("Error deleting user", error);
        });
    };


    // CANCEL
    $scope.cancelEdit = function(){
        $scope.isEdit = false;
        $scope.newUser = {};
    };

});