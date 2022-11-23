# Deploy the Application

Follow the steps in the root readme file first, then run the desired pipeline to deploy the project to an Azure subscription.

In the pipelines, specify which environments that you wish to deploy to. Stages will be created for each environment you specify with appropriate approvals.

Examples:

    environments: ['DEMO']
 
    environments: ['DEV','PROD']
    
    environments:  ['DEV','QA','PROD']
