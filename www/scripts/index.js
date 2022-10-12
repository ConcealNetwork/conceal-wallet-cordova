var app = {
    // Application Constructor
    initialize: function () {
        this.bindEvents();
    },
    bindEvents: function () {
        document.addEventListener('deviceready', this.onDeviceReady, false);
    },
    onDeviceReady: function () {
        app.receivedEvent('deviceready');
        // Here, we redirect to the web site.
        var targetUrl = "https://wallet.conceal.network/?platform=" + cordova.platformId;
        var bkpLink = document.getElementById("bkpLink");
        bkpLink.setAttribute("href", targetUrl);
        bkpLink.text = targetUrl;
        window.location.replace(targetUrl);

				// get camera permission
				var permissions = cordova.plugins.permissions;
				permissions.requestPermission(permissions.CAMERA, success, error);

				function error() {
					console.warn('Camera permission is not turned on');
				}

				function success( status ) {
					if( !status.hasPermission ) error();
				}

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