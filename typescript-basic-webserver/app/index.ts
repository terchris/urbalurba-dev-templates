/*
file: app/index.ts
This is a basic web server using Express and TypeScript
It serves a simple "Hello world" message on the root URL
It is a simple example to demonstrate how to set up a TypeScript project with Express
and how to run a basic web server
*/
import express from 'express';

const app = express();
const port = process.env.PORT || 3000;

// get the current time
const currentTime = new Date().toLocaleString();
// format the currenttime to a string " Time: HH:mm:ss Date: dd/mm/yyyy"
const timeDateString = new Date().toLocaleString('en-GB', {
  hour: '2-digit',
  minute: '2-digit',
  second: '2-digit',
  day: '2-digit',
  month: '2-digit',
  year: 'numeric'
}).replace(',', '').replace(/(\d{2}:.*) (\d{2}\/.*)/,'Time: $1 Date: $2');

app.get('/', (_, res) => {
  res.send('Hello world ! Template: typescript-basic-webserver. ' +
    'Time is: ' + timeDateString) 
});

app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});
