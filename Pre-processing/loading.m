list_string={'ucddb002','ucddb003','ucddb005','ucddb006','ucddb007','ucddb009',...
             'ucddb010','ucddb012','ucddb014','ucddb015','ucddb017',...
             'ucddb019','ucddb020','ucddb021','ucddb022','ucddb023','ucddb024',...
             'ucddb025','ucddb026','ucddb027','ucddb028'}; %all records in the dataset except ucddb008, , ucddb011, ucddb013, and ucddb018
         
load('timing_apnea.mat'); %apnea start and stop seconds stored
for l=1:length(list_string)
    
    [signalorig,Fs,tm]=rdsamp(strcat(list_string{l},'.rec'));
    signal=signalorig(:,6);

    timing=timing_val{l,1};

    labels=zeros(floor(length(signal)/Fs),1);
    for i=1:length(timing)
        labels(timing(i,1):timing(i,2),1)=ones(timing(i,2)-timing(i,1)+1,1);
    end

    save(strcat(list_string{l},'_label'),'labels')
    save(strcat(list_string{l}),'signal')
end