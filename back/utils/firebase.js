// firebase.js
import admin from 'firebase-admin';
import serviceAccount from '../sehatin-48d6c-firebase-adminsdk-fbsvc-ef0ffd576d.json' assert { type: 'json' };

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

export default admin;
