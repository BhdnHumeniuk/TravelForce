import { LightningElement, api, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { RefreshEvent } from 'lightning/refresh';

import getAvailableFlightsWithKeyword from '@salesforce/apex/FlightController.getAvailableFlightsWithKeyword';
import changeStatusTripToBook from '@salesforce/apex/TripController.changeStatusTripToBook';
import isTripBookedFlight from '@salesforce/apex/TripController.isTripBookedFlight';

import { publish, subscribe, MessageContext } from 'lightning/messageService';
import { subscribe as empSubscribe } from 'lightning/empApi'; 
import MESSAGE_CHANNEL from '@salesforce/messageChannel/LightningMessageService__c';

import { showSuccessMessage, showErrorMessage } from "c/showMessageHelper";

const columns = [    
    { label: 'Flight Name', fieldName: 'flightId', type: 'url', typeAttributes: { label: { fieldName: 'flightName' }, target: '_blank', tooltip: 'View Flight' }, sortable: true },
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
    isTripBooked;

    itemsPerPage = 5;
    currentPage = 1;
    visibleFlights = [];

    @wire(MessageContext)
    messageContext;

    subscription = {};
    @api channelName = '/event/TripUpdatedEvent__e';

    connectedCallback() {
        this.fetchTripStatus();
        this.subscribeToMessageChannel();   
        this.subscribeToTripUpdatedEvent();     
    }

    fetchTripStatus(){
        isTripBookedFlight({ tripId: this.recordId })
            .then((data) => {
                    this.isTripBooked = data;
                    this.updateFlightsBookingStatus();
            })
            .catch((error) => {
                console.error('Error fetching Trip status:', error.message);
            });
    }

    updateFlightsBookingStatus() {
        this.flights = this.flights.map(flight => ({
            ...flight,
            isBooked: this.isTripBooked
        }));
    }

    @wire(getAvailableFlightsWithKeyword, { recordId: '$recordId', searchKeyword: '$searchKeyword' })
    wiredFlights(result) {
        this.wiredFlightsResult = result;
        const { data, error } = result;
        if (data) {
            this.flights = data.map(flight => ({
                ...flight,
                flightName: flight.Name,
                flightId: "/" + flight.Id,
                isBooked: this.isTripBooked 
            }));
            this.updatePagination();
        } else if (error) {
            console.error('Error fetching available flights:', error.message);
        }
    }
    
    handleFlightSelect(event) {
        this.isLoading = true;
        const selectedFlightId = event.detail.row.Id;
        changeStatusTripToBook({ tripId: this.recordId, flightId: selectedFlightId })
            .then(() => {
                refreshApex(this.wiredFlightsResult);
                this.dispatchEvent(new RefreshEvent());
                publish(this.messageContext, MESSAGE_CHANNEL, {type: 'FlightBookingSuccess', payload: true});
                this.isTripBooked = true;
                this.updateFlightsBookingStatus(); 
                // this.fetchTripStatus();
                showSuccessMessage('Success', 'The flight has been successfully booked to the trip.');
            })
            .catch(error => {
                console.error('Error booking flight:', error.message);
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
                    
                    this.isTripBooked = false;
                    this.updateFlightsBookingStatus();
                    refreshApex(this.wiredFlightsResult);
                    // this.fetchTripStatus();
                }
            }
        );
    }

    subscribeToTripUpdatedEvent() {
        const messageCallback =  (response) => {
                if (response.data.payload.TripId__c === this.recordId) {
                refreshApex(this.wiredFlightsResult);
            }
        };
        
        empSubscribe(this.channelName, -1, messageCallback).then(response => {
            this.empSubscription = response;
        });
    }
}
