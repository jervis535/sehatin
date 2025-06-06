(function () {
  'use strict';

  angular
    .module('adminApp')
    .controller('LoginController', LoginController);

  LoginController.$inject = ['AuthService', '$location'];
  function LoginController(AuthService, $location) {
    const vm = this;
    vm.email = '';
    vm.password = '';
    vm.errorMessage = '';

    vm.login = function () {
      vm.errorMessage = '';
      AuthService.login(vm.email, vm.password)
        .then(response => {
          // We only care about level; ignore poi_id here
          const level = AuthService.getLevel(); // string "1" or "2"

          if (level === '1') {
            // Level 1 admins always go to the POI‐verification page
            $location.path('/verify');
          } else if (level === '2') {
            // Level 2 admins always go to the Chart page
            $location.path('/chart');
          } else {
            // Should never happen if backend always returns a valid level
            vm.errorMessage = 'Invalid admin level returned. Please try again.';
            AuthService.logout();
          }
        })
        .catch(err => {
          if (err.status === 401) {
            vm.errorMessage = 'Invalid email or password';
          } else {
            vm.errorMessage = 'An error occurred. Please try again.';
          }
        });
    };
  }
})();
