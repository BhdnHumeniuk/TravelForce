import { LightningElement, api, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getAvailableFlightsWithKeyword from '@salesforce/apex/FlightController.getAvailableFlightsWithKeyword';
import bookFlight from '@salesforce/apex/FlightController.bookFlight';
import isTripBookedFlight from '@salesforce/apex/TripController.isTripBookedFlight';

import { publish, subscribe, MessageContext } from 'lightning/messageService';
import MESSAGE_CHANNEL from '@salesforce/messageChannel/LightningMessageService__c';
import { showSuccessMessage, showErrorMessage } from "c/showMessageHelper";

const columns = [
    { label: 'Flight Name', fieldName: 'Name', type: 'text', sortable: true },
    { label: 'Flight Number', fieldName: 'Flight_Number__c', type: 'text', sortable: true },
    { label: 'Start', fieldName: 'Start__c', type: 'date', sortable: true },
    { label: 'Action', type: 'button', typeAttributes: { label: 'Book', name: 'book', disabled: { fieldName: 'isBooked' } } },
];

export default class FlightSearch extends LightningElement {
    @api recordId;
    flights = [];

    searchKeyword = '';
    columns = columns;
    sortDirection = 'asc';
    sortedBy;
    isLoading = false;
    isButtonActive = true;

    itemsPerPage = 5;
    currentPage = 1;
    visibleFlights = [];

    @wire(MessageContext)
    messageContext;

    connectedCallback() {
        this.subscribeToMessageChannel();        
    }

    @wire(getAvailableFlightsWithKeyword, { recordId: '$recordId', searchKeyword: '$searchKeyword' })
    wiredFlights(result) {
        this.wiredFlightsResult = result;
        const { data, error } = result;
        if (data) {
            this.flights = data.map(flight => ({ ...flight, isBooked: flight.isBooked || false }));
            this.updatePagination();
            this.updateFlightsBookingStatus(this.isButtonActive); 
        } else if (error) {
            console.error('Error fetching available flights:', error);
        }
    }

    @wire(isTripBookedFlight, { tripId: '$recordId' })
    wiredIsTripBookedFlight(result) {
        this.wiredIsTripBookedFlightResult = result;
        const { data, error } = result;
        if (data !== undefined) {
            this.isButtonActive = data;
            this.updateFlightsBookingStatus(this.isButtonActive);
        } else if (error) {
            refreshApex(this.wiredFlightsResult);
            this.updateFlightsBookingStatus(false);
            console.error('Error fetching trip booking status:', error);
        }
    }    

    updateFlightsBookingStatus(forceStatus) {
        this.flights = this.flights.map(flight => ({
            ...flight,
            isBooked: forceStatus !== undefined ? forceStatus : (this.isTripBooked || flight.isBooked || false)
        }));
    }
    
    handleFlightSelect(event) {
        this.isLoading = true;
        const selectedFlightId = event.detail.row.Id;
        bookFlight({ tripId: this.recordId, flightId: selectedFlightId })
            .then(() => {
                this.updateFlightsBookingStatus(true);
                refreshApex(this.wiredFlightsResult);
            })
            .then(() => {
                publish(this.messageContext, MESSAGE_CHANNEL, {type: 'FlightBookingSuccess', payload: true});
                showSuccessMessage('Success', 'The flight has been successfully booked to the trip.');
            })
            .catch(error => {
                console.error('Error booking flight:', error);
                showErrorMessage('Error', 'You have already booked this flight. Please press "Cancel Booking" and try again.');
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    handleSearch(event) {
        this.searchKeyword = event.target.value.toLowerCase();
        this.updatePagination();
    }

    handleSort(event) {
        const { fieldName: sortField, sortDirection } = event.detail;
        this.sortedBy = sortField;
        this.sortDirection = sortDirection === 'asc' ? 'asc' : 'desc';
        this.sortData(sortField, this.sortDirection);
        this.updatePagination();
    }

    sortData(sortField, sortDirection) {
        const data = [...this.flights];
        data.sort((a, b) => {
            const valueA = a[sortField] || '';
            const valueB = b[sortField] || '';
            let sortValue = 0;

            if (sortDirection === 'asc') {
                sortValue = valueA > valueB ? 1 : -1;
            } else if (sortDirection === 'desc') {
                sortValue = valueA < valueB ? 1 : -1;
            }

            return sortValue;
        });

        this.flights = data;
    }

    handleItemsPerPageChange(event) {
        this.itemsPerPage = event.target.value;
        this.currentPage = 1;
        this.updatePagination();
    }

    updatePagination() {
        const start = (this.currentPage - 1) * this.itemsPerPage;
        const end = this.itemsPerPage * this.currentPage;
        this.visibleFlights = this.flights.slice(start, end);
    }

    handleUpdatePagination(event) {
        this.visibleFlights = event.detail.records;
    }

    handleRecordSizeChange(event) {
        const newRecordSize = event.detail.recordSize;
        this.itemsPerPage = parseInt(newRecordSize, 10);
        this.currentPage = 1;
        this.updatePagination();
    }

    subscribeToMessageChannel() {
        this.subscription = subscribe(
            this.messageContext,
            MESSAGE_CHANNEL,
            (message) => {
                if (message.type === 'FlightBookingCancel') {
                    refreshApex(this.wiredFlightsResult);
                    this.updateFlightsBookingStatus(false);
                }
            }
        );
    }
}
