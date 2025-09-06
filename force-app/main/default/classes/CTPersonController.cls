public with sharing class CTPersonController {

    //hasing the mobile number
    public static String getToken(String mobileNo){
        Blob value = Blob.valueOf(mobileNo);
        Blob hash = Crypto.generateDigest('MD5', value);

        //geting the string value of has blob
        String result = EncodingUtil.base64Encode(hash);

        // you can mention the encoding directly in return like this
        //return EncodingUtil.base64Encode(hash); -- it will also retrun the string value.

        return result;
    }
    
    //Get 100 persons with recent health status change
    public static List<Person__c> getRecentHealthChanges(){
        List<Person__c> personList = [SELECT id, Name, Mobile__c, 	Token__c, Health_Status__c, Status_Update_Date__c
                                             FROM Person__c  ORDER BY Status_Update_Date__c DESC NULLS LAST LIMIT 100];
        return personList;
    } 
    
    //search a person by name or token or mobile
    public static List<Person__c> searchPeople(String searchTerm){
        searchTerm = searchTerm + '%';
        List<Person__c> searchPersonList = [SELECT id, Name, Mobile__c, Token__c, Health_Status__c, Status_Update_Date__c, CurrencyIsoCode
                                             FROM Person__c 
                                             WHERE Name LIKE :searchTerm OR Mobile__c LIKE :searchTerm OR Token__c LIKE :searchTerm  
                                             ORDER BY Status_Update_Date__c DESC NULLS LAST];

        return searchPersonList;
    }
    
    //search a person  by id
    public static Person__c getPersonId(String personId){
        List<Person__c> personIdlist = [SELECT id, Name, Mobile__c, Token__c, Health_Status__c, Status_Update_Date__c
                                             FROM Person__c  WHERE id =: personId];
        if(personIdlist != null && personIdlist.size() >0){
            return personIdlist[0];
        }                                     
        return null;

    
    }
    
    //Get count of people in each health status
    public static Map<String,Integer> getHealthStatusCount(){

             Map<String,Integer> healthCountMap =  new Map<String,Integer>();
             for (AggregateResult result : [SELECT COUNT(id) personCount, Health_Status__c
                                                         FROM Person__c 
                                                         GROUP BY Health_Status__c]) {

                healthCountMap.put(String.valueOf(result.get('Health_Status__c')),Integer.valueOf(result.get('personCount')));
                
             }
             return healthCountMap;
    }
}