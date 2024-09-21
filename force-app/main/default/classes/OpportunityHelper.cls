public class OpportunityHelper {
    public static void createOpportunity(List<Lead> newLeads) {
        Set<String> companyNames = new Set<String>();
        for (Lead lead : newLeads) {
            if (lead.Company != null) {
                companyNames.add(lead.Company);
            }
        }

        Map<String, Account> accountMap = new Map<String, Account>();
        for (Account acc : [SELECT Id, Name FROM Account WHERE Name IN :companyNames]) {
            accountMap.put(acc.Name, acc);
        }

        List<Lead> leadsToKeep = new List<Lead>();

        for (Lead lead : newLeads) {
            if (lead.Company != null && accountMap.containsKey(lead.Company)) {
                Account acc = accountMap.get(lead.Company);
                Opportunity opp = new Opportunity(
                    Name = 'Oportunidad para ' + lead.Company,
                    AccountId = acc.Id,
                    StageName = 'Prospecting',
                    CloseDate = Date.today().addMonths(1)
                );
                insert opp;
            } else {
                // Agregar el Lead a la lista de conservación
                leadsToKeep.add(lead);
            }
        }

        // Reemplazar la lista de Leads con la lista de conservación
        newLeads.clear();
        newLeads.addAll(leadsToKeep);
    }
}
