public with sharing class LeadEventController {
    @AuraEnabled
    public static String createEvent(Id leadId) {
        try {
            // Crear un nuevo evento relacionado con el Lead
            Event newEvent = new Event(
                Subject = 'Seguimiento con Lead Interesado',
                WhoId = leadId, // Relacionar el evento con el Lead
                StartDateTime = System.now(), // Fecha y hora de inicio
                EndDateTime = System.now().addHours(1) // Fecha y hora de fin (ejemplo)
            );
            insert newEvent;
            return newEvent.Id;
        } catch (Exception e) {
            throw new AuraHandledException('Error al crear el evento: ' + e.getMessage());
        }
    }
}
