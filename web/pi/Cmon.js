// Generated by CoffeeScript 1.9.3
define([], function() {
  var Cmon;
  return Cmon = (function() {
    function Cmon() {}

    Cmon.get = function(k) {
      var e;
      try {
        return localStorage[k];
      } catch (_error) {
        e = _error;
        return console.log("localstorage fail.");
      }
    };

    Cmon.set = function(k, v) {
      var e;
      try {
        return localStorage[k] = v;
      } catch (_error) {
        e = _error;
        return console.log("localstorage fail set.");
      }
    };

    Cmon.set_user_id = function(user_id) {
      return this.set("user_id", user_id);
    };

    Cmon.set_conv_id = function(conv_id) {
      return this.set("conv_id", conv_id);
    };

    Cmon.user_id = function() {
      return parseInt(this.get("user_id"));
    };

    Cmon.conv_id = function() {
      return parseInt(this.get("conv_id"));
    };

    Cmon.displayName = function(id, name, email) {
      if (name) {
        return name;
      } else if (email) {
        return email;
      } else {
        return id;
      }
    };

    Cmon.displayNameA = function(user) {
      var email, id, name;
      id = user[0], name = user[1], email = user[2];
      return this.displayName(id, name, email);
    };

    return Cmon;

  })();
});