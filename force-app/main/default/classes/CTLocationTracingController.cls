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

    public static List<Location_Tracing__c> checkDuplicates(List<Location_Tracing__c> newlocationTraces){
          
          //store unique locationIds
          Set<Id> locationIds =  new Set<Id>();
          //store unique personIds
          Set<Id> personIds = new Set<Id>();
          
          for(Location_Tracing__c trace : newlocationTraces){
            locationIds.add(trace.Location__c);
            personIds.add(trace.Person__c);
          }

          //map of location ids and set of personids
          //we are storing the location ids and correspoding person ids
          Map<Id, Set<Id>> mapOfExistingRecords = new Map<Id, Set<Id>>();

          //query existing location records
          List<Location_Tracing__c> existingRecords =  [SELECT Id, Name, Person__c, Location__c, Visit_Date__c ,Person__r.Token__c, Person__r.Health_Status__c 
                                                               FROM Location_Tracing__c 
                                                               WHERE  Location__c IN : locationIds 
                                                               AND Person__c IN : personIds];
          
          //list of duplicate records
          List<Location_Tracing__c> duplicates =  new List<Location_Tracing__c>();
           
          if(existingRecords != null && existingRecords.size() >0){
            for(Location_Tracing__c trace :  existingRecords){
                //check if the map  already has locationId key
                if( ! mapOfExistingRecords.containsKey(trace.Location__c)){

                    //map does not have this key
                    //Add this new item in the map using location id as key
                    //and blank Set<Id> as value
                    mapOfExistingRecords.put(trace.Location__c, new Set<Id>());
                }
                //add person ids to map set -- Set<Id> - which is declared inside of the map.
                // why we are using a get method here is, for example the map looks like location1, [Pesrson1, person2], 
                // so when you use the the get menthod you will get the person ids of the location like person1 and person 2 set
                // so since we got the set we are adding the new value(person id) using add method.

                mapOfExistingRecords.get(trace.Location__c).add(trace.Person__c);     

            } // till this we have built the map of existing records.
            
            //loop over new location tracing records
            for(Location_Tracing__c trace : newlocationTraces){

                /*
                 first here we will check if the location id of this trace record already exists in my map or not, 
                 if yes, then I'll also try to match the person id, and if we find a match, then it's a duplicate record.
                */
                
                //first check for location id
                //if item(means the location id) found in the map, then check for person in set
                if(mapOfExistingRecords.containsKey(trace.Location__c)                                  // here we are checking the map is contains the location id
                       && mapOfExistingRecords.get(trace.Location__c).contains(trace.Person__c)){       // heare we are checking the map is also contains the person id
                                                                                                        // why we are mentioning like this mapOfExistingRecords.get(trace.Location__c).contains(trace.Person__c)?
                                                                                                        //  mapOfExistingRecords.get(trace.Location__c) -- from this we will get the set of person ids
                                                                                                        // then we are using  .contains(trace.Person__c) to check the person ids are present.
                    //if the records is come inside the if condition then it is a duplicate record.
                   // so adding the records in to the duplicate list which we declared before at line 44     
                   duplicates.add(trace);
                }
            }

          }

          return duplicates;
    }
    
        
    
}