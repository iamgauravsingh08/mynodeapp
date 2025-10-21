const express = require('express');
const mongoose = require('mongoose');
const connectDB = require('./database/db');
const studentrouter= require("./routes/students");

const app = express();

const url = ""; 
const port = 3000;

connectDB();

app.use(express.json());

app.use('/students',studentrouter)

app.listen(port, () => {
    console.log('Server started on port ' + port);
});