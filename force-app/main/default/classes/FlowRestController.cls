public with sharing class FlowRestController {
	public void start() {
      	Map<String, Object> params = new Map<String, Object>();
		Flow.Interview.testNMSPC.Rest_test_flow myFlow = new Flow.Interview.testNMSPC.Rest_test_flow(params);
		myFlow.start();
   }
}