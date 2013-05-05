// Generated by IcedCoffeeScript 1.3.3g
(function() {
  var __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  module.exports = function(field, val) {
    var expectedKeys, i, item, k, key, keys, v, _i, _j, _k, _l, _len, _len1, _len2, _ref;
    if (field.optional && !(val != null)) return true;
    if (field.type === 'file' && field.images) {
      expectedKeys = [];
      for (key in field.images) {
        expectedKeys.push(key);
      }
      i = 0;
      if (typeof val !== 'object') return false;
      if (!(val != null)) return false;
      keys = [];
      for (k in val) {
        v = val[k];
        keys.push(k);
      }
      if (keys.length !== expectedKeys.length) return false;
      for (_i = 0, _len = expectedKeys.length; _i < _len; _i++) {
        k = expectedKeys[_i];
        if (!(__indexOf.call(keys, k) >= 0)) return false;
      }
      for (_j = 0, _len1 = keys.length; _j < _len1; _j++) {
        k = keys[_j];
        if (typeof val[k].url !== 'string') return false;
        if (typeof val[k].width !== 'number' || val[k].width < 1) return false;
        if (typeof val[k].height !== 'number' || val[k].height < 1) return false;
      }
      return true;
    } else if (field.type === 'text') {
      return typeof val === 'string' && val.trim().length > 0;
    } else if (field.type === 'textarea') {
      return typeof val === 'string' && val.trim().length > 0;
    } else if (field.type === 'wysiwyg') {
      return typeof val === 'string' && val.trim().length > 0;
    } else if (field.type === 'markdown') {
      return typeof val === 'string' && val.trim().length > 0;
    } else if (field.type === 'choice') {
      return typeof val === 'string' && val.trim().length > 0;
    } else if (field.type === 'date') {
      return typeof val === 'number' && Math.floor(val) === val;
    } else if (field.type === 'color') {
      if (!(val != null ? val.length : void 0) === 7) return false;
      if (!val.charAt(0) === '#') return false;
      for (i = _k = 1; _k <= 6; i = ++_k) {
        if (!((_ref = val.charAt(i).toLowerCase()) === '1' || _ref === '2' || _ref === '3' || _ref === '4' || _ref === '5' || _ref === '6' || _ref === '7' || _ref === '8' || _ref === '9' || _ref === 'a' || _ref === 'b' || _ref === 'c' || _ref === 'd' || _ref === 'e' || _ref === 'f')) {
          return false;
        }
      }
      return true;
    } else if (field.type === 'tags') {
      if (!(val instanceof Array)) return false;
      for (_l = 0, _len2 = val.length; _l < _len2; _l++) {
        item = val[_l];
        if (!typeof item === 'string') return false;
      }
      return true;
    } else {
      return false;
    }
  };

}).call(this);