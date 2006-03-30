// small cross browser function to get an HTTP object for making 
// AJAX style http requests in the background 
// -gustaf neumann Jan, 2006
// exended for dotlrn-chat and listing of users
// -peter alberer

// global variables
var msgcount = 0; // hack to overcome IE
var dataConnections = new Object; // variable to find all the registered datasources
// var inactivityTimeout = setTimeout(stopUpdates,300000);

// helper function to get a new http request object
function getHttpObject() {
     var http_request = false;
     if (window.XMLHttpRequest) { // Mozilla, Safari,...
         http_request = new XMLHttpRequest();
         if (http_request.overrideMimeType) {
              http_request.overrideMimeType('text/xml');
         }
     } else if (window.ActiveXObject) { // IE
         try {
             http_request = new ActiveXObject("Msxml2.XMLHTTP");
         } catch (e) {
             try {
                 http_request = new ActiveXObject("Microsoft.XMLHTTP");
             } catch (e) {}
         }
     }
     if (!http_request) {
         alert('Cannot create an instance of XMLHTTP');
     }
   return http_request;
}

if (typeof DOMParser == "undefined") {
   DOMParser = function () {}
   DOMParser.prototype.parseFromString = function (str, contentType) {
      if (typeof ActiveXObject != "undefined") {
         var d = new ActiveXObject("MSXML.DomDocument");
         d.loadXML(str);
         return d;
        }
   }
}

// functions that handle the incoming xml/html data
function messagesReceiver(content) {
  var xmlobject = (new DOMParser()).parseFromString(content, 'application/xhtml+xml');
  var items = xmlobject.getElementsByTagName('p');
  // alert('found ' + items.length + ' items');

  //var counter = document.getElementById('chatCounter');
  //counter.innerHTML = parseInt(counter.innerHTML) + 1;
  //document.getElementById('chatResponse').innerHTML = 'items = ' + items.length + ' l=' + content.length + ' ' + escape(content);

  //if (items.length > 0) {alert('appending ' + content);}
  var doc = frames['ichat'].document;
  var div = frames['ichat'].document.getElementById('messages');
  //var tbody = tbodies[tbodies.length -1];
  //for (var i = 0 ; i < items.length ; i++) {
  //  tbody.appendChild(frames['ichat'].document.importNode(items[i],true));
  //}
  var tr, td, e, s;
  var msgCount = 0;
  for (var i = 0 ; i < items.length ; i++) {
    msgCount++;
      // tbody.appendChild(items[i]);
    p = doc.createElement('p');
    p.className = 'line';
    e = items[i].getElementsByTagName('span');
    span = doc.createElement('span');
    span.innerHTML = decodeURIComponent(e[0].firstChild.nodeValue);
    span.className = 'timestamp';
    p.appendChild(span);

    span = doc.createElement('span');
    s = e[1].firstChild.nodeValue;
    span.innerHTML = decodeURIComponent(e[1].firstChild.nodeValue.replace(/\+/g,' '));
    span.className = 'user';
    p.appendChild(span);

    span = doc.createElement('span');
    span.innerHTML = decodeURIComponent(e[2].firstChild.nodeValue.replace(/\+/g,' '));
    span.className = 'message';
    p.appendChild(span);

    div.appendChild(p);
  }
  if ( msgCount > 0 ) { 
      frames['ichat'].window.scrollTo(0,div.offsetHeight);
  }
}

function pushReceiver(content) {
    messagesReceiver(content);
    var msgField = document.getElementById('chatMsg');
    msgField.value = '';
    msgField.disabled = false;
    msgField.focus();
}

function usersReceiver(content) {
  var xmlobject = (new DOMParser()).parseFromString(content, 'application/xhtml+xml');
  var items = xmlobject.getElementsByTagName('TR');
  var doc = frames['ichat-users'].document;
  var tbody = frames['ichat-users'].document.getElementById('users').tBodies[0];
  var tr, td, e, s, nbody;
  
  nbody = doc.createElement('tbody');
  
  for (var i = 0 ; i < items.length ; i++) {
    tr = doc.createElement('tr');
    e = items[i].getElementsByTagName('TD');
    
    td = doc.createElement('td');
    td.innerHTML = decodeURIComponent(e[0].firstChild.nodeValue.replace(/\+/g,' '));
    td.className = 'user';
    tr.appendChild(td);
    
    td = doc.createElement('td');
    td.innerHTML = decodeURIComponent(e[1].firstChild.nodeValue.replace(/\+/g,' '));
    td.className = 'timestamp';
    tr.appendChild(td);   
    
    nbody.appendChild(tr);
  }
  
  tbody.parentNode.replaceChild(nbody,tbody);
  
}

function DataConnection() {};

DataConnection.prototype = {
    handler: null,
    url: null,
    connection: null,
    busy: null,
    autoConnect: null,
    
    httpSendCmd: function(url) {
        // if (!this.connection) {
            this.busy = true;
            this.connection = getHttpObject();
        // }
        this.connection.open('GET', url + '&mc=' + msgcount++, true);
        var self = this;
        this.connection.onreadystatechange = function() {
            self.httpReceiver(self);
        }
        this.connection.send('');
    },
    
    httpReceiver: function(obj) {
         if (obj.connection.readyState == 4) {
            if (obj.connection.status == 200) {
                obj.handler(obj.connection.responseText);
                obj.busy = false;
            } else {
                clearInterval(updateInterval);
                alert('Something wrong in HTTP request, status code = ' + obj.connection.status);
            }
        }       
    }, 
    
    chatSendMsg: function(send_url) {
        // if (inactivityTimeout) {
        //     clearTimeout(inactivityTimeout);
            // alert("Clearing inactivityTimeout");
        // }
        // if (!updateInterval) {
            // alert("Rescheduling updateInterval");
        //     updateInterval = setInterval(updateDataConnections,5000);
        // }
        if (this.busy) {
            alert("chatSendMsg conflict!");
        }
        var msgField = document.getElementById('chatMsg');
        if (msgField.value == '') {
            return;
        }
        msgField.disabled = true;
        this.httpSendCmd(send_url + escape(msgField.value));
        msgField.value = '#chat.sending_message#';
        // alert("Reseting inactivityTimeout");
        // inactivityTimeout = setTimeout(stopUpdates,300000);
    },   
    
    updateBackground: function() {
        //alert("binda = " + this);
        if (this.busy) {
            alert("Message update function cannot run because the last connection is still busy!");
        }
        this.httpSendCmd(this.url);
    }
}

function registerDataConnection(handler,url,autoConnect) {
    // var ds = new DataConnection(handler,url,autoConnect);
    var ds = new DataConnection();
    ds.handler = handler;
    ds.url = url;
    ds.autoConnect = autoConnect;
    ds.busy = false;
    dataConnections[url] = ds;
    return ds;
}

function updateDataConnections() {
    for (var ds in dataConnections) {
        if (dataConnections[ds].autoConnect) {
            dataConnections[ds].updateBackground();
        }
    }
}

function stopUpdates() {
    // alert("Stopping all update operations");
    clearInterval(updateInterval);
    updateInterval = null;
    clearTimeout(inactivityTimeout);
    inactivityTimeout = null;
}

