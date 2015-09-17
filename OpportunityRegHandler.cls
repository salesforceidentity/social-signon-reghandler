global class OpportunityRegHandler implements Auth.RegistrationHandler{

    global User createUser(Id portalId, Auth.UserData data){

        // Find the Account to assign the Contact
        Account a = [SELECT Id FROM account WHERE name='Customers'];

        // Build the Contact
        Contact c = new Contact();
        c.accountId = a.Id;
        c.email = data.email;
        c.firstName = data.firstName;
        c.lastName = data.lastName;
        insert(c);

        // Let's create an opportunity
        Opportunity oppty = new Opportunity();
        oppty.name = 'Mobile Engagement';
        oppty.stageName = 'Registered';
        oppty.closeDate = System.Date.today() + 90;
        insert(oppty);

        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.opportunityid = oppty.id;
        ocr.contactId = c.id;
        ocr.isPrimary = true;
        insert(ocr);

        // Create the User
        User u = new User();
        Profile p = [SELECT Id FROM profile WHERE name='Customers'];
        u.username = data.email;
        u.email = data.email;
        u.lastName = data.lastName;
        u.firstName = data.firstName;
        String alias = data.email;
        //Alias must be 8 characters or less
        if(alias.length() > 8) {
            alias = alias.substring(0, 8);
        }
        u.alias = alias;
        u.languagelocalekey = UserInfo.getLocale();
        u.localesidkey = UserInfo.getLocale();
        u.emailEncodingKey = 'UTF-8';
        u.timeZoneSidKey = 'America/Los_Angeles';
        u.profileId = p.Id;
        u.contactId = c.Id;
        return u;
        
        

    }

    global void updateUser(Id userId, Id portalId, Auth.UserData data){
        //Update the User
        
        User u = [select firstName, lastName, email, contactId from User where id =: userId];
        u.email = data.email;
        u.lastName = data.lastName;
        u.firstName = data.firstName;
        update(u);
        
        Contact c = [select firstName, lastName, email from Contact where id =: u.contactId];
        c.email = data.email;
        c.lastName = data.lastName;
        c.firstName = data.firstName;
        update(c);
            
    }
    
}