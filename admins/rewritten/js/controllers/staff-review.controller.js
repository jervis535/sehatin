(function () {
  'use strict';

  angular
    .module('adminApp')
    .controller('StaffReviewController', StaffReviewController);

  StaffReviewController.$inject = ['ApiService', '$q', 'AuthService'];
  function StaffReviewController(ApiService, $q, AuthService) {
    const vm = this;

    vm.staffReviews = [];
    vm.loading = true;
    vm.errorMessage = '';

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

      // 1) Fetch all doctors + CS
      $q.all({
        doctors: ApiService.getAllDoctors(),
        services: ApiService.getAllCustomerServices()
      })
      .then(({ doctors, services }) => {
        // 2) Filter by poi_id
        const filteredDoctors = doctors.filter(d => parseInt(d.poi_id, 10) === adminPoiId);
        const filteredServices = services.filter(s => parseInt(s.poi_id, 10) === adminPoiId);

        // 3) Build placeholder array with real name fetching for each staff
        const staffPlaceholders = filteredDoctors.map(d => {
          // Fetch real name for doctor
          return ApiService.fetchUserInfo(d.user_id).then(user => ({
            staffId: d.user_id,
            name: user.username || `Dr. ${d.user_id}`,
            role: 'doctor'
          }));
        })
        .concat(
          filteredServices.map(s => {
            // Fetch real name for customer service staff
            return ApiService.fetchUserInfo(s.user_id).then(user => ({
              staffId: s.user_id,
              name: user.username || `CS ${s.user_id}`,
              role: 'customer_service'
            }));
          })
        );

        // 4) After fetching the real names, fetch reviews for each staff member
        return $q.all(staffPlaceholders).then(staffEntries => {
          return $q.all(staffEntries.map(staff => {
            return ApiService.getReviewsForStaff(staff.staffId)
              .then(reviews => ({
                staffId: staff.staffId,
                name: staff.name,
                role: staff.role,
                reviews: reviews // array of review objects
              }));
          }));
        });
      })
      .then(results => {
        vm.staffReviews = results;
        vm.loading = false;
      })
      .catch(err => {
        console.error('Error loading staff reviews:', err);
        vm.errorMessage = 'Failed to load staff reviews.';
        vm.loading = false;
      });
    }
  }
})();
