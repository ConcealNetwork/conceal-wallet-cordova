#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

module.exports = function(context) {
    console.log('🔧 Before Build Hook: Applying build-extras.gradle...');

    
    // Get the platform directory
    const platformRoot = path.join(context.opts.projectRoot, 'platforms', 'android', 'app');
    
    // Check if Android platform exists
    if (!fs.existsSync(platformRoot)) {
        console.log('⚠️  Android platform not found, skipping dependenciesInfo injection');
        return;
    }
    
    // Source build-extras.gradle from root
    const sourceFile = path.join(context.opts.projectRoot, 'build-extras.gradle');
    const targetFile = path.join(platformRoot, 'build-extras.gradle');
    
    // Check if source file exists
    if (!fs.existsSync(sourceFile)) {
        console.log('❌ build-extras.gradle not found at root, skipping dependenciesInfo injection');
        return;
    }
    
    try {
        // Copy build-extras.gradle to the Android app directory
        fs.copyFileSync(sourceFile, targetFile);
        console.log('✅ build-extras.gradle copied to Android platform successfully');
        console.log('✅ Includes _next asset packaging fix and F-Droid dependenciesInfo');
    } catch (error) {
        console.log('❌ Failed to copy build-extras.gradle:', error.message);
    }
};
