// Add an event listener to the form submit button
document.querySelector('#submit').addEventListener('click', function(event) {
    event.preventDefault(); // prevent the default form submission
  
    // Generate a random number between 0 and 999
    const randomNumber = Math.floor(Math.random() * 1000);
  
    // Create a new FormData object and add the form fields to it
    const formData = {
        Fname: document.querySelector('#First').value,
        Lname: document.querySelector('#Last').value,
        Email: document.querySelector('#email').value,
        DOB : document.querySelector('#dob').value,
        State: document.querySelector('#State').value,
        City: document.querySelector('#City').value,
        Phone: document.querySelector('#Phone').value,
        Gender: document.querySelector('#Gender').value,
        number: randomNumber,
      };

      console.log(formData.DOB)
      console.log('outside')

    // Create an AJAX request to post the form data to the server
    const xhr = new XMLHttpRequest();
    xhr.open('POST', '/submit', true);
    xhr.setRequestHeader('Content-Type', 'application/json;charset=UTF-8');
    xhr.onreadystatechange = function() {
        if (xhr.readyState === 4) {
            if (xhr.status === 200) {
                alert('Data saved successfully!');
            } else {
            alert('Email already exists.');
            }
        }
      };
      xhr.send(JSON.stringify(formData));
    });