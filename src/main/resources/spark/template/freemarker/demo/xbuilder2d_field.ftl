<script>
    function createField() {
        let num = getNewCollectionNum(fields);
        fieldId = "field_" + num;
        let description = "New Field " + (num + 1);
        let id_field = null;
        fields[fieldId] = {fl_name: description};
        if (expData["exname"]) {
            id_field = expData["exname"].substring(0,4) + (num + 1).toString().padStart(4, "0");
        }
        fieldData = fields[fieldId];
        $('#field_list').append('<li><a data-toggle="tab" href="#Field" id="' + fieldId + '" onclick="setField(this);">' + description + '</a></li>');
        if (id_field) {
            fieldData["id_field"] = id_field;
            $('#id_field').val(id_field);
        }
        $('#soil_id').val("");
        $('#wst_id').val("");
        $('#fl_name').val(description);
        for (let i in trtData) {
            $('#tr_field_' + trtData[i].trtno).append('<option value="' + fieldId + '">' + description + '</option>');
        }
        $('#field_badge').html(Object.keys(fields).length);
    }
    
    function setField(target) {
        fieldData = fields[target.id];
        fieldId = target.id;
        $('#id_field').val(fieldData['id_field']);
        $('#fl_name').val(fieldData['fl_name']);
        $('#soil_id').val(fieldData['soil_id']);
        $('#wst_id').val(fieldData['wst_id']);
    }
    
    function removeField() {
        delete fields[fieldId];
        $('#field_list li a[id="' + fieldId + '"]').remove();
        for (let i in trtData) {
            $('#tr_field_' + trtData[i].trtno + ' option[value="' + fieldId + '"]').remove();
        }
        let fieldIds = Object.keys(fields);
        $('#field_badge').html(fieldIds.length);
        if (fieldIds.length > 0) {
            $("#" + fieldIds[0]).click();
        } else {
            $("#SiteInfoTab a").click();
        }
    }
</script>
<div class="subcontainer">
    <fieldset>
        <legend>
            Field Information&nbsp;&nbsp;&nbsp;
            <a href="#"><span id="field_remove_btn" type="button" class="btn glyphicon glyphicon-trash" onclick="removeField();"></span></a>
        </legend>
        <div class="row col-sm-12">
            <div class="form-group has-feedback col-sm-4">
                <label class="control-label" for="id_field">Field ID</label>
                <div class="input-group col-sm-12">
                    <input type="text" id="id_field" name="id_field" class="form-control field_data" value="" placeholder="Field identifier" data-toggle="tooltip" title="Field, identifier usually consisting of institution+site+4 digit number">
                    <!--<span class="glyphicon glyphicon-asterisk form-control-feedback" aria-hidden="true"></span>-->
                </div>
            </div>
            <div class="form-group has-feedback col-sm-4">
                <label class="control-label" for="fl_name">Description</label>
                <div class="input-group col-sm-12">
                    <input type="text" id="fl_name" name="fl_name" class="form-control field_data" value="" placeholder="Locally used name for field" data-toggle="tooltip" title="Locally used name for field">
                    <!--<span class="glyphicon glyphicon-asterisk form-control-feedback" aria-hidden="true"></span>-->
                </div>
            </div>
        </div>
        <div class="row col-sm-12">
            <div class="form-group has-feedback col-sm-4">
                <label class="control-label" for="soil_id">Soil ID</label>
                <div class="input-group col-sm-12">
                    <input type="text" id="soil_id" name="soil_id" class="form-control field_data" value="" placeholder="Soil identifier" data-toggle="tooltip" title="Unique soil identifier linking from SOIL_PROFILES">
                    <!--<span class="glyphicon glyphicon-asterisk form-control-feedback" aria-hidden="true"></span>-->
                </div>
            </div>
            <div class="form-group has-feedback col-sm-4">
                <label class="control-label" for="wst_id">Weather Station ID</label>
                <div class="input-group col-sm-12">
                    <input type="text" id="wst_id" name="wst_id" class="form-control field_data" value="" placeholder="Weather station identifier" data-toggle="tooltip" title="Weather station identifier to link to site information">
                    <!--<span class="glyphicon glyphicon-asterisk form-control-feedback" aria-hidden="true"></span>-->
                </div>
            </div>
        </div>
        
    </fieldset>
</div>