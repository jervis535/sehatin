(function(){
  'use strict';
  angular
    .module('adminApp')
    .controller('ChatsByPoiController', ChatsByPoiController);

  ChatsByPoiController.$inject = ['ApiService','$q'];
  function ChatsByPoiController(ApiService, $q) {
    const vm = this;
    vm.byPoi = []; // [{ poiId, name, count }...]

    init();

    function init() {
      // fetch channels + staff lists
      $q.all({
        channels: ApiService.getAllChannels(),
        doctors:  ApiService.getAllDoctors(),
        services: ApiService.getAllCustomerServices()
      })
      .then(({channels, doctors, services}) => {
        // build user→poi map, skipping users with null/undefined poi_id
        const poiMap = {};
        doctors.concat(services).forEach(u => {
          if (u.poi_id != null) {  // skip null or undefined
            poiMap[u.user_id] = u.poi_id;
          }
        });

        // count per poi_id
        const countMap = {};
        channels.forEach(ch => {
          [ch.user_id0, ch.user_id1].forEach(uid => {
            const pid = poiMap[uid];
            if (pid != null) { // only count if poi_id is valid
              countMap[pid] = (countMap[pid] || 0) + 1;
            }
          });
        });

        // format result
        vm.byPoi = Object.keys(countMap).map(pid => ({
          poiId: pid,
          name: `POI ${pid}`, 
          count: countMap[pid]
        }));
      })
      .catch(() => { vm.byPoi = []; });
    }
  }
})();
