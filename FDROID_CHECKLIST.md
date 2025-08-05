# F-Droid Requirements Checklist

## ✅ Completed Requirements

### 1. Metadata File
- **File**: `metadata/com.concealnetwork.concealmobile.yml`
- **Status**: ✅ Complete
- **Contains**:
  - App description and features
  - Categories (Finance, Internet)
  - License (MIT)
  - Source code and issue tracker links
  - Build configuration
  - Screenshots section (placeholders)

### 2. Gradle Configuration
- **Files**: 
  - `build.gradle` (root level)
  - `settings.gradle`
  - `platforms/android/build.gradle` (existing)
  - `platforms/android/app/build.gradle` (existing)
- **Status**: ✅ Complete
- **Features**:
  - F-Droid specific build task
  - APK output configuration
  - Dependency management

### 3. Build Scripts
- **Files**:
  - `build-fdroid.sh` (Linux/macOS)
  - `build-fdroid.bat` (Windows)
- **Status**: ✅ Complete
- **Features**:
  - Automated Cordova build process
  - Plugin installation
  - APK generation and copying

### 4. Screenshots Directory
- **Directory**: `metadata/Screenshots/`
- **Status**: ✅ Structure created
- **Needed**: Actual screenshots

### 5. Project Structure
- **Status**: ✅ Complete
- **Features**:
  - Proper gitignore entries
  - Documentation files
  - Build configuration

## 📋 Still Required

### Screenshots
**Priority**: HIGH
**Files needed**:
- `metadata/Screenshots/main-wallet.png`
- `metadata/Screenshots/send-transaction.png`
- `metadata/Screenshots/receive-qr.png`
- `metadata/Screenshots/settings.png`

**Requirements**:
- PNG format
- Minimum 320x320 pixels
- Actual app screenshots (no mockups)
- No device frames

### Build Testing
**Priority**: HIGH
**Action needed**:
```bash
# Test the build process
./build-fdroid.sh  # Linux/macOS
# or
build-fdroid.bat   # Windows
```

## 📝 F-Droid Submission Steps

1. **Add Screenshots** (Required)
   - Take screenshots of your app
   - Place them in `metadata/Screenshots/`
   - Update metadata file if needed

2. **Test Build** (Required)
   - Run build scripts
   - Verify APK generation
   - Check for any build errors

3. **Fork F-Droid Data Repository**
   - Go to https://gitlab.com/fdroid/fdroiddata
   - Fork the repository

4. **Add Your App**
   - Copy metadata file to your fork
   - Add screenshots
   - Create merge request

5. **Submit for Review**
   - F-Droid maintainers will review
   - Respond to any feedback

**Alternative Submission Methods**:
- **Email**: Send to fdroid@lists.f-droid.org
- **Forum**: Post at https://forum.f-droid.org/

## 🔧 Technical Details

### App Information
- **Package Name**: com.ConcealNetwork.ConcealMobile
- **Version**: 5.0.0
- **Version Code**: 46
- **License**: MIT
- **Categories**: Finance, Internet

### Build Configuration
- **Build System**: Gradle
- **Android SDK**: 35
- **Min SDK**: 22
- **Target SDK**: 35
- **Dependencies**: Cordova plugins listed as source libraries

### Repository Information
- **Source**: https://github.com/ConcealNetwork/conceal-wallet-cordova
- **Issues**: https://github.com/ConcealNetwork/conceal-wallet-cordova/issues
- **Releases**: https://github.com/ConcealNetwork/conceal-wallet-cordova/releases

## 🎯 Next Actions

1. **Immediate** (Before submission):
   - [ ] Add actual screenshots
   - [ ] Test build process
   - [ ] Verify all files are correct

2. **Submission**:
   - [ ] Fork F-Droid data repository
   - [ ] Add metadata and screenshots
   - [ ] Create merge request
   - [ ] Monitor review process

## 📞 Support Resources

- **F-Droid Documentation**: https://f-droid.org/docs/
- **F-Droid GitLab**: https://gitlab.com/fdroid/fdroiddata
- **F-Droid Forum**: https://forum.f-droid.org/
- **F-Droid Wiki**: https://f-droid.org/wiki/

---

**Status**: Ready for screenshots and testing! 🚀 