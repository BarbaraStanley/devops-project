const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  Fname: {
    type: String,
  },
  Lname: {
    type: String,
  },
  Email: {
    type: String,
    unique: true
  },
  DOB: {
    type: String
  },
  State: {
    type: String
  },
  City: {
    type: String
  },
  Phone: {
    type: Number,
  },
  Gender: {
    type: String,
  }
});

const User = mongoose.model('User', userSchema);

module.exports = User;