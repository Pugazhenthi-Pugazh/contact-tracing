public with sharing class CTPeopleTracingController {

    public static List<People_Tracing__c> getTraces(String personId){

        return [SELECT Id, Name, Contact_Date__c, Person_1__c, Person_1__r.Health_Status__c, Person_1__r.Token__c, Person_2__c,Person_2__r.Health_Status__c, Person_2__r.Token__c
                       FROM People_Tracing__c 
                       WHERE Person_1__c =: personId OR Person_2__c =: personId 
                       ORDER BY Contact_Date__c DESC];
    }

    public static List<People_Tracing__c> checkDuplicates(List<People_Tracing__c> newPeopleTraces){
       
        //To store unique pesonids, here using a single set collection becasue
        //becasue the person could be available in both person1 and person2
        //so we are declared one set and will add the both person1 and person2 ids in the set.
        Set<Id> personIds = new Set<Id>();

        for(People_Tracing__c trace : newPeopleTraces){
            personIds.add(trace.Person_1__c);
            personIds.add(trace.Person_2__c);
        }
        
        //duplicate list
        List<People_Tracing__c> duplicates= new List<People_Tracing__c>();
       // in the map we are  storing  a person ID and then all the person or all the people he(which stored in the peroson ID) has met in the set of ids.
       // Example:| Key(PersonId) | Value(Set of Id)|
       //         |  John         |   Tony          |
       //         |               |   Nick          |
       //         -----------------------------------
       //         |   XYZ         |   ABC           |

        Map<Id, Set<Id>> mapOfExistingRecords = new Map<Id, Set<Id>>();

        //query existing records
        List<People_Tracing__c> existingRecords = [SELECT Id, Name, Person_1__c, Person_2__c 
                                                          FROM People_Tracing__c 
                                                          WHERE Person_1__c IN: personIds 
                                                          AND Person_2__c IN : personIds];
        
        
        if(existingRecords != null && existingRecords.size()>0){

            for(People_Tracing__c trace : existingRecords){
                if(!mapOfExistingRecords.containsKey(trace.Person_1__c)){
                    mapOfExistingRecords.put(trace.Person_1__c, new Set<Id>());
                }
                mapOfExistingRecords.get(trace.Person_1__c).add(trace.Person_2__c);
                
                // we need to repeated the lines 44 to 47 for person 2 as well, because these persons can be stored in
                // the person 1 field as well or person 2 field as well,
                if(!mapOfExistingRecords.containsKey(trace.Person_2__c)){
                    mapOfExistingRecords.put(trace.Person_2__c, new Set<Id>());
                }
                mapOfExistingRecords.get(trace.Person_2__c).add(trace.Person_1__c);
            }
            
            //loop over existing records to find the duplicates
            for (People_Tracing__c trace : newPeopleTraces) {
                //check for duplicates in map
                if ( 
                    (mapOfExistingRecords.containsKey(trace.Person_1__c) && mapOfExistingRecords.get(trace.Person_1__c).contains(trace.Person_2__c))
                    || 
                    (mapOfExistingRecords.containsKey(trace.Person_2__c) && mapOfExistingRecords.get(trace.Person_2__c).contains(trace.Person_1__c))  
                    ){

                      duplicates.add(trace);
                }
            }
        }
        return duplicates;
    }
}