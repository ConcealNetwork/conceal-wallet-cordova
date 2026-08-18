#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

// cordova-android (through 15.1.0) generates cordova.js from a template whose
// findCordovaPath() uses an incorrect suffix check:
//   src.indexOf(term) === (src.length - term.length)
// which wrongly matches when indexOf returns -1 and src is term.length - 1 chars
// long (CodeQL js/incorrect-suffix-check, alerts #4 and #5). This hook re-applies
// the corrected src.endsWith(term) form after every cordova prepare / platform add,
// so regenerating the platform does not restore the vulnerable pattern.

const VULNERABLE = "src.indexOf(term) === (src.length - term.length)";
const PATCHED = "src.endsWith(term)";

module.exports = function(context) {
    const targets = [
        path.join(context.opts.projectRoot, 'platforms', 'android', 'app', 'src', 'main', 'assets', 'www', 'cordova.js'),
        path.join(context.opts.projectRoot, 'platforms', 'android', 'platform_www', 'cordova.js')
    ];

    for (const file of targets) {
        if (!fs.existsSync(file)) {
            continue;
        }
        const original = fs.readFileSync(file, 'utf8');
        if (!original.includes(VULNERABLE)) {
            if (!original.includes(PATCHED)) {
                console.warn(`⚠️  cordova.js suffix check pattern not found (upstream template may have changed): ${file}`);
            }
            continue;
        }
        fs.writeFileSync(file, original.split(VULNERABLE).join(PATCHED));
        console.log(`✅ cordova.js suffix check patched: ${file}`);
    }
};
