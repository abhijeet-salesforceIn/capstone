@RestResource(urlMapping='/ApexFieldGenPrompt')
global with sharing class FieldGenCaller {
    @HttpGet
    global static ApexResponseCustom generations(){
            ConnectApi.EinsteinPromptTemplateGenerationsInput promptGenerationsInput = new ConnectApi.EinsteinPromptTemplateGenerationsInput();
            promptGenerationsInput.isPreview = false;
            
            Map<String,ConnectApi.WrappedValue> valueMap = new Map<String,ConnectApi.WrappedValue>();
            Map<String, String> account1RecordIdMap = new Map<String, String>();
            account1RecordIdMap.put('id', '001RZ000004uwWsYAI');
            
            ConnectApi.WrappedValue account1WrappedValue = new ConnectApi.WrappedValue();
            account1WrappedValue.value = account1RecordIdMap;
            
            valueMap.put('Input:Account', account1WrappedValue);
            
            promptGenerationsInput.inputParams = valueMap;
            
            promptGenerationsInput.additionalConfig = new ConnectApi.EinsteinLlmAdditionalConfigInput();
            promptGenerationsInput.additionalConfig.applicationName = 'PromptTemplateGenerationsInvocable';
            
            ConnectApi.EinsteinPromptTemplateGenerationsRepresentation generationsOutput = 
            ConnectApi.EinsteinLLM.generateMessagesForPromptTemplate('0hfRZ000000GFO5YAO', promptGenerationsInput); 
            
        	ApexResponseCustom actuals = new ApexResponseCustom();
            ApexResponseBody body = new ApexResponseBody();
        	body.text = generationsOutput.generations[0].text;
        	body.responseId = generationsOutput.generations[0].responseId;
        	body.safetyScoreRepresentation = generationsOutput.generations[0].safetyScoreRepresentation;
        	actuals.generations.add(body);
        
        	System.debug(body);
            return actuals;
        }
}