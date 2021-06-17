timing_apnea contains the apnea start and stop time in seconds for each record and event.
loading.m extracts the ecg signals from the raw data, as well as create a second by second label for apnea events.
splitting_datasets normalized the signal record, windows the signals, and split them into training, validation and test set. Minority upsampling is carried ouut on the training and validation set.
