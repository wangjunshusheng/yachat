// Generated by CoffeeScript 1.9.3
var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

define(["pi/Pi"], function(Pi) {
  var ProfileAttr;
  return ProfileAttr = (function(superClass) {
    extend(ProfileAttr, superClass);

    function ProfileAttr() {
      return ProfileAttr.__super__.constructor.apply(this, arguments);
    }

    ProfileAttr.prototype.attr = function() {
      return ProfileAttr.__super__.attr.apply(this, arguments).concat(["target"]);
    };

    ProfileAttr.prototype.init = function() {
      return this.e.click((function(_this) {
        return function(ev, args) {
          return _this.rpc(_this.a.target);
        };
      })(this));
    };

    return ProfileAttr;

  })(Pi);
});