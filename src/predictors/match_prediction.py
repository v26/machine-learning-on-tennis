import warnings
import numpy as np
import keras
with warnings.catch_warnings():
          warnings.simplefilter("ignore")
          import pandas as pd

def get_data(path, file):
    data = pd.read_csv(
               path + file,
               header=0,
               sep='\s*,\s*',
               encoding="ascii",
               engine='python')

    # Total number of matches.
    n_matches = data.shape[0]
    # Calculate number of features. -1 because we are
    # saving one as the target variable (win/lose)
    n_features = data.shape[1] - 1

    # Print the results
    print ("Total number of matches:", n_matches)
    print ("Number of features:", n_features)

    # Reverse dataset to start teaching model from
    # earliest matches to latest ones
    data = data.iloc[::-1]

    return data

def split_data(data, test_part):
    # Separate into feature set and target variable
    # res = 1 if left player wins,
    # res = -1 - if the right one does.
    X_all, y_all = _feat_target_sep(data)

#    pd.options.display.max_rows=50
#    np.set_printoptions(threshold=np.inf)
    X_all = _standardise_data(X_all)
#    y_all = _encode_target(y_all.values)
    y_all = _relabel(y_all)

    total_matches = X_all.shape[0]
    test_num = total_matches * test_part
    test_num = int(test_num)
    train_num = total_matches - test_num

    X_train = X_all[:train_num]
    y_train = y_all[:train_num]
    y_train = _encode_target(y_train.values)

    X_test = X_all[train_num:]
    y_test = y_all[train_num:]
#    y_test = _relabel(y_test)

#    y_train = _encode_target(y_train.values)

    return X_train, y_train, X_test, y_test

def _feat_target_sep(data):
    features = data.drop(['res'],1)
    target = data['res']

    return features, target

def _standardise_data(features):
    # Standardising the data.
    from sklearn.preprocessing import scale
    #Center to the mean and component wise scale to unit
    #variance.
    cols = features.columns

    for col in cols:
        features[col] = scale(features[col])

    return features

def _encode_target(y):
    y_encoded = np.zeros( (y.shape[0], 2) )

    y_neg_index = y == 2
    y_pos_index = y == 1

    y_encoded[y_neg_index,0] = 1
    y_encoded[y_pos_index,1] = 1

    y_encoded = pd.DataFrame({'player_1':y_encoded[:,0],'player_2':y_encoded[:,1]})
    return y_encoded

def _relabel(y):
    print('initial:')
    print(y[1])
    y = y.replace(to_replace=-1, value=2)
    print('after replace:')
    print(y[1])
    return y

def _relabel_output(y):
    print(y)
#    y = y.replace(to_replace=0, value=2)
#    for elem in y:
#        if elem == 0:
#            elem = 2
    y[y == 0] = 2
    print(y)
    return y

def train_k_fold(
        model,
        features,
        target,
        k,
        batch_size=512,
        epochs=100):

    num_val_samples = len(features) // k
    validation_scores = []

    print ('Training model...')
    for fold in range(k):
        print('Fold #', fold + 1)
        val_features = _get_val_data(
                           features,
                           num_val_samples,
                           fold)
        val_target = _get_val_data(
                         target,
                         num_val_samples,
                         fold)

        train_features = _get_train_data(
                             features,
                             num_val_samples,
                             fold)
        train_target = _get_train_data(
                           target,
                           num_val_samples,
                           fold)
        model.fit(
            train_features,
            train_target,
            batch_size,
            epochs)

        validation_score = model.evaluate(
                               val_features,
                               val_target)
        validation_scores.append(validation_score)

    validation_score = np.average(validation_scores, axis=0)

    print('Metrics =', model.metrics_names)
    print(validation_scores)
    print('validation score = ', validation_score)
    return model

def _get_val_data(data, num_val_samples, fold):
    validation_data = data[num_val_samples * fold:
     num_val_samples * (fold + 1)]
    return validation_data

def _get_train_data(data, num_val_samples, fold):
    left_part = data[:num_val_samples * fold]
    right_part = data[num_val_samples * (fold + 1):]
    training_data = pd.concat([left_part, right_part])
    return training_data

def train_classifier(
        model,
        train_features,
        train_target,
        batch_size=512,
        epochs=100):

    model.fit(
        train_features,
        train_target,
        batch_size,
        epochs)
    return model

def test_classifier_f1(
        model,
        test_features,
        test_target):

    from sklearn.metrics import f1_score
    print('Testing model...')
    target_pred = model.predict_classes(test_features)
    _relabel_output(target_pred)
    test_target = test_target.values

    print('Predicted target:')
    print(target_pred)
    print('Test target:')
    print(test_target)

    f1 = f1_score(
             test_target,
             target_pred,
             average='macro')
    print( 'sum =', sum(test_target == target_pred) )
    print( 'target size =', len(target_pred) )
    acc = sum(test_target == target_pred) / float(len(target_pred))
    return f1, acc

def get_model(
        optimizer,
        loss):

    from keras.models import Sequential
    import keras.layers as ll
    from keras import regularizers

    model = Sequential(name="mlp")
    #model = Sequential()

    # input layer
    inputs = ll.Dense(
                 24,
                 kernel_regularizer=regularizers.l2(0.001),
                 activation='relu',
                 input_shape=(24, ) )
    #flatten = ll.Flatten()

    # network body
    layer1 = ll.Dense(24, kernel_regularizer=regularizers.l2(0.001))
    activ = ll.Activation('relu')
    dropout = ll.Dropout(0.15)
    layer2 = ll.Dense(24, kernel_regularizer=regularizers.l2(0.001))
    layer3 = ll.Dense(24, kernel_regularizer=regularizers.l2(0.001))
    layer4 = ll.Dense(24, kernel_regularizer=regularizers.l2(0.001))

    # output layer
    output = ll.Dense(2, kernel_regularizer=regularizers.l2(0.001), activation='sigmoid')

    # model constructing
    model.add(inputs)

    model.add(layer1)
    model.add(activ)
    model.add(dropout)

    model.add(layer2)
    model.add(activ)
    model.add(dropout)

    model.add(layer3)
    model.add(activ)
    model.add(dropout)

    model.add(layer4)
    model.add(activ)
    model.add(dropout)

    model.add(output)

    # categorical_crossentropy is our good old
    # crossentropy but applied for one-hot-encoded
    # vectors
    from keras.metrics import categorical_accuracy
    model.compile(
       optimizer=optimizer,
       loss=loss,
#       lr = 0.0001,
       metrics=[categorical_accuracy])
#       metrics='accuracy')

    return model

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
def _train_classifier(clf, X_train, y_train):
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

#train_predict(clf_C, X_train, y_train, X_test, y_test)

# Report the final F1 score for training and testing
# after parameter tuning
#f1, acc = predict_labels(clf, X_train, y_train)
#print (f"F1 score and accuracy score for training set: {f1:.4f} , {acc:.4f}.")

#f1, acc = predict_labels(clf, X_test, y_test)
#print (f"F1 score and accuracy score for test set: {f1:.4f} , {acc:.4f}.")





def main():
    path = 'data/match_data_preprocessed/'
    file = 'preprocessed_atp_matches_1993-2018.csv'
    
    data = get_data(path, file)
    X_train, y_train, X_test, y_test = split_data(data, 0.15)
    
    #learning_rate = 0.0001
    opt = keras.optimizers.Adam(lr=0.001)
    #opt = keras.optimizers.RMSprop(lr=0.008)
    #opt = keras.optimizers.Adagrad(lr=0.008)
    #opt = keras.optimizers.Adadelta(lr=1.0)
    #loss = 'binary_crossentropy'
    loss = 'categorical_crossentropy'
    
    model = get_model(
                opt,
                loss)
    k = 5
    batch_size = 256
    epochs = 110
    #model = train_k_fold(model, X_train, y_train, k, batch_size, epochs)
    
    model = get_model(
                opt,
                loss)
    model = train_classifier(model, X_train, y_train, batch_size, epochs)
    
    f1, acc = test_classifier_f1(model, X_test, y_test)
    print (f"F1 score and accuracy score for test set: {f1:.4f} , {acc:.4f}.")

if __name__ == '__main__':
    main()