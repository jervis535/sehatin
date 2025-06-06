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
          const staffPlaceholders = filteredDoctors.map(d => ({
            staffId:      d.user_id,        // assuming doctor table has user_id (or id)
            name:         d.name || d.username || `Dr. ${d.user_id}`, // whatever your backend returns
            role:         'doctor'
          }))
          .concat(
            filteredServices.map(s => ({
              staffId:    s.user_id,       // or s.id, whichever is unique identifier
              name:       s.name || s.username || `CS ${s.user_id}`,
              role:       'customer_service'
            }))
          );

          // 3) For each entry, fetch day+month counts in parallel
          return $q.all(staffPlaceholders.map(staff => {
            return $q.all({
              daily:   ApiService.getChannelCount(staff.staffId, 'day'),
              monthly: ApiService.getChannelCount(staff.staffId, 'month')
            }).then(({ daily, monthly }) => ({
              staffId:       staff.staffId,
              name:          staff.name,
              role:          staff.role,
              dailyCounts:   daily.data || [],
              monthlyCounts: monthly.data || []
            }));
          }));
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
