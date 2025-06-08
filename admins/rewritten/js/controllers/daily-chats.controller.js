(function(){
  'use strict';
  angular
    .module('adminApp')
    .controller('DailyChatsController', DailyChatsController);

  DailyChatsController.$inject = ['ApiService'];
  function DailyChatsController(ApiService) {
    const vm = this;
    vm.dailyCounts = []; // [{ date: '2025-06-01', count: 5 }, ...]

    init();

    function init() {
      ApiService.getAllChannels()
        .then(channels => {
          // group by date (YYYY-MM-DD)
          const map = {};
          channels.forEach(ch => {
            const date = ch.created_at.slice(0,10); // assume ISO timestamp
            map[date] = (map[date]||0) + 1;
          });
          vm.dailyCounts = Object.keys(map)
            .sort()
            .map(date => ({ date, count: map[date] }));
        })
        .catch(() => { vm.dailyCounts = []; });
    }
  }
})();
