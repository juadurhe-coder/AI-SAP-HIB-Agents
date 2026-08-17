sap.ui.define([
    "sap/ui/core/mvc/Controller"
], function (Controller) {

    return Controller.extend("com.legacy.app.controller.Main", {
        onPress: function () {
            jQuery.sap.require("sap.m.MessageToast");
            var elem = document.getElementById("customInput");
            elem.style.color = "red";
            
            jQuery.ajax({
                url: "/api/sync",
                async: false
            });
        }
    });
});
