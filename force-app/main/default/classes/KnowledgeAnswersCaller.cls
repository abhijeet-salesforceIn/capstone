@RestResource(urlMapping='/ApexKnowledgeAnswersPrompt')
global with sharing class KnowledgeAnswersCaller {
    @HttpGet
    global static ApexResponseCustom generations(){
            ConnectApi.EinsteinPromptTemplateGenerationsInput promptGenerationsInput = new ConnectApi.EinsteinPromptTemplateGenerationsInput();
            promptGenerationsInput.isPreview = false;
            
        	Map<String,ConnectApi.WrappedValue> valueMap = new Map<String,ConnectApi.WrappedValue>();
            
            ConnectApi.WrappedValue queryWrappedValue = new ConnectApi.WrappedValue();
            queryWrappedValue.value = 'whats is the name of beyonce fanbase';
        	
        	ConnectApi.WrappedValue retrieverWrappedValue = new ConnectApi.WrappedValue();
            retrieverWrappedValue.value = 'KA_ASA_New_DL_1Cx_QaX523b9b82';
            
            valueMap.put('Input:Query', queryWrappedValue);
            valueMap.put('Input:RetrieverIdOrName', retrieverWrappedValue);
            promptGenerationsInput.inputParams = valueMap;
                        
            promptGenerationsInput.additionalConfig = new ConnectApi.EinsteinLlmAdditionalConfigInput();
            promptGenerationsInput.additionalConfig.applicationName = 'PromptTemplateGenerationsInvocable';
        	promptGenerationsInput.citationMode = 'post_generation';
            
            ConnectApi.EinsteinPromptTemplateGenerationsRepresentation generationsOutput = 
            ConnectApi.EinsteinLLM.generateMessagesForPromptTemplate('einstein_gpt__answerWithKnowledge', promptGenerationsInput); 
        
			ApexResponseCustom actuals = new ApexResponseCustom();
            ApexResponseBody body = new ApexResponseBody();
        	System.debug(generationsOutput.citations);
        	body.text = generationsOutput.generations[0].text;
        	body.responseId = generationsOutput.generations[0].responseId;
        	body.safetyScoreRepresentation = generationsOutput.generations[0].safetyScoreRepresentation;
        	actuals.generations.add(body);
        
        	System.debug(body);
            return actuals;
            
        }
}