(function(){
  'use strict';
  angular
    .module('adminApp')
    .controller('DailyChatsController', DailyChatsController);

  DailyChatsController.$inject = [];
  function DailyChatsController() {
    const vm = this;

    // Fake data mirip dari database
    vm.dailyCounts = [
      { date: '2025-06-10', count: 5 },
      { date: '2025-06-11', count: 3 },
      { date: '2025-06-12', count: 7 },
    ];

    // Render Chart
    renderChart(vm.dailyCounts);

    function renderChart(data) {
      const ctx = document.getElementById('chatChart').getContext('2d');
      const labels = data.map(d => d.date);
      const counts = data.map(d => d.count);

      new Chart(ctx, {
        type: 'bar',
        data: {
          labels: labels,
          datasets: [{
            label: 'Total Chats',
            data: counts,
            backgroundColor: 'rgba(54, 162, 235, 0.7)',
            borderColor: 'rgba(54, 162, 235, 1)',
            borderWidth: 1
          }]
        },
        options: {
          scales: {
            y: {
              beginAtZero: true,
              ticks: {
                precision: 0
              }
            }
          }
        }
      });
    }
  }
})();
