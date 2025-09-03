public with sharing class CTLocationTracingController {

    //get all visitors by kocation id
    public static List<Location_Tracing__c> getVisitors(String locationId){
        return [SELECT Id, Name, Person__c, Location__c, Visit_Date__c, Person__r.Token__c, Person__r.Health_Status__c 
                       FROM Location_Tracing__c WHERE Id =: locationId ORDER BY Visit_Date__c DESC ];
    }

   //get all location ids for visitors
    public static List<Location_Tracing__c> getLocationsByPersonIds(Set<Id> PersonIds){
        return [SELECT Id, Name, Person__c, Location__c, Visit_Date__c , Person__r.Token__c, Person__r.Health_Status__c
                       FROM Location_Tracing__c WHERE Person__c IN : PersonIds  AND  Visit_Date__c = LAST_N_DAYS:10 ];
    }
     
    //Get all vitors by location ids who's health status is green
    public static List<Location_Tracing__c> getLocationsByLocationsIds(Set<Id> locationIds){
        return [SELECT Id, Name, Person__c, Location__c, Visit_Date__c ,Person__r.Token__c, Person__r.Health_Status__c
                       FROM Location_Tracing__c WHERE  Location__c IN : locationIds AND Person__r.Health_Status__c = 'Green' AND Visit_Date__c = LAST_N_DAYS:10];
    }
}