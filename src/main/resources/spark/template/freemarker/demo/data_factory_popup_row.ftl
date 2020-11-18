<script>
    function showRowDefDialog(callback, errMsg, sheets) {
//        let singleFileName;
        if (!sheets) {
            sheets = JSON.parse(JSON.stringify(templates));
        }
//        let data = [];
        // TODO editFlg = true will use different routine to handle
        let sheetDef = getCurSheetDef(sheets);
        // Setup default value for row definition of a table
        let latestHeaderRow = 1;
        for (let i in sheetDef) {
            let tableDef = sheetDef[i];
//                if (!tableDef.header_row) {
//                    tableDef.header_row = latestHeaderRow;
//                    latestHeaderRow++;
//                }
            if (!tableDef.data_start_row) {
                if (tableDef.header_row) {
                    tableDef.data_start_row = tableDef.header_row + 1;
                } else {
                    tableDef.data_start_row = latestHeaderRow + 1;
                }
                latestHeaderRow = tableDef.data_start_row + 1;
            }
        }
        let buttons = {
            cancel: {
                label: "Cancel",
                className: 'btn-default',
                callback: function() {}
            },
            ok: {
                label: "Confirm",
                className: 'btn-primary',
                callback: function(){
                    let idxErrFlg = false;
                    let repeatedErrFlg = false;
//                    let includedCnt = 0;
                    // Check if the last row input is meaningful or not
                    let lastRow = sheetDef.pop();
                    if (lastRow.header_row || lastRow.data_start_row) {
                        sheetDef.push(lastRow);
                    }
                    for (let i in sheetDef) {
                        let tableDef = sheetDef[i];
                        delete tableDef.button;
                        if (!tableDef.data_start_row || !tableDef.header_row) {
                            idxErrFlg = true;
                        }
//                                if (tableDef.included_flg) { // TODO replace with remove button
//                                    includedCnt++;
//                                    delete tableDef.included_flg;
                        let keys = ["data_start_row", "data_end_row", "header_row", "unit_row", "desc_row"];
                        for (let i = 0; i < keys.length; i++) {
                            if (tableDef[keys[i]]) {
                                for (let j = i + 1; j < keys.length; j++) {
                                    if (tableDef[keys[i]] === tableDef[keys[j]]) {
                                        if ((keys[i] !== "data_start_row" || keys[j] !== "data_end_row") &&
                                            (keys[j] !== "data_start_row" || keys[i] !== "data_end_row")) {
                                            repeatedErrFlg = true;
                                            break;
                                        }
                                    }
                                }
                            }
                        }
                        if (tableDef.data_start_row) {
                            tableDef.single_flg = isSingleRecordTable(wbObj[curFileName][curSheetName].data, tableDef);
                        }
                    }
//                    if (idxErrFlg) {
//                        showRowDefDialog(callback, "[warning] Please provide header row number and data start row number.");
//                    } else if (includedCnt === 0) {
//                        showRowDefDialog(callback, "[warning] Please select at least one sheet for reading in.");
//                    } else
                    if (repeatedErrFlg) {
                        showRowDefDialog(callback, "[warning] Please select different raw for each definition.", sheets);
                    }  else {
                        isViewUpdated = false;
                        isDebugViewUpdated = false;
                        isChanged = true;
                        callback(sheets, true);
                    }
                }
            }
        };
        let dialog = bootbox.dialog({
            title: '<h2>Table Definition</h2>',
            size: 'large',
            message: $("#row_define_popup").html(),
            buttons: buttons
        });
        dialog.find(".modal-content").drags();
        dialog.on("shown.bs.modal", function() {
            if (errMsg) {
                dialog.find("[name='dialog_msg']").text(errMsg);
            }
            let data = sheetDef;
            let mergeCells = [];
            // =========== TODO update popup spreadsheet to enable add/remove sub-table ===========
            let columns = [
//                {type: 'text', data : "file_name", readOnly: true},
//                {type: 'text', data : "sheet_name", readOnly: true},
//                {type: 'text', data : "table_index", readOnly: true},
                {type: 'text', data : "table_name"},
                {type: 'numeric', data : "header_row"},
                {type: 'numeric', data : "unit_row"},
                {type: 'numeric', data : "desc_row"},
                {type: 'numeric', data : "data_start_row"},
                {type: 'numeric', data : "data_end_row"},
                {type: 'text', data : "button", readOnly: true, renderer: 'html', className: "htCenter"}
//                {type: 'checkbox', data : "included_flg"}
            ];
            let colHeaders = ["Table Name", "Header Row #", "Unit Row #", "Description Row #", "Data Start Row #", "Data End Row #", "Edit"];
//            data.push({table_index: curFileName, file_name_row:true});
//            mergeCells.push({row: data.length - 1, col: 0, rowspan: 1, colspan: columns.length});
//            data.push({table_index: curSheetName, sheet_name_row:true});
//            mergeCells.push({row: data.length - 1, col: 0, rowspan: 1, colspan: columns.length});
//            for (let sheetName in sheets[curFileName]) {
//                let tmp = {};
//                tmp.included_flg = true;
//                tmp.file_name = curFileName;
//                if (templates[curFileName]) {
//                    tmp.file_def = curFileName;
//                    if (isSheetDefExist(curFileName, sheetName)) {
//                        tmp.sheet_def = sheetName;
//                    }
//                } else if (templates[singleFileName]) {
//                    tmp.file_def = singleFileName;
//                    if (templates[singleFileName][sheetName]) {
//                        tmp.sheet_def = sheetName;
//                    }
//                }
//                if (!tmp.sheet_def) {
//                    tmp.included_flg = callback.name !== "loadSC2Obj";
//                }
            for (let i in sheetDef) {
                let tableDef = sheetDef[i];
//                addTableDef2(data, tableDef);
                if (!tableDef.table_index) {
                    tableDef.table_index = Number(i) + 1;
                }
                if (!tableDef.table_name) {
                    if (sheetDef.length === 1) {
                        tableDef.table_name = tableDef.sheet_name;
                    } else {
                        tableDef.table_name = tableDef.sheet_name + "_" + (Number(i) + 1);
                    }
                }
                tableDef.button = '<button type="button" name="row_define_remove_btn" class="btn btn-danger btn-xs"><span name="table_index' + '_' + tableDef.table_index + '" class="glyphicon glyphicon-minus"></span></button>';
            }
            addTableDef2(data, {
                button : '<button type="button" name="row_define_add_btn" class="btn btn-primary btn-xs"><span class="glyphicon glyphicon-plus"></span></button>'
            });
            let spsOptions = {
                licenseKey: 'non-commercial-and-evaluation',
                data: data,
                columns : columns,
                stretchH: 'all',
                autoWrapRow: true,
                height: 300,
                minRows: 1,
                maxRows: 365 * 30,
                manualRowResize: false,
                manualColumnResize: false,
                rowHeaders: false,
                colHeaders: colHeaders,
                manualRowMove: false,
                manualColumnMove: false,
                filters: true,
                dropdownMenu: true,
                contextMenu: false,
                mergeCells: mergeCells
            };
            $(this).find("[name='rowDefSheet']").each(function () {
                let spDiv = $(this);
                $(this).handsontable(spsOptions);
                let popSpreadsheet = $(this).handsontable('getInstance');

                popSpreadsheet.updateSettings({
                    cells: function(row, col, prop) {
                        let cell = popSpreadsheet.getCell(row,col);
                        if (!cell) {
                            return;
                        }
                        // TODO === could be deleted ===
                        if (row === data.length - 1) {
                            cell.style.backgroundColor = "#F4F6F6";
                        }
//                        else if (data[row].file_name_row) {
//                            cell.style.color = "white";
//                            cell.style.fontWeight = "bold";
//                            cell.style.backgroundColor = "grey";
//                        } else if (data[row].sheet_name_row) {
//                            cell.style.color = "white";
//                            cell.style.fontWeight = "bold";
//                            cell.style.fontStyle = "italic";
//                            cell.style.backgroundColor = "grey";
//                        }
//                        else {
//                            return {readOnly : true};
//                        }
                    }
                });
                
                $(this).find("[name='row_define_remove_btn']").on("click", function() {
                    let tableIdx = $(this).parent().parent().index();
                    let tableDef = sheetDef[tableIdx];
                    alert(tableDef.table_name);
                });
                $(this).find("[name='row_define_add_btn']").on("click", function() {
                    let tableDef = data[data.length - 1];
                    tableDef.button = '<button type="button" name="row_define_remove_btn" class="btn btn-danger btn-xs"><span name="table_index' + '_' + tableDef.table_index + '" class="glyphicon glyphicon-minus"></span></button>';
                    addTableDef2(data, {
                        button : '<button type="button" name="row_define_add_btn" class="btn btn-primary btn-xs"><span class="glyphicon glyphicon-plus"></span></button>'
                    });
                    popSpreadsheet.render();
                });
                
                popSpreadsheet.addHook('afterRenderer', function(TD, row, column, prop, value, cellProperties) {
                    if (column !== columns.length - 1) {
                        return;
                    }
                    if (row < data.length - 1) {
                        TD.firstChild.onclick = function () {
                            let tableIdx = $(this).parent().parent().index();
                            let tableDef = sheetDef[tableIdx];
                            alert(tableDef.table_name);
                        };
                    } else {
                        TD.firstChild.onclick = function () {
                            let tableDef = data[data.length - 1];
                            tableDef.button = '<button type="button" name="row_define_remove_btn" class="btn btn-danger btn-xs"><span name="table_index' + '_' + tableDef.table_index + '" class="glyphicon glyphicon-minus"></span></button>';
                            addTableDef2(data, {
                                button : '<button type="button" name="row_define_add_btn" class="btn btn-primary btn-xs"><span class="glyphicon glyphicon-plus"></span></button>'
                            });
                            popSpreadsheet.render();
                        };
                    }
//                    spDiv.find("[name='row_define_remove_btn']").on("click", function() {
//                        let tableIdx = $(this).parent().parent().index();
//                        let tableDef = sheetDef[tableIdx];
//                        alert(tableDef.table_name);
//                    });
//                    spDiv.find("[name='row_define_add_btn']").on("click", function() {
//                        let tableDef = data[data.length - 1];
//                        tableDef.button = '<button type="button" name="row_define_remove_btn" class="btn btn-danger btn-xs"><span name="table_index' + '_' + tableDef.table_index + '" class="glyphicon glyphicon-minus"></span></button>';
//                        addTableDef2(data, {
//                            button : '<button type="button" name="row_define_add_btn" class="btn btn-primary btn-xs"><span class="glyphicon glyphicon-plus"></span></button>'
//                        });
//                        popSpreadsheet.render();
//                    });
                });
            });
        });
    }

    function showSheetDefPrompt(callback) {
        let dialog = bootbox.dialog({
            message: $("#sheet_define_init_popup").html(),
            buttons: {
                confirm: {
                    label: 'Confirm',
                    className: 'btn-primary',
                    callback: function() {
                        showRowDefDialog(callback);
                    }
                },
                copy: {
                    label: 'Copy',
                    className: 'btn-success',
                    callback: function() {
                        showSheetDefCopyPrompt(callback);
                    }
                },
                cancel: {
                    label: 'Later',
                    className: 'btn-default',
                    callback: function() {}
                }
            }
        });
        dialog.find(".modal-content").drags();
    }
    
    function showSheetDefCopyPrompt(callback, errMsg) {
        let dialog = bootbox.dialog({
            message: $("#sheet_define_copy_popup").html(),
            buttons: {
                confirm: {
                    label: 'Confirm',
                    className: 'btn-primary',
                    callback: function() {
                        let ret = $(this).find("[name='sheet_def_from']").val();
                        if (ret) {
                            let tmp = ret.split("__");
                            let sheetDef = JSON.parse(JSON.stringify(templates[tmp[0]][tmp[1]]));
                            templates[curFileName][curSheetName] = sheetDef;
                            sheetDef.references = {};
                            callback();
                        } else {
                            showSheetDefCopyPrompt(callback, "error message");
                        }
                    }
                },
                cancel: {
                    label: 'Later',
                    className: 'btn-default',
                    callback: function() {}
                }
            }
        });
        dialog.find(".modal-content").drags();
        dialog.on("shown.bs.modal", function() {
            if (errMsg) {
                dialog.find("[name='dialog_msg']").text(errMsg);
            }
            let sb = dialog.find("[name='sheet_def_from']");
            for (let fileName in templates) {
                let optgrp = $('<optgroup label="' + fileName + '"></optgroup>');
                sb.append(optgrp);
                for (let sheetName in templates[fileName]) {
                    if (sheetName !== curSheetName || fileName !== curFileName) {
                        optgrp.append($('<option value="' + fileName + '__' + sheetName + '">' + sheetName + '</option>'));
                    }
                }
            }
            chosen_init_target(sb, "chosen-select-deselect-single");
        });
    }
</script>

<!-- popup page for define sheet -->
<div id="row_define_popup" hidden>
    <p name="dialog_msg" class="label label-danger"></p>
    <div class="col-sm-12">
        <!-- 1st row -->
        <div class="form-group col-sm-12">
            <div name="rowDefSheet"></div>
        </div>
    </div>
    <p>&nbsp;</p>
</div>
<!-- popup page for initial define sheet -->
<div id="sheet_define_init_popup" hidden>
    <p>
        <h3>The rows of the sheet has not been defined yet, you could ...</h3>
        <li>Click confirm to manually do the definition</li>
        <li>Click copy to apply the definition from another sheet to the current one</li>
    </p>
</div>
<!-- popup page for copy sheet definition -->
<div id="sheet_define_copy_popup" hidden>
    <p name="dialog_msg" class="label label-danger"></p>
    <p>By clicking the confirm button, this will overwrite the existing mapping configuration</p>
    <div class="col-sm-12">
        <!-- 1st row -->
        <div class="form-group col-sm-12">
            <select name="sheet_def_from" class="form-control"></select>
        </div>
    </div>
    <p>&nbsp;</p>
</div>
