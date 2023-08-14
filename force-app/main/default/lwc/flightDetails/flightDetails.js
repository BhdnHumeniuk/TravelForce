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
        } else if (error) {
            this.error = error;
            this.flightDetails = undefined;
        }
    }

    handleCancelBookingFlight() {
        this.isLoading = true;
        cancelBookingFlight({ tripId: this.recordId })
            .then(() => {
                refreshApex(this.wiredFlightDetailsResult);
                this.flightDetails = undefined;
            })
            .then(() => {
                publish(this.messageContext, MESSAGE_CHANNEL, {type: 'FlightBookingCancel', payload: true});
                showSuccessMessage('Success', 'The flight has been successfully rejected to the trip.');
            })
            .catch(error => {
                console.error('Error rejecting flight:', error);
                showErrorMessage('Error', 'Failed to reject the flight to the trip.');
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    subscribeToMessageChannel() {
        this.subscription = subscribe(
            this.messageContext,
            MESSAGE_CHANNEL,
            (message) => {
                if (message.type === 'FlightBookingSuccess') {
                    refreshApex(this.wiredFlightDetailsResult);
                }
            }
        );
    }
}
