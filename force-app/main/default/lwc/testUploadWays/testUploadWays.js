import { LightningElement, api } from 'lwc';
import sheetJS from '@salesforce/resourceUrl/sheetJS1';
import {loadScript } from 'lightning/platformResourceLoader';
import insertAccounts from '@salesforce/apex/AccauntCreator.insertAccounts'


const BATCH_SIZE = 200;

export default class TestUploadWays extends LightningElement{

    @api recotdId;
    fileName;
    fileData = 'a';
    res;
    batchSize = BATCH_SIZE;
    progress = 0;
    progressStep;

    connectedCallback() {
        loadScript(this, sheetJS).then(() => {
             console.log(' load  sheet JS complete ');
        });
    }

    readFile(event) {
        console.log(this.fileData);

        event.preventDefault();
        let files = event.target.files;
        this.fileName = files[0].name;
        const analysisExcel = (file) =>
            new Promise((resolve, reject) => {
                const reader = new FileReader();
                reader.readAsBinaryString(file);
                reader.onload = () => resolve(reader.result);
                reader.onerror = (error) => reject(error);
        });

        analysisExcel(files[0])        

            .then((result) => {
                this.sheetsBtn =[];
                var datas = new Map();
                let XLSX = window.XLSX;
                let workbook = XLSX.read(result, {
                    type: 'binary'
                });
                console.log(workbook);
                console.log(workbook.SheetNames[0]);
                let firstSheet = workbook.SheetNames[0];
                console.log(workbook.Sheets[firstSheet]);
                console.log(XLSX.utils.sheet_to_row_object_array(workbook.Sheets[firstSheet]))

            });

        // let file = event.target.files[0]; 
        // console.log(file);
        // let fileReader = new FileReader(); 
        // this.fileName = file.name;
        
        // fileReader.onload = (fileReader) => {
        //     console.log('reader');
        //     console.log(this.fileData);
        //     console.log(fileReader.target.result);
        //     let fileData = fileReader.target.result;
        //     console.log(fileData.split('\n'));
        //     const lines = fileData.split('\n');
        //     var result = [];

        //     for (let i = 1; i < lines.length - 1; i++ ){
        //         let record = {Name: lines[i].split(',')[0]};
        //         result.push(record);
        //     }
        //     console.log('result: ' + result);
        //     this.res = result;
        // }; 
        // fileReader.onerror = function() {
        //   alert(fileReader.error);
        // }; 
        // fileReader.readAsText(file); 
    }

    handleClick(event){

        let batches = Math.ceil(this.res.length / this.batchSize);
        this.progressStep = (1/batches) * 100;

        this.insertData(0, batches);
        
    }

    insertData(currentBatchNo, batchesTotal) {
        let batch = this.res.slice((currentBatchNo * this.batchSize), ((currentBatchNo + 1) * this.batchSize));
        insertAccounts({accs: batch}).then(result =>{
            this.progress += this.progressStep;
            console.log('progress: ' + this.progress);
            if(currentBatchNo < batchesTotal - 1){
                this.insertData(currentBatchNo + 1, batchesTotal);
            } else{
                this.progress = 100;
            }
        });

    }

}