import warnings

#data preprocessing
with warnings.catch_warnings():
  warnings.simplefilter("ignore")
  import pandas as pd
#produces a prediction model in the form of an
#ensemble of weak prediction models, typically
#decision tree
with warnings.catch_warnings():
  warnings.simplefilter("ignore")
  import xgboost as xgb
#the outcome (dependent variable) has only a limited
#number of possible values. Logistic Regression is
#used when response variable is categorical in
#nature.
with warnings.catch_warnings():
  warnings.simplefilter("ignore")
  from sklearn.linear_model import LogisticRegression
#A random forest is a meta estimator that fits a
#number of decision tree classifiers on various
#sub-samples of the dataset and use averaging to
#improve the predictive accuracy and control
#over-fitting.
from sklearn.ensemble import RandomForestClassifier
#a discriminative classifier formally defined by a
#separating hyperplane.
with warnings.catch_warnings():
  warnings.simplefilter("ignore")
  from sklearn.svm import SVC

data = pd.read_csv('data/match_data_preprocessed/preprocessed_atp_matches_1993-2018.csv', header=0, sep='\s*,\s*', encoding="ascii", engine='python')

# Total number of matches.
n_matches = data.shape[0]
# Calculate number of features. -1 because we are
# saving one as the target variable (win/lose)
n_features = data.shape[1] - 1

# Print the results
print ("Total number of matches:", n_matches)
print ("Number of features:", n_features)

# Separate into feature set and target variable
#res = 1 if left player wins, -1 - if the right one does.
X_all = data.drop(['res'],1)
y_all = data['res']
print(y_all)
print(X_all)

# Standardising the data.
from sklearn.preprocessing import scale
#Center to the mean and component wise scale to unit
#variance.
cols = X_all.columns
# print (cols.tolist())
# print (data)
for col in cols:
    X_all[col] = scale(X_all[col])

with warnings.catch_warnings():
  warnings.simplefilter("ignore")
  from sklearn.cross_validation import train_test_split
# Shuffle and split the dataset into training and
# testing set.
X_train, X_test, y_train, y_test = train_test_split(X_all, y_all,
                                                    test_size = 0.15,
                                                    random_state = 42,
                                                    stratify = y_all)

#for measuring training time
from time import time
# F1 score (also F-score or F-measure) is a measure
#of a test's accuracy. It considers both the
#precision p and the recall r of the test to compute
#the score: p is the number of correct positive
#results divided by the number of all positive
#results, and r is the number of correct positive
#results divided by the number of positive results
#that should have been returned. The F1 score can be
#interpreted as a weighted average of the precision
#and recall, where an F1 score reaches its best
#value at 1 and worst at 0.
from sklearn.metrics import f1_score
def train_classifier(clf, X_train, y_train):
    ''' Fits a classifier to the training data. '''

    # Start the clock, train the classifier, then
    # stop the clock
    start = time()
    clf.fit(X_train, y_train)
    end = time()

    # Print the results
    dur = end - start
    print (f'Trained model in {dur:.4f} seconds.')

def predict_labels(clf, features, target):
    ''' Makes predictions using a fit classifier based on F1 score. '''

    # Start the clock, make predictions, then stop
    # the clock
    start = time()
    y_pred = clf.predict(features)
    end = time()
    # Print and return results
    dur = end - start
    print (f'Made predictions in {dur:.4f} seconds.')

    return f1_score(target, y_pred, pos_label=1), sum(target == y_pred) / float(len(y_pred))

def train_predict(clf, X_train, y_train, X_test, y_test):
    ''' Train and predict using a classifer based on F1 score. '''

    # Indicate the classifier and the training set
    # size
    print (f"Training a {clf.__class__.__name__} using a training set size of {len(X_train)}. . .")

    # Train the classifier
    train_classifier(clf, X_train, y_train)

    # Print the results of prediction for both
    # training and testing
    f1, acc = predict_labels(clf, X_train, y_train)
    print (f1, acc)
    print (f"F1 score and accuracy score for training set: {f1:.4f} , {acc:.4f}.")

    f1, acc = predict_labels(clf, X_test, y_test)
    print (f"F1 score and accuracy score for test set: {f1:.4f} , {acc:.4f}.")

# Initialize the three models (XGBoost is
# initialized later)
clf_A = LogisticRegression(random_state = 42)
clf_B = SVC(random_state = 912, kernel='rbf')
#Boosting refers to this general problem of
#producing a very accurate prediction rule by
#combining rough and moderately inaccurate
#rules-of-thumb
clf_C = xgb.XGBClassifier(seed = 82)

#train_predict(clf_A, X_train, y_train, X_test, y_test)
print ('')
#train_predict(clf_B, X_train, y_train, X_test, y_test)
print ('')
#train_predict(clf_C, X_train, y_train, X_test, y_test)
print ('')

# TODO: Import 'GridSearchCV' and 'make_scorer'
with warnings.catch_warnings():
  warnings.simplefilter("ignore")
  from sklearn.grid_search import GridSearchCV
from sklearn.metrics import make_scorer
# TODO: Create the parameters list you wish to tune
parameters = { 'learning_rate' : [0.008],
               'n_estimators' : [10],
               'max_depth': [10],
               'min_child_weight': [15],
               'gamma':[0.4],
                'subsample' : [0.5],
               'colsample_bytree' : [0.9],
               'scale_pos_weight' : [0.8],
               'reg_alpha':[1e-3]
             }
# TODO: Initialize the classifier
clf = xgb.XGBClassifier(seed=2)
# TODO: Make an f1 scoring function using
# 'make_scorer'
f1_scorer = make_scorer(f1_score,pos_label=1)
# TODO: Perform grid search on the classifier using
# the f1_scorer as the scoring method
grid_obj = GridSearchCV(clf,
                        scoring=f1_scorer,
                        param_grid=parameters,
                        cv=5)
# TODO: Fit the grid search object to the training
# data and find the optimal parameters
grid_obj = grid_obj.fit(X_train,y_train)
# Get the estimator
clf = grid_obj.best_estimator_
#print(clf)
# Report the final F1 score for training and testing
# after parameter tuning
#f1, acc = predict_labels(clf, X_train, y_train)
#print (f"F1 score and accuracy score for training set: {f1:.4f} , {acc:.4f}.")

#f1, acc = predict_labels(clf, X_test, y_test)
#print (f"F1 score and accuracy score for test set: {f1:.4f} , {acc:.4f}.")


import keras
from keras.models import Sequential
import keras.layers as ll

from keras.utils import to_categorical
y_train = to_categorical(y_train)
y_test = to_categorical(y_test)

model = Sequential(name="mlp")
#model = Sequential()

# input layer
inputs = ll.Dense(24, activation='relu', input_shape=(24, ))
#flatten = ll.Flatten()

# network body
layer1 = ll.Dense(24)
activ = ll.Activation('relu')
dropout = ll.Dropout(0.1)
layer2 = ll.Dense(24)
#layer3 = ll.Dense(6, activation='relu')

# output layer
output = ll.Dense(2, activation='softmax')

# model constructing
model.add(inputs)

model.add(layer1)
model.add(activ)
model.add(dropout)

#model.add(layer2)
#model.add(activ)
#model.add(dropout)

#model.add(layer3)
#model.add(activ)
#model.add(dropout)

model.add(output)

# categorical_crossentropy is our good old
# crossentropy but applied for one-hot-encoded
# vectors
from keras import metrics
model.compile(optimizer='adam',
              loss='categorical_crossentropy',
              learning_rate=0.0001,
              metrics=[metrics.categorical_accuracy])

# fit(X,y) ships with a neat automatic logging.
#          Highly customizable under the hood.
print ('Fitting model...')
model.fit(X_train, y_train,
#          validation_data=(X_test, y_test),
          validation_split=0.15,
          batch_size=256,
          epochs=10);

results = model.evaluate(X_test, y_test)
print (results)
#model.summary()

"""

from sklearn.neural_network import MLPClassifier
clf = MLPClassifier(solver='lbfgs',
                    alpha=1e-5,
                    hidden_layer_sizes=(5, 2),
                    random_state=1
                   )
clf.fit(X_train, y_train)
clf.predict(X_test)
"""
