import { LightningElement, api, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getFlightDetails from '@salesforce/apex/FlightController.getFlightDetails';
import cancelBookingFlight from '@salesforce/apex/FlightController.cancelBookingFlight';

import { publish, subscribe, MessageContext } from 'lightning/messageService';
import MESSAGE_CHANNEL from '@salesforce/messageChannel/LightningMessageService__c';
import { showSuccessMessage, showErrorMessage } from "c/showMessageHelper";

export default class FlightDetails extends LightningElement {
    @api recordId;

    flightDetails;

    showComponent = false;
    isLoading = false;

    @wire(MessageContext)
    messageContext;

    connectedCallback() {
        this.subscribeToMessageChannel();
    }

    @wire(getFlightDetails, { tripId: '$recordId' })
    wiredFlightDetails(result) {
        this.wiredFlightDetailsResult = result;
        const { data, error } = result;
        if (data && Object.keys(data).length !== 0) {
            this.flightDetails = data;
            this.showComponent = true;
        } else if (error) {
            this.error = error;
            this.flightDetails = undefined;
        }
    }

    handleCancelBookingFlight() {
        this.isLoading = true;
        cancelBookingFlight({ tripId: this.recordId })
            .then(() => {
                showSuccessMessage('Success', 'The flight has been successfully rejected to the trip.');
                publish(this.messageContext, MESSAGE_CHANNEL, {type: 'FlightBookingCancel', payload: true});
                this.showComponent = false;
            })
            .catch(error => {
                showErrorMessage('Error', 'Failed to reject the flight to the trip.');
                console.error('Error rejecting flight:', error);
            })
            .finally(() => (this.isLoading = false));
    }

    subscribeToMessageChannel() {
        this.subscription = subscribe(
            this.messageContext,
            MESSAGE_CHANNEL,
            (message) => {
                if (message.type === 'FlightBookingSuccess') {
                    this.showComponent = true;
                    refreshApex(this.wiredFlightDetailsResult);
                }
            }
        );
    }
}
