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
      getPoiId:        getPoiId,
      getAdminId:      getAdminId
    };

    function login(email, password) {
      return $http
        .post(`${BASE_URL}/admins/login`, { email, password })
        .then(res => {
          const admin = res.data.admin;
          const token = res.data.token;
          const level = res.data.admin.level;
          const poiId = res.data.admin.poi_id;

          if (token) {
            $window.localStorage.setItem(tokenKey, token);
            $window.localStorage.setItem(levelKey, level.toString());
            $window.localStorage.setItem('adminId', admin.id.toString());

            if (poiId !== null && poiId !== undefined) {
              $window.localStorage.setItem(poiIdKey, poiId.toString());
            } else {
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
      return $window.localStorage.getItem(poiIdKey);
    }
    function getAdminId() {
      return parseInt($window.localStorage.getItem('adminId'), 10);
    }
  }
})();
