(function () {
  'use strict';

  angular
    .module('adminApp')
    .factory('ApiService', ApiService);

  ApiService.$inject = ['$http'];
  function ApiService($http) {
    const BASE_URL = 'http://localhost:3000';

    return {
      // POI endpoints
      getUnverifiedPois: getUnverifiedPois,
      verifyPoi:        verifyPoi,
      deletePoi:        deletePoi,

      // Doctor endpoints
      getUnverifiedDoctors: getUnverifiedDoctors,
      verifyDoctor:         verifyDoctor,
      deleteDoctor:         deleteDoctor,

      // Customer Service endpoints
      getUnverifiedCustomerServices: getUnverifiedCustomerServices,
      verifyCustomerService:         verifyCustomerService,
      deleteCustomerService:         deleteCustomerService,

      // Auxiliaries
      fetchUserInfo:    fetchUserInfo,
      fetchPoiName:     fetchPoiName,
      fetchEvidenceImage: fetchEvidenceImage,
      fetchAdminInfo:      fetchAdminInfo,
      getAllAdmins:                  getAllAdmins,

      createPoi:                   createPoi,
      createAdmin:                 createAdmin,
      // ─── NEW staff‐listing endpoints ───
      getAllDoctors:                 getAllDoctors,                 // GET /doctors
      getAllCustomerServices:        getAllCustomerServices,        // GET /customerservices

      // ─── NEW channels_count endpoints ───
      getChannelCount:               getChannelCount,               // GET /channels_count?staff_id=&period=

      // ─── NEW reviews endpoint ───
      getReviewsForStaff:            getReviewsForStaff,
      getAdminById:        getAdminById,       // GET /admins/:id
      updateAdmin:         updateAdmin,        // PUT /admins/:id
      getPoiById:          getPoiById,         // GET /pois/:id
      updatePoi:           updatePoi,          // PUT /pois/:id
      getAllChannels:        getAllChannels,
      getAllDoctors:         getAllDoctors,
      getAllCustomerServices:getAllCustomerServices,
      changeAdminPassword:changeAdminPassword,
      getDailyPayments:   getDailyPayments,   // GET /payments/daily
      getMonthlyPayments: getMonthlyPayments  // GET /payments/monthly
      
    };


    function getAdminById(id) {
      return $http.get(`${BASE_URL}/admins/${id}`)
                  .then(r => r.data);
    }
    function updateAdmin(id, payload) {
      return $http.put(`${BASE_URL}/admins/${id}`, payload)
                  .then(r => r.data);
    }
    function getPoiById(id) {
      return $http.get(`${BASE_URL}/pois/${id}`)
                  .then(r => r.data);
    }
    function updatePoi(id, payload) {
      return $http.put(`${BASE_URL}/pois/${id}`, payload)
                  .then(r => r.data);
    }
    
    // ——— POIs ———
    function getUnverifiedPois() {
      return $http
        .get(`${BASE_URL}/pois?verified=false`)
        .then(res => res.data);
    }
    function verifyPoi(id) {
      return $http
        .put(`${BASE_URL}/pois/verify/${id}`)
        .then(res => res.data);
    }
    function deletePoi(id) {
      return $http
        .delete(`${BASE_URL}/pois/${id}`)
        .then(res => res.data);
    }

    // ——— Doctors ———
    function getUnverifiedDoctors() {
      return $http
        .get(`${BASE_URL}/doctors?verified=false`)
        .then(res => res.data);
    }
    function verifyDoctor(userId) {
      return $http
        .put(`${BASE_URL}/doctors/verify/${userId}`)
        .then(res => res.data);
    }
    function deleteDoctor(userId) {
      return $http
        .delete(`${BASE_URL}/users/${userId}`)
        .then(res => res.data);
    }

    // ——— Customer Services ———
    function getUnverifiedCustomerServices() {
      console.log(`${BASE_URL}/customerservices?verified=false`)
      return $http
        .get(`${BASE_URL}/customerservices?verified=false`)
        .then(res => res.data);
    }
    function verifyCustomerService(userId) {
      return $http
        .put(`${BASE_URL}/customerservices/verify/${userId}`)
        .then(res => res.data);
    }
    function deleteCustomerService(userId) {
      return $http
        .delete(`${BASE_URL}/users/${userId}`)
        .then(res => res.data);
    }

    // ——— Auxiliaries ———
    function fetchUserInfo(userId) {
      return $http
        .get(`${BASE_URL}/users/${userId}`)
        .then(res => res.data);
    }
    function fetchPoiName(poiId) {
      return $http
        .get(`${BASE_URL}/pois/${poiId}`)
        .then(res => res.data.name);
    }
    function fetchEvidenceImage(userId) {
      return $http
        .get(`${BASE_URL}/evidences/${userId}`)
        .then(res => {
          // Expecting { image: "<base64-string>" }
          return res.data.image || null;
        })
        .catch(() => {
          // If no evidence or 404, just return null, don’t break the promise chain
          return null;
        });
    }
    function createPoi(poiData) {
      // poiData should be { name, category, address, latitude, longitude }
      return $http
        .post(`${BASE_URL}/pois`, poiData)
        .then(res => res.data);
    }

    // Create a new Admin (given the returned poi_id from createPoi)
    function createAdmin(adminData) {
      // adminData should be { poi_id, telno, email, level, password }
      return $http
        .post(`${BASE_URL}/admins`, adminData)
        .then(res => res.data);
    }
    // ─── NEW: GET /admins/:id ───
    function fetchAdminInfo(adminId) {
      return $http.get(`${BASE_URL}/admins/${adminId}`).then(res => res.data);
    }

    function getAllAdmins() {
      return $http
        .get(`${BASE_URL}/admins`)
        .then(res => res.data);
    }

     // ─── NEW: Return all doctors (assumes your backend exposes GET /doctors) ───
    function getAllDoctors() {
      return $http.get(`${BASE_URL}/doctors`).then(res => res.data);
    }

    // ─── NEW: Return all customer‐service staff (GET /customerservices) ───
    function getAllCustomerServices() {
      return $http.get(`${BASE_URL}/customerservices`).then(res => res.data);
    }

    // ─── NEW: Get chat counts (day or month) for a given staff_id ───
    function getChannelCount(staffId = '', period = 'day', type = '') {
      let url = `${BASE_URL}/channels_count?period=${period}`;

      // Append staff_id if provided
      if (staffId) {
        url += `&staff_id=${staffId}`;
      }

      // Append type if provided
      if (type) {
        url += `&type=${type}`;
      }

      return $http
        .get(url)
        .then(res => {
          // Return the 'data' property from the response if it's an array
          if (res.data && Array.isArray(res.data.data)) {
            return res.data.data;  // Extract and return the actual array of data
          } else {
            // If it's not in the expected format, return an empty array
            console.error('Invalid API response:', res.data);
            return [];
          }
        })
        .catch(error => {
          console.error('Error in API request:', error);
          return [];  // Return an empty array on error to avoid breaking the controller
        });
    }


    // ─── NEW: Get all reviews where reviewee_id = staffId ───
    function getReviewsForStaff(staffId) {
      return $http
        .get(`${BASE_URL}/reviews?reviewee_id=${staffId}`)
        .then(res => res.data);
    }
    function getAllChannels() {
      return $http
        .get(`${BASE_URL}/channels?all=true`)
        .then(r => r.data);
    }

    function changeAdminPassword(adminId, oldpass, newpass) {
      return $http
        .put(`${BASE_URL}/admins/changepass/${adminId}`, { oldpass, newpass })
        .then(res => res.data);
    }

    function getDailyPayments() {
      return $http
        .get(`${BASE_URL}/payments/daily`)
        .then(res => res.data);
    }
    function getMonthlyPayments() {
      return $http
        .get(`${BASE_URL}/payments/monthly`)
        .then(res => res.data);
    }
  }
})();
