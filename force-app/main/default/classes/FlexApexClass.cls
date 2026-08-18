public class FlexApexClass {
  @InvocableMethod()
  public static List<Response> getCaseContactPrompt(List<Request> requests) {
    Request input = requests[0];
    List<Response> responses = new List<Response>();
    Response output = new Response();
    // update below prompt as per the template inputs
    output.Prompt = 'create an new email for account=' + input.My_Account.Name + ' case=' + input.My_Case.Subject;
	responses.add(output);
    return responses;
  }
  
  // All inputs will be from the template into the apex class
  public class Request {
  // update below input entity and apiName as per Flex template. 
      @InvocableVariable
      public Account My_Account;
      @InvocableVariable
      public Case My_Case;
  }
  
  public class Response {
    @InvocableVariable(required=true)
    public String Prompt;
  }
}