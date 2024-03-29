# ------------------------------------------------------------------------------------
# Image File Processor - call Computer Vision API to extract text from image
# ------------------------------------------------------------------------------------
import io
import logging
import os

import azure.functions as func
from azure.cognitiveservices.vision.computervision import ComputerVisionClient
from msrest.authentication import CognitiveServicesCredentials

def main(inputblob: func.InputStream, outputblob: func.Out[str]) -> None:
    functionName = "ImageFileTrigger"
    extensionsToProcess = ['.jpg','.jpeg','.gif','.png','.bmp']

    try:
        fileNameArray = os.path.splitext(inputblob.name)
        #fileName = fileNameArray[0]
        fileExtension = fileNameArray[1].lower()

        if fileExtension in extensionsToProcess:
            logging.info(f"{functionName}: Image processor triggered by file: {inputblob.name}")
            cvKey = os.environ["ComputerVisionAccessKey"]
            cvResource = os.environ["ComputerVisionResourceName"]
            cvRegion = os.environ["ComputerVisionRegion"]
            cvResourceLocation = os.environ.get(cvResource, cvRegion)

            file_text = ""
            cvEndpoint="https://" + cvResourceLocation + ".api.cognitive.microsoft.com/"
            client = ComputerVisionClient(endpoint=cvEndpoint, credentials=CognitiveServicesCredentials(cvKey))

            logging.info(f"{functionName}:   Sending stream from {inputblob.name} to {cvEndpoint}")
            with io.BytesIO(inputblob.read()) as myStream:
                myStream.seek(0)
                image_analysis = client.recognize_printed_text_in_stream(image=myStream, language="en")

            logging.info(f"{functionName}:   Found {len(image_analysis.regions)} regions of text in {inputblob.name}")
            regionCount = 0
            for scanRegion in image_analysis.regions:
                regionCount = regionCount + 1
                if scanRegion.lines:
                    lines = scanRegion.lines
                    logging.info(f"{functionName}:   Found {len(lines)} lines of text in region {regionCount}!")
                    for line in lines:
                        line_text = " ".join([word.text for word in line.words])
                        file_text = file_text + line_text + "\n"
                else:
                    logging.info(f"{functionName}:   Found 0 lines of text in region {regionCount}!")

            #logging.info(f"{functionName}:   Found results: {file_text}")
            logging.info(f"{functionName}:   Writing results to output folder {inputblob.name}.txt")

            outputblob.set(file_text)

            logging.info(f"{functionName}:   Done with OCR processing and writing output to container outputfiles!")

        else:
            logging.info(f"{functionName}:   Skipping non-image file {inputblob.name}...")

    except Exception as ex:
        logging.exception(f"{functionName}: Error occurred during OCR processing!")
        outputblob.set(ex.message)
