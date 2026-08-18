public class FieldGenerationApexClass {
  
  @InvocableMethod(CapabilityType='PromptTemplateType://einstein_gpt__fieldCompletion')
  public static List<Response> getAccountsPrompt(List<Request> requests) {
	Request input = requests[0];
    List<Response> responses = new List<Response>();
    Response output = new Response();
    output.Prompt = 'Account Name= ' + input.RelatedEntity.Name + ' having Phone number as : '+ input.RelatedEntity.Phone;
    responses.add(output);
    return responses;
      
  }
    
    public class Request {
	@InvocableVariable
    	public Account RelatedEntity;
	}
      
    public class Response {
    @InvocableVariable(required=true)
    	public String Prompt;
	}
}