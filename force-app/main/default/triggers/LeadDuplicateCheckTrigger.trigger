

trigger LeadDuplicateCheckTrigger on Lead (before insert) {
    // Crear un mapa para almacenar los nombres de compañía de los Leads
    Set<String> companyNames = new Set<String>();
    for (Lead lead : Trigger.new) {
        if (lead.Company != null) {
            companyNames.add(lead.Company);
        }
    }
    
    System.debug('Company Names from Leads: ' + companyNames);

    // Consultar las cuentas que coinciden con los nombres de compañía de los Leads
    List<Account> accounts = [SELECT Id, Name FROM Account WHERE Name IN :companyNames];
    System.debug('Accounts found: ' + accounts);
    
    Map<String, Account> nameToAccountMap = new Map<String, Account>();
    for (Account acc : accounts) {
        nameToAccountMap.put(acc.Name, acc);
    }
    
    System.debug('Map of Company Names to Accounts: ' + nameToAccountMap);
    
    // Crear una lista para las oportunidades a insertar
    List<Opportunity> opportunitiesToInsert = new List<Opportunity>();
    
    // Comprobar cada Lead y decidir si se debe crear una oportunidad o mostrar un error
    for (Lead lead : Trigger.new) {
        if (nameToAccountMap.containsKey(lead.Company)) {
            System.debug('Lead with Company ' + lead.Company + ' matches an existing Account.');
            
            // Crear oportunidad para la cuenta existente
            Account existingAccount = nameToAccountMap.get(lead.Company);
            Opportunity opp = new Opportunity(
                Name = lead.Company + ' Opportunity',
                AccountId = existingAccount.Id,
                StageName = 'Prospecting',
                CloseDate = Date.today().addMonths(1)
            );
            opportunitiesToInsert.add(opp);
            
            // Evitar la creación del Lead
            lead.addError('A Lead with this company already exists as an Account. An Opportunity will be created instead.');
        }
    }
    
    System.debug('Opportunities to Insert: ' + opportunitiesToInsert);
    
    // Insertar oportunidades fuera del trigger `before insert`
    if (!opportunitiesToInsert.isEmpty()) {
        try {
            insert opportunitiesToInsert;
            System.debug('Opportunities successfully inserted.');
        } catch (DmlException e) {
            // Manejar excepciones de DML
            System.debug('Error inserting opportunities: ' + e.getMessage());
        }
    }
}


