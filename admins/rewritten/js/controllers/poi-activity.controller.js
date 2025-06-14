(function () {
  'use strict';

  angular
    .module('adminApp')
    .controller('PoiActivityController', PoiActivityController);

  PoiActivityController.$inject = ['ApiService', '$q', 'AuthService', '$timeout'];
  function PoiActivityController(ApiService, $q, AuthService, $timeout) {
    const vm = this;

    // Initialize counts
    vm.historicalData = [];
    vm.chartData = [];
    vm.chartLabels = [];

    // Dropdown selections
    vm.selectedType = 'consultation'; // Default to consultation
    vm.selectedPeriod = 'day'; // Default to daily
    vm.selectedDays = 7; // Default to showing last 7 days/weeks/months

    vm.loading = true;
    vm.errorMessage = '';

    // On load
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

      // 1) Fetch all doctors + CS in parallel
      $q.all({
        doctors: ApiService.getAllDoctors(),
        services: ApiService.getAllCustomerServices()
      })
        .then(({ doctors, services }) => {
          // 2) Filter only staff with matching poi_id
          const filteredDoctors = doctors.filter(d => parseInt(d.poi_id, 10) === adminPoiId);
          const filteredServices = services.filter(s => parseInt(s.poi_id, 10) === adminPoiId);

          // Build an array of staff IDs
          const staffIds = filteredDoctors.map(d => d.user_id)
            .concat(filteredServices.map(s => s.user_id));

          // 3) Fetch historical data for each staff member
          return $q.all(staffIds.map(staffId => {
            return ApiService.getChannelCount(staffId, vm.selectedPeriod, vm.selectedType);
          }));
        })
        .then(results => {
          // 4) Process and aggregate the historical data
          processHistoricalData(results);
          updateChartData();
          vm.loading = false;
        })
        .catch(err => {
          console.error('Error loading staff activity data:', err);
          vm.errorMessage = 'Failed to load staff activity data.';
          vm.loading = false;
        });
    }

    function processHistoricalData(results) {
      // Combine all results into a single array of period data
      const allPeriods = results.flat();

      // Group by period and sum chat counts
      const periodMap = new Map();
      
      allPeriods.forEach(item => {
        const count = parseInt(item.chat_count) || 0;
        if (periodMap.has(item.period)) {
          periodMap.set(item.period, periodMap.get(item.period) + count);
        } else {
          periodMap.set(item.period, count);
        }
      });

      // Convert to array and sort by date
      vm.historicalData = Array.from(periodMap.entries())
        .map(([period, count]) => ({ period, count }))
        .sort((a, b) => new Date(a.period) - new Date(b.period));

      // If we have more data than selected days, take the most recent ones
      if (vm.historicalData.length > vm.selectedDays) {
        vm.historicalData = vm.historicalData.slice(-vm.selectedDays);
      }
    }

    function updateChartData() {
      // Clear existing chart
      if (vm.chart) {
        vm.chart.destroy();
      }

      // Prepare chart data
      vm.chartLabels = vm.historicalData.map(item => formatPeriodLabel(item.period));
      vm.chartData = vm.historicalData.map(item => item.count);

      // Render chart
      $timeout(() => renderChart(), 0);
    }

    function formatPeriodLabel(period) {
      const date = new Date(period);
      if (vm.selectedPeriod === 'day') {
        return date.toLocaleDateString('en-US', { month: 'short', day: 'numeric' });
      } else {
        return date.toLocaleDateString('en-US', { month: 'short', year: 'numeric' });
      }
    }

    function renderChart() {
      const ctx = document.getElementById('activityChart')?.getContext('2d');

      if (!ctx) {
        console.error("Chart.js could not find the canvas context.");
        return;
      }

      const chartTitle = `${vm.selectedPeriod === 'day' ? 'Daily' : 'Monthly'} ${vm.selectedType === 'consultation' ? 'Consultation' : 'Service'} Chats`;
      const backgroundColor = vm.selectedType === 'consultation' ? '#4e73df' : '#1cc88a';

      vm.chart = new Chart(ctx, {
        type: 'bar',
        data: {
          labels: vm.chartLabels,
          datasets: [{
            label: chartTitle,
            data: vm.chartData,
            backgroundColor: backgroundColor,
            borderColor: backgroundColor,
            borderWidth: 1
          }]
        },
        options: {
          responsive: true,
          plugins: {
            title: {
              display: true,
              text: `Last ${vm.selectedDays} ${vm.selectedPeriod === 'day' ? 'Days' : 'Months'}`,
              font: {
                size: 16
              }
            },
            tooltip: {
              callbacks: {
                label: function(context) {
                  return `${context.dataset.label}: ${Math.round(context.raw)}`;
                }
              }
            }
          },
          scales: {
            y: {
              beginAtZero: true,
              ticks: {
                precision: 0,
                callback: function(value) {
                  if (value % 1 === 0) {
                    return value;
                  }
                }
              }
            }
          }
        }
      });
    }

    // Watch for changes in selections
    vm.updateChart = function () {
      vm.loading = true;
      init(); // Re-fetch data with new parameters
    };
  }
})();