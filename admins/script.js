const BASE_URL = 'http://localhost:3000';

function renderList(data, listId) {
  const list = document.getElementById(listId);
  list.innerHTML = '';

  data.forEach(item => {
    if (!item.verified) {
      if (listId === 'poi-list') {
  const li = document.createElement('li');
  const googleMapsLink = `https://www.google.com/maps?q=${item.latitude},${item.longitude}`;

  li.innerHTML = [
    `ID: ${item.id}`,
    `Name: ${item.name}`,
    `Category: ${item.category}`,
    `Address: ${item.address || 'N/A'}`,
    `<a href="${googleMapsLink}" target="_blank">View on Google Maps</a>`,
    `<button onclick="verifyItem(${item.id}, '${listId}')">Verify</button>`,
    `<button onclick="denyItem(${item.id}, '${listId}')">Deny</button>`
  ].join('<br>');

  list.appendChild(li);
}


 else if (listId === 'doctor-list' || listId === 'customer-service-list') {
        Promise.all([
          fetchUserInfo(item.user_id),
          fetchPoiName(item.poi_id),
          fetchEvidenceImage(item.user_id)
        ])
        .then(([userInfo, poiName, imageBase64]) => {
          const li = document.createElement('li');

          const imageTag = imageBase64
            ? `<img src="data:image/jpeg;base64,${imageBase64}" alt="Evidence" style="max-width: 200px; display: block; margin-top: 8px;" />`
            : `<span style="color:red;">No evidence image</span>`;

          li.innerHTML = [
            `Username: ${userInfo.username}`,
            `Email: ${userInfo.email}`,
            `Phone: ${userInfo.telno}`,
            `POI: ${poiName}`,
            imageTag,
            `<button onclick="verifyItem(${item.user_id}, '${listId}')">Verify</button>`,
            `<button onclick="denyItem(${item.user_id}, '${listId}')">Deny</button>`
          ].join('<br>');
          list.appendChild(li);
        })
        .catch(err => console.error("Error fetching data for list item:", err));
      }
    }
  });
}

async function denyItem(id, listId) {
  try {
    let endpoint = '';

    if (listId === 'poi-list') {
      endpoint = `${BASE_URL}/pois/${id}`;
    } else if (listId === 'doctor-list') {
      endpoint = `${BASE_URL}/users/${id}`;
    } else if (listId === 'customer-service-list') {
      endpoint = `${BASE_URL}/users/${id}`;
    }

    const response = await fetch(endpoint, {
      method: 'DELETE',
      headers: {
        'Content-Type': 'application/json'
      }
    });

    if (!response.ok) {
      throw new Error('Failed to delete item');
    }

    await loadData();
  } catch (err) {
    console.error('Error denying item:', err);
  }
}


async function verifyItem(id, listId) {
  try {
    let endpoint = '';
    let method = 'PUT';

    if (listId === 'poi-list') {
      endpoint = `${BASE_URL}/pois/verify/${id}`;
    } else if (listId === 'doctor-list') {
      endpoint = `${BASE_URL}/doctors/verify/${id}`;
    } else if (listId === 'customer-service-list') {
      endpoint = `${BASE_URL}/customerservices/verify/${id}`;
    }

    const response = await fetch(endpoint, {
      method: method,
      headers: {
        'Content-Type': 'application/json'
      }
    });

    if (!response.ok) {
      throw new Error('Failed to verify item');
    }

    await loadData();
  } catch (err) {
    console.error('Error verifying item:', err);
  }
}

async function fetchUserInfo(userId) {
  try {
    const response = await fetch(`${BASE_URL}/users/${userId}`);
    if (!response.ok) {
      throw new Error('Failed to fetch user info');
    }
    const userInfo = await response.json();
    return userInfo;
  } catch (err) {
    console.error('Error fetching user info:', err);
  }
}

async function fetchPoiName(poiId) {
  try {
    const response = await fetch(`${BASE_URL}/pois/${poiId}`);
    if (!response.ok) {
      throw new Error('Failed to fetch POI name');
    }
    const poi = await response.json();
    return poi.name;
  } catch (err) {
    console.error('Error fetching POI name:', err);
  }
}

async function fetchEvidenceImage(userId) {
  try {
    const response = await fetch(`${BASE_URL}/evidences/${userId}`);
    if (!response.ok) {
      console.warn(`No evidence found for user ${userId}`);
      return null;
    }
    const { image } = await response.json();
    return image;
  } catch (err) {
    console.error(`Error fetching evidence image for user ${userId}:`, err);
    return null;
  }
}

async function loadData() {
  try {
    const [poiRes, doctorRes, customerServiceRes] = await Promise.all([
      fetch(`${BASE_URL}/pois?verified=false`),
      fetch(`${BASE_URL}/doctors?verified=false`),
      fetch(`${BASE_URL}/customerservices?verified=false`)
    ]);

    const [poiData, doctorData, customerServiceData] = await Promise.all([
      poiRes.json(),
      doctorRes.json(),
      customerServiceRes.json()
    ]);

    const unverifiedPois = poiData.filter(poi => !poi.verified);
    const unverifiedDoctors = doctorData.filter(doctor => !doctor.verified);
    const unverifiedCustomerServices = customerServiceData.filter(service => !service.verified);

    renderList(unverifiedPois, 'poi-list');
    renderList(unverifiedDoctors, 'doctor-list');
    renderList(unverifiedCustomerServices, 'customer-service-list');
  } catch (err) {
    console.error('Error loading data:', err);
  }
}

document.addEventListener('DOMContentLoaded', () => {
  loadData();
});

const ctx = document.getElementById('dataChart').getContext('2d');

const dataChart = new Chart(ctx, {
  type: 'bar',
  data: {
    labels: ['Consultation', 'Service'], // 2 kategori
    datasets: [{
      label: 'Value',
      data: [3, 3],  // nilai bar Consultation=3, Service=3
      backgroundColor: ['rgba(54, 162, 235, 0.7)', 'rgba(255, 99, 132, 0.7)'],
      borderWidth: 1
    }]
  },
  options: {
    responsive: true,
    plugins: {
      title: {
        display: true,
        text: 'CHANNELS',
        font: {
          size: 18,
          weight: 'bold'
        }
      },
      legend: {
        display: false
      }
    },
    scales: {
      y: {
        beginAtZero: true,
        max: 6,
        title: {
          display: true,
          text: 'Chat Per Day'
        },
        ticks: {
          stepSize: 1
        }
      },
      x: {
        title: {
          display: true,
          text: 'User Chats'
        }
      }
    }
  }
});
