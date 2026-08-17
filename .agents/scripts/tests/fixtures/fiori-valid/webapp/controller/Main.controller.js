sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/ui/model/json/JSONModel"
], function (Controller, JSONModel) {
    "use strict";

    return Controller.extend("com.hiberus.salesorder.controller.Main", {
        onInit: function () {
            var oViewModel = new JSONModel({
                busy: false
            });
            this.getView().setModel(oViewModel, "viewModel");
        },

        onSaveOrder: function () {
            var oModel = this.getView().getModel();
            oModel.submitBatch("orderGroup");
        }
    });
});
