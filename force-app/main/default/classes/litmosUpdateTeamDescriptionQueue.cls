public class litmosUpdateTeamDescriptionQueue implements Queueable,Database.AllowsCallouts{
    private String endpoint;
    private String apikey;
    private Litmos_Team__c team;
    public litmosUpdateTeamDescriptionQueue(Litmos_Team__c team, String endpoint, String apikey) {
        this.team = team;
        this.endpoint = endpoint;
        this.apikey = apikey;
    }
    public void execute(QueueableContext context) {
        HttpResponse response = litmosConnection.getLitmosExternalService(endpoint, apikey);
        if(response.getStatusCode() == 200 && response.getBody() != '') {
            System.debug('response: ' + response.getBody());
            Map<String,Object> o = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
            team.Description__c = String.valueOf(o.get('Description'));
        }
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