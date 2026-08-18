cordova.define("cordova-plugin-biometric-unlock.BiometricUnlock", function(require, exports, module) {
var exec = require("cordova/exec");

function promisify(action, args) {
  return new Promise(function (resolve, reject) {
    exec(resolve, reject, "BiometricUnlock", action, args || []);
  });
}

module.exports = {
  isAvailable: function () {
    return promisify("isAvailable", []).then(function (value) {
      return value === 1 || value === true;
    });
  },
  enroll: function () {
    return promisify("enroll", []);
  },
  unlock: function (credentialId) {
    return promisify("unlock", [credentialId]);
  },
  remove: function (credentialId) {
    return promisify("remove", [credentialId]);
  },
};

});
