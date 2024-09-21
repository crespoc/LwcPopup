import { LightningElement, api, wire } from 'lwc';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createEvent from '@salesforce/apex/LeadEventController.createEvent';
import LEAD_OBJECT from '@salesforce/schema/Lead';
import INTERESADO_CHECK_FIELD from '@salesforce/schema/Lead.InteresadoCheck__c'; // Campo checkbox
import STATUS_FIELD from '@salesforce/schema/Lead.Status'; // Campo Status

const FIELDS = ['Lead.Status', 'Lead.InteresadoCheck__c'];

export default class LeadStatusPopup extends LightningElement {
    @api recordId; // El ID del Lead actual
    showPopup = false; // Controla si el popup debe mostrarse o no
    leadData; // Almacena los datos del Lead

    // Wire para obtener el Lead actualizado
    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    lead({ error, data }) {
        if (data) {
            this.leadData = data;
            const status = data.fields.Status.value;
            const interesadoCheck = data.fields.InteresadoCheck__c.value;

            // Mostrar el popup solo si Status es "Interesado" y el campo InteresadoCheck es false
            if (status === 'Interesado' && !interesadoCheck) {
                this.showPopup = true;

                // Marcar el campo InteresadoCheck como true después de mostrar el popup
                this.markInteresadoCheck();
            }
        } else if (error) {
            console.error(error);
        }
    }

    // Método para marcar el campo InteresadoCheck como true
    markInteresadoCheck() {
        const fields = {};
        fields.Id = this.recordId;
        fields[INTERESADO_CHECK_FIELD.fieldApiName] = true; // Marcar el checkbox como true

        const recordInput = { fields };

        updateRecord(recordInput)
            .then(() => {
                // Mostrar un mensaje de éxito al usuario (Toast opcional)
                /*this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Éxito',
                        message: 'InteresadoCheck marcado como true.',
                        variant: 'success'
                    })
                );*/
            })
            .catch(error => {
                console.error('Error al actualizar el campo InteresadoCheck:', error);
            });
    }

    // Método para cerrar el modal y crear un nuevo evento
    closeModal() {
        this.showPopup = false;
        this.createNewEvent(); //Crear un nuevo evento al cerrar el popup
    }
}