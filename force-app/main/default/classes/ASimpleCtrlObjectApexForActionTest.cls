public without sharing class ASimpleCtrlObjectApexForActionTest{

    @InvocableMethod
    public static List<Account> getPropertyBasedOnCity(List<Integer> Amount){
        return [select Id, Name from Account limit 1];
    }
}