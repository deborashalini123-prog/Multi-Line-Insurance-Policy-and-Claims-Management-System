public with sharing class ClaimsAdjusterController {

    public class ClaimWrapper {
        @AuraEnabled public Id claimId;
        @AuraEnabled public String claimNumber;
        @AuraEnabled public Decimal claimAmount;
        @AuraEnabled public String status;
        @AuraEnabled public String policyType;
        @AuraEnabled public String policyHolderName;
        @AuraEnabled public Integer daysOpen;

        public ClaimWrapper(Claim__c c) {

            this.claimId = c.Id;
            this.claimNumber = c.Name;
            this.claimAmount = c.Claim_Amount__c;
            this.status = c.Approval_Status__c;

            this.policyType = 'Unknown';
            this.policyHolderName = '';
            
            if (c.Policy__c != null) {
                this.policyType = 'Policy Assigned';
            }

            if (c.Date_of_Loss__c != null) {
                this.daysOpen = c.Date_of_Loss__c.daysBetween(Date.today());
            } else {
                this.daysOpen = 0;
            }
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<ClaimWrapper> getAssignedClaims() {

        List<ClaimWrapper> results = new List<ClaimWrapper>();

        List<Claim__c> claims = [
            SELECT
                Id,
                Name,
                Claim_Amount__c,
                Approval_Status__c,
                Date_of_Loss__c,
                Policy__c
            FROM Claim__c
            WHERE OwnerId = :UserInfo.getUserId()
            ORDER BY Date_of_Loss__c DESC
        ];

        for (Claim__c claim : claims) {
            results.add(new ClaimWrapper(claim));
        }

        return results;
    }
}