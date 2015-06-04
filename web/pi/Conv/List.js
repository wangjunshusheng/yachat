// Generated by CoffeeScript 1.9.3
var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

define(["pi/Pi", "pi/m/Source"], function(aPi, mSource) {
  var ConvList;
  return ConvList = (function(superClass) {
    extend(ConvList, superClass);

    function ConvList() {
      return ConvList.__super__.constructor.apply(this, arguments);
    }

    ConvList.prototype.attr = function() {
      return ConvList.__super__.attr.apply(this, arguments).concat(["view"]);
    };

    ConvList.prototype.init = function() {
      this.sub("#bullet@user/conv_list", (function(_this) {
        return function(ev, args) {
          var List, conv, i, len, status, tmpl;
          _this.empty();
          status = args[0], List = args[1];
          tmpl = _this.rt.source(_this.a.view);
          for (i = 0, len = List.length; i < len; i++) {
            conv = List[i];
            _this.e.append(tmpl({
              id: conv
            }));
          }
          return _this.rt.pi(_this.e);
        };
      })(this));
      this.sub("#bullet@conv/status/join", (function(_this) {
        return function(ev, args) {
          return _this.rpc("#bullet@query_convs");
        };
      })(this));
      return this.sub("#bullet@conv/status/part", (function(_this) {
        return function(ev, args) {
          return _this.rpc("#bullet@query_convs");
        };
      })(this));
    };

    return ConvList;

  })(aPi);
});
