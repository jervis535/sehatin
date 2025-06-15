(function () {
  'use strict';

  angular
    .module('adminApp')
    .controller('RegisterController', RegisterController);

  RegisterController.$inject = ['ApiService', '$location'];
  function RegisterController(ApiService, $location) {
    const vm = this;

    // A single form object to hold all fields
    vm.formData = {
      name: '',
      category: '',
      address: '',
      latitude: null,
      longitude: null,
      telno: '',
      email: '',
      level: '',
      password: ''
    };

    vm.errorMessage = '';
    vm.successMessage = '';

    vm.register = function () {
      vm.errorMessage = '';
      vm.successMessage = '';

      // 1) Create the POI
      const poiPayload = {
        name:       vm.formData.name,
        category:   vm.formData.category,
        address:    vm.formData.address,
        latitude:   parseFloat(vm.formData.latitude),
        longitude:  parseFloat(vm.formData.longitude)
      };

      ApiService.createPoi(poiPayload)
        .then(poiResponse => {
          // poiResponse is the POI object, including { id, name, ... }
          const newPoiId = poiResponse.id;

          // 2) Create the Admin using newPoiId
          const adminPayload = {
            poi_id:   newPoiId,
            telno:    vm.formData.telno,
            email:    vm.formData.email,
            level:    2,
            password: vm.formData.password
          };

          return ApiService.createAdmin(adminPayload);
        })
        .then(adminResponse => {
          // adminResponse contains { admin: { … }, token: '…' }
          vm.successMessage = 'Registration successful! You can now log in.';
          // Optionally: redirect to login page after a short delay
          // $location.path('/login');
        })
        .catch(err => {
          console.error('Error during registration:', err);
          // If the POI create succeeded but admin create failed, you may want to delete the POI, but for simplicity:
          if (err.data && err.data.error) {
            vm.errorMessage = err.data.error;
          } else {
            vm.errorMessage = 'An unexpected error occurred. Please try again.';
          }
        });
    };
  }
})();
