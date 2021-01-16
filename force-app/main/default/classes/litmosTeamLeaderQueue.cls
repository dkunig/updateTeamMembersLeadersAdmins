public class litmosTeamLeaderQueue implements Queueable,Database.AllowsCallouts{
    private String endpoint;
    private String apikey;
    private Litmos_Team__c team;
    public litmosTeamLeaderQueue(Litmos_Team__c team, String endpoint, String apikey) {
        this.endpoint = endpoint;
        this.apikey = apikey;
        this.team = team;
    }
    public void execute(QueueableContext context) {
        //current team leaders
        List<Litmos_Team_Member__c> leaders = [SELECT Id,Learner__c,Litmos_User_Id__c,Member_Type__c FROM Litmos_Team_Member__c WHERE Litmos_Team__c =: team.Id AND Member_Type__c = 'Leader'];
        Map<String,Litmos_Team_Member__c> mapLeaders = new Map<String,Litmos_Team_Member__c>();
        for(Litmos_Team_Member__c mem : leaders) {
            mapLeaders.put(mem.Litmos_User_Id__c, mem);
        }
        //System.debug('mapLeaders: ' + mapLeaders);
        //callout
        //Set to hold new leaders
        Set<String> teamLeaders = new Set<String>();
        HttpResponse response = litmosConnection.getLitmosExternalService(endpoint, apikey);
        if(response.getStatusCode() == 200) {
            List<Object> results = (List<Object>)JSON.deserializeUntyped(response.getBody());
            for(Object o : results) {
                Map<String,Object> mapObj = (Map<String,Object>)o;
                teamLeaders.add(String.valueOf(mapObj.get('Id')));
            }
        }
        //System.debug('newLeaders: ' + teamLeaders);
        //promote members
        Map<String, Litmos_Team_Member__c> updateMembers = new Map<String, Litmos_Team_Member__c>();
        for(Litmos_Team_Member__c member : [SELECT Id,Learner__c,Litmos_User_Id__c,Member_Type__c FROM Litmos_Team_Member__c WHERE Litmos_Team__c =: team.Id AND Member_Type__c != 'Leader' AND Litmos_User_Id__c IN :teamLeaders]) {
            member.Member_Type__c = 'Leader';
            updateMembers.put(member.Litmos_User_Id__c, member);
        }
        System.debug('updateMembers before demote: ' + updateMembers);
        //demote members
        if(!teamLeaders.containsAll(mapLeaders.keySet())) {
            for(Litmos_Team_Member__c mem : mapLeaders.values()) {
                if(!teamLeaders.contains(mem.Litmos_User_Id__c)) {
                    mem.Member_Type__c = 'Learner';
                    updateMembers.put(mem.Litmos_User_Id__c, mem);
                }
            }
        }
        teamLeaders.removeAll(updateMembers.keySet());
        //System.debug('teamLeaders: ' + teamLeaders);
        //System.debug('updateMembers after demote: ' + updateMembers);
        //add users to team and promote automatically
        //users that are in "newLeaders" from Litmos but aren't in updateMembers aren't on the team **** THIS LOGIC IS INCORRECT
        Set<String> noTeamMembers = new Set<String>();
        if(!mapLeaders.keySet().containsAll(teamLeaders)) {
            for(String s : teamLeaders) {
                if(!mapLeaders.containsKey(s)) {
                    noTeamMembers.add(s);
                }
            }
        }
        if(noTeamMembers.size() > 0) {
            litmosAddTeamMembers.addTeamMembers([SELECT Id,Litmos__LitmosUserId__c FROM User WHERE Litmos__LitmosUserId__c IN : noTeamMembers], team.Id, 'Leader');
        }
        
        //update members and log successes or add to error log
        Set<Id> successes = new Set<Id>();
        String errors = 'Error updating ';
        if(updateMembers.size() > 0) {
            List<Database.SaveResult> saveResults = Database.update(updateMembers.values());
            for(Database.SaveResult sr : saveResults) {
                if(sr.isSuccess()) {
                    successes.add(sr.getId());
                } else {
                    errors = errors + sr.getId() + ' ';
                }
            }
        }
        Map<String,String> errorMap = new Map<String,String>{team.Id => errors};
       	if(errorMap.size() > 0) {
           litmosSyncLogs.logTeamMemberErrors(errorMap);
        }
        if(successes.size() > 0) {
            litmosSyncLogs.logTeamMemberSuccess([SELECT Id FROM Litmos_Team_Member__c WHERE Id IN : successes]);
        }
        String adminEndpoint = endpoint.left(endpoint.lastIndexOf('/')) + '/admins?source=sourceapp&format=json';
        if(!Test.isRunningTest()){
            litmosTeamAdminQueue adminQueue = new litmosTeamAdminQueue(team, adminEndpoint, apikey);
        	Id jobId = System.enqueueJob(adminQueue);
        }
        
    }
    
        
}