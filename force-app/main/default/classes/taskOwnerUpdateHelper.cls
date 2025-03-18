public class taskOwnerUpdateHelper {
	@InvocableMethod (label = 'Update task owner')
    public static void updTasks(List<List<String>> taskIdsInput){
        System.debug(taskIdsInput);
        List<String> taskIds = taskIdsInput.get(0);
        System.debug(taskIds);
        Id userId = userInfo.getUserId();
        List<Account> tasksToUpdate = new List<Account>();
        for(String taskId : taskIds){
            tasksToUpdate.add(new Account(Id = taskId, OwnerId = userId));
        }
        
        update tasksToUpdate;
    }
}