/**
  FaceBook Registration Handler example
  
  @Author - Bobby White
  @email bobby.white@salesforce.com
  @company  Salesforce
  
  @date  March 16, 2016
**/
global class MyFaceBookRegistrationHandler implements Auth.RegistrationHandler{
    
    private static final String ORG_SUFFIX = '.sso.badge.org';
    public static final String DEFAULT_ACCOUNTNAME = 'Acme';
    
/**
 * Let anyone register as long as the required fields are supplied
 * 
 * We require email, lastName, firstName
 * 
 * @data - the user's info from the Auth Provider
 **/ 
global boolean canCreateUser(Auth.UserData data) {
    System.debug('canCreateUser was called for ' + (data != null ? data.email : 'null'));
    Boolean retVal = (data != null 
            && data.email != null
            && data.lastName != null
            && data.firstName != null);
    
    System.debug('data.username='+data.username);
    System.debug('data.email='+data.email);
    System.debug('data.lastName='+data.lastName);
    System.debug('data.firstName='+data.firstName);
    
    return retVal;
}

/**
 * Create the User - A required method to implement the Handler Interface
 * 
 * @param portalId  - Id of the Community
 * @param data - Auth Provider user data describing the User to create
 * 
 * @return User that has been initialized
**/ 
global User createUser(Id portalId, Auth.UserData data){
    if(!canCreateUser(data)) {
        // Returning null signals the auth framework we can't create the user
        return null;
    }
    
    // Is this a Community Context?
    if(data.attributeMap.containsKey('sfdc_networkid')) {
        System.debug('Registering Community user: ' + data.email);
        
        // To keep things modular, we're creating the PersonAccount in a separate method
        Id contactId = createPersonAccountContact(data);
        
        // You'd likely use other logic to assign the Profile
        Profile p = [SELECT Id FROM profile WHERE name='Customer Community User'];

        // Keeping it modular, we initialize the user in another method
        User u = createUser(data,p);
        
        u.contactId = contactId;
        return u;
    } else {
        //This is not a community, so we Assign an internal profile
        Profile p = [SELECT Id FROM profile WHERE name='Standard User'];
        
        // Keeping it modular, we initialize the user in another method
        User u = createUser(data,p);

        return u;
    }
}

/**
 * Update the user
 * @param portalId  - Id of the Community
 * @param data - Auth Provider user data describing the User to create
 **/     
global void updateUser(Id userId, Id portalId, Auth.UserData data){
    System.debug('Update User called for: ' + data.email);
    
    User u = new User(id=userId);
    u.email = data.email;
    u.lastName = data.lastName;
    u.firstName = data.firstName;
    update(u);
}
    /**
     * Create a PersonAccount for the contact
     * 
     * @param data - Facebook provided context for this User
     **/ 
    private Id createPersonAccountContact(Auth.UserData data) {
        Account person = new Account();
        person.LastName = data.lastName;
        person.FirstName = data.FirstName;
        person.personEmail = data.email;
        person.RecordTypeId = [Select Id From RecordType 
                                Where SobjectType='Account' 
                                  AND isPersonType=true LIMIT 1].id;
        
        insert person;
        
        System.debug('Person Account created for ' + data.email + ' id=' + person.id);
        
        /**
         * This next step is necessary to get a valid contact Id,
         * it won't exist until the PersonAcct is saved
         **/         
        Account a = [Select PersonContactId From Account Where Id = :person.Id];
        
        return a.PersonContactId; 

    }
    
    /**
     * Create and initialize the User but don't save it yet
     * 
     * @param data - the provided User context from FaceBook
     * @param p - the Profile we are going to assign to this user
     * 
     * @return User that has been initialized but not Saved
     **/ 
    private User createUser(Auth.UserData data, Profile p) {
        User u = new User();
        u.username = data.email + ORG_SUFFIX;
        u.email = data.email;
        u.lastName = data.lastName;
        u.firstName = data.firstName;
        String alias = data.firstName + data.lastName;
        
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
        return u;
    }
    
    
}