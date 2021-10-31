import { Server } from 'ws'; // Imports the ws server
import * as fs from 'fs'; // Imports the filesystem functions
const wss = new Server({port: 3000}); // starts a new websocket server on port 3000
console.log("Server started"); // log when server starts
wss.on('connection', async function connection(ws) {// code below happens every time a client connects
  var id = Math.floor((1 + Math.random()) * 0x10000).toString(16).substring(1); // generates uuid specific to session for client
  console.log(ws); // logs the ws info
  ws.on('message', function incoming(msg) {// code below happens when a client sends a message
    console.log(id, msg)// logs the message
    if (msg.toString("utf-8").includes("request")){ // converts the msg from raw data to a string using utf-8 and checks to see if it contains the request keyword
      var recv = msg.toString('utf-8').substring(msg.toString().indexOf('-') + 1); // splits the message after the - to get the command
      if (recv === "ip"){// is the 2nd value of the message ip
        ws.send("PHONE:" + id); // sends the client their uuid
      };
      if (recv === "date"){// is the 2nd value of the message date
        var date = new Date(); // creates a new date with the current date
        var fulldate = date.getDate() + "/" + date.getMonth() + "/" + date.getFullYear(); // gets the date month and year and concatenates it to a string
        ws.send(fulldate); // sends the date to the client
      };
      if (recv === "listapps"){// is the 2nd value of the message listapps
        var index = 1
        fs.readdir("./apps", function (err: any, files: any[]) {// reads all the items in the /apps
            if (err) {
                console.log('Unable to scan directory: ' + err); // log if error occurs
                return ws.send("There was a problem try again later or contact the server admin if the problem persists."); // informs client of the problem
            }
            files.forEach(function (file) {
                ws.send(`App[${index}]: ` + file); // sends each app name to the client -- this will only be used for the store
                index++
            });
            ws.send("LISTEND")
        });
      };
      if (recv.includes('msg')){
        console.log('message');
      };
      if (recv.includes("app+") === true){// checks to see if the request is for an app
        var requestapp = recv.split('+', 2); // splits the request by the + so when requesting an app the request goes from 'app+Test.lua' to 'app', 'Test.lua'
        var appname = requestapp[1];
        var app = `./apps/${appname}`; // creates the pathname to the file in thiscase it will be './apps/Test.lua'
        try{
          fs.readFile(app, function(err, buffer){
            let bindat = base64ToArrayBuffer(buffer);
            ws.send(bindat);
            if (err){
              console.log([id] + ':' + [err])
              ws.send("There was an error please try again later or contact a server admin if the problem persists."); // if the transfer reaches an error
          }});
      }catch (e){// catches an exception in the app name
        ws.send("Error App either does not exist or was spelt wrongly, if problem persists please contact an admin"); // sends an error message to the client
      }};
    };
  });
  ws.on('close', async function close(){// when the connection is closed
    console.log("Client has disconnected!"); // logs when a client disconnects
  });
});
// This program was made to be used on my personal minecraft server it is a phone system using computercraft all functions are managed by the websockets with the phone app being only a request sender
function base64ToArrayBuffer(base64 : any) {
  var binary_string = Buffer.from(base64, 'base64').toString('binary');
  var len = binary_string.length;
  var bytes = new Uint8Array(len);
  for (var i = 0; i < len; i++) {
      bytes[i] = binary_string.charCodeAt(i);
  }
  return bytes.buffer;
}