function ExplicitOmissionAnalysis()

clear all
clc

global maxBlocks trialTypes fid1

RemoveInitial_N_trials = 2;
Remove_N_trialsAfterBreak = 2;
requiredTrialPropGoodSamples = 0;
anticipationLimit = 150;
slowResponseLimit = 9999;

a=0;

minSubNumber = input('Lowest participant number (default = 1)  ---> ');
maxSubNumber = input('Highest participant number (default = 200) ---> ');

if isempty(minSubNumber)
    minSubNumber = 1;
end
if isempty(maxSubNumber)
    maxSubNumber = 200;
end

maxBlocks = 12;
TotalTrials = 1536;
trialTypes = 2;

rtStore = zeros(maxSubNumber, trialTypes, maxBlocks);
rtStoreNum = zeros(maxSubNumber, trialTypes, maxBlocks);

subNumSummary = zeros(maxSubNumber);
conditionSummary = zeros(maxSubNumber);
missingTrials = zeros(maxSubNumber);
ageSummary = zeros(maxSubNumber);
counterbalSummary = zeros(maxSubNumber);

awareSummary = zeros(maxSubNumber, 2);
finalPayment = zeros(maxSubNumber);

trialTimeouts = zeros(maxSubNumber);
trialSoftTimeouts = zeros(maxSubNumber);

currentWD = pwd;

fileCounter = 0;

for subNum = minSubNumber : maxSubNumber
    
    secSessFile = [pwd, '\ExptData\CirclesEEGmultiDataP', num2str(subNum), 'S2.mat'];
    
    if exist(secSessFile, 'file') ~= 2
        continue
    end
    
    for s = 1:2
    
    
    dataFilename = [ pwd, '\ExptData\CirclesEEGmultiDataP', num2str(subNum), 'S', num2str(s), '.mat'];   % Start processing only if there's a session 1 file for this participant
    
    if exist(dataFilename, 'file') == 2
        
        load(dataFilename)
        
        if s == 1
            
            fileCounter = fileCounter + 1;
        
        
        
            subNumSummary(fileCounter) = DATA.subject;
            ageSummary(fileCounter) = DATA.age;
            counterbalSummary(fileCounter) = DATA.counterbal;
            
            finalTrial = 512;
            step = 0;
            blockStep = 0;
        else 
            
            finalTrial = 1024;
            step = 512;
            blockStep = 16;
            if isfield(DATA, 'actual_money')
                finalPayment(fileCounter) = DATA.actual_money;
            end
        
            if isfield(DATA, 'awareTestInfo')
            
                for ii = 1 : 2
                    if DATA.awareTestInfo(ii, 3) == 1
                        awareSummary(fileCounter, DATA.awareTestInfo(ii, 2)) = DATA.awareTestInfo(ii, 4);
                    else
                        awareSummary(fileCounter, DATA.awareTestInfo(ii, 2)) = -DATA.awareTestInfo(ii, 4);
                    end
                end
            
            else
                awareSummary(fileCounter, :) = [1/0, 1/0, 1/0];
            end
            
        end
        
        for trial = 1 : finalTrial
            
            actualTrial = step + trial;
            
            fprintf('SubNum %d     Trial %d\n', subNum, actualTrial);
            
            if isfield(DATA, 'expttrialInfo')
                
            
                if DATA.expttrialInfo(trial, 1) == 0

                    missingTrials(fileCounter) = missingTrials(fileCounter) + 1;

                else

                    if DATA.expttrialInfo(trial, 3) > RemoveInitial_N_trials && DATA.expttrialInfo(trial, 5) > Remove_N_trialsAfterBreak

                        if DATA.expttrialInfo(trial, 11) == 1 %if hard timeout

                            a = 0;

                        else                           

                            distractType = DATA.expttrialInfo(trial, 9);                            

                            actualBlock = blockStep + DATA.expttrialInfo(trial, 2);     % The expt actually had 48 blocks of 32 trials each...
                            block = ceil(actualBlock / 4);                  % ...but we're analysing as 12 blocks of 128 trials each, so we divide block number by 4

                            rt = DATA.expttrialInfo(trial, 13);

                            rtStore(fileCounter, distractType, block) = rtStore(fileCounter, distractType, block) + rt;
                            rtStoreNum(fileCounter, distractType, block) = rtStoreNum(fileCounter, distractType, block) + 1;


                        end       % If a timeout

                    end   % If an excluded trial at start of expt / after pause

                end   % If data missing
                
            end
            
        end   % For loop for trials
        
           
        
    else
        disp(['File ', dataFilename, ' not found']);
        
    end    % If file exists
    
end   % For loop for subjects

rtStore(fileCounter, :, :) = rtStore(fileCounter, :, :) ./ rtStoreNum(fileCounter, :, :);   
end


fid1 = fopen('SummaryRTs_EEG.csv', 'w');

outputHeaders;

for ii = 1 : fileCounter
    fprintf(fid1,'%d,', subNumSummary(ii));
    fprintf(fid1,'%d,', ageSummary(ii));
    fprintf(fid1,'%d,', counterbalSummary(ii));
    fprintf(fid1,'%f,', finalPayment(ii));
    fprintf(fid1,'%d,', missingTrials(ii));
    fprintf(fid1,'%d,', trialTimeouts(ii));
    fprintf(fid1,',');
    fprintf(fid1,'%d,', awareSummary(ii,:));
    
    
    for jj = 1 : trialTypes
        fprintf(fid1,',');
        
        fprintf(fid1,',%8.4f', rtStore(ii, jj, :)  );
    end
    
    
    fprintf(fid1,'\n');
    
end


% rtStore = zeros(maxSubNumber, trialTypes, maxBlocks);


fclose(fid1);

disp(['FINISHED: ',num2str(fileCounter), ' data files processed']);

clear all


end



function outputHeaders

global maxBlocks trialTypes fid1

fprintf(fid1,'subNum,');
fprintf(fid1,'age,');
fprintf(fid1,'counterbal,');
fprintf(fid1,'bonus,');
fprintf(fid1,'missing,');
fprintf(fid1,'trialTimeouts,');
fprintf(fid1,',');
fprintf(fid1,'awareHigh,awareLow');
fprintf(fid1,',');


for jj = 1 : trialTypes

        fprintf(fid1,',');
        for mm = 1 : maxBlocks
            fprintf(fid1,[',cue',num2str(jj),'_b', num2str(mm)] );
        end

end


fprintf(fid1,'\n');



end

