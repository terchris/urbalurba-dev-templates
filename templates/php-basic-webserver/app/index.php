# filename: templates/php-basic-webserver/app/index.php
# This is a basic web server using PHP's built-in web server
# It serves a simple "Hello world" message on the root URL
# It is a simple example to demonstrate how to set up a PHP project
# and how to run a basic web server

<?php
// Get the current time and format it
$currentTime = new DateTime();
$timeDateString = $currentTime->format('H:i:s d/m/Y');

// Set the response content type
header('Content-Type: text/plain');

// Output the response
echo "Hello world ! Template: php-basic-webserver. Time: " . 
     $currentTime->format('H:i:s') . 
     " Date: " . 
     $currentTime->format('d/m/Y');
?> 