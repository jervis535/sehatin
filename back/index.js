import express from 'express';
import http from 'http';
import bodyParser from 'body-parser';
import cors from 'cors';
import './utils/firebase.js';

import usersRoute from './routes/UserRoutes.js';
import poisRoute from './routes/POIRoutes.js';
import customerServiceRoute from './routes/CustomerServiceRoutes.js';
import doctorsRoute from './routes/DoctorRoutes.js';
import channelsRoute from './routes/ChannelRoutes.js';
import medicalHistoryRoute from "./routes/MedicalRecordRoutes.js";
import messageRoute from "./routes/MessagesRoutes.js";
import evidenceRoute from "./routes/EvidenceRoutes.js";
import tokenRoutes from './routes/TokenRoute.js';
import fileUpload from 'express-fileupload';
import adminRoutes from './routes/AdminRoute.js';
import reviewRoute from './routes/ReviewRoutes.js';


import { setupWebSocket } from './websocket.js';

const app = express();
const port = 3000;

app.use(fileUpload({
  limits: { fileSize: 10 * 1024 * 1024 }, // 10 MB
}));
app.use(cors());

app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

app.use(usersRoute);
app.use(poisRoute);
app.use(tokenRoutes);
app.use(customerServiceRoute);
app.use(doctorsRoute);
app.use(channelsRoute);
app.use(medicalHistoryRoute);
app.use(messageRoute);
app.use(evidenceRoute);
app.use(adminRoutes);
app.use(reviewRoute);

// Create HTTP server and attach Express app
const server = http.createServer(app);

// Setup WebSocket server on the same HTTP server
setupWebSocket(server);

server.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});
