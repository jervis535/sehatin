(function(){
  'use strict';
  angular
    .module('adminApp')
    .controller('ProfileController', ProfileController);

  ProfileController.$inject = ['AuthService','ApiService','$location'];
  function ProfileController(AuthService, ApiService, $location) {
    const vm = this;
    vm.admin               = {};
    vm.poi                 = {};
    vm.isLevel2            = AuthService.getLevel() === '2';
    vm.currentPasswordInfo = '';
    vm.currentPasswordPwd  = '';
    vm.currentPasswordPoi  = '';
    vm.newPassword         = '';
    vm.confirmPassword     = '';
    vm.errorMessage        = '';
    vm.successMessage      = '';

    vm.updatePersonalInfo = updatePersonalInfo;
    vm.updatePoiInfo      = updatePoiInfo;
    vm.updatePassword     = updatePassword;
    vm.logout             = () => {
      AuthService.logout();
      $location.path('/login');
    };

    init();

    function init() {
      const adminId = AuthService.getAdminId();
      ApiService.getAdminById(adminId)
        .then(a => {
          vm.admin.id    = a.id;
          vm.admin.email = a.email;
          vm.admin.telno = a.telno;
          vm.admin.level = a.level;
          if (vm.isLevel2 && a.poi_id) {
            return ApiService.getPoiById(a.poi_id)
                     .then(p => vm.poi = angular.copy(p));
          }
        })
        .catch(() => vm.errorMessage = 'Failed to load profile.');
    }

    // ─── PERSONAL INFO ─────────────────────────────────────────────────
    function updatePersonalInfo() {
      vm.errorMessage   = '';
      vm.successMessage = '';

      // 1) Re-authenticate
      AuthService.login(vm.admin.email, vm.currentPasswordInfo)
        .then(() => {
          // 2) Update admin info
          const payload = {
            poi_id: vm.isLevel2 ? vm.poi.id : null,
            telno:  vm.admin.telno,
            email:  vm.admin.email,
            level:  vm.admin.level
          };
          return ApiService.updateAdmin(vm.admin.id, payload);
        })
        .then(() => {
          vm.successMessage = 'Personal info updated.';
          vm.currentPasswordInfo = '';
        })
        .catch(err => {
          if (err.status === 401) {
            vm.errorMessage = 'Current password is incorrect.';
          } else {
            vm.errorMessage = 'Failed to update personal info.';
          }
        });
    }

    // ─── POI INFO (LEVEL 2) ────────────────────────────────────────────
    function updatePoiInfo() {
      vm.errorMessage   = '';
      vm.successMessage = '';

     // require the new, separate POI password
     if (!vm.currentPasswordPoi) {
       vm.errorMessage = 'Enter current password to update POI.';
       return;
     }

        AuthService.login(vm.admin.email, vm.currentPasswordPoi)
        .then(() => {
          const payload = {
            name:      vm.poi.name,
            category:  vm.poi.category,
            address:   vm.poi.address,
            latitude:  vm.poi.latitude,
            longitude: vm.poi.longitude
          };
          return ApiService.updatePoi(vm.poi.id, payload);
        })
        .then(() => {
          vm.successMessage = 'POI info updated.';
          vm.currentPasswordInfo = '';
        })
        .catch(err => {
          if (err.status === 401) {
            vm.errorMessage = 'Current password is incorrect.';
          } else {
            vm.errorMessage = 'Failed to update POI info.';
          }
        });
    }

    // ─── PASSWORD CHANGE ───────────────────────────────────────────────
    function updatePassword() {
      vm.errorMessage   = '';
      vm.successMessage = '';

      AuthService.login(vm.admin.email, vm.currentPasswordPwd)
        .then(() => {
          const payload = {
            poi_id:   vm.isLevel2 ? vm.poi.id : null,
            telno:    vm.admin.telno,
            email:    vm.admin.email,
            level:    vm.admin.level,
            password: vm.newPassword
          };
          return ApiService.updateAdmin(vm.admin.id, payload);
        })
        .then(() => {
          vm.successMessage = 'Password changed successfully.';
          vm.currentPasswordPwd = vm.newPassword = vm.confirmPassword = '';
        })
        .catch(err => {
          if (err.status === 401) {
            vm.errorMessage = 'Current password is incorrect.';
          } else {
            vm.errorMessage = 'Failed to change password.';
          }
        });
    }
  }
})();
