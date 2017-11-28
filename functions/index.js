const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp(functions.config().firebase);

exports.addUserToDB = functions.auth.user().onCreate(event => {
	const user = event.data; // The firebase user
	const id = user.uid;
	console.log(user);
	var userDatabase = admin.database().ref("/users/");
	var idChild = userDatabase.child(id);
	idChild.set ({
		email: user.email,
		uid: user.uid
	});
});