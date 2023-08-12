import { LightningElement, api, wire } from 'lwc';
import { showSuccessMessage, showErrorMessage } from "c/showMessageHelper";
import getAvailableFlightsWithKeyword from '@salesforce/apex/FlightController.getAvailableFlightsWithKeyword';
import bookFlight from '@salesforce/apex/FlightController.bookFlight';

const columns = [
    { label: 'Flight Name', fieldName: 'Name', type: 'text', sortable: true },
    { label: 'Flight Number', fieldName: 'Flight_Number__c', type: 'text', sortable: true },
    { label: 'Start', fieldName: 'Start__c', type: 'date', sortable: true },
    { label: 'Action', type: 'button', typeAttributes: { label: 'Book', name: 'book' } },
];

export default class FlightSearch extends LightningElement {
    @api recordId;
    flights = [];

    searchKeyword = '';
    columns = columns;
    sortDirection = 'asc';
    sortedBy;
    isLoading = false;

    itemsPerPage = 5;
    currentPage = 1;
    visibleFlights = [];

    @wire(getAvailableFlightsWithKeyword, { recordId: '$recordId', searchKeyword: '$searchKeyword' })
    wiredFlights(result) {
        const { data, error } = result;
        if (data) {
            this.flights = data;
            this.updatePagination();
        } else if (error) {
            console.error('Error fetching available flights:', error);
        }
    }

    handleFlightSelect(event) {
        const selectedFlightId = event.detail.row.Id;
        bookFlight({ tripId: this.recordId, flightId: selectedFlightId })
        .then(() => {
            showSuccessMessage('Success', 'The flight has been successfully booked to the trip.');
        })
        .catch(error => {
            showErrorMessage('Error', 'Failed to book the flight to the trip.');
            console.error('Error booking flight:', error);
        })
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
}
