const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp(functions.config().firebase);

exports.addUserToDB = functions.auth.user().onCreate(event => {
	const user = event.data; // The firebase user
	const id = user.uid;
	const displayName = user.displayName;

return admin.database().ref("/users/"+id+"/info/status").set("ok"); });