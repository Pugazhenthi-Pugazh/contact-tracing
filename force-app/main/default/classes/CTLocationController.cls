public with sharing class CTLocationController {

    //Get 100 location with recent status change
    public static List<Location__c> getRecentStatusChanges(){
        return  [SELECT Id, Name, Address__c, Pincode__c, Red_Score__c, Status_Update_Date__c, Status__c
                                    FROM Location__c ORDER BY Status_Update_Date__c DESC NULLS LAST LIMIT 100];
        
    }
    
    //search a location by name or pincode or address
    public static List<Location__c> searchLocations(String SearchTerm){
        SearchTerm = SearchTerm + '%';
        return  [SELECT Id, Name, Address__c, Pincode__c, Red_Score__c, Status_Update_Date__c, Status__c
                                    FROM Location__c  
                                    WHERE Name LIKE : SearchTerm 
                                    OR Pincode__c LIKE : SearchTerm 
                                    OR Address__c LIKE : SearchTerm ORDER BY Status_Update_Date__c NULLS LAST];
    }
    
    //search location by id
    public static Location__c getLocationById(String locationId){
        
        List<Location__c> locationList =  [SELECT Id, Name, Address__c, Pincode__c, Red_Score__c, Status_Update_Date__c, Status__c
                                    FROM Location__c WHERE Id =:locationId];
        if(locationList != null && locationList.size() >0){
            return locationList[0];
        }

        return null;

    }

}