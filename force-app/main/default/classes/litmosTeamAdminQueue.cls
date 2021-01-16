public class litmosTeamAdminQueue implements Queueable,Database.AllowsCallouts {
	private String endpoint;
    private String apikey;
    private Litmos_Team__c team;
    public litmosTeamAdminQueue(Litmos_Team__c team, String endpoint, String apikey) {
        this.team = team;
        this.endpoint = endpoint;
        this.apikey = apikey;
    }
    public void execute(QueueableContext context) {
        //current team admins
        List<Litmos_Team_Member__c> admins = [SELECT Id,Learner__c,Litmos_User_Id__c,Member_Type__c FROM Litmos_Team_Member__c WHERE Litmos_Team__c =: team.Id AND Member_Type__c = 'Admin'];
        Map<String,Litmos_Team_Member__c> mapAdmins = new Map<String,Litmos_Team_Member__c>();
        for(Litmos_Team_Member__c mem : admins) {
            mapAdmins.put(mem.Litmos_User_Id__c, mem);
        }
        System.debug('mapAdmins: ' + mapAdmins);
        //callout
        //Set to hold new admins
        Set<String> teamAdmins = new Set<String>();
        HttpResponse response = litmosConnection.getLitmosExternalService(endpoint, apikey);
        if(response.getStatusCode() == 200) {
            List<Object> results = (List<Object>)JSON.deserializeUntyped(response.getBody());
            for(Object o : results) {
                Map<String,Object> mapObj = (Map<String,Object>)o;
                teamAdmins.add(String.valueOf(mapObj.get('Id')));
            }
        }
        //promote members
        Map<String, Litmos_Team_Member__c> updateMembers = new Map<String, Litmos_Team_Member__c>();
        for(Litmos_Team_Member__c member : [SELECT Id,Learner__c,Litmos_User_Id__c,Member_Type__c FROM Litmos_Team_Member__c WHERE Litmos_Team__c =: team.Id AND Member_Type__c != 'Admin' AND Litmos_User_Id__c IN :teamAdmins]) {
            member.Member_Type__c = 'Admin';
            updateMembers.put(member.Litmos_User_Id__c, member);
            
        }
        //demote members
        if(!teamAdmins.containsAll(mapAdmins.keySet())) {
            for(Litmos_Team_Member__c mem : mapAdmins.values()) {
                if(!teamAdmins.contains(mem.Litmos_User_Id__c)) {
                    mem.Member_Type__c = 'Learner';
                    updateMembers.put(mem.Litmos_User_Id__c, mem);
                }
            }
        }
        //add users to team and promote automatically
        //users that are in "newAdmins" from Litmos but aren't in updateMembers aren't on the team
        teamAdmins.removeAll(updateMembers.keySet());
        Set<String> noTeamMembers = new Set<String>();
        if(!mapAdmins.keySet().containsAll(teamAdmins)) {
            for(String s : teamAdmins) {
                if(!mapAdmins.containsKey(s)) {
                    noTeamMembers.add(s);
                }
            }
        }
        if(noTeamMembers.size() > 0) {
            litmosAddTeamMembers.addTeamMembers([SELECT Id,Litmos__LitmosUserId__c FROM User WHERE Litmos__LitmosUserId__c IN : noTeamMembers], team.Id, 'Admin');
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
        String descEndpoint = endpoint.substringBeforeLast('/') + '?source=sourceapp&format=json';
        if(!Test.isRunningTest()) {
            
            litmosUpdateTeamDescriptionQueue updateDesc = new litmosUpdateTeamDescriptionQueue(team, descEndpoint, apikey);
            Id updateJobId = System.enqueueJob(updateDesc);
        }
        
    }
}