(function () {
  'use strict';

  angular
    .module('adminApp')
    .factory('AuthService', AuthService);

  AuthService.$inject = ['$http', '$window'];
  function AuthService($http, $window) {
    const BASE_URL = 'http://localhost:3000';
    const tokenKey    = 'adminToken';
    const levelKey    = 'adminLevel';
    const poiIdKey    = 'adminPoiId';

    return {
      login:           login,
      logout:          logout,
      getToken:        getToken,
      isAuthenticated: isAuthenticated,
      getLevel:        getLevel,
      getPoiId:        getPoiId
    };

    // ─── Attempt login; store token & level, and store poi_id only if not null ───
    function login(email, password) {
      return $http
        .post(`${BASE_URL}/admins/login`, { email, password })
        .then(res => {
          const token = res.data.token;
          const level = res.data.admin.level;    // e.g. 1 or 2
          const poiId = res.data.admin.poi_id;   // may be null for level 1

          if (token) {
            $window.localStorage.setItem(tokenKey, token);
            $window.localStorage.setItem(levelKey, level.toString());

            // Only store poi_id if it’s non‐null/defined
            if (poiId !== null && poiId !== undefined) {
              $window.localStorage.setItem(poiIdKey, poiId.toString());
            } else {
              // Remove any leftover value if the user was previously logged in with a POI
              $window.localStorage.removeItem(poiIdKey);
            }
          }
          return res.data;
        });
    }

    function logout() {
      $window.localStorage.removeItem(tokenKey);
      $window.localStorage.removeItem(levelKey);
      $window.localStorage.removeItem(poiIdKey);
    }

    function getToken() {
      return $window.localStorage.getItem(tokenKey);
    }
    function isAuthenticated() {
      return !!$window.localStorage.getItem(tokenKey);
    }
    function getLevel() {
      return $window.localStorage.getItem(levelKey);
    }
    function getPoiId() {
      // If nothing was stored, returns null
      return $window.localStorage.getItem(poiIdKey);
    }
  }
})();
