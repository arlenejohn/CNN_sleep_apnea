list_string={'ucddb002','ucddb003','ucddb005','ucddb006','ucddb007','ucddb008','ucddb009',...
             'ucddb010','ucddb012','ucddb013','ucddb014','ucddb015','ucddb017',...
             'ucddb018','ucddb019','ucddb020','ucddb021','ucddb022','ucddb023','ucddb024',...
             'ucddb025','ucddb026','ucddb027','ucddb028'};

folder = 'D:\PhD topics\Datasets\sleep_apnea\selected';

for l=1:length(list_string)

    %load signal and normalize
    load(strcat(list_string{l},'.mat')); 
    ecg=signal(:,1);
    ecg=(ecg-mean(ecg))/std(ecg);
    
    %load apnea locations
    load(strcat(list_string{l},'_label.mat'));
    labels=labels(1:length(labels)-11);
    
    %windowing features
    ecg_features=zeros(round(length(ecg)/128)-11,1408);
    i = 129;
    k=1;
    while i < length(ecg)-1279
        feature_window=ecg(i-128: i+1279);
        feature_window=feature_window';
        ecg_features(k,:)=feature_window;
        k=k+1;
        i=i+128;
    end
    
    
     
    clear ecg
    clear signal
    
    total_features=ecg_features;
    
    
    % splitting into test set (10%) and train+valid set(90%)
    c = cvpartition(labels,'HoldOut',0.1);
    idxTrain=training(c);
    idxTest=test(c);
    test_list=total_features(idxTest,:);
    class_test=labels(idxTest);
    save(fullfile(folder,strcat(list_string{l},'_test_labels.mat')),'class_test');
    clear class_test
    ecg_test=test_list(:,1:1408);
    save(fullfile(folder,strcat(list_string{l},'_ecg_test.mat')),'ecg_test');
    clear ecg_test
    
    train_valid_list=total_features(idxTrain,:);
    class_train_valid=labels(idxTrain);
    
    clear total_features
    clear labels
    
    % splitting into validation (10%) and test set(80%)
    c = cvpartition(class_train_valid,'HoldOut',0.1/0.9);
    idxTrain=training(c);
    idxValid=test(c);
    
    
    train_list=train_valid_list(idxTrain,:);
    class_train=class_train_valid(idxTrain);
    
    % minority upsampling in train set
    df_majority = train_list(class_train==0,:);
    df_minority = train_list(class_train==1,:);
    
    
    s = RandStream('mlfg6331_64');
    y = datasample(s,1:size(df_minority,1),size(df_majority,1)-size(df_minority,1),'Replace',true);
    df_minority_upsampled = df_minority(y,:);
    total_features_resampled = [df_majority;df_minority; df_minority_upsampled];
    labels_resampled=[zeros(size(df_majority,1),1);ones(size(df_minority,1),1);ones(size(df_minority_upsampled,1),1)];
        
    class_train=labels_resampled;
    train_list=total_features_resampled;
    
    clear y
    clear s
    clear labels_resampled
    clear total_features_resampled
    
    
    save(fullfile(folder,strcat(list_string{l},'_train_labels.mat')),'class_train');
    clear class_train
    ecg_train=train_list(:,1:1408);
    save(fullfile(folder,strcat(list_string{l},'_ecg_train.mat')),'ecg_train');
    clear ecg_train
    
    clear train_list
    clear idxTrain
    
    
    valid_list=train_valid_list(idxValid,:);
    class_valid=class_train_valid(idxValid);
    
    % minority upsampling in validation set
    
    df_majority = valid_list(class_valid==0,:);
    df_minority = valid_list(class_valid==1,:);
    
    s = RandStream('mlfg6331_64');
    y = datasample(s,1:size(df_minority,1),size(df_majority,1)-size(df_minority,1),'Replace',true);
    df_minority_upsampled = df_minority(y,:);
    total_features_resampled = [df_majority;df_minority; df_minority_upsampled];
    labels_resampled=[zeros(size(df_majority,1),1);ones(size(df_minority,1),1);ones(size(df_minority_upsampled,1),1)];
    
    
    class_valid=labels_resampled;
    valid_list=total_features_resampled;
    clear labels_resampled
    clear total_features_resampled
    
    
    save(fullfile(folder,strcat(list_string{l},'_valid_labels.mat')),'class_valid');
    clear class_valid
    ecg_valid=valid_list(:,1:1408);
    save(fullfile(folder,strcat(list_string{l},'_ecg_valid.mat')),'ecg_valid');
    clear ecg_valid
    clear valid_list
    clear idxValid
    
    clearvars -except list_string l folder
    
    list_string{l}
end
    