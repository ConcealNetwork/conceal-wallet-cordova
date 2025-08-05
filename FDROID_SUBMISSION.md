# F-Droid Submission Guide for Conceal Mobile Wallet

This document outlines the requirements and steps for submitting the Conceal Mobile Wallet to F-Droid.

## Requirements Checklist

### ✅ Completed Requirements

1. **Metadata File**: `metadata/com.concealnetwork.concealmobile.yml`
   - Contains app description, categories, license, and build configuration
   - Includes screenshots section (placeholders created)

2. **Gradle Configuration**: 
   - Root `build.gradle` for F-Droid builds
   - `settings.gradle` to include Android platform
   - Existing Android platform gradle files

3. **Build Scripts**:
   - `build-fdroid.sh` (Linux/macOS)
   - `build-fdroid.bat` (Windows)

4. **Screenshots Directory**: `metadata/Screenshots/`
   - Placeholder structure created

## 📋 Still Needed

### Screenshots
- `main-wallet.png` - Main wallet interface
- `send-transaction.png` - Send transaction screen
- `receive-qr.png` - Receive screen with QR code
- `settings.png` - Settings screen

**Screenshot Requirements**:
- Format: PNG
- Resolution: At least 320x320 pixels
- Content: Should show the actual app interface
- No device frames or mockups

### Build Testing
Test the build process:
```bash
# Linux/macOS
./build-fdroid.sh

# Windows
build-fdroid.bat
```

## 📝 F-Droid Submission Process

### Option 1: GitHub (Recommended)
1. **Fork the F-Droid Data Repository**:
   - Go to https://github.com/fdroid/fdroiddata
   - Click "Fork" to create your own copy

2. **Add Your App**:
   - Copy `metadata/com.concealnetwork.concealmobile.yml` to `metadata/com.concealnetwork.concealmobile.yml` in your fork
   - Add screenshots to `metadata/Screenshots/`

3. **Create Pull Request**:
   - Submit a pull request to the main F-Droid repository
   - Include a description of your app

4. **Review Process**:
   - F-Droid maintainers will review your submission
   - They may request changes or additional information

### Option 2: Email Submission
If you prefer not to use GitHub, you can also submit via email:
1. **Prepare Files**:
   - Create a zip file with your metadata and screenshots
   - Include a description of your app

2. **Email Submission**:
   - Send to: fdroid@lists.f-droid.org
   - Subject: "App submission: Conceal Mobile Wallet"
   - Include all required files and information

### Option 3: Forum Submission
1. **Join F-Droid Forum**:
   - Go to https://forum.f-droid.org/
   - Create an account

2. **Post Submission**:
   - Create a new topic in the "App Requests" section
   - Include your metadata file and screenshots
   - Provide app description and links

## 🔧 Build Configuration Details

### Metadata File Structure
The metadata file includes:
- **Categories**: Finance, Internet
- **License**: MIT
- **Build Configuration**: Gradle-based build
- **Dependencies**: All Cordova plugins listed as source libraries

### Build Process
1. F-Droid will clone your repository
2. Run the gradle build process
3. Generate the APK using the specified configuration

### Version Management
- Current version: 5.0.0
- Version code: 46
- Auto-update mode: Version-based
- Update check: Git tags

## 🚀 Next Steps

1. **Add Screenshots**: Take actual screenshots of your app
2. **Test Build**: Ensure the build scripts work correctly
3. **Submit**: Follow the F-Droid submission process
4. **Monitor**: Track the review process and respond to feedback

## 📞 Support

For questions about F-Droid submission:
- F-Droid Documentation: https://f-droid.org/docs/
- F-Droid GitHub: https://github.com/fdroid/fdroiddata
- F-Droid Forum: https://forum.f-droid.org/
- F-Droid Email: fdroid@lists.f-droid.org

## 📄 License

This project is licensed under the MIT License, which is compatible with F-Droid requirements. 