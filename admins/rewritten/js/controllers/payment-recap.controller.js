(function () {
  'use strict';

  angular
    .module('adminApp')
    .controller('PaymentsRecapController', PaymentsRecapController);

  PaymentsRecapController.$inject = ['ApiService'];
  function PaymentsRecapController(ApiService) {
    const vm = this;
    vm.mode      = 'daily';   // 'daily' or 'monthly'
    vm.dataRows  = [];
    vm.loading   = false;
    vm.error     = '';

    vm.switchMode = switchMode;

    init();

    function init() {
      loadRecap(vm.mode);
    }

    function switchMode(mode) {
      if (vm.mode === mode) return;
      vm.mode = mode;
      loadRecap(mode);
    }

    function loadRecap(mode) {
      vm.loading = true;
      vm.error   = '';
      vm.dataRows = [];

      const p = mode === 'daily'
        ? ApiService.getDailyPayments()
        : ApiService.getMonthlyPayments();

      p.then(rows => vm.dataRows = rows)
       .catch(() => vm.error = 'Failed to load data.')
       .finally(() => vm.loading = false);
    }
  }
})();
