global class SocialRegHandler implements Auth.RegistrationHandler{
    
    static final string social_account = 'Social Sign-On';
    static final string community_profile = 'Customer Community User';
    static final string standard_profile  = 'Standard User';
    
    void prepareUserData(Auth.UserData data, User u)
    {   
        String name, firstName, lastName, username, alias, email;

        //TODO: Customize the user attributes. Also check that the username doesn't 
        //already exist and possibly ensure there are enough org licenses to 
        //create a user. Must be 80 characters or less
        
        // Print the attributes list retrieved by the Authentication Provider
        system.debug('Email: ' + data.email);
        system.debug('First Name: ' + data.firstName);
        system.debug('Last Name: ' + data.lastName);
        for(string key : data.attributeMap.keySet())
        {
            system.debug('key: ' + key + ' value: ' + data.attributeMap.get(key));
        }
    
        // Initialize the attributes essential for creating a new user with dummy values 
        // in case they will not be provided by the Auth Provider 
        firstName = 'change-me';
        lastName  = 'change-me';
        email     = 'change@me.com';
       
        if(data.email != null && data.email != '')
            email = data.email;
     
        if(data.firstName != null && data.firstName != '')
            firstName = data.firstName;
       
        if(data.LastName != null && data.lastName != '')
            lastName = data.lastName;

        if(data.attributeMap.containsKey('full_name'))
            name = data.attributeMap.get('full_name');
     
       if(data.attributeMap.containsKey('name'))
           name = data.attributeMap.get('name');

        if(firstName == 'change-me' && name != '')
            firstName = name.substringBefore(' ');

       if(lastName == 'change-me' && name.substringAfter(' ') != '')
           lastName = name.substringAfter(' ');
           
     
        // Generate a random username
        Integer rand = Math.round(Math.random()*100000000);
        username = firstName + '.' + rand + '@social-sign-on.com';        
    
        alias = firstName;
        //Alias must be 8 characters or less
        if(alias.length() > 8)
            alias = alias.substring(0, 8);   
            
        u.username = username;
        u.email = email;
        u.lastName = lastName;
        u.firstName = firstName;
        u.alias = alias;
        u.languagelocalekey = UserInfo.getLanguage();
        u.localesidkey = UserInfo.getLocale();
        u.emailEncodingKey = 'UTF-8';
        u.timeZoneSidKey = 'America/Los_Angeles';
    }
    
 // Creates a Standard salesforce or a community user
 global User createUser(Id portalId, Auth.UserData data){
    
    User u = new User();
    
    prepareUserData(data, u);
    
    //TODO: Customize the username, profile and account name
 
    if(data.attributeMap.containsKey('sfdc_networkid')) {
       //We have a community id, so create a user with community access
       
       //TODO: Customize the Account
       Account a;
       List<Account> accounts = [SELECT Id FROM account WHERE name=:social_account];
       if(accounts.isEmpty())
       {
           a = new Account(name = social_account);
           insert(a);
       }else
           a = accounts[0];
      
       Contact c = new Contact();
       c.accountId = a.Id;
  
       c.firstName = u.firstName;
       c.lastName  = u.lastName;
       insert(c);
       
       //TODO: Customize the profile
       Profile p = [SELECT Id FROM profile WHERE name=:community_profile];     
       u.profileId = p.Id;
       u.contactId = c.Id;
       return u;
    } else {
       //TODO: Customize the profile
       Profile p = [SELECT Id FROM profile WHERE name=:standard_profile];
       u.profileId = p.Id;
       return u;
    } 
}
    
// Updates the user's first and last name
global void updateUser(Id userId, Id portalId, Auth.UserData data){
 
  User u = new User(id=userId);
     
  if(data.email != null && data.email != '')
      u.email = data.email;
     
  if(data.lastName != null && data.lastName != '')
    u.lastName = data.lastName;
  
  if(data.firstName != null && data.firstName != '') 
    u.firstName = data.firstName;
  
  update(u);
} 

}
