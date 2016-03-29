//This class provides logic for inbound just-in-time provisioning of single sign-on users in your Salesforce organization.
global class SamlRegHandler implements Auth.SamlJitHandler {
    private class JitException extends Exception{}
    
    private User handlePersonAccount(boolean create, User u, Map<String, String> attributes, String federationIdentifier) {
        System.debug('--------------------------------------Creating a Person Account---------------------------------------------------');
        RecordType personAccountRecordType =  [SELECT Id FROM RecordType WHERE Name = 'Person Account' and SObjectType = 'Account'];
        Account personAccount = new Account();
        personAccount.FirstName = attributes.get('User.FirstName');
        personAccount.LastName = attributes.get('User.LastName');
        personAccount.RecordType = personAccountRecordType;
        
        //Insert the person account
        insert personAccount;
        
        Profile p = [SELECT Id FROM profile WHERE name='Customer Portal Manager'];
        u.Username = attributes.get('User.Username');
        u.FederationIdentifier = federationIdentifier;
        u.email = attributes.get('User.Email');
        u.lastName = attributes.get('User.LastName');
        u.firstName = attributes.get('User.FirstName');
        u.alias = u.username.substring(0, 7);
        
        String uid = UserInfo.getUserId();
        User currentUser = 
            [SELECT LocaleSidKey, LanguageLocaleKey, TimeZoneSidKey, EmailEncodingKey FROM User WHERE Id=:uid];
            
        u.languagelocalekey = currentUser.LanguageLocaleKey;
        u.localesidkey =  currentUser.LocaleSidKey;
        u.EmailEncodingKey = currentUser.EmailEncodingKey;
        u.timeZoneSidKey = 'America/Los_Angeles';
        u.profileId = p.Id;
        
        
        Account a = [Select PersonContactId From Account Where Id = :personAccount.Id];
        System.debug('Person Account Id : ' + personAccount.Id);
        u.contactId = a.PersonContactId; 
        return u;
    }

    private void handleJit(boolean create, User u, Id samlSsoProviderId, Id communityId, Id portalId,
        String federationIdentifier, Map<String, String> attributes, String assertion) {
           handlePersonAccount(create, u, attributes, federationIdentifier);
    }

    global User createUser(Id samlSsoProviderId, Id communityId, Id portalId,
        String federationIdentifier, Map<String, String> attributes, String assertion) {
        User u = new User();
        handleJit(true, u, samlSsoProviderId, communityId, portalId,        
            federationIdentifier, attributes, assertion);
        return u;
    }

    global void updateUser(Id userId, Id samlSsoProviderId, Id communityId, Id portalId,
        String federationIdentifier, Map<String, String> attributes, String assertion) {
        throw new NoDataFoundException();
    }
}
