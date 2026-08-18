public class CaseEmail {
    @AuraEnabled
    @InvocableVariable(description='email subject' required=true)
    public String subject;
    @AuraEnabled
    @InvocableVariable(description='email body' required=true)
    public String body;
}