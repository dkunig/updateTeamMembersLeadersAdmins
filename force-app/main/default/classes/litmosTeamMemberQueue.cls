public class litmosTeamMemberQueue implements Queueable, Database.AllowsCallouts{
	private Litmos_Team__c team;
    private string endpoint;
    private string apikey;
    public litmosTeamMemberQueue(Litmos_Team__c team, String endpoint, String apikey) {
        this.team = team;
        this.endpoint = endpoint;
        this.apikey = apikey;
    }
    
    public void execute(QueueableContext context) {
		System.debug('inside litmosTeamMemberQueue');
        //variables
        //Set<String> currentLitmosIds = new Set<String>();
        Map<String, Litmos_Team_Member__c> checkMembers = new Map<String,Litmos_Team_Member__c>();
        Map<String, Litmos_Team_Member__c> updateMembers = new Map<String,Litmos_Team_Member__c>();
        List<Litmos_Team_Member__c> deleteMembers = new List<Litmos_Team_Member__c>();
        
        //get current list of team members
        List<Litmos_Team_Member__c> currentMembers = [SELECT Id,Learner__c,Litmos_User_Id__c,Litmos_Team__c,Member_Type__c FROM Litmos_Team_Member__c WHERE Litmos_Team__c = :team.Id];
        Map<String, Litmos_Team_Member__c> mapCurrent = new Map<String, Litmos_Team_Member__c>();
        //get set of Litmos Ids to check against results received from callout; if litmosId is in Set, don't add to updateMembers
        //if litmosId is in Set but not in results, add to deleteMembers
        for(Litmos_Team_Member__c member : currentMembers) {
            mapCurrent.put(member.Litmos_User_Id__c, member);
        }
        //perform callout
        //for production -- uncomment
        //HttpResponse response = litmosConnection.getLitmosExternalService(config.Litmos__Api_End_Point__c + '/teams/' + litmosId + '/users?source=sourceapp&format=json&limit=1000', config.Litmos__Api_Key__c);
        //for test org
		HttpResponse response = litmosConnection.getLitmosExternalService(endpoint, apikey);
        if(response.getStatusCode() == 200) {
            List<Object> results = (List<Object>)JSON.deserializeUntyped(response.getBody());
            System.debug('results size: ' + results.size());
            for(Object o : results) {
                Map<String, Object> newMap = (Map<String,Object>) o;
                checkMembers.put(String.valueOf(newMap.get('Id')),new Litmos_Team_Member__c(
                    Litmos_User_Id__c = String.valueOf(newMap.get('Id')),
                    Litmos_Team__c = team.Id,
                    Member_Type__c = 'Learner'
                ));
            }
        }
        
        //if currentMembers is NOT in checkMembers, move it to deleteMembers
        for(String litmos : mapCurrent.keySet()) {
            if(!checkMembers.containsKey(litmos)) {
                deleteMembers.add(mapCurrent.get(litmos));
            }
        }
        
        //if key is in currentMembers, delete it from map
        //
        checkMembers.keySet().removeAll(mapCurrent.keySet());
        
        //delete members
        if(deleteMembers.size() > 0) {
            List<String> errors = new List<String>();
            List<Database.DeleteResult> deleteRes = Database.delete(deleteMembers, false);
            Integer countSuccesses = 0;
            for(Database.DeleteResult dr : deleteRes) {
                if(dr.isSuccess()) {
                    countSuccesses += 1;
                } else {
                    errors.add('Error deleting team members from team: ' + team.Id + ' *** ' + String.valueOf(dr.getErrors()));
                }
        	}
            if(errors.size() > 0) {
                litmosSyncLogs.logTeamMemberErrors(errors);
            }
            if(countSuccesses > 0) {
                litmosSyncLogs.logTeamMemberDeletions(countSuccesses, team.Id);
            }
        }
        if(checkMembers.size() > 0) {
            //get user ids
            for(User u : [SELECT Id, Litmos__LitmosUserId__c FROM User WHERE Litmos__LitmosUserId__c IN :checkMembers.keySet()]) {
                checkMembers.get(u.Litmos__LitmosUserId__c).Learner__c = u.Id;
            }
            //if user doesn't exist, remove from checkMembers
            System.debug('checkMembers before remove: ' + checkMembers);
            for(String litmos : checkMembers.keySet()) {
                if(checkMembers.get(litmos).Learner__c == null) {
                    checkMembers.remove(litmos);
                }
            }
            System.debug('checkMembers after remove: ' + checkMembers);
            //insert team members
            Set<Id> successes = new Set<Id>();
            List<String> errors = new List<String>();
            List<Database.SaveResult> sr = Database.Insert(checkMembers.values());
            for(Database.SaveResult res : sr) {
                if(res.isSuccess()) {
                    successes.add(res.getId());
                } else {
                    errors.add('Error inserting team members for team : ' + team.Id + ' *** ' + String.valueOf(res.getErrors()));
                }
            }
            if(successes.size() > 0) {
                litmosSyncLogs.logTeamMemberSuccess([SELECT Id FROM Litmos_Team_Member__c WHERE Id IN: successes]);
            }
            if(errors.size() > 0) {
                litmosSyncLogs.logTeamMemberErrors(errors);
            }
        }
        String leaderEndpoint = endpoint.left(endpoint.lastIndexOf('/')) + '/leaders?source=sourceapp&format=json';
        if(!Test.isRunningTest()) {
            litmosTeamLeaderQueue leaderQueue = new litmosTeamLeaderQueue(team, leaderEndpoint, apikey);
        	Id jobId = System.enqueueJob(leaderQueue);
        }
        
    }
}