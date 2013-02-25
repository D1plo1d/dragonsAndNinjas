/*
 * http://stackoverflow.com/questions/865590/unit-of-measure-conversion-library
 * Unknown Licence
 * posted by jvenema on stackoverflow on August 20th 2010
 * String parsing and distances patch by d1plo1d
 */

(function () {
    var table = {};

    window.unitConverter = function (value, unit) {
        this.value = value;
        if (unit) {
            this.currentUnit = unit;
            this.targetUnit = unit;
        }
    };
    unitConverter.prototype.as = function (targetUnit) {
        this.targetUnit = targetUnit;
        return this;
    };
    unitConverter.prototype.is = function (currentUnit) {
        this.currentUnit = currentUnit;
        return this;
    };

    unitConverter.prototype.val = function () {
        // first, convert from the current value to the base unit
        var target = table[this.targetUnit];
        var current = table[this.currentUnit];
        if (target.base != current.base) {
            throw new Error('Incompatible units; cannot convert from "' + this.currentUnit + '" to "' + this.targetUnit + '"');
        }
        return this.value * (current.multiplier / target.multiplier);
    };
    unitConverter.prototype.toString = function () {
        if (this.targetUnit == "'"){
            val = this.val();
            ft = Math.floor(val);
            inch = Math.round(120*(val - ft)/10);
            if (inch != 0 && ft != 0){
                return ft + "'  " + inch + "\"";
            } else if (inch == 0){
                return ft + "'";
            } else if (ft == 0) {
                return inch + "\"" ;
            }
        }
        return this.val() + ' ' + this.targetUnit;
    };
    unitConverter.prototype.debug = function () {
        return this.value + ' ' + this.currentUnit + ' is ' + this.val() + ' ' + this.targetUnit;
    };
    unitConverter.addUnit = function (baseUnit, actualUnit, multiplier) {
        table[actualUnit] = { base: baseUnit, actual: actualUnit, multiplier: multiplier };
    };

    var prefixes = ['Y', 'Z', 'E', 'P', 'T', 'G', 'M', 'k', 'h', 'da', '', 'd', 'c', 'm', 'u', 'n', 'p', 'f', 'a', 'z', 'y'];
    var factors = [24, 21, 18, 15, 12, 9, 6, 3, 2, 1, 0, -1, -2, -3, -6, -9, -12, -15, -18, -21, -24];
    // SI units only, that follow the mg/kg/dg/cg type of format
    var units = ['g', 'b', 'l', 'm'];

    for (var j = 0; j < units.length; j++) {
        var base = units[j];
        for (var i = 0; i < prefixes.length; i++) {
            unitConverter.addUnit(base, prefixes[i] + base, Math.pow(10, factors[i]));
        }
    }

    // we use the SI gram unit as the base; this allows
    // us to convert between SI and English units

    // Weights
    unitConverter.addUnit('g', 'ounces', 28.3495231);
    unitConverter.addUnit('g', 'oz', 28.3495231);
    unitConverter.addUnit('g', 'pounds', 453.59237);
    unitConverter.addUnit('g', 'lb', 453.59237);


    // Distances
    unitConverter.addUnit('m', '"', 0.0254);
    unitConverter.addUnit('m', 'inches', 0.0254);
    unitConverter.addUnit('m', '\'', 0.3048);
    unitConverter.addUnit('m', 'feet', 0.3048);
    unitConverter.addUnit('m', 'miles', 1609.344);

    unitConverter.addUnit("deg", "°", 1.0);
    unitConverter.addUnit("deg", "deg", 1.0);
    unitConverter.addUnit("deg", "degrees", 1.0);
    unitConverter.addUnit("deg", "rad", 57.296);
    unitConverter.addUnit("deg", "radians", 57.296);
    unitConverter.addUnit("deg", "grad", 1.11);
    unitConverter.addUnit("deg", "gradian", 1.11);
    unitConverter.addUnit("deg", "turn", 360);


    window.$u = function (value, unit) {
        //$u(String) parses the string and returns a unit converter instance
        if (typeof(value) == "string")
        {
          if ( value.match("(([0-9]*.?[0-9]*) *')? *(([0-9]*.?[0-9]*) *\"?)? *")[0] == value
            && value.match(" *")[0] != value                                                 ) // imperial distances
          {
            matches = new RegExp("(([0-9.]*) *')? *(([0-9.]*) *\"?)? *").exec(value);
            if (matches[2] == null || matches[2].length == 0) 
                return $u(parseFloat(matches[4])||0, "\"")
            if (matches[4] == null || matches[4].length == 0)
                return $u(parseFloat(matches[2])||0, "\'")
            return $u(parseFloat(matches[2]) + parseFloat(matches[4])/12, "\'")
          }
          else if (value.match("(([0-9.]*) *?([pnμmcdkMG]?m))?")[0] == value) // metric
          {
            matches = new RegExp("([0-9.]*) *?([pnμmcdkMG]?m)").exec(value);
            return $u( parseFloat(matches[1]), (matches[2] == null? "m" : matches[2]) );
          } else {
            matches = new RegExp("([0-9.]*) *([^0-9 ]*)").exec(value);
            return $u( parseFloat(matches[1]), matches[2] );
          }
          // TODO: throw exceptions for invalid measurements
        }

        //$u(value, unit) returns a unit converter instance
        else
        {
          var u = new window.unitConverter(value, unit);
          return u;
        }
    };
})();
