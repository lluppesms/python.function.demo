# ------------------------------------------------------------------------------------
# Text File Processor - simple read file and dump to output file
# ------------------------------------------------------------------------------------
import logging
import os

import azure.functions as func

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
