const express = require('express');
const app = express();

app.use(express.json());

app.post('/boosting', (req, res) => {
    if (req.query.key) {
        console.log("good bye");
        res.send('Request received');
    } else {
        res.status(400).send('Missing key parameter');
    }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});