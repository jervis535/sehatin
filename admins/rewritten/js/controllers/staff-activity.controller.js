(function () {
  'use strict';

  angular
    .module('adminApp')
    .controller('StaffActivityController', StaffActivityController);

  StaffActivityController.$inject = ['ApiService', '$q', 'AuthService'];
  function StaffActivityController(ApiService, $q, AuthService) {
    const vm = this;

    vm.staffActivities = [];   // final array for ng‐repeat
    vm.loading = true;
    vm.errorMessage = '';

    // On load
    init();

    function init() {
      vm.loading = true;
      const poiIdStr = AuthService.getPoiId();
      const adminPoiId = parseInt(poiIdStr, 10);

      if (isNaN(adminPoiId)) {
        vm.errorMessage = 'Unable to determine your assigned POI.';
        vm.loading = false;
        return;
      }

      // 1) Fetch all doctors + CS in parallel
      $q.all({
        doctors: ApiService.getAllDoctors(),
        services: ApiService.getAllCustomerServices()
      })
        .then(({ doctors, services }) => {
          // 2) Filter only staff with matching poi_id
          const filteredDoctors = doctors.filter(d => parseInt(d.poi_id, 10) === adminPoiId);
          const filteredServices = services.filter(s => parseInt(s.poi_id, 10) === adminPoiId);

          // Build an array of “staffEntry” placeholders
          const staffPlaceholders = filteredDoctors.map(d => {
            // Fetch real name for doctor from user info
            return ApiService.fetchUserInfo(d.user_id).then(user => ({
              staffId: d.user_id,
              name: user.username || `Dr. ${d.user_id}`,  // Use real name from the user table
              role: 'doctor'
            }));
          })
          .concat(
            filteredServices.map(s => {
              // Fetch real name for customer service staff from user info
              return ApiService.fetchUserInfo(s.user_id).then(user => ({
                staffId: s.user_id,
                name: user.username || `CS ${s.user_id}`,  // Use real name from the user table
                role: 'customer_service'
              }));
            })
          );

          // 3) For each entry, fetch day+month counts in parallel
          return $q.all(staffPlaceholders).then(staffEntries => {
            return $q.all(staffEntries.map(staff => {
              return $q.all({
                daily: ApiService.getChannelCount(staff.staffId, 'day'),
                monthly: ApiService.getChannelCount(staff.staffId, 'month')
              }).then(({ daily, monthly }) => ({
                staffId: staff.staffId,
                name: staff.name,
                role: staff.role,
                dailyCounts: daily || [],
                monthlyCounts: monthly || []
              }));
            }));
          });
        })
        .then(results => {
          vm.staffActivities = results;
          vm.loading = false;
        })
        .catch(err => {
          console.error('Error loading staff activity:', err);
          vm.errorMessage = 'Failed to load staff activity.';
          vm.loading = false;
        });
    }
  }
})();
