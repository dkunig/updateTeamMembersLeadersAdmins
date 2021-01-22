public class litmosUpdateTeam {
    private static final Litmos__Configuration__c config = [SELECT Litmos__Api_Key__c, Litmos__Api_End_Point__c FROM Litmos__Configuration__c WHERE isDeleted = false AND Litmos__Sync_Active__c = true];
    
	//public static void updateTeam(List<Id> teamIds) {
	@InvocableMethod
    public static void updateTeam(List<Litmos_Team__c> teams) {
        Litmos_Team__c team = teams[0];
        //testing: 
        string apikey = 'c86a5a1f-4057-411a-99cd-e180ecfe9bee';
        string endpoint = 'https://api.litmos.com/v1.svc/teams/' + teams[0].Litmos_Id__c;
        string endpointCap = '?source=sourceapp&format=json';
        //make all callouts then call methods for each one
        //member updates
        Map<String, Litmos_Team_Member__c> checkMembers = new Map<String,Litmos_Team_Member__c>();
        HttpResponse response = litmosConnection.getLitmosExternalService(endpoint + '/users' + endpointCap + '&limit=1000', apikey);
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
        //leader updates
        Set<String> teamLeaders = new Set<String>();
        response = litmosConnection.getLitmosExternalService(endpoint + '/leaders' + endpointCap, apikey);
        if(response.getStatusCode() == 200) {
            List<Object> results = (List<Object>)JSON.deserializeUntyped(response.getBody());
            for(Object o : results) {
                Map<String,Object> mapObj = (Map<String,Object>)o;
                teamLeaders.add(String.valueOf(mapObj.get('Id')));
            }
        }
        //admin updates
        Set<String> teamAdmins = new Set<String>();
        response = litmosConnection.getLitmosExternalService(endpoint + '/admins' + endpointCap, apikey);
        if(response.getStatusCode() == 200) {
            List<Object> results = (List<Object>)JSON.deserializeUntyped(response.getBody());
            for(Object o : results) {
                Map<String,Object> mapObj = (Map<String,Object>)o;
                teamAdmins.add(String.valueOf(mapObj.get('Id')));
            }
        }
        //description updates
        response = litmosConnection.getLitmosExternalService(endpoint + endpointCap, apikey);
        if(response.getStatusCode() == 200 && response.getBody() != '') {
            System.debug('response: ' + response.getBody());
            Map<String,Object> o = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
            team.Description__c = String.valueOf(o.get('Description'));
        }
        //update members
        memberUpdates(team, checkMembers);
        //update leaders();
        leaderUpdates(team, teamLeaders);
        //update admins();
        adminUpdates(team, teamAdmins);
        //description updates();
        descriptionUpdates(team);
    }
    static void memberUpdates(Litmos_Team__c team, Map<String,Litmos_Team_Member__c> checkMembers) {
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
    }        
    static void leaderUpdates(Litmos_Team__c team, Set<String> teamLeaders) {
        //current team leaders
        List<Litmos_Team_Member__c> leaders = [SELECT Id,Learner__c,Litmos_User_Id__c,Member_Type__c FROM Litmos_Team_Member__c WHERE Litmos_Team__c =: team.Id AND Member_Type__c = 'Leader'];
        Map<String,Litmos_Team_Member__c> mapLeaders = new Map<String,Litmos_Team_Member__c>();
        for(Litmos_Team_Member__c mem : leaders) {
            mapLeaders.put(mem.Litmos_User_Id__c, mem);
        }
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
    }
    static void adminUpdates(Litmos_Team__c team, Set<String> teamAdmins) {
        //current team admins
        List<Litmos_Team_Member__c> admins = [SELECT Id,Learner__c,Litmos_User_Id__c,Member_Type__c FROM Litmos_Team_Member__c WHERE Litmos_Team__c =: team.Id AND Member_Type__c = 'Admin'];
        Map<String,Litmos_Team_Member__c> mapAdmins = new Map<String,Litmos_Team_Member__c>();
        for(Litmos_Team_Member__c mem : admins) {
            mapAdmins.put(mem.Litmos_User_Id__c, mem);
        }
        System.debug('mapAdmins: ' + mapAdmins);
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
    }
    static void descriptionUpdates(Litmos_Team__c team) {
        Database.SaveResult result = Database.update(team, false);
        if(result.isSuccess()) {
            litmosSyncLogs.logTeamsSuccess(new List<Litmos_Team__c>{team});
        } else {
            Map<String, String> errorMap = new Map<String, String>();
            errorMap.put(team.Id, 'Error updating description for ' + team.Id);
            litmosSyncLogs.logTeamsErrors(new List<Litmos_Team__c>{team}, errorMap);
        }
    }
        
        
}