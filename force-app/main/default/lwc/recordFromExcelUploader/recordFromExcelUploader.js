import { LightningElement, api } from 'lwc';
import sheetJS from '@salesforce/resourceUrl/sheetJS';
import {loadScript } from 'lightning/platformResourceLoader';
import getMappingTable from '@salesforce/apex/RecordFromExcelUploadController.getMappingTable'
import runLogicAfterInsert from '@salesforce/apex/RecordFromExcelUploadController.runLogicAfterInsert';
import getObjectName from '@salesforce/apex/RecordFromExcelUploadController.getObjectName';
import getFieldTypes from '@salesforce/apex/RecordFromExcelUploadController.getFieldTypes';
import createRecords from '@salesforce/apex/RecordFromExcelUploadController.createRecords';

import Done_button from '@salesforce/label/c.Done_button';
import File_upload_field_label from '@salesforce/label/c.File_upload_field_label';
import Formatting_error_message from '@salesforce/label/c.Formatting_error_message';
import Header from '@salesforce/label/c.Header';
import Mapping_error_message from '@salesforce/label/c.Mapping_error_message';
import Progress_bar_status_message from '@salesforce/label/c.Progress_bar_status_message';
import Submit_button from '@salesforce/label/c.Submit_button';
import Unhandled_error_message from '@salesforce/label/c.Unhandled_error_message';

export default class RecordFromExcelUploader extends LightningElement {

    label = {
        Done_button,
        File_upload_field_label,
        Formatting_error_message,
        Header,
        Mapping_error_message,
        Progress_bar_status_message,
        Submit_button,
        Unhandled_error_message
    };

    @api
    srName;
    @api
    batchSize;
    @api 
    recordId;
    fileName;
    //variable for progress bar
    progress = 0;
    //step of the progress bar value increase
    progressStep;
    //list of collumn names in imported file and related API names
    dataMapping = [];
    dataMappingV2 = new Map();
    //handled data from the file
    res = [];
    //booleans to chage LWC elemnts state
    uploadStarted = false;
    noFile = true;
    isLoading = true;
    uploadFinished = false;
    //list to store records with errors
    errorList = [];
    //errors formatted to display
    errorsText = [];
    //list to store all sheets in uploaded excel to display in the piclist 
    uploadedSheets = [];
    //stores name of the selected sheet to upload data from it
    selectedSheet;
    //unhandled excel file
    workbook;
    //string that displays upload status on the component
    uploadStatus;
    headerText = this.label.Header.replace('{recordName}', '');;
    defaultValues = [];
    recordIdFieldName;
    sheetNumber;
    sObjectName;

    fieldTypes;

    additionalLogic = {className:'', methodToRunOnRecords:'', methodToRunAfterInsert:''};

    connectedCallback() {
        //load shettJS 
        loadScript(this, sheetJS).then(() => {
             console.log(' load  sheet JS complete ');
             //get data from mapping table
             getMappingTable({developerName: this.srName}).then((result) => {
                //handle the data
                let rows = result.split('\n');
                this.sheetNumber = rows[1].split(',')[4];
                this.sObjectName = rows[1].split(',')[5];
                if(rows[1].split(',')[6]){
                    this.additionalLogic.className = rows[1].split(',')[6];
                    this.additionalLogic.methodToRunOnRecords = rows[1].split(',')[7];
                    this.additionalLogic.methodToRunAfterInsert = rows[1].split(',')[8];
                    this.additionalLogic.methodToRunAfterInsert = this.additionalLogic.methodToRunAfterInsert.slice(0,this.additionalLogic.methodToRunAfterInsert.length - 1)
                }
                for(let i = 1; i < rows.length; i++){
                    
                    if(rows[i] === ''){
                        break;
                    }
                    let cells = rows[i].split(',');
                    if(cells[2] === 'recordId'){
                        this.recordIdFieldName = cells[1];
                    } else if(cells[2] === 'defaultValue'){
                        let defaultVal = {apiName: cells[1], value: cells[3]}
                        this.defaultValues.push(defaultVal);
                        
                    } else {
                        if(cells[0] && cells[1]){
                            let mapping = {input: cells[0], apiName: cells[1]};
                            this.dataMapping.push(mapping);
                            this.dataMappingV2.set(cells[1], cells[0]);
                        }
                    }
                }
                getObjectName({objectApiName: this.sObjectName} ).then((result) => {
                    this.headerText = this.label.Header.replace('{recordName}', result);
                    getFieldTypes({sObjectName: this.sObjectName}).then((result) => {
                        this.fieldTypes = result;
                        this.isLoading = false;
                    });
                });
             });
        });
    }


  
    //on file upload
    readFile(event) {

        event.preventDefault();
        this.isLoading = true;
        //clear previous inputs, if there are any
        this.workbook = null;
        this.uploadedSheets =[];
        this.selectedSheet = null;
        this.fileName = null;

        this.noFile = true;
        let files = event.target.files;
        
        const analysisExcel = (file) =>
            new Promise((resolve, reject) => {
                const reader = new FileReader();
                reader.readAsBinaryString(file);
                reader.onload = () => resolve(reader.result);
                reader.onerror = (error) => reject(error);
        });
        //start reading the file
        analysisExcel(files[0])        

            .then((result) => {
                let XLSX = window.XLSX;
                //save unhandled file in the component
                this.workbook = XLSX.read(result, {
                    type: 'binary',
                    cellText:false, 
                    cellDates: true
                });

                this.fileName = files[0].name;
                this.noFile = false;
                this.isLoading = false;
        });
    }

    handleClick(){
        this.noFile = true;
        this.uploadStatus = "Preparing data";
        this.uploadStarted = true;
        let header = this.getHeaderRow(this.workbook.Sheets[this.workbook.SheetNames[this.sheetNumber]]);
        let unmappedCollumns = [];
        let collumnValues = Array.from(this.dataMappingV2.values());
        for(let i = 0; i < header.length; i++){
            if(!collumnValues.includes(header[i])){
                unmappedCollumns.push(header[i]);
            }
        }
        if(unmappedCollumns.length > 0){
            let errorsText = [''];
            for(let i = 0; i < unmappedCollumns.length; i++){
                errorsText.push(this.label.Mapping_error_message.replace('{collumnName}', unmappedCollumns[i]));
                
            }
            this.errorsText = errorsText;
            this.uploadFinished = true;
            return;
        }
        //extract data from the chosen sheet of the file with salesfroce acceptable date formatting
        let fileData = XLSX.utils.sheet_to_row_object_array(this.workbook.Sheets[this.workbook.SheetNames[this.sheetNumber]], { header: 0, raw: false, dateNF: 'yyyy"-"mm"-"dd' });
        //file data handling by mapping table
        for(let i = 0; i < fileData.length; i++){
            let record = {};
            for(let j = 0; j < this.dataMapping.length; j++){
                    record[this.dataMapping[j].apiName] = fileData[i][this.dataMapping[j].input];                
            }
            if(this.recordIdFieldName){
                record[this.recordIdFieldName] = this.recordId;
            }
            if(this.defaultValues.length > 0){
                for(let j = 0; j < this.defaultValues.length; j++){
                    record[this.defaultValues[j].apiName] = this.defaultValues[j].value;
                }
            }
            //store imput ready record on the component
            this.res.push(record);
        }
        //calculate total number of batches
        let batches = Math.ceil(this.res.length / this.batchSize);
        this.progressStep = (1/batches) * 95;
        //set progress to 5% 
        this.progress = 5;
        //call the data input menthod
        
        this.insertData(0, batches);
    }

    //data input menthod
    insertData(currentBatchNo, batchesTotal) {
        //get data for current batch
        let batch = this.res.slice((currentBatchNo * this.batchSize), ((currentBatchNo + 1) * this.batchSize));

        
        //pass bath to the controller
        createRecords({records: batch, sObjectName: this.sObjectName, 
            dataTypes: this.fieldTypes, className: this.additionalLogic.className, 
            methodName: this.additionalLogic.methodToRunOnRecords}).then(result =>{
            //after the input increase progress by progress step
            this.errorList = this.errorList.concat(JSON.parse(result));
            this.progress += this.progressStep;
            console.log('progress: ' + this.progress);
            //if batch is not the last
            if(currentBatchNo < batchesTotal - 1){
                //update status message
                this.uploadStatus = this.label.Progress_bar_status_message.replace(
                    '{processedRecords}', (currentBatchNo + 1) * this.batchSize).replace(
                        '{totalRecords}', this.res.length).replace(
                            '{errors}', this.errorList.length);
                
                //call the data input menthod
                this.insertData(currentBatchNo + 1, batchesTotal);
            } else{
                //call controller method to change the invoice status
                if(this.errorList.length > 0){
                    this.handleErrors();
                    this.uploadEnd();
                }else{
                    if(!(this.additionalLogic.className === '') && !(this.additionalLogic.methodToRunAfterInsert === '')){
                        runLogicAfterInsert({className: this.additionalLogic.className, methodName: this.additionalLogic.methodToRunAfterInsert, recordId: this.recordId}).then(result=>{
                            this.uploadEnd();
                        });
                    }else{
                        this.uploadEnd();
                    }
                }
            }
        }).catch((error)=>{
            console.log(error);
        });

    }

    handleErrors(){
        let formattedErrors =[];
        let errorsText = [''];
        for(let i = 0; i < this.errorList.length; i++){
            if(this.errorList[i].errorInfo.Type === 'MappingError'){
                errorsText.push(this.label.Formatting_error_message.replace('{colName}', this.dataMappingV2.get(this.errorList[i].errorInfo.Field)).replace('{value}',this.errorList[i].errorInfo.Value));
            }else if(this.errorList[i].errorInfo.Type === 'InsertError'){
                errorsText.push(this.label.Unhandled_error_message);
            }
            formattedErrors.push({record: this.errorList[i].record, error: this.errorList[i].errorInfo.Error});
        }
        console.log(formattedErrors);
        this.errorsText = errorsText;
    }

    uploadEnd(){
        //set final status message that all data is handled
        this.uploadStatus = this.label.Progress_bar_status_message.replace(
            '{processedRecords}', this.res.length).replace(
                '{totalRecords}', this.res.length).replace(
                    '{errors}', this.errorList.length);

        this.progress = 100;
        this.uploadFinished = true;
    }
    
    getHeaderRow(sheet) {
        var headers = [];
        var range = XLSX.utils.decode_range(sheet['!ref']);
        var C, R = range.s.r; /* start in the first row */
        /* walk every column in the range */
        for(C = range.s.c; C <= range.e.c; ++C) {
            var cell = sheet[XLSX.utils.encode_cell({c:C, r:R})] /* find the cell in the first row */

            if(cell && cell.t){ 
                headers.push(XLSX.utils.format_cell(cell));
            }
        }
        return headers;
    }

    //handle the done button click
    crlear(){
        this.res = [];

        this.workbook = null;
        this.uploadedSheets =[];
        this.selectedSheet = null;
        this.fileName = null;
        this.progress = 0;
        this.progressStep = null;
        this.errorList = [];
        this.uploadStarted = false;
        this.uploadStatus = null;
        this.uploadFinished = false;
        this.errorList = [];
        this.errorsText = [];
    }
}