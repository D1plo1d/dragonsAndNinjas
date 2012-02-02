/*
 * Authors:
 *  - D1plo1d (basic/glitchy hash, array, number, and string -> yaml functionality)
 *
 * Example usage:
 *  console.log( YAML.dump( {test: "a", test2: ["b", "c"]} ) );
 */


;(function(){
  YAML = {
    /* Dump Components
     * ================= */
    dump: function(obj, indent, indentFirst) {
      str = "";
      if (indentFirst == undefined || indentFirst == null)
      {
        str += "---\n";
      }
      if (indent == null) indent = 0;
      first = true;
      // TODO: better array detection

      // Hashes and Arrays (and hashes with any number keys will be misdetected. yes this is that shoddy.)
      for (key in obj)
      {
        // Indentation
        if (first == false || indentFirst == false)
        {
          for (i = 0; i < indent; i++)
          {
            str += " ";
          }
        }
        else
        {
          first = false;
        };

        // Key
        keyIsNumber = ( "" + parseInt(key) ) == key;

        // Key and Value
        val = obj[key];

        if(val == null || val == undefined)
        {
          str += (keyIsNumber)? ("- ") : (key + ": ");
          str += "null"
        }
        else if (typeof(val) == "object")
        {
          if (keyIsNumber == true)
          {
            str += "- " + YAML.dump(val, indent+2, keyIsNumber);
          }
          else
          {
             valIsArray = (val.length > 0 && val[0] != undefined  && val[0] != null)
             str += key + ":\n" + YAML.dump(val, indent + (valIsArray? 0 : 2), keyIsNumber);
          }
        }
        else
        {
          str += (keyIsNumber)? ("- ") : (key + ": ");
          if(typeof(val) == "number")
          {
            str += '"' + val + '"';
          }
          else
          {
            str += '"' + val + '"';
          };
        };

        // New Line
        str += "\n"
      };
      return str;
    },


    parse: function(str) {
      // TODO
    }

  }
})()
