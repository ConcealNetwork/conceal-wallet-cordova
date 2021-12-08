#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const rootdir = process.argv[2];

function replace_string_in_file(filename, to_replace, replace_with) {
	var data = fs.readFileSync(filename, 'utf8');
	var result = data.replace(new RegExp(to_replace, "g"), replace_with);
	fs.writeFileSync(filename, result, 'utf8');
}

if (rootdir) {

	var route = '';
	var filestoreplace = ["www/index.html"];

	filestoreplace.forEach(function (val) {
		var fullfilename = path.join(route, val);
		if (fs.existsSync(fullfilename)) {
			replace_string_in_file(fullfilename, /<!-- web-version-config-on -->/, '<!-- web-version-config-off');
			replace_string_in_file(fullfilename, /<!-- end-web-version-config-on -->/, 'end-web-version-config-off -->');
			replace_string_in_file(fullfilename, /<!-- cordova-version-config-off/, '<!-- cordova-version-config-on -->');
			replace_string_in_file(fullfilename, /end-cordova-version-config-off -->/, '<!-- end-cordova-version-config-on -->');
		} else {
			console.log("missing: " + fullfilename);
		}
	});

}