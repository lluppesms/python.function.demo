import os
import logging
import azure.functions as func
# from dotenv import load_dotenv

def main(req: func.HttpRequest) -> func.HttpResponse:
    functionName = "EchoTrigger"
    logging.info(f'{functionName}: triggered by request.')

    # cvRegion = os.environ["ComputerVisionRegion"]
    # logging.info(f'{functionName}: System Environment Variable: cvRegion={cvRegion}')
    
    # secretEnvironment = ""
    # #load local variables if .env file exists
    # if os.path.exists('.env'):
    #     logging.info(f'.env file exists - loading variables...')
    #     load_dotenv()
    #     secretEnvironment = os.getenv("SECRET_ENVIRONMENT")
    # else:
    #     logging.info(f'No .env file found - skipping local secrets load...')

    # logging.info(f'Environment Variable SECRET_ENVIRONMENT={secretEnvironment}')

    try:
      name = req.params.get('name')
      if not name:
        req_body = req.get_json()
        name = req_body.get('name')
      if not name:
        name = 'Nobody'
    except ValueError:
      name = 'Unknown'
      pass

    logging.info(f"{functionName}:   Received name: '{name}'.")
    if name:
        return func.HttpResponse(f"{functionName} executed successfully and received name '{name}'!")
    else:
        return func.HttpResponse(
             "{functionName} executed successfully but there was no name in the query string or in the request body!",
             status_code=200
        )
