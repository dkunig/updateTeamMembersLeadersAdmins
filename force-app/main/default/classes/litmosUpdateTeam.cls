public class litmosUpdateTeam {
    
    @InvocableMethod
	public static void updateTeam(List<Id> teamIds) {
        //get team
        Litmos_Team__c team = [SELECT Id, Litmos_Id__c, Name, Description__c FROM Litmos_Team__c WHERE Id IN : teamIds LIMIT 1];
		System.debug(team);
        Litmos__Configuration__c config = [SELECT Litmos__Api_Key__c, Litmos__Api_End_Point__c FROM Litmos__Configuration__c WHERE isDeleted = false AND Litmos__Sync_Active__c = true];
        //for testing in dev org only
        string apikey = 'c86a5a1f-4057-411a-99cd-e180ecfe9bee';
        string endpoint = 'https://api.litmos.com/v1.svc/teams/' + team.Litmos_Id__c;
        
        //update team members
        //for production -- uncomment
        //litmosTeamMemberQueue memberQueue = new litmosTeamMemberQueue(team, config.Litmos__API_End_Point__c + '/users?source=sourceapp&format=json&limit=1000', config.Litmos__Api_Key__c);
        litmosTeamMemberQueue memberQueue = new litmosTeamMemberQueue(team, endpoint + '/users?source=sourceapp&format=json&limit=1000', apikey);
        Id jobId = System.enqueueJob(memberQueue);
        
        
    }
}