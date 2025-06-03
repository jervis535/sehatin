// firebase.js
import admin from 'firebase-admin';
import serviceAccount from '../sehatin-a7972-firebase-adminsdk-fbsvc-485c5c49be.json' assert { type: 'json' };

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

export default admin;
