
An Auth. Provider registration handler that implements the following:

First time login into salesforce:
- Create a new 'Standard User' user

First time login into Communities
- Create a 'Social Sign-On' Account if not exists
- Create a new 'Customer Community User' user
- Create a new contact under the 'Social Sign-on' account and link it with the newly created user

A returning login into salesforce or communities:
- Update the user email, first and last name if changed

This Apex will populate the user records with default values if not provided by the Identity Provider. For example if twitter doesn't provide users' email address, the following value will be used: 'change@me.com'

You may change this implementation to best fit your provisioning flow
