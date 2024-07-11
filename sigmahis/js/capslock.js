$(document).ready(function(){ 
    var cUrl = window.location;
    var capitalize = cUrl.toString().indexOf("expediente3.0") < 0;
    if ("forceCapitalize" in window) {
      if(typeof forceCapitalize==="undefined"||forceCapitalize)capitalize=true;
      else capitalize=false;
    }
    if (capitalize){
        $('input[type=text]').not('.ignore').blur(function() {
            this.value = this.value.toLocaleUpperCase();
        });
        $('textarea').not('.ignore').blur(function() {
            this.value = this.value.toLocaleUpperCase();
        });
    }
 });