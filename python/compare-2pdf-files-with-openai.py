import fitz  # PyMuPDF for PDF handling
import os
from openai import OpenAI

def extract_text_from_pdf(pdf_path):
    """
    Extracts all text from a PDF file.

    Parameters:
        pdf_path (str): The path to the PDF file.

    Returns:
        str: The extracted text from the PDF.
    """
    doc = fitz.open(pdf_path)
    text = ""
    for page in doc:
        text += page.get_text()
    return text

def get_unique_sentences(text1, text2):
    """
    Identifies unique sentences in both texts.

    This helps reduce the amount of text for further processing by
    filtering out sentences that are common between the two texts.

    Parameters:
        text1 (str): Text from the first document.
        text2 (str): Text from the second document.

    Returns:
        str: A string containing the unique sentences from both texts.
    """
    set1 = set(text1.splitlines())
    set2 = set(text2.splitlines())
    
    # Identify unique sentences in both texts
    unique_to_text1 = set1 - set2
    unique_to_text2 = set2 - set1
    
    # Combine unique sentences for analysis
    unique_combined = list(unique_to_text1.union(unique_to_text2))
    return "\n".join(unique_combined)

def analyze_differences_with_openai(differences_text):
    """
    Analyzes the differences between two texts using OpenAI API.

    Parameters:
        differences_text (str): The text containing differences between two documents.

    Prints:
        str: The detailed analysis of differences provided by OpenAI.
    """
    # Initialize OpenAI client with the API key from environment variables
    client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))
    
    # Create a request to OpenAI to analyze the differences
    response = client.chat.completions.create(
        messages=[
            {
                "role": "assistant",
                "content": f"The first document is a template, the second is a completed document. Provide a detailed comparison of the differences.\n{differences_text}",
            }
        ],
        model="gpt-4-turbo",
        max_tokens=1024
    )
    
    # Print the analysis provided by OpenAI
    print("\nAnalysis of differences by OpenAI:")
    print(response.choices[0].message.content)

# Example usage
if __name__ == "__main__":
    # Define paths to the PDF files (replace with your actual paths)
    pdf_path1 = '/path/to/your/NDA1.pdf'
    pdf_path2 = '/path/to/your/NDA2.pdf'

    # Extract text from PDFs
    text1 = extract_text_from_pdf(pdf_path1)
    text2 = extract_text_from_pdf(pdf_path2)

    # Get unique sentences to minimize processing of identical text
    differences_text = get_unique_sentences(text1, text2)

    # Analyze the differences using OpenAI
    analyze_differences_with_openai(differences_text)
