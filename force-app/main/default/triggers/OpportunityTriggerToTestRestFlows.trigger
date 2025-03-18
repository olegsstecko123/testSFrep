trigger OpportunityTriggerToTestRestFlows on Opportunity (before insert) {
	FlowRestController cont = new FlowRestController();
	cont.start();
}