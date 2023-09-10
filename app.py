import json
import numpy as np
import string
from nltk.corpus import stopwords
from flask import Flask, request, jsonify

app = Flask(__name__)

def text_clean(text_message):
    remove_punc = [text for text in text_message if text not in string.punctuation]
    remove_punc = ''.join(remove_punc)
    return [word for word in remove_punc.split() if word.lower() not in stopwords.words('english')]

@app.route('/predict', methods=['POST'])
def predict():
    input_data = request.get_json()

    with open('tokenizer_config.json', 'r') as f:
        dic = json.load(f)
    dic = dic['vocabulary']

    input_text = input_data.get('input_text', '')
    cleaned_text = text_clean(input_text)
    ss = [dic.get(key.lower(), 0) for key in cleaned_text]

    max_len = 2000
    padded_seqs = [seq + [0] * (max_len - len(seq)) if len(seq) < max_len else seq[:max_len] for seq in [ss]]
    padded_seqs = np.asarray(padded_seqs)
    padded_seqs = padded_seqs.astype(np.float32)

    import tflite_runtime.interpreter as tflite

    # Load the TFLite model
    interpreter = tflite.Interpreter(model_path='model.tflite')
    interpreter.allocate_tensors()

    input_details = interpreter.get_input_details()
    output_details = interpreter.get_output_details()

    # Provide input data and run the interpreter
    interpreter.set_tensor(input_details[0]['index'], padded_seqs)
    interpreter.invoke()

    # Get the output results
    predictions = interpreter.get_tensor(output_details[0]['index'])

    response = {
        'prediction': float(predictions[0][0])
    }

    return jsonify(response)

if __name__ == '__main__':
    app.run(debug=True)
