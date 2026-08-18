#!/usr/bin/env node

const fs = require('node:fs');
const path = require('node:path');

// cordova-android (through 15.1.0) ships a generated cordova.js with two
// CodeQL findings. This hook re-applies the patches after every prepare /
// platform add so switch.sh cannot restore the templates.

const SUFFIX_VULNERABLE = 'if (src.indexOf(term) === (src.length - term.length))';
const SUFFIX_PATCHED = 'if (index !== -1 && index === (src.length - term.length))';
const SUFFIX_BLOCK = [
    'var index = src.indexOf(term);',
    '        ' + SUFFIX_PATCHED
].join('\n');

const MERGE_VULNERABLE = [
    'function recursiveMerge (target, src) {',
    '    for (var prop in src) {',
    '        if (Object.prototype.hasOwnProperty.call(src, prop)) {',
    '            if (target.prototype && target.prototype.constructor === target) {',
    '                // If the target object is a constructor override off prototype.',
    '                clobber(target.prototype, prop, src[prop]);',
    '            } else {',
    '                if (typeof src[prop] === \'object\' && typeof target[prop] === \'object\') {',
    '                    recursiveMerge(target[prop], src[prop]);',
    '                } else {',
    '                    clobber(target, prop, src[prop]);',
    '                }',
    '            }',
    '        }',
    '    }',
    '}'
].join('\n');

const MERGE_PATCHED = [
    'function recursiveMerge (target, src) {',
    '    for (var prop in src) {',
    '        if (Object.prototype.hasOwnProperty.call(src, prop)) {',
    '            if (prop === \'__proto__\' || prop === \'constructor\' || prop === \'prototype\') {',
    '                continue;',
    '            }',
    '            if (target.prototype && target.prototype.constructor === target) {',
    '                // If the target object is a constructor override off prototype.',
    '                clobber(target.prototype, prop, src[prop]);',
    '            } else {',
    '                if (typeof src[prop] === \'object\' &&',
    '                    Object.prototype.hasOwnProperty.call(target, prop) &&',
    '                    typeof target[prop] === \'object\') {',
    '                    recursiveMerge(target[prop], src[prop]);',
    '                } else {',
    '                    clobber(target, prop, src[prop]);',
    '                }',
    '            }',
    '        }',
    '    }',
    '}'
].join('\n');

const PATCHES = [
    {
        name: 'suffix check',
        vulnerable: SUFFIX_VULNERABLE,
        patched: SUFFIX_PATCHED,
        replacement: SUFFIX_BLOCK
    },
    {
        name: 'prototype-polluting merge',
        vulnerable: MERGE_VULNERABLE,
        patched: 'prop === \'__proto__\' || prop === \'constructor\' || prop === \'prototype\'',
        replacement: MERGE_PATCHED
    }
];

function cordovaJsTargets (projectRoot) {
    return [
        path.join(projectRoot, 'platforms', 'android', 'platform_www', 'cordova.js'),
        path.join(projectRoot, 'platforms', 'android', 'app', 'src', 'main', 'assets', 'www', 'cordova.js')
    ];
}

function applyPatches (file) {
    let source = fs.readFileSync(file, 'utf8');
    let changed = false;

    for (const patch of PATCHES) {
        if (source.includes(patch.patched)) {
            continue;
        }
        if (!source.includes(patch.vulnerable)) {
            console.warn('⚠️  cordova.js ' + patch.name + ' pattern not found (upstream template may have changed): ' + file);
            continue;
        }
        source = source.split(patch.vulnerable).join(patch.replacement);
        changed = true;
        console.log('✅ cordova.js ' + patch.name + ' patched: ' + file);
    }

    if (changed) {
        fs.writeFileSync(file, source);
    }
}

module.exports = function (context) {
    for (const file of cordovaJsTargets(context.opts.projectRoot)) {
        if (fs.existsSync(file)) {
            applyPatches(file);
        }
    }
};
