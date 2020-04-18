var ws, cmd = "";
var input = document.getElementById("symInput");
var output = document.getElementById("tableOutput");

// Add enter key functionality to click filter button
input.addEventListener("keyup", function(event) {
    if (event.keyCode === 13) {
     event.preventDefault();
     document.getElementById("cmdInput").click();
    }
  });

// Remove add new line event when pressing enter key in the text area

function connect(){
    if ("WebSocket" in window){ // check if WebSockets supported
        // open a WebSocket
        ws = new WebSocket("ws://localhost:5013");
        output.value="Connecting to the hdb process...";
        ws.onopen = function(e){
            // called upon successful WebSocket connection
            output.innerHTML="Successfully connected!";
        };
        ws.onclose = function(){
            // called when WebSocket is closed
            output.innerHTML="Disconnected from the hdb!"
        };
        ws.onmessage = function(msg){
            // parse message from JSON String into an Object
            var tab = JSON.parse(msg.data);
            console.log("Retrieved results...");
            setTradeTable(tab);
        };
    } else alert("WebSockets not supported on your browser");
}

function send(){
    /* 
        store the input command so that we can access it later 
        to print in with the response 
    */
    cmd = `Requesting trade results for sym: ${input.value}`;
    console.log(cmd);
    /* send the input command across the WebSocket connection */
    ws.send(input.value);
    /* 
        reset the input test box to empty, and 
        focus the cursor back on it ready for the next input 
    */
    input.value="";
    input.focus();
    output.innerHTML=cmd;
}

function setTradeTable(data) { output.innerHTML = generateTableHTML(data) }

function generateTableHTML(data){
    console.log("Converting table to html format in GenerateTableHTML...");
    /* we will iterate through the object wrapping it in the HTML table tags */
    var tableHTML = '<table id="tradeTable" border="1"><tr>';
    for (var x in data[0]) {
        /* loop through the keys to create the table headers */
        tableHTML += '<th>' + x + '</th>';
    }
    tableHTML += '</tr>';
    for (var i = 0; i < data.length; i++) {
        /* loop through the rows, putting tags around each col value */
        tableHTML += '<tr>';
        for (var x in data[0]) {
            /* Instead of pumping out the raw data to the table, let's
            format it according to its type*/
            var cellData;
            if("time" === x)
                cellData = data[i][x].substring(2,10);
            else if("number" == typeof data[i][x])
                cellData = data[i][x].toFixed(2);
            else cellData = data[i][x];
            tableHTML += '<td>' + cellData + '</td>';
        }
        tableHTML += '</tr>';
    }
    tableHTML += '</table>';
    return tableHTML;
}

