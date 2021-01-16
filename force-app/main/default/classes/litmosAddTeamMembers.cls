public class litmosAddTeamMembers {
    public static void addTeamMembers(List<User> users, Id teamId, String memberType) {
        List<Litmos_Team_Member__c> newMembers = new List<Litmos_Team_Member__c>();
        for(User u : users) {
            newMembers.add(new Litmos_Team_Member__c(
            	Learner__c = u.Id,
                Litmos_Team__c = teamId,
                Member_Type__c = memberType,
                Litmos_User_Id__c = u.Litmos__LitmosUserId__c
            ));
        }
        //log successes and errors
        Set<String> successes = new Set<String>();
        String errors;
        if(newMembers.size() > 0) {
            List<Database.SaveResult> saveResults = Database.Insert(newMembers, false);
            for(Database.SaveResult sr : saveResults) {
                if(sr.isSuccess()) {
                    successes.add(sr.Id);
                } else {
                    errors = 'Error adding members of type ' + memberType + 'to team ' + teamId;
                }
            }
        }
        if(successes.size() > 0) {
            litmosSyncLogs.logTeamMemberSuccess([SELECT Id FROM Litmos_Team_Member__c WHERE Id IN : successes]);
        }
        if(errors != null) {
            litmosSyncLogs.logTeamMemberErrors(new Map<String,String>{teamId => errors});
        }
    }
}