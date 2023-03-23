import logging
import os

import azure.functions as func

# doesn't seem to work...
# app = func.FunctionApp()
# @app.function_name(name="ImageFileTrigger")
# @app.route(route="file")
# @app.blob_input(arg_name="inputblob", path="inputfiles/{name}", connection="DataStorageConnectionAppSetting")
# @app.blob_output(arg_name="outputblob", path="outputfiles/{name}", connection="DataStorageConnectionAppSetting")
# def main(req: func.HttpRequest, inputblob: str, outputblob: func.Out[str]):

def main(inputblob: func.InputStream, outputblob: func.Out[str]) -> None:
    functionName = "TextFileTrigger"
    extensionsToProcess = ['.txt','.md']

    try:
        fileNameArray = os.path.splitext(inputblob.name)
        #fileName = fileNameArray[0]
        fileExtension = fileNameArray[1].lower()

        if fileExtension in extensionsToProcess:
            logging.info(f"{functionName}: Text processor triggered by file: {inputblob.name}")
            file_text = inputblob.read()
            logging.info(f"{functionName}:   Read {len(file_text)} bytes from {inputblob.name}...")
            outputblob.set(file_text)
            logging.info(f"{functionName}:   Done processing and writing output to container outputfiles!")
        else:
            logging.info(f"{functionName}:   Skipping non-text document file {inputblob.name}!")
    except:
        logging.exception(f"{functionName}: Error occurred during text file processing!")
