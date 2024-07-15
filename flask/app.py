from flask import Flask, render_template, request,send_file , jsonify
import pandas as pd
import torch
import torch.nn as nn
from sklearn.preprocessing import LabelEncoder
import seaborn as sns
import matplotlib.pyplot as plt
from sklearn.model_selection import train_test_split
import torch.optim as optim
import joblib

app = Flask(__name__)


# Load data and preprocess
path =  r'C:\Users\mayha\OneDrive\Desktop\fyp\semester_8\flask\mayhan.xlsx'
df = pd.read_excel(path)
df['Date'] = pd.to_datetime(df['Date'])
X_pred = df[['Area', 'City', 'Day']]
label_encoder_X = LabelEncoder()
X_pred_encoded = X_pred.apply(lambda col: label_encoder_X.fit_transform(col.astype(str)))
X_pred_tensor = torch.tensor(X_pred_encoded.values, dtype=torch.float32)

# Encode the target variable 'crime_type'
label_encoder_y = LabelEncoder()
df['Crime Type Encoded'] = label_encoder_y.fit_transform(df['Crime Type'])

# Define a deep neural network
class DeepNN(nn.Module):
    def __init__(self, input_size, hidden_size1, hidden_size2, hidden_size3, hidden_size4, hidden_size5, hidden_size6, hidden_size7, hidden_size8,output_size):
        super(DeepNN, self).__init__()
        self.fc1 = nn.Linear(input_size, hidden_size1)
        self.relu1 = nn.ReLU()
        self.fc2 = nn.Linear(hidden_size1, hidden_size2)
        self.relu2 = nn.ReLU()
        self.fc3 = nn.Linear(hidden_size2, hidden_size3)
        self.relu3 = nn.ReLU()
        self.fc4 = nn.Linear(hidden_size3, hidden_size4)
        self.relu4 = nn.ReLU()
        self.fc5 = nn.Linear(hidden_size4, hidden_size5)
        self.relu5 = nn.ReLU()
        self.fc6 = nn.Linear(hidden_size5, hidden_size6)
        self.relu6 = nn.ReLU()
        self.fc7 = nn.Linear(hidden_size6, hidden_size7)
        self.relu7 = nn.ReLU()
        self.fc8 = nn.Linear(hidden_size7, hidden_size8)
        self.relu8 = nn.ReLU()
        self.fc9 = nn.Linear(hidden_size8, output_size)

        self.dropout = nn.Dropout(0.3)  # Dropout layer with 30% dropout probability
        self.batch_norm1 = nn.BatchNorm1d(hidden_size1)  # Batch normalization layer after first hidden layer
        self.batch_norm2 = nn.BatchNorm1d(hidden_size2)  # Batch normalization layer after second hidden layer
        self.batch_norm3 = nn.BatchNorm1d(hidden_size3)  # Batch normalization layer after third hidden layer
        self.batch_norm4 = nn.BatchNorm1d(hidden_size4)  # Batch normalization layer after fourth hidden layer
        self.batch_norm5 = nn.BatchNorm1d(hidden_size5)  # Batch normalization layer after fifth hidden layer
        self.batch_norm6 = nn.BatchNorm1d(hidden_size6)  # Batch normalization layer after sixth hidden layer
        self.batch_norm7 = nn.BatchNorm1d(hidden_size7)  # Batch normalization layer after seventh hidden layer
        self.batch_norm8 = nn.BatchNorm1d(hidden_size8)  # Batch normalization layer after eighth hidden layer


 

    def forward(self, x):
        x = self.fc1(x)
        x = self.batch_norm1(x)
        x = self.relu1(x)
        x = self.dropout(x)
        x = self.fc2(x)
        x = self.batch_norm2(x)
        x = self.relu2(x)
        x = self.dropout(x)
        x = self.fc3(x)
        x = self.batch_norm3(x)
        x = self.relu3(x)
        x = self.dropout(x)
        x = self.fc4(x)
        x = self.batch_norm4(x)
        x = self.relu4(x)
        x = self.dropout(x)
        x = self.fc5(x)
        x = self.batch_norm5(x)
        x = self.relu5(x)
        x = self.dropout(x)
        x = self.fc6(x)
        x = self.batch_norm6(x)
        x = self.relu6(x)
        x = self.dropout(x)
        x = self.fc7(x)
        x = self.batch_norm7(x)
        x = self.relu7(x)
        x = self.dropout(x)
        x = self.fc8(x)
        x = self.batch_norm8(x)
        x = self.relu8(x)
        x = self.dropout(x)
        x = self.fc9(x)
       


        return x




# Initialize the model, loss function, and optimizer
hidden_size1 = 1000  # Adjust the hidden layer size as needed
hidden_size2 = 1000 
hidden_size3 = 1000  # Adjust the hidden layer size as needed
hidden_size4 = 1000
hidden_size5 = 1000  # Adjust the hidden layer size as needed
hidden_size6 = 1000
hidden_size7 = 1000  # Adjust the hidden layer size as needed
hidden_size8 = 1000

model = DeepNN(input_size=X_pred_tensor.shape[1], hidden_size1=hidden_size1, hidden_size2=hidden_size2,hidden_size3=hidden_size3, hidden_size4=hidden_size4, 
               hidden_size5=hidden_size5, hidden_size6=hidden_size6,hidden_size7=hidden_size7, hidden_size8=hidden_size8,output_size=len(df['Crime Type Encoded'].unique()))

model = joblib.load(r'C:\Users\mayha\OneDrive\Desktop\fyp\semester_8\flask\fyp.joblib')
model.eval()


@app.route('/')
def index():
    return render_template('index.html')

@app.route('/predict', methods=['POST'])
def predict():

        """"
        day = request.form.get('day')
        city = request.form.get('city')
        area = request.form.get('area')
        print("-------------------------------------------------------------")
        print("------------------------HERE-------------------------------------")
        print("Received form data - day:", day, "city:", city, "area:", area)
        # Create a dictionary with form data
        form_data = {
            'day': day,
            'city': city,
            'area': area
        }

        # Convert form data to JSON
        json_data = jsonify(form_data)
        """
        json_data = request.get_json()
        print('Incoming JSON data:', json_data)

        # Extract values of 'day', 'city', and 'area' from JSON data
        day = json_data.get('day')
        city = json_data.get('city')
        area = json_data.get('area')
        print('Extracted values - day:', day, 'city:', city, 'area:', area)
        filter_condition = (df['Day'] == day) & (df['City'] == city)& (df['Area'] == area)
        input_data = X_pred_tensor[filter_condition]


        # Make predictions using the trained model
        with torch.no_grad():
            predictions = model(input_data)
            probabilities = nn.functional.softmax(predictions, dim=1).numpy()
        # Map the encoded labels back to crime types
        decoded_labels = label_encoder_y.inverse_transform(range(len(probabilities[0])))
        custom_palette = sns.color_palette('husl', len(decoded_labels))

        plt.figure(figsize=(10, 6))
        sns.barplot(x=decoded_labels, y=probabilities[0], palette=custom_palette)
        plt.xlabel('Crime Type')
        plt.ylabel('Probability')
        plt.title(f'Crime Probability Distribution for Day {day} in {city}')
        plt.xticks(rotation=45, ha='right')  # Rotate x-axis labels for better visibility
        plt.tight_layout()  # Adjust layout to prevent overlapping
        plt.savefig('static/plot.png')

        return send_file('static/plot.png', mimetype='image/png')
       

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
