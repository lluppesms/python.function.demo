# ------------------------------------------------------------------------------------
# PDF File Processor - call Forms Recognizer API to extract text from PDF
# https://learn.microsoft.com/en-us/azure/applied-ai-services/form-recognizer/how-to-guides/use-sdk-rest-api?view=form-recog-3.0.0&preserve-view=true%3Fpivots%3Dprogramming-language-python&tabs=windows&pivots=programming-language-python
# https://learn.microsoft.com/en-us/azure/applied-ai-services/form-recognizer/create-a-form-recognizer-resource?view=form-recog-3.0.0
# https://learn.microsoft.com/en-us/python/api/azure-ai-formrecognizer/azure.ai.formrecognizer.documentanalysisclient?view=azure-python
# ------------------------------------------------------------------------------------
import io
import logging
import os

import azure.functions as func
from azure.ai.formrecognizer import DocumentAnalysisClient
from azure.core.credentials import AzureKeyCredential

def format_polygon(polygon):
    if not polygon:
        return "N/A"
    return ", ".join([f"[{p.x}, {p.y}]" for p in polygon])

def main(inputblob: func.InputStream, outputblob: func.Out[str]) -> None:
    functionName = "PdfFileTrigger"
    extensionsToProcess = ['.pdf']

    try:
        fileNameArray = os.path.splitext(inputblob.name)
        #fileName = fileNameArray[0]
        fileExtension = fileNameArray[1].lower()

        if fileExtension in extensionsToProcess:
            logging.info(f"{functionName}: PDF processor triggered by file: {inputblob.name}")

            formsKey = os.environ.get('FormsRecognizerKey')
            formsResourceName = os.environ.get('FormsRecognizerResourceName')

            file_text = ""
            result = {};

            frEndpoint="https://" + formsResourceName + ".cognitiveservices.azure.com/"
            client = DocumentAnalysisClient(endpoint=frEndpoint, credential=AzureKeyCredential(formsKey))

            logging.info(f"{functionName}:   Sending stream from {inputblob.name} to {frEndpoint}")
            with io.BytesIO(inputblob.read()) as myStream:
                myStream.seek(0)
                poller = client.begin_analyze_document("prebuilt-read", document=myStream)
                result = poller.result()

            # for page in result.pages:
            #     logging.info(f"----Analyzing Read from page #{page.page_number}----")
            for page in result.pages:
                logging.info(f"{functionName}:   Found {len(page.lines)} lines of text in page {page.page_number}!")
                #logging.info(f"Page has width: {page.width} and height: {page.height}, measured with unit: {page.unit}")
                file_text = file_text + f"Page: {page.page_number}\n"
                for line in page.lines:
                    logging.info(f"...Line '{line.content}'")
                    file_text = file_text + line.content + "\n"
                # for word in page.words:
                #     logging.info(f"...Word '{word.content}' has a confidence of {word.confidence}")
                #     file_text = file_text + word.content + "\n"
                # for selection_mark in page.selection_marks:
                #     logging.info(f"...Selection mark is '{selection_mark.state}' and has a confidence of {selection_mark.confidence}")

            # for i, table in enumerate(result.tables):
            #     pageNumber = i + 1
            #     logging.info(f"\nTable {pageNumber} can be found on page:")
            #     for region in table.bounding_regions:
            #         logging.info(f"...{region.page_number}")
            #     tableCount = 0
            #     for cell in table.cells:
            #         tableCount = tableCount + 1
            #         logging.info(f"...Cell[{cell.row_index}][{cell.column_index}] has content '{cell.content}'")
            #         file_text = file_text + f"Page: {pageNumber} Table: {tableCount} Cell[{cell.row_index}][{cell.column_index}]: '{cell.content}'\n"

            #logging.info(f"{functionName}:   Document contains content: {result.content}")
            #logging.info(f"{functionName}:   Found results: {file_text}")
            logging.info(f"{functionName}:   Writing results to output folder {inputblob.name}.txt")

            outputblob.set(file_text)

            logging.info(f"{functionName}:   Done with PDF OCR processing and writing output to container outputfiles!")

        else:
            logging.info(f"{functionName}:   Skipping non-PDF file {inputblob.name}...")

    except Exception as ex:
        logging.exception(f"{functionName}: Error occurred during PDF OCR processing!")
        outputblob.set(ex.message)
