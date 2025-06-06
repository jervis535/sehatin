(function () {
  'use strict';

  angular
    .module('adminApp')
    .controller('VerifyController', VerifyController);

    VerifyController.$inject = ['ApiService', '$q', 'AuthService'];
    function VerifyController(ApiService, $q, AuthService) {
    const vm = this;
    vm.pois = [];
    vm.doctors = [];
    vm.customerServices = [];

    // Admin level (1 or 2)
    vm.adminLevel = parseInt(AuthService.getLevel(), 10);
        // Read the admin’s POI ID (string) and convert to number
    vm.adminPoiId = parseInt(AuthService.getPoiId(), 10) || -1;  // NaN → -1 for safety

    // Expose methods
    vm.refreshAll              = refreshAll;
    vm.verifyPoi               = verifyPoi;
    vm.denyPoi                 = denyPoi;
    vm.verifyDoctor            = verifyDoctor;
    vm.denyDoctor              = denyDoctor;
    vm.verifyCustomerService   = verifyCustomerService;
    vm.denyCustomerService     = denyCustomerService;

    // On init, load data
    refreshAll();

    function refreshAll() {
      // ─── POIs + attach admin contact ───
      // 1) Get unverified POIs
      // 2) Get all admins
      // 3) For each POI, find admin with admin.poi_id === poi.id

      $q.all({
        pois: ApiService.getUnverifiedPois(),
        admins: ApiService.getAllAdmins()
      })
      .then(({ pois, admins }) => {
        // Filter only unverified POIs
        pois = pois.filter(poi => !poi.verified);

        // Map each POI to include adminTel & adminEmail
        const augmentedPois = pois.map(poi => {
          const admin = admins.find(a => a.poi_id === poi.id);
          return {
            id:          poi.id,
            name:        poi.name,
            category:    poi.category,
            address:     poi.address,
            latitude:    poi.latitude,
            longitude:   poi.longitude,
            adminTel:    admin ? admin.telno : 'N/A',
            adminEmail:  admin ? admin.email : 'N/A'
          };
        });

        vm.pois = augmentedPois;
      })
      .catch(err => console.error('Error loading POIs or Admins:', err));

      // ─── DOCTORS (unchanged) ───
      ApiService.getUnverifiedDoctors()
        .then(doctors => {
          doctors = doctors.filter(d => !d.verified && d.poi_id === vm.adminPoiId);
          return $q.all(
            doctors.map(item =>
              $q.all([
                ApiService.fetchUserInfo(item.user_id),
                ApiService.fetchPoiName(item.poi_id),
                ApiService.fetchEvidenceImage(item.user_id)
              ]).then(([userInfo, poiName, imageBase64]) => ({
                user_id:     item.user_id,
                poi_id:      item.poi_id,
                verified:    item.verified,
                username:    userInfo.username,
                email:       userInfo.email,
                telno:       userInfo.telno,
                poiName:     poiName,
                imageBase64: imageBase64
              }))
            )
          );
        })
        .then(augmentedDoctors => {
          vm.doctors = augmentedDoctors;
        })
        .catch(err => console.error('Error loading doctors:', err));

      // ─── CUSTOMER SERVICES (unchanged) ───
      ApiService.getUnverifiedCustomerServices()
        .then(services => {
          services = services.filter(s => !s.verified && s.poi_id === vm.adminPoiId);;
          return $q.all(
            services.map(item =>
              $q.all([
                ApiService.fetchUserInfo(item.user_id),
                ApiService.fetchPoiName(item.poi_id),
                ApiService.fetchEvidenceImage(item.user_id)
              ]).then(([userInfo, poiName, imageBase64]) => ({
                user_id:     item.user_id,
                poi_id:      item.poi_id,
                verified:    item.verified,
                username:    userInfo.username,
                email:       userInfo.email,
                telno:       userInfo.telno,
                poiName:     poiName,
                imageBase64: imageBase64
              }))
            )
          );
        })
        .then(augmentedServices => {
          vm.customerServices = augmentedServices;
        })
        .catch(err => console.error('Error loading customer services:', err));
    }

    // ─── VERIFY/DELETE handlers ───
    function verifyPoi(poiId) {
      ApiService.verifyPoi(poiId)
        .then(() => refreshAll())
        .catch(err => console.error('Error verifying POI:', err));
    }
    function denyPoi(poiId) {
      ApiService.deletePoi(poiId)
        .then(() => refreshAll())
        .catch(err => console.error('Error deleting POI:', err));
    }

    function verifyDoctor(userId) {
      ApiService.verifyDoctor(userId)
        .then(() => refreshAll())
        .catch(err => console.error('Error verifying doctor:', err));
    }
    function denyDoctor(userId) {
      ApiService.deleteDoctor(userId)
        .then(() => refreshAll())
        .catch(err => console.error('Error deleting doctor:', err));
    }

    function verifyCustomerService(userId) {
      ApiService.verifyCustomerService(userId)
        .then(() => refreshAll())
        .catch(err => console.error('Error verifying customer service:', err));
    }
    function denyCustomerService(userId) {
      ApiService.deleteCustomerService(userId)
        .then(() => refreshAll())
        .catch(err => console.error('Error deleting customer service:', err));
    }
  }
})();
