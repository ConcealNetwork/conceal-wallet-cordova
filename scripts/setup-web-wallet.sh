#!/bin/bash

# Conceal Web Wallet Setup Script
# This script sets up the web wallet locally for Cordova integration using Git subtree

set -e  # Exit on any error

echo "Starting Conceal Web Wallet setup with Git subtree..."

# 1. Remove www folder contents from git tracking if it exists
echo "1. Removing existing www folder contents from git tracking..."
if [ -d "www" ]; then
    # Backup our modified files
    echo "   Backing up modified files..."
    mkdir -p temp_backup
    if [ -f "www/src/index.html" ]; then
        cp www/src/index.html temp_backup/index.html
        echo "   ✓ Backed up www/src/index.html"
    fi
    if [ -f "www/src/index.js" ]; then
        cp www/src/index.js temp_backup/index.js
        echo "   ✓ Backed up www/src/index.js"
    fi
    
    # Remove the www directory completely
    rm -rf www
    echo "   ✓ www folder removed"
else
    echo "   ✓ www folder doesn't exist, skipping removal"
fi

# 2. Add the external repository as a subtree
echo "2. Adding Conceal Web Wallet as Git subtree..."
git subtree add --prefix=www https://github.com/ConcealNetwork/conceal-web-wallet.git testing --squash
echo "   ✓ Repository added as subtree successfully"

# 3. Change to www directory and checkout testing branch (if needed)
echo "3. Switching to testing branch..."
cd www
git checkout testing 2>/dev/null || echo "   ✓ Already on testing branch"
echo "   ✓ Switched to testing branch"

# 4. Install npm dependencies
echo "4. Installing npm dependencies..."
npm install
echo "   ✓ Dependencies installed"

# 5. Build the project
echo "5. Building the project..."
node ./node_modules/typescript/bin/tsc --project tsconfig.prod.json && node build.js
echo "   ✓ Build completed successfully"

# 6. Remove all TypeScript files and markdown files
echo "6. Removing TypeScript and markdown files..."
find . -name "*.ts" -type f -delete
find . -name "*.md" -type f -delete
echo "   ✓ TypeScript and markdown files removed"

# 7. Add cordova.js script to index.html
echo "7. Adding cordova.js script to index.html..."
if [ -f "src/index.html" ]; then
    # Create a temporary file
    temp_file=$(mktemp)
    
    # Add cordova.js script before the first script tag
    awk '
    /<script/ && !cordova_added {
        print "        <script type=\"text/javascript\" src=\"../cordova.js\"></script>"
        cordova_added = 1
    }
    { print }
    ' src/index.html > "$temp_file"
    
    # Replace the original file
    mv "$temp_file" src/index.html
    echo "   ✓ cordova.js script added to src/index.html"
else
    echo "   ⚠ Warning: src/index.html not found"
fi

# 8. Fix router configuration
echo "8. Fixing router configuration..."
if [ -f "src/index.js" ]; then
    # Fix the router initialization to use correct paths
    sed -i 's/new Router_1\.Router('\''\.\/'\'', '\''\.\.\/\.\.\/'\'')/new Router_1.Router('\''\.\/'\'', '\''\.\/'\'')/g' src/index.js
    echo "   ✓ Router configuration fixed"
else
    echo "   ⚠ Warning: src/index.js not found"
fi

# 9. Fix QR reader paths
echo "9. Fixing QR reader paths..."
if [ -f "src/pages/importFromQr.js" ]; then
    sed -i 's/this\.qrReader\.init('\''\/lib\/'\'')/this.qrReader.init('\''\/src\/lib\/'\'')/g' src/pages/importFromQr.js
    echo "   ✓ QR reader path fixed in importFromQr.js"
fi
if [ -f "src/pages/send.js" ]; then
    sed -i 's/this\.qrReader\.init('\''\/lib\/'\'')/this.qrReader.init('\''\/src\/lib\/'\'')/g' src/pages/send.js
    echo "   ✓ QR reader path fixed in send.js"
fi
if [ -f "src/pages/messages.js" ]; then
    sed -i 's/this\.qrReader\.init('\''\/lib\/'\'')/this.qrReader.init('\''\/src\/lib\/'\'')/g' src/pages/messages.js
    echo "   ✓ QR reader path fixed in messages.js"
fi

# 10. Fix worker file paths
echo "10. Fixing worker file paths..."
if [ -f "src/workers/TransferProcessingEntrypoint.js" ]; then
    sed -i 's/importScripts('\''\.\.\/src\/lib\//importScripts('\''\.\.\/lib\//g' src/workers/TransferProcessingEntrypoint.js
    echo "   ✓ Worker paths fixed in TransferProcessingEntrypoint.js"
fi
if [ -f "src/workers/ParseTransactionsEntrypoint.js" ]; then
    sed -i 's/importScripts('\''\.\.\/src\/lib\//importScripts('\''\.\.\/lib\//g' src/workers/ParseTransactionsEntrypoint.js
    echo "   ✓ Worker paths fixed in ParseTransactionsEntrypoint.js"
fi

# 11. Fix all module and dynamic dependency paths (excluding QR reader paths)
echo "11. Fixing all module and dynamic dependency paths..."
# Fix ../src/lib/ → ../lib/ everywhere (but exclude QR reader files)
find src -name "*.js" -type f ! -name "*importFromQr*" ! -name "*send*" ! -name "*messages*" -exec sed -i 's#\.\./src/lib/#\.\./lib/#g' {} \;
# Fix ./src/lib/ → ./lib/ in src root
find src -maxdepth 1 -name "*.js" -type f -exec sed -i 's#\./src/lib/#\./lib/#g' {} \;
# Fix '/src/lib/' → '/lib/' for dynamic imports (but exclude QR reader files)
find src -name "*.js" -type f ! -name "*importFromQr*" ! -name "*send*" ! -name "*messages*" -exec sed -i "s#'/src/lib/'#'/lib/'#g" {} \;
echo "   ✓ All module and dynamic dependency paths fixed"

# 12. Restore our modified files
echo "12. Restoring modified files..."
if [ -f "../temp_backup/index.html" ]; then
    cp ../temp_backup/index.html src/index.html
    echo "   ✓ Restored www/src/index.html"
fi
if [ -f "../temp_backup/index.js" ]; then
    cp ../temp_backup/index.js src/index.js
    echo "   ✓ Restored www/src/index.js"
fi

# Return to parent directory
cd ..

# 13. Install required Cordova plugins
echo "13. Installing required Cordova plugins..."
cordova plugin add cordova-plugin-insomnia@~4.3.0
cordova plugin add cordova-plugin-app-version@~0.1.9
cordova plugin add cordova-plugin-android-permissions@~1.1.5
cordova plugin add cordova-plugin-network-information@~3.0.0
echo "   ✓ Cordova plugins installed"

# 14. Clean up backup files
echo "14. Cleaning up backup files..."
rm -rf temp_backup
echo "   ✓ Backup files cleaned up"

# 15. Commit the subtree changes to the parent repository
echo "15. Committing subtree changes to parent repository..."
git add www/
git commit -m "Add Conceal Web Wallet as subtree from testing branch

- Integrated conceal-web-wallet repository as Git subtree
- Applied Cordova-specific modifications
- Fixed file paths for Cordova integration
- Added required Cordova plugins"
echo "   ✓ Changes committed to parent repository"

echo ""
echo "✓ Conceal Web Wallet setup completed successfully!"
echo "The web wallet is now part of your Git repository as a subtree."
echo ""
echo "Next steps:"
echo "1. Update your Cordova app to load the local web wallet"
echo "2. Test the integration"
echo "3. Build your Cordova app"
echo ""
echo "To update the subtree in the future, use:"
echo "  git subtree pull --prefix=www https://github.com/ConcealNetwork/conceal-web-wallet.git testing --squash" 