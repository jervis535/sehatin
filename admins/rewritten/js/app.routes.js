(function () {
  'use strict';

  angular
    .module('adminApp')
    .config(appConfig)
    .run(appRun);

  appConfig.$inject = ['$routeProvider', '$locationProvider'];
  function appConfig($routeProvider, $locationProvider) {
    $routeProvider
      // ─── Register Route (no auth required) ───
      .when('/register', {
        templateUrl:  'templates/register.html',
        controller:   'RegisterController',
        controllerAs: 'vm',
        requiresAuth: false
      })

      // ─── Login Route (no auth required) ───
      .when('/login', {
        templateUrl:  'templates/login.html',
        controller:   'LoginController',
        controllerAs: 'vm',
        requiresAuth: false
      })

      // ─── Verify Route (requires auth) ───
      .when('/verify', {
        templateUrl:  'templates/verify.html',
        controller:   'VerifyController',
        controllerAs: 'vm',
        requiresAuth: true,
        minLevel: 1   // both level 1 & level 2 can go, but content is hidden per level
      })

      // ─── Chart Route (requires auth) ───
      .when('/chart', {
        templateUrl:  'templates/chart.html',
        controller:   'ChartController',
        controllerAs: 'vm',
        requiresAuth: true,
        minLevel: 2
      })
      .when('/staff-activity', {
        templateUrl:  'templates/staff-activity.html',
        controller:   'StaffActivityController',
        controllerAs: 'vm',
        requiresAuth: true,
        minLevel:     2
      })
      .when('/staff-reviews', {
        templateUrl:  'templates/staff-reviews.html',
        controller:   'StaffReviewController',
        controllerAs: 'vm',
        requiresAuth: true,
        minLevel:     2
      })

      // ─── All other routes → redirect to /login ───
      .otherwise({
        redirectTo: '/login'
      });

    $locationProvider.hashPrefix('!');
  }

  appRun.$inject = ['$rootScope', '$location', 'AuthService'];
  function appRun($rootScope, $location, AuthService) {
    // Sidebar "active" helper remains the same
    $rootScope.isActive = function (viewLocation) {
      return viewLocation === $location.path();
    };

    // On every route change, block if requiresAuth && not authenticated
    $rootScope.$on('$routeChangeStart', function (event, next, current) {
      if (next.$$route && next.$$route.requiresAuth) {
        if (!AuthService.isAuthenticated()) {
          event.preventDefault();
          $location.path('/login');
        }
      }
            // If route defines a minLevel, ensure user meets it
      if (next.$$route && next.$$route.minLevel) {
        const userLevel = parseInt(AuthService.getLevel(), 10);
        if (isNaN(userLevel) || userLevel < next.$$route.minLevel) {
          // Not authorized for this route
          event.preventDefault();
          // If they’re level 1 but trying to see /chart, send them to /verify
          if (userLevel === 1) {
            $location.path('/verify');
          } else {
            $location.path('/login');
          }
          return;
        }
      }

      // If already logged in and goes to /login or /register, redirect to /chart
      if (next.$$route && (next.$$route.originalPath === '/login' || next.$$route.originalPath === '/register')) {
        if (AuthService.isAuthenticated()) {

            const lvl = parseInt(AuthService.getLevel(), 10);
            if (lvl === 2) {
                event.preventDefault();
                $location.path('/chart');
            } else if (lvl === 1) {
                event.preventDefault();
                $location.path('/verify');
          }
        }
      }
    });
  }
})();