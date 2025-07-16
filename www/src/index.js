/*
 * Copyright (c) 2018 Gnock
 * Copyright (c) 2018-2019 The Masari Project
 * Copyright (c) 2018-2020 The Karbo developers
 * Copyright (c) 2018-2025 Conceal Community, Conceal.Network & Conceal Devs
 *
 * Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 *
 * 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

﻿// App configuration
var APP_VERSION = "5.0.0";
var APP_COPYRIGHT_YEAR = new Date().getFullYear();

// Function to show version info for 3 seconds then hide it
function updateVersionInfo() {
    // Create version info div if it doesn't exist
    var versionInfo = document.querySelector('.version-info');
    if (!versionInfo) {
        versionInfo = document.createElement('div');
        versionInfo.className = 'version-info';
        versionInfo.innerHTML = `
            <div>APK version loading...</div>
            <div>developed by the Conceal Devs</div>
            <br>
            <div>copyright loading...</div>
        `;
        document.body.appendChild(versionInfo);
    }
    
    // Create network status indicator if it doesn't exist
    var networkStatus = document.querySelector('.network-status');
    if (!networkStatus) {
        networkStatus = document.createElement('div');
        networkStatus.className = 'network-status';
        networkStatus.innerHTML = `
            <div class="network-indicator">
                <span class="network-icon">🌐</span>
                <span class="network-text">Checking network...</span>
            </div>
        `;
        networkStatus.style.cssText = `
            position: fixed;
            top: 10px;
            right: 10px;
            background: rgba(0,0,0,0.8);
            color: white;
            padding: 8px 12px;
            border-radius: 20px;
            font-size: 12px;
            z-index: 10000;
            display: none;
        `;
        document.body.appendChild(networkStatus);
    }
    
    // Update version info
    var versionElements = versionInfo.querySelectorAll('div');
    if (versionElements.length >= 3) {
        // Use app-version plugin if available, otherwise fallback to APP_VERSION
        if (window.cordova && window.cordova.getAppVersion) {
            window.cordova.getAppVersion.getVersionNumber().then(function(version) {
                versionElements[0].textContent = 'APK version ' + version;
            }).catch(function() {
                versionElements[0].textContent = 'APK version ' + APP_VERSION;
            });
        } else {
            versionElements[0].textContent = 'APK version ' + APP_VERSION;
        }
        versionElements[2].textContent = 'copyright 2018-' + APP_COPYRIGHT_YEAR;
    }
    
    // Show version info for 3 seconds then hide it
    versionInfo.style.display = 'block';
    setTimeout(function() {
        if (versionInfo && versionInfo.parentNode) {
            versionInfo.style.display = 'none';
        }
    }, 3000);
}

// Function called when Cordova device is ready
function onDeviceReady() {
    console.log('📱 Cordova deviceready event fired');
    
    // Hide the native splash screen to show our HTML content
    try {
        navigator.splashscreen.hide();
    } catch (error) {
        // Splash screen plugin not available
    }
    
    // Ensure all splash screen content is visible
    var connectivity = document.querySelector('.connectivity');
    var versionInfo = document.querySelector('.version-info');
    if (connectivity) connectivity.style.display = 'block';
    if (versionInfo) versionInfo.style.display = 'block';
    
    // Keep screen awake for wallet app (prevents screen timeout)
    try {
        if (window.plugins && window.plugins.insomnia) {
            window.plugins.insomnia.keepAwake();
            console.log('📱 Screen will stay awake');
        }
    } catch (error) {
        // Insomnia plugin not available
    }
    
    // Request camera permission (non-blocking)
    try {
        if (window.cordova && window.cordova.plugins && window.cordova.plugins.permissions) {
            console.log('📷 Requesting camera permission via Cordova plugin');
            window.cordova.plugins.permissions.requestPermission(
                window.cordova.plugins.permissions.CAMERA,
                function(status) {
                    if (status.hasPermission) {
                        console.log('📷 Camera permission granted via Cordova plugin');
                    } else {
                        console.log('📷 Camera permission denied via Cordova plugin');
                    }
                },
                function() {
                    console.log('📷 Camera permission request failed via Cordova plugin');
                }
            );
        } else {
            // Fallback to getUserMedia API
            console.log('📷 Requesting camera permission via getUserMedia API');
            if (navigator.mediaDevices && navigator.mediaDevices.getUserMedia) {
                navigator.mediaDevices.getUserMedia({ video: true })
                    .then(function(stream) {
                        console.log('📷 Camera permission granted via getUserMedia');
                        // Stop the stream immediately - we just needed permission
                        stream.getTracks().forEach(track => track.stop());
                    })
                    .catch(function(err) {
                        console.log('📷 Camera permission request failed via getUserMedia:', err);
                    });
            }
        }
    } catch (error) {
        console.log('📷 Camera permission plugin error:', error);
    }
    
    // Check network connectivity for Cordova apps
    try {
        if (window.cordova && window.cordova.connection) {
            console.log('🌐 Network type:', window.cordova.connection.type);
            console.log('🌐 Network effective type:', window.cordova.connection.effectiveType);
            
            // Listen for network changes
            document.addEventListener('online', function() {
                console.log('🌐 Network connection restored');
                // Try to reconnect to nodes when network is restored
                if (window.router && window.router.currentPage && window.router.currentPage.refresh) {
                    setTimeout(function() {
                        window.router.currentPage.refresh();
                    }, 1000);
                }
            }, false);
            
            document.addEventListener('offline', function() {
                console.log('🌐 Network connection lost');
            }, false);
        }
    } catch (error) {
        console.log('🌐 Network connectivity check error:', error);
    }
    
    // Test network connectivity to Conceal nodes
    setTimeout(function() {
        console.log('🌐 Testing connectivity to Conceal nodes...');
        var networkStatus = document.querySelector('.network-status');
        if (networkStatus) {
            networkStatus.style.display = 'block';
        }
        testNetworkConnectivity(false);
    }, 5000); // Increased delay to 5 seconds
    
    // Function to update network status indicator
    function updateNetworkStatus(reachableNodes, totalNodes, isRetry) {
        var networkStatus = document.querySelector('.network-status');
        if (networkStatus) {
            var networkText = networkStatus.querySelector('.network-text');
            var networkIcon = networkStatus.querySelector('.network-icon');
            
            if (reachableNodes > 0) {
                networkIcon.textContent = '✅';
                networkText.textContent = 'Network OK (' + reachableNodes + '/' + totalNodes + ')';
                networkStatus.style.background = 'rgba(0,128,0,0.8)';
                
                // Hide after 3 seconds if network is good
                setTimeout(function() {
                    if (networkStatus) {
                        networkStatus.style.display = 'none';
                    }
                }, 3000);
            } else {
                networkIcon.textContent = '❌';
                networkText.textContent = 'No nodes reachable';
                networkStatus.style.background = 'rgba(255,0,0,0.8)';
                
                // Retry once after 3 seconds if first attempt failed
                if (!isRetry) {
                    setTimeout(function() {
                        console.log('🌐 Retrying network connectivity test...');
                        testNetworkConnectivity(true);
                    }, 3000);
                }
            }
        }
    }
    
    // Function to test network connectivity
    function testNetworkConnectivity(isRetry) {
        if (window.config && window.config.nodeList) {
            var reachableNodes = 0;
            var totalNodes = window.config.nodeList.length;
            
            window.config.nodeList.forEach(function(nodeUrl, index) {
                fetch(nodeUrl + 'getinfo', { 
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ jsonrpc: '2.0', id: 'test', method: 'getinfo', params: {} }),
                    timeout: 10000 // Increased timeout
                }).then(function(response) {
                    console.log('🌐 Node ' + (index + 1) + ' (' + nodeUrl + ') is reachable');
                    reachableNodes++;
                    updateNetworkStatus(reachableNodes, totalNodes, isRetry);
                }).catch(function(error) {
                    console.log('🌐 Node ' + (index + 1) + ' (' + nodeUrl + ') is not reachable:', error.message);
                    updateNetworkStatus(reachableNodes, totalNodes, isRetry);
                });
            });
        }
    }
    
    // Hide loading screen after a short delay to ensure smooth transition
    setTimeout(function() {
        $('#pageLoading').hide();
    }, 500);
}

var __extends = (this && this.__extends) || (function () {
    var extendStatics = function (d, b) {
        extendStatics = Object.setPrototypeOf ||
            ({ __proto__: [] } instanceof Array && function (d, b) { d.__proto__ = b; }) ||
            function (d, b) { for (var p in b) if (Object.prototype.hasOwnProperty.call(b, p)) d[p] = b[p]; };
        return extendStatics(d, b);
    };
    return function (d, b) {
        if (typeof b !== "function" && b !== null)
            throw new TypeError("Class extends value " + String(b) + " is not a constructor or null");
        extendStatics(d, b);
        function __() { this.constructor = d; }
        d.prototype = b === null ? Object.create(b) : (__.prototype = b.prototype, new __());
    };
})();
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
define(["require", "exports", "./lib/numbersLab/Router", "./model/Mnemonic", "./lib/numbersLab/VueAnnotate", "./model/Storage", "./model/Translations", "./lib/numbersLab/messageClick"], function (require, exports, Router_1, Mnemonic_1, VueAnnotate_1, Storage_1, Translations_1, messageClick_1) {
    "use strict";
    Object.defineProperty(exports, "__esModule", { value: true });
    //========================================================
    //bridge for cnUtil with the new mnemonic class
    //========================================================
    window.mn_random = Mnemonic_1.Mnemonic.mn_random;
    window.mn_encode = Mnemonic_1.Mnemonic.mn_encode;
    window.mn_decode = Mnemonic_1.Mnemonic.mn_decode;
    //========================================================
    //====================Translation code====================
    //========================================================
    var i18n = new VueI18n({
        locale: 'en',
        fallbackLocale: 'en',
    });
    window.i18n = i18n;
    var browserUserLang = '' + (navigator.language || navigator.userLanguage);
    browserUserLang = browserUserLang.toLowerCase().split('-')[0];
    // Create a promise that resolves when i18n is ready
    var i18nReadyPromise = new Promise(function (resolve) {
        Storage_1.Storage.getItem('user-lang', browserUserLang).then(function (userLang) {
            if (userLang) {
                Translations_1.Translations.loadLangTranslation(userLang).catch(function (err) {
                    console.error("Failed to load '".concat(userLang, "' language"), err);
                    return Translations_1.Translations.loadLangTranslation('en');
                }).catch(function (err) {
                    console.error("Failed to load 'en' language", err);
                }).finally(function () {
                    resolve();
                });
            }
            else {
                resolve();
            }
        });
    });
    window.i18nReadyPromise = i18nReadyPromise;
    window.safeSwal = function (options) {
        return i18nReadyPromise.then(function () {
            return swal(options);
        });
    };
    //========================================================
    //====================Generic design======================
    //========================================================
    var MenuView = /** @class */ (function (_super) {
        __extends(MenuView, _super);
        function MenuView(containerName, vueData) {
            if (vueData === void 0) { vueData = null; }
            var _this = _super.call(this, vueData) || this;
            _this.isMenuHidden = false;
            _this.isMenuHidden = $('body').hasClass('menuHidden');
            if ($('body').hasClass('menuDisabled'))
                _this.isMenuHidden = true;
            _this.update();
            return _this;
        }
        MenuView.prototype.toggle = function () {
            if ($('body').hasClass('menuDisabled'))
                this.isMenuHidden = true;
            else
                this.isMenuHidden = !this.isMenuHidden;
            this.update();
        };
        MenuView.prototype.update = function () {
            if (this.isMenuHidden)
                $('body').addClass('menuHidden');
            else
                $('body').removeClass('menuHidden');
        };
        MenuView = __decorate([
            (0, VueAnnotate_1.VueClass)()
        ], MenuView);
        return MenuView;
    }(Vue));
    var menuView = new MenuView('#menu');
    $('#menu a').on('click', function (event) {
        menuView.toggle();
    });
    $('#menu').on('click', function (event) {
        event.stopPropagation();
    });
    $('#topBar .toggleMenu').on('click', function (event) {
        menuView.toggle();
        event.stopPropagation();
        return false;
    });
    $(window).click(function () {
        menuView.isMenuHidden = true;
        $('body').addClass('menuHidden');
    });
    //mobile swipe
    var pageWidth = window.innerWidth || document.body.clientWidth;
    var treshold = Math.max(1, Math.floor(0.2 * (pageWidth)));
    var touchstartX = 0;
    var touchstartY = 0;
    var touchendX = 0;
    var touchendY = 0;
    var gestureZone = $('body')[0];
    gestureZone.addEventListener('touchstart', function (event) {
        touchstartX = event.changedTouches[0].screenX;
        touchstartY = event.changedTouches[0].screenY;
    }, false);
    gestureZone.addEventListener('touchend', function (event) {
        touchendX = event.changedTouches[0].screenX;
        touchendY = event.changedTouches[0].screenY;
        handleGesture(event);
    }, false);
    var limit = 0.8; // Add this constant before handleGesture function
    function handleGesture(e) {
        var x = touchendX - touchstartX;
        var y = touchendY - touchstartY;
        var xy = Math.abs(x / y);
        var yx = Math.abs(y / x);
        if (Math.abs(x) > treshold) { // || Math.abs(y) > treshold      ----- >   do we care about y other than a big diagonal swipe already taken into account by xy and yx ?
            if (yx <= limit) {
                if (x < 0) {
                    //left
                    if (!menuView.isMenuHidden)
                        menuView.toggle();
                }
                else {
                    //right
                    if (menuView.isMenuHidden)
                        menuView.toggle();
                }
            }
            else if (xy <= limit) {
                if (y < 0) {
                    //top
                }
                else {
                    //bottom
                }
            }
        }
        else {
            //tap
        }
    }
    //Collapse the menu after clicking on a menu item
    function navigateToPage(page) {
        window.location.hash = "!".concat(page);
    }
    function isMobileDevice() {
        return window.innerWidth <= 600; // Adjust this breakpoint as needed
    }
    // Select all menu items
    var menuItems = document.querySelectorAll('#menu a[href^="#!"]');
    menuItems.forEach(function (item) {
        item.addEventListener('click', function (event) {
            // Prevent the default action
            event.preventDefault();
            var target = event.currentTarget.getAttribute('href');
            if (target) {
                // Remove the "#!" from the beginning of the href
                var page = target.substring(2);
                navigateToPage(page);
                // Toggle the menu off only on mobile devices
                if (isMobileDevice() && !menuView.isMenuHidden) {
                    menuView.toggle();
                }
            }
        });
    });
    var CopyrightView = /** @class */ (function (_super) {
        __extends(CopyrightView, _super);
        function CopyrightView(containerName, vueData) {
            if (vueData === void 0) { vueData = null; }
            var _this = _super.call(this, vueData) || this;
            Translations_1.Translations.getLang().then(function (userLang) {
                _this.language = userLang;
            });
            _this.isNative = window.native;
            return _this;
        }
        CopyrightView.prototype.languageWatch = function () {
            var _this = this;
            Translations_1.Translations.setBrowserLang(this.language);
            Translations_1.Translations.loadLangTranslation(this.language).catch(function (err) {
                console.error("Failed to load \"".concat(_this.language, "\" language"), err);
            });
        };
        __decorate([
            (0, VueAnnotate_1.VueVar)(false)
        ], CopyrightView.prototype, "isNative", void 0);
        __decorate([
            (0, VueAnnotate_1.VueVar)('en')
        ], CopyrightView.prototype, "language", void 0);
        __decorate([
            (0, VueAnnotate_1.VueWatched)()
        ], CopyrightView.prototype, "languageWatch", null);
        CopyrightView = __decorate([
            (0, VueAnnotate_1.VueClass)()
        ], CopyrightView);
        return CopyrightView;
    }(Vue));
    var copyrightView = new CopyrightView('#copyright');
    //========================================================
    //==================Loading the right page================
    //========================================================
    var isCordovaApp = false;
    // Check for traditional Cordova app (local files)
    var isLocalFileApp = document.URL.indexOf('http://') === -1 && document.URL.indexOf('https://') === -1;
    // Check for WebView app (remote content in WebView)
    var isWebViewApp = navigator.userAgent.includes('Android') && navigator.userAgent.includes('wv');
    // Either local Cordova app or WebView app should be treated as native
    isCordovaApp = isLocalFileApp || isWebViewApp;
    var promiseLoadingReady;
    window.native = false;
    if (isCordovaApp) {
        window.native = true;
        copyrightView.isNative = true;
        $('body').addClass('native');
        
        console.log('📱 Cordova WebView detected - waiting for deviceready');
        
        
        // Update version info immediately for Cordova apps
        updateVersionInfo();
        // Show loading screen immediately for Cordova apps
        $('#pageLoading').show();
        
        // Wait for Cordova to be ready
        let promiseLoadingReadyResolve = null;
        let promiseLoadingReadyReject = null;
        promiseLoadingReady = new Promise(function(resolve, reject) {
            promiseLoadingReadyResolve = resolve;
            promiseLoadingReadyReject = reject;
        });
        
        // Set a timeout in case deviceready never fires
        let timeoutCordovaLoad = setTimeout(function() {
            console.log('⚠️ Cordova deviceready timeout - proceeding anyway');
            if (promiseLoadingReadyResolve) {
                promiseLoadingReadyResolve();
            }
        }, 10000); // 10 second timeout
        
        // Listen for deviceready event
        document.addEventListener('deviceready', function() {
            clearTimeout(timeoutCordovaLoad);
            onDeviceReady();
            if (promiseLoadingReadyResolve) {
                promiseLoadingReadyResolve();
            }
        }, false);
    }
    else
        promiseLoadingReady = Promise.resolve();
    promiseLoadingReady.then(function () {
        var router = new Router_1.Router('./', './');
        window.onhashchange = function () {
            router.changePageFromHash();
        };
        // Initialize message menu after the page is ready
        (0, messageClick_1.initializeMessageMenu)();
    });
    //========================================================
    //==================Service worker for web================
    //========================================================
    //only install the service on web platforms and not native
    console.log("%c                                            \n .d8888b.  888                       888    \nd88P  Y88b 888                       888    \nY88b.      888                       888    This is a browser feature intended for \n \"Y888b.   888888  .d88b.  88888b.   888    developers. If someone told you to copy-paste \n    \"Y88b. 888    d88\"\"88b 888 \"88b  888    something here to enable a feature \n      \"888 888    888  888 888  888  Y8P    or \"hack\" someone's account, it is a \nY88b  d88P Y88b.  Y88..88P 888 d88P         scam and will give them access to your \n \"Y8888P\"   \"Y888  \"Y88P\"  88888P\"   888    Conceal Network Wallet!\n                           888              \n                           888              \n                           888              \n\nIA Self-XSS scam tricks you into compromising your wallet by claiming to provide a way to log into someone else's wallet, or some other kind of reward, after pasting a special code or link into your web browser.", "font-family:monospace");
    if (!isCordovaApp && 'serviceWorker' in navigator) {
        // Flag to prevent showing the same update multiple times
        var updateModalShown_1 = false;
        var showRefreshUI_1 = function (registration) {
            // Prevent showing the same update multiple times
            if (updateModalShown_1) {
                return;
            }
            updateModalShown_1 = true;
            // Use safeSwal which automatically waits for i18n
            window.safeSwal({
                type: 'info',
                title: i18n.t('global.newVersionModal.title'),
                html: i18n.t('global.newVersionModal.content'),
                confirmButtonText: i18n.t('global.newVersionModal.confirmText'),
                showCancelButton: true,
                cancelButtonText: i18n.t('global.newVersionModal.cancelText'),
            }).then(function (value) {
                if (!value.dismiss) {
                    registration.waiting.postMessage('force-activate');
                }
                else {
                    // Reset flag when user cancels so they can see it again later
                    updateModalShown_1 = false;
                }
            });
        };
        var onNewServiceWorker_1 = function (registration, callback) {
            if (registration.waiting) {
                // SW is waiting to activate. Can occur if multiple clients open and
                // one of the clients is refreshed.
                return callback();
            }
            var listenInstalledStateChange = function () {
                registration.installing.addEventListener('statechange', function (event) {
                    if (event.target.state === 'installed') {
                        // A new service worker is available, inform the user
                        callback();
                    }
                });
            };
            if (registration.installing) {
                return listenInstalledStateChange();
            }
            // We are currently controlled so a new SW may be found...
            // Add a listener in case a new SW is found,
            registration.addEventListener('updatefound', listenInstalledStateChange);
        };
        navigator.serviceWorker.addEventListener('message', function (event) {
            if (!event.data) {
                return;
            }
            switch (event.data) {
                case 'reload-window-update':
                    window.location.reload();
                    break;
                default:
                    // NOOP
                    break;
            }
        });
        navigator.serviceWorker.register('/service-worker.js').then(function (registration) {
            // Track updates to the Service Worker.
            if (!navigator.serviceWorker.controller) {
                // The window client isn't currently controlled so it's a new service
                // worker that will activate immediately
                return;
            }
            //console.log('on new service worker');
            onNewServiceWorker_1(registration, function () {
                showRefreshUI_1(registration);
            });
        });
    }

});
