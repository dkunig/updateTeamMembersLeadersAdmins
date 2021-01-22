@isTest
public class litmosUpdateTeamTEST {
	@testSetup
    static void setup() {
        //config
        insert new Litmos__Configuration__c(
        	Litmos__Api_Key__c = 'abcde',
            Litmos__Api_End_Point__c = 'https://api.litmos.com/v1.svc/',
            Litmos__Sync_Active__c = true
        );
        //6 users
        Profile standardUser = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        List<User> users = new List<User>();
        User learner1 = new User(
        	FirstName = 'Learner 1',
            LastName = 'Test Learner 1',
            Litmos__OriginalId__c = 13488946,
            Litmos__LitmosUserId__c = 'NotOnTeamLeader',
            ProfileId = standardUser.Id,
            isActive = true,
            email='learner1@learner1.com',
            Username='learner1@learner1.com',
            alias='lear1',
            TimeZoneSidKey='America/New_York',
            LocaleSidKey='en_US',
            EmailEncodingKey='UTF-8',
            LanguageLocaleKey='en_US'
        );
        User learner2 = new User(
        	FirstName = 'Learner 2',
            LastName = 'Test Promote to Leader',
            Litmos__OriginalId__c = 2345678,
            Litmos__LitmosUserId__c = 'Promote2Leader',
            ProfileId = standardUser.Id,
            isActive = true,
            email='learner2@learner2.com',
            Username='learner2@learner2.com',
            alias='lear2',
            TimeZoneSidKey='America/New_York',
            LocaleSidKey='en_US',
            EmailEncodingKey='UTF-8',
            LanguageLocaleKey='en_US');
        User learner3 = new User(
        	FirstName = 'Learner 3',
            LastName = 'Test Promote to Admin',
            Litmos__OriginalId__c = 2233445,
            Litmos__LitmosUserId__c = 'Promote2Admin',
            ProfileId = standardUser.Id,
            isActive = true,
            email='learner3@learner3.com',
            Username='learner3@learner3.com',
            alias='lear3',
            TimeZoneSidKey='America/New_York',
            LocaleSidKey='en_US',
            EmailEncodingKey='UTF-8',
            LanguageLocaleKey='en_US'
        );
        User learner4 = new User(
        	FirstName = 'Learner 4',
            LastName = 'Test Promote to Admin and Add to team',
            Litmos__OriginalId__c = 11223344,
            Litmos__LitmosUserId__c = 'NotOnTeamAdmin',
            ProfileId = standardUser.Id,
            isActive = true,
            email='learner4@learner4.com',
            Username='learner4@learner4.com',
            alias='lear4',
            TimeZoneSidKey='America/New_York',
            LocaleSidKey='en_US',
            EmailEncodingKey='UTF-8',
            LanguageLocaleKey='en_US'
        );
        User member1 = new User(
        	FirstName = 'Member 1',
            LastName = 'Test Add Member',
            Litmos__OriginalId__c = 11223344,
            Litmos__LitmosUserId__c = 'Member1',
            ProfileId = standardUser.Id,
            isActive = true,
            email='member1@member1.com',
            Username='member1@member1.com',
            alias='memb1',
            TimeZoneSidKey='America/New_York',
            LocaleSidKey='en_US',
            EmailEncodingKey='UTF-8',
            LanguageLocaleKey='en_US'
        );
        User member2 = new User(
        	FirstName = 'Member 2',
            LastName = 'Remove from team',
            Litmos__OriginalId__c = 22334455,
            Litmos__LitmosUserId__c = 'RemoveMember',
            ProfileId = standardUser.Id,
            isActive = true,
            email='member2@member2.com',
            Username='member2@member2.com',
            alias='lead1',
            TimeZoneSidKey='America/New_York',
            LocaleSidKey='en_US',
            EmailEncodingKey='UTF-8',
            LanguageLocaleKey='en_US'
        );
        User leader1 = new User(
        	FirstName = 'Leader 1',
            LastName = 'Test Keep Leader',
            Litmos__OriginalId__c = 3456789,
            Litmos__LitmosUserId__c = 'Leader1',
            ProfileId = standardUser.Id,
            isActive = true,
            email='leader1@leader1.com',
            Username='leader1@leader1.com',
            alias='lead1',
            TimeZoneSidKey='America/New_York',
            LocaleSidKey='en_US',
            EmailEncodingKey='UTF-8',
            LanguageLocaleKey='en_US'
        );
        User leader2 = new User(
        	FirstName = 'Leader 2',
            LastName = 'Test Demote Leader',
            Litmos__OriginalId__c = 4567891,
            Litmos__LitmosUserId__c = 'LeaderDemote',
            ProfileId = standardUser.Id,
            isActive = true,
            email='leader2@leader2.com',
            Username='leader2@leader2.com',
            alias='lead2',
            TimeZoneSidKey='America/New_York',
            LocaleSidKey='en_US',
            EmailEncodingKey='UTF-8',
            LanguageLocaleKey='en_US'
        );
        User leader3 = new User(
        	FirstName = 'Leader 3',
            LastName = 'Test Promote to Admin',
            Litmos__OriginalId__c = 5678912,
            Litmos__LitmosUserId__c = 'PromoteLeadToAdmin',
            ProfileId = standardUser.Id,
            isActive = true,
            email='leader3@leader3.com',
            Username='leader3@leader3.com',
            alias='lead3',
            TimeZoneSidKey='America/New_York',
            LocaleSidKey='en_US',
            EmailEncodingKey='UTF-8',
            LanguageLocaleKey='en_US'
        );
        User admin1 = new User(
        	FirstName = 'Admin 1',
            LastName = 'Test Leave Admin',
            Litmos__OriginalId__c = 6789123,
            Litmos__LitmosUserId__c = 'LeaveAdmin',
            ProfileId = standardUser.Id,
            isActive = true,
            email='lmsadmin1@admin1.com',
            Username='lmsadmin1@admin1.com',
            alias='admi1',
            TimeZoneSidKey='America/New_York',
            LocaleSidKey='en_US',
            EmailEncodingKey='UTF-8',
            LanguageLocaleKey='en_US'
        );
        User admin2 = new User(
        	FirstName = 'Admin 2',
            LastName = 'Test Demote Admin',
            Litmos__OriginalId__c = 7891234,
            Litmos__LitmosUserId__c = 'DemoteAdmin',
            ProfileId = standardUser.Id,
            isActive = true,
            email='lmsadmin2@admin2.com',
            Username='lmsadmin2@admin2.com',
            alias='admi2',
            TimeZoneSidKey='America/New_York',
            LocaleSidKey='en_US',
            EmailEncodingKey='UTF-8',
            LanguageLocaleKey='en_US'
        );
        User admin3 = new User(
        	FirstName = 'Admin 3',
            LastName = 'Test Promote Leader',
            Litmos__OriginalId__c = 8912345,
            Litmos__LitmosUserId__c = 'PromoteAdminToLeader',
            ProfileId = standardUser.Id,
            isActive = true,
            email='admin3@admin3.com',
            Username='admin3@admin3.com',
            alias='admi3',
            TimeZoneSidKey='America/New_York',
            LocaleSidKey='en_US',
            EmailEncodingKey='UTF-8',
            LanguageLocaleKey='en_US'
        );
        users.add(learner1);
        users.add(learner2);
        users.add(learner3);
        users.add(learner4);
        users.add(leader1);
        users.add(leader2);
        users.add(leader3);
        users.add(admin1);
        users.add(admin2);
        users.add(admin3);
        users.add(member1);
        users.add(member2);
        insert users;
        //team with 2 leaders, 2 learner, 2 admins
        Litmos_Team__c team = new Litmos_Team__c(
        	Name = 'My Test Team',
            Litmos_Id__c = 'MyTestTeam'
        );
        insert team;
        //7 team members
        List<Litmos_Team_Member__c> teamMembers = new List<Litmos_Team_Member__c>();
        //learners -- add three learners on team. Learner 1 will be promoted but not on team to confirm learner is added to the team, then promoted; member2 will be removed from team
        teamMembers.add(new Litmos_Team_Member__c(
        	Litmos_User_Id__c = learner2.Litmos__LitmosUserId__c,
            Litmos_Team__c = team.Id,
            Learner__c = learner2.Id,
            Member_Type__c = 'Learner'
        ));
        teamMembers.add(new Litmos_Team_Member__c(
        	Litmos_User_Id__c = learner3.Litmos__LitmosUserId__c,
            Litmos_Team__c = team.Id,
            Learner__c = learner3.Id,
            Member_Type__c = 'Learner'
        ));
        teamMembers.add(new Litmos_Team_Member__c(
        	Litmos_User_Id__c = member2.Litmos__LitmosUserId__c,
            Litmos_Team__c = team.Id,
            Learner__c = member2.Id,
            Member_Type__c = 'Learner'
        ));
        //leaders
        teamMembers.add(new Litmos_Team_Member__c(
        	Litmos_User_Id__c = leader1.Litmos__LitmosUserId__c,
            Litmos_Team__c = team.Id,
            Learner__c = leader1.Id,
            Member_Type__c = 'Leader'
        ));
        teamMembers.add(new Litmos_Team_Member__c(
        	Litmos_User_Id__c = leader2.Litmos__LitmosUserId__c,
            Litmos_Team__c = team.Id,
            Learner__c = leader2.Id,
            Member_Type__c = 'Leader'
        ));
        teamMembers.add(new Litmos_Team_Member__c(
        	Litmos_User_Id__c = leader3.Litmos__LitmosUserId__c,
            Litmos_Team__c = team.Id,
            Learner__c = leader3.Id,
            Member_Type__c = 'Leader'
        ));
        //admins
        teamMembers.add(new Litmos_Team_Member__c(
        	Litmos_User_Id__c = admin1.Litmos__LitmosUserId__c,
            Litmos_Team__c = team.Id,
            Learner__c = admin1.Id,
            Member_Type__c = 'Admin'
        ));
        teamMembers.add(new Litmos_Team_Member__c(
        	Litmos_User_Id__c = admin2.Litmos__LitmosUserId__c,
            Litmos_Team__c = team.Id,
            Learner__c = admin2.Id,
            Member_Type__c = 'Admin'
        ));
        teamMembers.add(new Litmos_Team_Member__c(
        	Litmos_User_Id__c = admin3.Litmos__LitmosUserId__c,
            Litmos_Team__c = team.Id,
            Learner__c = admin3.Id,
            Member_Type__c = 'Admin'
        ));
        insert teamMembers;
    }
    @isTest
    static void testMembers() {
        System.debug('testMembers() method');
        //at the end of this test, there should be 3 learners and one learner removed
        Litmos__Configuration__c config = [SELECT Litmos__Api_End_Point__c, Litmos__Api_Key__c FROM Litmos__Configuration__c LIMIT 1];
        //check that member 2 is on the team
        List<Litmos_Team__c> teams = [SELECT Id,Litmos_Id__c FROM Litmos_Team__c];
        System.assertNotEquals(null, [SELECT Id FROM Litmos_Team_Member__c WHERE Litmos_Team__c =: teams[0].Id AND Litmos_User_Id__c ='RemoveMember'], 'Expected 1 team member with Litmos Id \'RemoveMember\'');
        //set up mock
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource(config.Litmos__API_End_Point__c + 'teams/' + teams[0].Litmos_Id__c + '/users?source=sourceapp&format=json&limit=1000', 'Litmos_Team_Member_Updates_Demand');
        multimock.setStaticResource(config.Litmos__API_End_Point__c + 'teams/' + teams[0].Litmos_Id__c + '/leaders?source=sourceapp&format=json', 'Litmos_Team_Leader_Updates_Demand');
		multimock.setStaticResource(config.Litmos__API_End_Point__c + 'teams/' + teams[0].Litmos_Id__c + '/admins?source=sourceapp&format=json', 'Litmos_Team_Admin_Updates_Demand');
       	multimock.setStaticResource(config.Litmos__API_End_Point__c + 'teams/' + teams[0].Litmos_Id__c + '?source=sourceapp&format=json', 'Litmos_Team_Description_Updates_Demand');
        multimock.setStatusCode(200);
        multimock.setHeader('apikey', config.Litmos__API_Key__c);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, multimock);
        litmosUpdateTeam.updateTeam(teams);
        Test.stopTest();
        //MEMBER ASSERTIONS
        //confirm member1 is on team (3 learners total)
        System.assertEquals(3, [SELECT count() FROM Litmos_Team_Member__c WHERE Member_Type__c = 'Learner' AND Litmos_Team__c =: teams[0].Id], 'Expected 3 learners on team');
        //confirm member2 is removed from team
        System.assertEquals(0, [SELECT count() FROM Litmos_Team_Member__c WHERE Litmos_Team__c =: teams[0].Id AND Litmos_User_Id__c ='RemoveMember'], 'Expected no team member with Litmos Id \'RemoveMember\'');
        //LEADER ASSERTIONS
        //check number of leaders
        System.assertEquals(4,[SELECT count() FROM Litmos_Team_Member__c WHERE Member_Type__c = 'Leader' AND Litmos_Team__c =: teams[0].Id], 'Expected 4 leaders');
        //ADMIN ASSERTIONS
        //check number of admins
        System.assertEquals(4, [SELECT count() FROM Litmos_Team_Member__c WHERE Litmos_Team__c =: teams[0].Id AND Member_Type__c = 'Admin'], 'Expected 4 admins');
        //confirm user demotion to learner
        System.assertEquals(1, [SELECT count() FROM Litmos_Team_Member__c WHERE Litmos_User_Id__c = 'DemoteAdmin' AND Member_Type__c = 'Learner'], 'Expected team member with Litmos Id \'DemoteAdmin\' to now have Member Type of \'Learner\'');
        //DESCRIPTION ASSERTIONS
        //confirm team now has a description
        System.assertEquals('Here\'s a description', [SELECT Id,Description__c FROM Litmos_Team__c LIMIT 1].Description__c);
    }
    /*@isTest
    static void testUpdateLeaders() {
        System.debug('testUpdateLeaders() method');
        Litmos__Configuration__c config = [SELECT Litmos__Api_End_Point__c, Litmos__Api_Key__c FROM Litmos__Configuration__c LIMIT 1];
        //at the end of this test, there should be 1 learner and 2 leaders
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('Litmos_Team_Leader_Updates_Demand');
        mock.setStatusCode(200);
        mock.setHeader('apikey', config.Litmos__Api_Key__c);

        
		Litmos_Team__c team = [SELECT Id FROM Litmos_Team__c LIMIT 1];
        Test.startTest();
        //Test.setMock(HttpCalloutMock.class, new Mock());
        litmosTeamLeaderQueue leaderqueue = new litmosTeamLeaderQueue(team, config.Litmos__API_End_Point__c + team.Id + '/leaders?source=sourceapp&format=json', config.Litmos__API_Key__c);
        Id jobId = System.enqueueJob(leaderqueue);
        Test.stopTest();
        //check number of leaders
        System.assertEquals(4,[SELECT count() FROM Litmos_Team_Member__c WHERE Member_Type__c = 'Leader' AND Litmos_Team__c =: team.Id], 'Expected 4 leaders');
        //check number of learners
        System.assertEquals(4, [SELECT count() FROM Litmos_Team_Member__c WHERE Member_Type__c = 'Learner' AND Litmos_Team__c =: team.Id], 'Expected 4 learners');
    }
    @isTest
    static void testUpdateAdmins() {
        System.debug('testUpdateAdmins() method');
        //at the end of this test, there should be 1 learner and 2 admins
        Litmos__Configuration__c config = [SELECT Litmos__Api_End_Point__c, Litmos__Api_Key__c FROM Litmos__Configuration__c LIMIT 1];
        Litmos_Team__c team = [SELECT Id FROM Litmos_Team__c LIMIT 1];
		//confirm there are currently 3 admins
		System.debug('Admins: ' + [SELECT Litmos_User_Id__c FROM Litmos_Team_Member__c WHERE Member_Type__c = 'Admin']);
		System.assertEquals(3, [SELECT count() FROM Litmos_Team_Member__c WHERE Litmos_Team__c =: team.Id AND Member_Type__c = 'Admin'], 'Expected 3 admins prior to calling queueable method');
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('Litmos_Team_Admin_Updates_Demand');
        mock.setStatusCode(200);
        mock.setHeader('apikey', config.Litmos__API_Key__c);
        
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Mock());
        litmosTeamAdminQueue adminQueue = new litmosTeamAdminQueue(team, config.Litmos__API_End_Point__c + team.Id + '/admins?source=sourceapp&format=json', config.Litmos__API_Key__c);
        Id jobId = System.enqueueJob(adminQueue);
        Test.stopTest();
        //check number of admins -- should now be 4
        System.assertEquals(4, [SELECT count() FROM Litmos_Team_Member__c WHERE Litmos_Team__c =: team.Id AND Member_Type__c = 'Admin'], 'Expected 4 admins');
        //confirm user demotion to learner
        System.assertEquals(1, [SELECT count() FROM Litmos_Team_Member__c WHERE Litmos_User_Id__c = 'DemoteAdmin' AND Member_Type__c = 'Learner'], 'Expected team member with Litmos Id \'DemoteAdmin\' to now have Member Type of \'Learner\'');
    }
    @isTest
    static void testDescription() {
        //at the end of this test, there should be a confirmed description for the team
        Litmos__Configuration__c config = [SELECT Litmos__Api_End_Point__c, Litmos__Api_Key__c FROM Litmos__Configuration__c LIMIT 1];
        Litmos_Team__c team = [SELECT Id, Description__c FROM Litmos_Team__c LIMIT 1];
        //confirm no description
        System.assertEquals(null, team.Description__c);
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStatusCode(200);
        mock.setHeader('apikey', config.Litmos__API_Key__c);
        mock.setStaticResource('Litmos_Team_Description_Updates_Demand');
        
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Mock());
        litmosUpdateTeamDescriptionQueue descQueue = new litmosUpdateTeamDescriptionQueue(team, config.Litmos__API_End_Point__c + team.Id + '?source=sourceapp&format=json', config.Litmos__Api_Key__c);
        Id jobId = System.enqueueJob(descQueue);
        Test.stopTest();
        //confirm team now has a description
        System.assertEquals('Here\'s a description', [SELECT Id,Description__c FROM Litmos_Team__c LIMIT 1].Description__c);
    }*/
}