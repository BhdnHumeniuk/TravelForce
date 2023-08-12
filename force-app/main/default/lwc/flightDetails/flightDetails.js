import { LightningElement, api, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getFlightDetails from '@salesforce/apex/FlightController.getFlightDetails';
import handleCancelBookingFlight from '@salesforce/apex/FlightController.handleCancelBookingFlight';
import { showToast } from 'c/showMessageHelper';

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
        rejectFlight({ tripId: this.recordId })
            .then(() => {
                showToast('Success', 'The flight has been successfully rejected to the trip.', 'success');
                return refreshApex(this.wiredFlightDetails);
            })
            .catch(error => {
                console.error('Error rejecting flight:', error);
                showToast('Error', 'Failed to reject the flight to the trip.', 'error');
            });
    }
}
