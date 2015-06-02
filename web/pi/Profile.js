// Generated by CoffeeScript 1.9.3
var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty,
  slice = [].slice;

define(["pi/Pi"], function(Pi) {
  var Profile;
  return Profile = (function(superClass) {
    extend(Profile, superClass);

    function Profile() {
      return Profile.__super__.constructor.apply(this, arguments);
    }

    Profile.prototype.attr = function() {
      return Profile.__super__.attr.apply(this, arguments).concat(["row"]);
    };

    Profile.prototype.init = function() {
      return this.sub("#bullet@user/register", (function(_this) {
        return function(e, args) {
          var status;
          return status = args[0], args;
        };
      })(this));
    };

    Profile.prototype.error = function() {
      var m;
      m = 1 <= arguments.length ? slice.call(arguments, 0) : [];
      return this.rt.append("dialog/error", {
        text: m
      });
    };

    return Profile;

  })(Pi);
});