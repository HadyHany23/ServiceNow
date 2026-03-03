app.service("UserService", function ($http) {
  const API_URL = "https://spnuxpfrtluagbirquiv.supabase.co/rest/v1/users";

  const config = {
    headers: {
      apikey: "sb_publishable_iBx7OvsnV3GiQw4FKLhWKA_p4QpRnKo",
      Authorization: "Bearer sb_publishable_iBx7OvsnV3GiQw4FKLhWKA_p4QpRnKo",
      "Content-Type": "application/json",
    },
  };

  this.getUsers = function () {
    return $http.get(API_URL, config);
  };

  this.createUser = function (user) {
    return $http.post(API_URL, user, config);
  };

  this.updateUser = function (user) {
    return $http.patch(API_URL + "?id=eq." + user.id, user, config);
  };

  this.getUserId = function (id) {
    return $http.get(API_URL + "?id=eq." + id, config);
  };

  this.deleteUser = function (id) {
    return $http.delete(API_URL + "?id=eq." + id, config);
  };
});
