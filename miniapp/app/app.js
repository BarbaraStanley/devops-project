const express = require('express');
const jwt = require('jsonwebtoken');
const path = require('path');
const bodyParser = require('body-parser')
const mongoose = require('mongoose')
const User = require('./user'); // user model

// Set up Express app and connect to MongoDB
const app = express();
mongoose.connect('mongodb://localhost/mydatabase');
const mongoUrl = process.env.MONGO_URL || 'mongodb://localhost:27017/mydatabase';

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }))
// app.use('/', )
//get form data
app.get('/', function(req, res){
    res.sendFile(path.join(__dirname, "index.html"));
});

app.get('/style.css', (req, res) => {
    res.set('Content-Type', 'text/css');
    res.sendFile(__dirname + '/style.css');
});
app.get('/images', (req, res) => {
    const imageType = 'image/jpeg'; 
    
    res.setHeader('Content-Type', imageType);
    res.sendFile(__dirname + "/images/final-space-mooncake-4k-5q.jpg");
});

app.get('/index.js', (req, res) => {
    res.set('Content-Type', 'application/javascript');
    res.sendFile(__dirname + '/index.js');
});

app.get('/submit', function(req, res){
    console.log('getting user data')
    User.find({})
    .exec()
    res.json(User);
});

// Set up a route to handle the form submission
app.post('/submit', async (req, res) => {
    // Get the form data from the request body
  const { Fname, Lname, Email, DOB, State, City, Phone, Gender} = req.body;

  const randomNumber = Math.floor(Math.random() * 1000000);

  const user = new User({
    Fname: Fname, 
    Lname: Lname, 
    Email: Email, 
    DOB: DOB, 
    State: State, 
    City: City, 
    Phone: Phone, 
    Gender: Gender,
    IdNumber: randomNumber, 
  });
  // Save the new record to the database
//   user.save((err) => {
//     if (err) {
    //       res.status(500).send('Error saving record to database');
    //     } else {
//       res.status(200).send('Record saved to database');
//     }
//   });
  await user.save();
  res.status(200).send('Record saved to database');
  //   const token = jwt.sign({ userId: user._id }, 'my-secret-key');
//   res.json({ token });
});

app.listen(3000, function() {
    console.log('Na port 3000 dey reign');
});