const express = require('express');
const app = express();

app.use(express.json());

app.post('/boosting', (req, res) => {
    console.log("good bye");
    res.send('Request received');
});