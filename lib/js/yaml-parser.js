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
        if (typeof(val) == "object")
        {
          str += ((keyIsNumber)? "- " : key + ":\n") + YAML.dump(val, indent+2, keyIsNumber);
        }
        else
        {
          str += (keyIsNumber)? ("- ") : (key + ": ");
          if(typeof(val) == "number")
          {
            str += val;
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
    }

  }
})()
