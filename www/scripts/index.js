// App configuration
var APP_VERSION = "4.0.4";
var APP_COPYRIGHT_YEAR = new Date().getFullYear();

var app = {
    // Application Constructor
    initialize: function () {
        this.bindEvents();
        
        // Update version and copyright in the HTML
        this.updateVersionInfo();
        
        // Fallback timeout in case deviceready never fires
        setTimeout(function() {
            if (!app.deviceReadyFired) {
                app.performRedirect();
            }
        }, 2000); // 2 second fallback
    },
    bindEvents: function () {
        document.addEventListener('deviceready', this.onDeviceReady, false);
    },
    onDeviceReady: function () {
        app.deviceReadyFired = true;
        app.receivedEvent('deviceready');
        app.performRedirect();
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
        
        // Request camera permission (non-blocking)
        try {
            var permissions = cordova.plugins.permissions;
            permissions.requestPermission(permissions.CAMERA, function(status) {
                // Permission result - do nothing
            }, function(error) {
                // Permission error - do nothing
            });
        } catch (error) {
            // Permission plugin error - do nothing
        }

       
    },
    updateVersionInfo: function() {
        // Update version info in the HTML
        var versionElements = document.querySelectorAll('.version-info div');
        if (versionElements.length >= 3) {
            versionElements[0].textContent = 'APK version ' + APP_VERSION;
            versionElements[2].textContent = 'copyright 2018-' + APP_COPYRIGHT_YEAR;
        }
    },
    performRedirect: function() {
        // Here, we redirect to the web site.
        var targetUrl = "https://wallet.conceal.network/?platform=" + cordova.platformId;
        var bkpLink = document.getElementById("bkpLink");
        bkpLink.setAttribute("href", targetUrl);
        bkpLink.text = targetUrl;

        setTimeout(function() {
            window.location.replace(targetUrl);
        }, 2000);
    },
    // Note: This code is taken from the Cordova CLI template.
    receivedEvent: function (id) {
        var parentElement = document.getElementById(id);
        var listeningElement = parentElement.querySelector('.listening');
        var receivedElement = parentElement.querySelector('.received');
        listeningElement.setAttribute('style', 'display:none;');
        receivedElement.setAttribute('style', 'display:block;');
        console.log('Received Event: ' + id);
    }
    
};

app.initialize();