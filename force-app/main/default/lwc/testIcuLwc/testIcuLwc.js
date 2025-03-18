import { LightningElement } from 'lwc';

import testLocale from '@salesforce/apex/testIcuController.testLocale';

export default class TestIcuLwc extends LightningElement {
    date;
    dateTime;
    currency;

    connectedCallback() {
        testLocale().then((result) => {
            this.date = result.testNMSPC__test_date__c;
            this.dateTime = result.testNMSPC__test_date_time__c;
            this.currency = result.testNMSPC__test_currency__c;
        });
    }


}