import { LightningElement, api, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getFlightDetails from '@salesforce/apex/FlightController.getFlightDetails';
import cancelBookingFlight from '@salesforce/apex/FlightController.cancelBookingFlight';
import { showSuccessMessage, showErrorMessage } from "c/showMessageHelper";

export default class FlightDetails extends LightningElement {
    @api recordId;

    flightDetails;

    @wire(getFlightDetails, { tripId: '$recordId' })
    wiredFlightDetails({ data, error }) {
        if (data && Object.keys(data).length !== 0) {
            this.flightDetails = data;
        } else if (error) {
            this.error = error;
            this.flightDetails = undefined;
        }
    }

    handleCancelBookingFlight() {
        cancelBookingFlight({ tripId: this.recordId })
            .then(() => {
                showSuccessMessage('Success', 'The flight has been successfully rejected to the trip.');
                return refreshApex(this.wiredFlightDetails);
            })
            .catch(error => {
                showSuccessMessage('Error', 'Failed to reject the flight to the trip.');
                console.error('Error rejecting flight:', error);
            });
    }
}
