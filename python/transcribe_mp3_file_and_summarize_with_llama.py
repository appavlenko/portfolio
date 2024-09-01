import os
from faster_whisper import WhisperModel
import ollama

# Allow duplicate library loading (specific to your environment)
os.environ["KMP_DUPLICATE_LIB_OK"] = "TRUE"

# Paths to model and audio files
model_path = r"*\whisper-large-v3\"  # Path to the converted Whisper model
audio_path = r"*\whisper-large-v3\*.mp3"  # Path to the audio file

# Create an instance of the Whisper model, specifying the device and computation type
model = WhisperModel(model_path, device="cuda", compute_type="float32")

# Transcribe the audio file with additional settings for better accuracy and context handling
segments, info = model.transcribe(
    audio_path,
    beam_size=15,  # Increase beam size for higher accuracy
    vad_filter=True,  # Enable Voice Activity Detection (VAD) filtering
    vad_parameters=dict(min_silence_duration_ms=500),  # Configure VAD parameters
    condition_on_previous_text=True  # Improve context recognition
)

# Concatenate all transcribed segments into a single text string
transcription_text = " ".join([segment.text for segment in segments])

# Print the detected language and probability
print(f"Detected language '{info.language}' with probability {info.language_probability:.6f}")

# Function to query the model with the transcribed text and specific instructions
def query_model(transcription, instructions):
    messages = [
        {'role': 'user', 'content': f"Question: {transcription}\nInstructions: {instructions}"}
    ]
    response = ollama.chat(model='llama3.1:8b', messages=messages)
    return response['message']['content']

if __name__ == "__main__":
    # Provide clear instructions for generating a concise and objective report
    instructions = (
        "This is a transcription of a dialogue between two users – provide an objective report "
        "within the following example format, without unnecessary details or inventions:\n"
        "- Brief summary of the dialogue\n"
        "- Main issue discussed\n"
        "- Service rating from 1 to 5"
    )
    
    # Query the model using the transcription and instructions, then print the result
    result = query_model(transcription_text, instructions)
    print(result)
