
function totalPay = runTrials(exptPhase)

global MainWindow scr_centre DATA datafilename
global keyCounterbal starting_total_points
global distract_col
global white black gray yellow
global bigMultiplier smallMultiplier
global zeroPayRT testing
global stim_size stim_pen
global address exptSession nf
global runEEG condition

standardPriority = Priority;

timeoutDuration = 2;     % 2 timeout duration
iti = 0;            % 0.1
onscreenAfterResponse = 0.1; %time that display remains onscreen after response
minOnscreenTime = 0.6;
correctFBDuration = [0.7, 1];       %[0.001, 0.001]    [0.7, 1]  Practice phase feedback duration  1 Main task feedback duration
errorFBDuration = [0.7, 1];       %[0.001, 0.001]      [0.7, 1.5]  Practice phase feedback duration  1.5 Main task feedback duration

minFixation = 0.8;         % 0.8   Minimum fixation duration
maxFixation = 1.2;         % 1.2   Maximum fixation duration

initialPause = 3;   % 3 ***
breakDuration = 15;  % 15 ***

exptTrialsPerBlock = 48;    % 48. This is used to ensure people encounter the right number of each of the different types of distractors.

exptTrialsBeforeBreak = exptTrialsPerBlock;     % 2 * exptTrialsPerBlock = 64

if exptSession == 2
    preFrequency = 4; %4 - every 4th block will be a "pre-training" block. Block 1,5,9 etc.
end

if testing == 1
    if exptSession == 1
        pracTrials = 0;
        maxBlocks = 2;
    else
        pracTrials = 0;
        maxBlocks = 4;
    end
else
    if exptSession == 1
        pracTrials = 8;
        maxBlocks = 12;
    else
        pracTrials = 32; %increased number of practice trials for eye movements
        maxBlocks = 36; %1728 trials total. 1296 trials of post-training. 162 trials for each trial type/configuration combo
    end
end

exptTrials = maxBlocks * exptTrialsBeforeBreak; 
% Session 1: 12 * exptTrialsBeforeBreak = 576;
% Session 2: 36 * exptTrialsBeforeBreak = 1728;

stimLocs = 10;       % Number of stimulus locations
stim_size = 165;     % 165 Size of diamond stimulus. = Visual angle of 4.39 dva at 57cm from screen. Slightly larger than diameter of circles, but should be equal area of grey outline
circ_stim_size = 124; % 3.3 degrees at 57cm
stim_pen = 10;      % Pen width of stimuli, 0.3 dva at 57cm
lineLength = 56;    % 80, 1.5 dva at 57cm. Line of target line segments
line_pen = 10;       % Pen width of line segments

circ_diam = 348;    % 348 for 16:9 23 inch screen = 9.2 deg vis angle from centre. Diameter of imaginary circle on which stimuli are positioned
fix_size = 20;      % This is the side length of the fixation cross. Approx 1 dva

bonusWindowWidth = 400;
bonusWindowHeight = 100;
bonusWindowTop = scr_centre(2)-50-bonusWindowHeight;

roundRT = 0;

winMultiplier = zeros(4);
winMultiplier(1) = bigMultiplier;         % distractor associated with big win
winMultiplier(2) = smallMultiplier;     % distractor associated with small win
winMultiplier(3) = bigMultiplier;       % target associated with big win
winMultiplier(4) = smallMultiplier;     % distractor associated with big win


% Latency testing square
% if testing == 1
%     testSquare = Screen('OpenOffscreenWindow', MainWindow, white, [0 0 100 100]);
% end

% This plots the points of a large diamond, that will be filled with colour
d_pts = [stim_size/2, 0;
    stim_size, stim_size/2;
    stim_size/2, stim_size;
    0, stim_size/2];

% This plots the points of a smaller diamond that will be drawn in black
% inside the previous one to make a frame (this is a pain, but you can't
% use FramePoly as it has limits on allowable pen widths). The first line is
% Pythagoras to make sure the pen width is correct.
d_inset = sqrt(2*(stim_pen^2));
small_d_pts = [stim_size/2, d_inset;
    stim_size - d_inset, stim_size/2;
    stim_size/2, stim_size - d_inset;
    d_inset, stim_size/2];

% Create an offscreen window, and draw the two diamonds onto it to create a diamond-shaped frame.
DiamondTex(1) = Screen('OpenOffscreenWindow', MainWindow, black, [0 0 stim_size stim_size]);
Screen('FillPoly', DiamondTex(1), gray, d_pts);
Screen('FillPoly', DiamondTex(1), black, small_d_pts);
CircleTex(1) = Screen('OpenOffscreenWindow', MainWindow, black, [0 0 stim_size stim_size]);
Screen('FrameOval', CircleTex(1), gray, [stim_size/2-circ_stim_size/2 stim_size/2-circ_stim_size/2 stim_size/2+circ_stim_size/2 stim_size/2+circ_stim_size/2], stim_pen, stim_pen);      % Draw coloured target circle

for dd = 1:length(distract_col) %make diamonds in each distractor colour
    DiamondTex(dd+1) = Screen('OpenOffscreenWindow', MainWindow, black, [0 0 stim_size stim_size]);
    Screen('FillPoly', DiamondTex(dd+1), distract_col(dd,:), d_pts);
    Screen('FillPoly', DiamondTex(dd+1), black, small_d_pts);
    CircleTex(dd+1) = Screen('OpenOffscreenWindow', MainWindow, black, [0 0 stim_size stim_size]);
    Screen('FrameOval', CircleTex(dd+1), distract_col(dd,:), [stim_size/2-circ_stim_size/2 stim_size/2-circ_stim_size/2 stim_size/2+circ_stim_size/2 stim_size/2+circ_stim_size/2], stim_pen, stim_pen);      % Draw coloured target circle
end

% Create an offscreen window, and draw the fixation cross in it.
fixationTex = Screen('OpenOffscreenWindow', MainWindow, black, [0 0 fix_size fix_size]);
Screen('FillOval', fixationTex, white);

% Create a rect for the fixation cross
fixRect = [scr_centre(1) - fix_size/2    scr_centre(2) - fix_size/2   scr_centre(1) + fix_size/2   scr_centre(2) + fix_size/2];

% The oblique line segments need to have the same length as the vertical /
% horizontal target lines. Use Pythagoras to work out vertical and
% horizontal displacements of these lines (which are equal because lines
% are at 45 deg).

%obliqueDisp = round(sqrt(lineLength * lineLength / 2));

% Create a matrix containing the six stimulus locations, equally spaced
% around an imaginary circle of diameter circ_diam
% Also create sets of points defining the positions of the oblique and
% target (horizontal / vertical) lines that appear inside each stimulus
stimCentre = zeros(stimLocs,4);
stimRect = zeros(stimLocs, 4);
%lineRight = zeros(stimLocs,4);
%lineLeft = zeros(stimLocs,4);
lineVert = zeros(stimLocs,4);
lineHorz = zeros(stimLocs,4);
lineOrientation = zeros(1,stimLocs);   % Used below; preallocating for speed

circRectVals = [-circ_stim_size/2 -circ_stim_size/2 circ_stim_size/2 circ_stim_size/2];
diamondRectVals = [-stim_size/2 -stim_size/2 stim_size/2 stim_size/2];


for i = 0 : stimLocs - 1    % Define rects for stimuli and line segments
    stimCentre(i+1,:) = [scr_centre(1) - circ_diam * sin(i*2*pi/stimLocs)   scr_centre(2) - circ_diam * cos(i*2*pi/stimLocs)  scr_centre(1) - circ_diam * sin(i*2*pi/stimLocs)  scr_centre(2) - circ_diam * cos(i*2*pi/stimLocs)];
    lineVert(i+1,:) = [stimCentre(i+1,1) stimCentre(i+1,2) - lineLength/2 stimCentre(i+1,1) stimCentre(i+1,2)+lineLength/2];
    lineHorz(i+1,:) = [stimCentre(i+1,1) - lineLength/2 stimCentre(i+1,2) stimCentre(i+1,1)+lineLength/2 stimCentre(i+1,2)];
    %lineRight(i+1,:) = [stimCentre(i+1,1) - obliqueDisp/2   stimCentre(i+1,2) + obliqueDisp/2   stimCentre(i+1,1) + obliqueDisp/2   stimCentre(i+1,2) - obliqueDisp/2];
    %lineLeft(i+1,:) = [stimCentre(i+1,1) - obliqueDisp/2   stimCentre(i+1,2) - obliqueDisp/2   stimCentre(i+1,1) + obliqueDisp/2   stimCentre(i+1,2)  + obliqueDisp/2];
    
    stimRect(i+1,:,1) = stimCentre(i+1,:)+circRectVals; %stimRect(:,:,1) has all the rects for the circle stimuli
    stimRect(i+1,:,2) = stimCentre(i+1,:)+diamondRectVals; %stimRect(:,:,2) has all the rects for the diamond stimuli
    
    %     targetRect(i+1,:) = [scr_centre(1) - circ_diam * sin(i*2*pi/stimLocs) - stim_size / 2   scr_centre(2) - circ_diam * cos(i*2*pi/stimLocs) - stim_size / 2   scr_centre(1) - circ_diam * sin(i*2*pi/stimLocs) + stim_size / 2   scr_centre(2) - circ_diam * cos(i*2*pi/stimLocs) + stim_size / 2];
    %     circleRect(i+1,:) = [scr_centre(1) - circ_diam * sin(i*2*pi/stimLocs) - circ_stim_size / 2   scr_centre(2) - circ_diam * cos(i*2*pi/stimLocs) - circ_stim_size / 2   scr_centre(1) - circ_diam * sin(i*2*pi/stimLocs) + circ_stim_size / 2   scr_centre(2) - circ_diam * cos(i*2*pi/stimLocs) + circ_stim_size / 2];
    %     lineVert(i+1,:) = [targetRect(i+1,1) + stim_size/2   targetRect(i+1,2) + (stim_size-lineLength)/2    targetRect(i+1,1) + stim_size/2    targetRect(i+1,2) + stim_size/2 + lineLength/2];
    %     lineHorz(i+1,:) = [targetRect(i+1,1) + (stim_size-lineLength)/2   targetRect(i+1,2) + stim_size/2    targetRect(i+1,1) + stim_size/2 + lineLength/2    targetRect(i+1,2) + stim_size/2];
    
    
end


% Create a full-size offscreen window that will be used for drawing all
% stimuli and targets (and fixation cross) into
stimWindow = Screen('OpenOffscreenWindow', MainWindow, black);


% Create a small offscreen window and draw the bonus multiplier into it
bonusTex = Screen('OpenOffscreenWindow', MainWindow, yellow, [0 0 bonusWindowWidth bonusWindowHeight]);
%Screen('FrameRect', bonusTex, yellow, [], 8);
Screen('TextSize', bonusTex, 42);
Screen('TextFont', bonusTex, 'Calibri');
Screen('TextStyle', bonusTex, 1);
DrawFormattedText(bonusTex, [num2str(bigMultiplier), ' x  bonus trial!'], 'center', 'center', black);

errorTex = Screen('OpenOffscreenWindow', MainWindow, black, [0 0 bonusWindowWidth bonusWindowHeight]);
Screen('TextSize', errorTex, 40);
Screen('TextFont', errorTex, 'Courier New');
Screen('TextStyle', errorTex, 1);
[~, ~, errorBox] = DrawFormattedText(errorTex, 'ERROR', 'center', 'center', white, [], [], [], 1.5);
errorBoxW = errorBox(3)-errorBox(1);
errorBoxH = errorBox(4)-errorBox(2);




if exptPhase == 0
    numTrials = pracTrials;
    DATA.practrialInfo = zeros(pracTrials, 13);    
    distractArrayPre = zeros(1, pracTrials);
    configArray = zeros(1, pracTrials);
    distractArrayPre(1 : pracTrials) = 5;
    distractArrayPost(1 : pracTrials) = 5;
    configArray(1:pracTrials) = ones(1,pracTrials)*5;
    configArrayPre = configArray;
    configArrayPost = configArray;
else
    numTrials = exptTrials;
    if exptSession == 2
        switch condition
            case 1
                valueLevelsPost = [1 3];
            case 2
                valueLevelsPost = [2 4];
        end
    else
        valueLevelsPost = 1:4;
    end
    valueLevelsPre = 1:4;
    DATA.expttrialInfo = zeros(exptTrials, 21);
    
    distractArrayPre = repmat(valueLevelsPre,1,exptTrialsPerBlock/length(valueLevelsPre));
    distractArrayPost = repmat(valueLevelsPost,1,exptTrialsPerBlock/length(valueLevelsPost));
    
    configArrayPre = ones(1,exptTrialsPerBlock)*5; %random configurations for pre-training blocks
    configArrayPost = [ones(1,exptTrialsPerBlock/4) ones(1,exptTrialsPerBlock/4)*2 ones(1,exptTrialsPerBlock/4)*3 ones(1,exptTrialsPerBlock/4)*4]; %equal proportion of critical configurations for post-training blocks
end


totalPay = 0;

tempTrialOrder(:,:,1) = [distractArrayPre' configArrayPre']; % pre-training trial order
tempTrialOrder(:,:,2) = [distractArrayPost' configArrayPost']; % post-training trial order

shuffled_trialOrder = shuffleTrialorder(tempTrialOrder(:,:,1), exptPhase);   % Calls a function to shuffle the first block of trials
nextBlockType = 1; %first block is a pre-training block
shuffled_distractArray = shuffled_trialOrder(:,1);
shuffled_configArray = shuffled_trialOrder(:,2);

trialCounter = 0;
block = 1;
trials_since_break = 0;

rightPos = 7:10;
leftPos = 2:5;
midlinePos = [1 6];

RestrictKeysForKbCheck([KbName('4'), KbName('5')]);   % Only accept keypresses from numpad keys 4 and 5

WaitSecs(initialPause);

VBLTime = zeros(1,numTrials);
StimOnsetTime = zeros(1,numTrials);
FlipTime = zeros(1,numTrials);
Missed = zeros(1,numTrials);

for trial = 1 : numTrials
    maxPriorityLvl = MaxPriority(MainWindow); %find out what the maximum priority level available is
    Priority(maxPriorityLvl); % Set PTB to higher priority level
    
    %Perform an extra calibration of the monitor to estimate monitor
    %refresh interval. This uses at least 100 valid samples, requiring a
    %standard deviation of the measurements below 50 microseconds. Will
    %time out after 20 seconds if can't obtain that level of accuracy.
    if trial == 1
        [ ifi nvalid stddev ]= Screen('GetFlipInterval', MainWindow, 100, 0.00005, 20); 
    end
    
    targetHem = 0; %used to track the hemifield of the target, 1 = left, 2 = right.
    distractHem = 0; %used to track the hemifield of the distractor, 1 = left, 2 = right.
    
    trialCounter = trialCounter + 1;    % This is used to set distractor type below; it can cycle independently of trial
    trials_since_break = trials_since_break + 1;
    
    distractType = shuffled_distractArray(trialCounter);
    targetType = randi(2); %orientation of line within target
    
    singletonType = randi(2); %randomly determine whether diamond or circle target
    
    switch shuffled_configArray(trialCounter)
        case 1 %lateral target, midline distractor
            availTargetPos = [leftPos rightPos];
            targetLoc = availTargetPos(randi(length(availTargetPos)));
            availDistractorPos = midlinePos;            
        case 2 %lateral distractor, midline target
            availTargetPos = [midlinePos];
            targetLoc = availTargetPos(randi(length(availTargetPos)));
            availDistractorPos = [leftPos rightPos];
        case 3 % lateral target, ipsilateral distractor
            availTargetPos = [leftPos rightPos];
            targetLoc = availTargetPos(randi(length(availTargetPos)));
            if ismember(targetLoc, rightPos)
                availDistractorPos = rightPos;
            else
                availDistractorPos = leftPos;
            end
            availDistractorPos(availDistractorPos(:)==targetLoc) = [];
        case 4 %lateral target, contralateral distractor
            availTargetPos = [leftPos rightPos];
            targetLoc = availTargetPos(randi(length(availTargetPos)));
            if ismember(targetLoc, rightPos)
                availDistractorPos = leftPos;
            else
                availDistractorPos = rightPos;
            end
        case 5 %random configuration
            availTargetPos = 1:10;
            targetLoc = availTargetPos(randi(length(availTargetPos)));
            if distractType > 2 && distractType < 5 %target = distractor
                availDistractorPos = targetLoc;
            elseif distractType == 5
                if randi(2) == 1
                    availDistractorPos = targetLoc;
                else
                    availDistractorPos = availTargetPos;
                    availDistractorPos(availDistractorPos(:)==targetLoc) = [];
                end
            else %target /= distractor
                availDistractorPos = availTargetPos;
                availDistractorPos(availDistractorPos(:)==targetLoc) = [];
            end            
    end
    
    if ismember(targetLoc, leftPos)
        targetHem = 1; %target left
    elseif ismember(targetLoc, rightPos)
        targetHem = 2; %target right
    else
        targetHem = 3; %target mid
    end
    
    distractLoc = availDistractorPos(randi(length(availDistractorPos)));
    
    if ismember(distractLoc, leftPos)
        distractHem = 1; %distractor left
    elseif ismember(distractLoc, rightPos)
        distractHem = 2; %distractor right
    else
        distractHem = 3; %distractor mid
    end
    
    if shuffled_configArray(trialCounter) == 5 && distractType > 2 && distractType < 5
        distractHem = 4; %"No" separate distractor
    end
    
    fix_pause = round((minFixation + rand*(maxFixation - minFixation))/.01)*.01;    % Creates random fixation interval in range minFixation to maxFixation, rounded to 10ms (updated for better alpha desynch)
    
    waitframes = ceil(fix_pause/ifi); % find out how many frames we need to wait given our refresh rate
    
    Screen('FillRect', stimWindow, black);  % Clear the screen from the previous trial by drawing a black rectangle over the whole thing
    Screen('DrawTexture', stimWindow, fixationTex, [], fixRect); %draw fixation dot
    
    for i = 1 : stimLocs
        if singletonType == 1 %draw grey circles
            Screen('FrameOval', stimWindow, gray, stimRect(i,:,1), stim_pen, stim_pen);       % Draw stimulus circles
        else %draw grey squares
            Screen('DrawTexture', stimWindow, DiamondTex(1), [], stimRect(i,:,2));
        end
    end
   
    if distractLoc ~= targetLoc %if distractor /= target
        if singletonType == 1
            Screen('DrawTexture', stimWindow, CircleTex(distractType+1), [], stimRect(distractLoc,:,2));      % Draw distractor circle
        else
            Screen('DrawTexture', stimWindow, DiamondTex(distractType+1), [], stimRect(distractLoc,:,2)); %draw distractor diamond
        end
    end
    
    for i = 1 : stimLocs
        lineOrientation(i) = round(rand);
        if lineOrientation(i) == 0
            Screen('DrawLine', stimWindow, gray, lineHorz(i,1), lineHorz(i,2), lineHorz(i,3), lineHorz(i,4), line_pen);
        else
            Screen('DrawLine', stimWindow, gray, lineVert(i,1), lineVert(i,2), lineVert(i,3), lineVert(i,4), line_pen);
        end
    end
    
    if distractLoc ~= targetLoc %if distractor /= target
        if singletonType == 1
            Screen('FillRect', stimWindow, black, stimRect(targetLoc,:,2));
            Screen('DrawTexture', stimWindow, DiamondTex(1), [], stimRect(targetLoc,:,2)); %draw diamond target
        else
            Screen('FillRect', stimWindow, black, stimRect(targetLoc,:,2));
            Screen('DrawTexture', stimWindow, CircleTex(1), [], stimRect(targetLoc,:,2)); %draw circle target
        end
    else
        if singletonType == 1
            Screen('FillRect', stimWindow, black, stimRect(targetLoc,:,2));
            Screen('DrawTexture', stimWindow, DiamondTex(distractType+1), [], stimRect(targetLoc,:,2)); %draw diamond coloured target
        else
            Screen('FillRect', stimWindow, black, stimRect(targetLoc,:,2));
            Screen('DrawTexture', stimWindow, CircleTex(distractType+1), [], stimRect(targetLoc, :, 2)); %draw circle coloured target
        end
    end
    
    if targetType == 1
        Screen('DrawLine', stimWindow, gray, lineHorz(targetLoc,1), lineHorz(targetLoc,2), lineHorz(targetLoc,3), lineHorz(targetLoc,4), line_pen);
    else
        Screen('DrawLine', stimWindow, gray, lineVert(targetLoc,1), lineVert(targetLoc,2), lineVert(targetLoc,3), lineVert(targetLoc,4), line_pen);
    end
    
%     if testing == 1
%         Screen('DrawTexture', stimWindow, testSquare, [], [0 0 100 100]);
%     end
    
    %%%%%%%%%%%%%%%%%%%%%%%% STIMULUS EVENT CODES %%%%%%%%%%%%%%%%%%%%%%%%%
    %%%                                                                 %%%
    %%% Hundreds Place %%%
    % 0 = Pre-training block
    % 1 = Post-training block
    % 2 = Practice Trial
    %%% Tens Place %%%
    % 1 = Left Side Target, Midline/no Distractor
    % 2 = Left Side Target, Left Side Distractor
    % 3 = Left Side Target, Right Side Distractor
    % 4 = Right Side Target, Midline/no Distractor
    % 5 = Right Side Target, Left Side Distractor
    % 6 = Right Side Target, Right Side Distractor
    % 7 = Midline Target, Midline/no Distractor
    % 8 = Left Side Distractor, Midline Target
    % 9 = Right Side Distractor, Midline Target
    %%% Ones Place %%%
    % 1 = Low distractor
    % 2 = High distractor
    % 3 = Low target
    % 4 = High target
    %%% EG - 122 = Post-training, left side target, left side distractor,
    %%% high val that was previously trained as a distractor
    %%%                                                                 %%%
    %%%%%%%%%%%%%%%%%%%%%%% RESPONSE EVENT CODES %%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%                                                                 %%%
    % xx5 = Left Response
    % xx6 = Right Response
    % xx7 = No response
    %%%                                                                 %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%% FEEDBACK CODES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%                                                                 %%%
    % xx8 = Correct FB
    % xx9 = Incorrect FB
    %%%                                                                 %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if exptSession == 2
        triggerOn = 0;
        triggerFB = 0;
        if exptPhase == 0
            triggerOn = triggerOn + 200; %trigger is 200 for all practice trials
        elseif exptPhase == 1
            if nextBlockType == 2 %if post-training (EEG) block
                triggerOn = triggerOn + 100;
            end
            switch distractType
                case 1
                    triggerOn = triggerOn + 2; % low distractor
                case 2
                    triggerOn = triggerOn + 1; %high distractor
                case 3
                    triggerOn = triggerOn + 4; %low target
                case 4
                    triggerOn = triggerOn + 3; %high target
            end
            switch targetHem
                case 1
                    triggerOn = triggerOn + 10; %left target
                case 2
                    triggerOn = triggerOn + 40; %right target
                case 3
                    triggerOn = triggerOn + 70; %midline target
            end
            switch distractHem
                case 1
                    triggerOn = triggerOn + 10; %left distractor
                case 2
                    triggerOn = triggerOn + 20; %right distractor
                case 3
                    triggerOn = triggerOn + 0; %midline distractor
                case 4
                    triggerOn = triggerOn + 0; %no distractor (only relevant to pre-training blocks where target is coloured)
            end
        end
    else
        triggerOn = 0;
        triggerFB = 0;
    end
    
    Screen('FillRect',MainWindow, black);
    
    Screen('DrawTexture', MainWindow, fixationTex, [], fixRect);
    fixOn = Screen(MainWindow, 'Flip');     % Present fixation cross
    %WaitSecs(fix_pause);
    
    Screen('DrawTexture', MainWindow, stimWindow);
    
    
    %Now saving a bunch of timestamps for the stimulus presentation. This
    %allows us to check for timing issues from the PTB end
    [VBLTime(trial) StimOnsetTime(trial) FlipTime(trial) Missed(trial)] = Screen(MainWindow, 'Flip', fixOn + (waitframes-0.5) * ifi); 
    if runEEG == 1; outp(address, triggerOn); end % Send ON trigger
    
    st = VBLTime(trial); %record start time when stimuli are presented
    
%     image = Screen('GetImage', MainWindow, [scr_centre(1)-450 scr_centre(2)-450 scr_centre(1)+450 scr_centre(2)+450] );
%     
%     if singletonType == 1
%         if distractLoc == targetLoc
%             imwrite(image, 'exampleDiamondTargetColoured.jpg') %400 x 400
%         else
%             imwrite(image, 'exampleDiamondTarget.jpg')
%         end
%     else
%        if distractLoc == targetLoc
%            imwrite(image, 'exampleCircleTargetColoured.jpg') 
%        else
%            imwrite(image, 'exampleCircleTarget.jpg')
%        end
%     end
    
    %%% FOR SCREENSHOTS
    
    %     image = Screen('GetImage', MainWindow);
    %
    %     if targetHem == 1
    %         imwrite(image, 'targetImage.png');
    %     elseif distractHem == 1
    %         imwrite(image, 'distractImage.png');
    %     end
    
    if testing == 1
        et = WaitSecs(0.55);
        timeout = 0;
        if rand > .05
            if targetType == 1
                keyCodePressed = 100;
            else
                keyCodePressed = 101;
            end
        else
            if targetType == 1
                keyCodePressed = 101;
            else
                keyCodePressed = 100;
            end
        end
    else
        [keyCode, et, timeout] = accKbWait(st, timeoutDuration);
        keyCodePressed = find(keyCode, 1, 'first');
    end
    
    Priority(standardPriority); %Revert to standard priority level for less important stuff
  
    if keyCodePressed == 100
        if runEEG == 1; outp(address, 5); end %left response trigger
    elseif keyCodePressed == 101
        if runEEG == 1; outp(address, 6); end %right response trigger
    else
        if runEEG == 1; outp(address, 7); end %no response trigger
    end
    
    keyPressed = KbName(keyCodePressed); %Get the name of the key that was pressed
    
    rt = 1000 * (et - st); %response time in ms
    
    correct = 0;
    
    if timeout == 1  % No key pressed (i.e. timeout)
        trialPay = 0;
        Beeper;
        fbStr = 'TOO SLOW\n\nPlease try to respond faster';
        
    else
        
        fbStr = 'ERROR';
        
        if keyPressed == '4'
            if keyCounterbal == targetType     % If C = horizontal and line is horizontal, or if C = vertical and line is vertical
                correct = 1;
                fbStr = 'correct';
            end
            
        elseif keyPressed == '5'
            if keyCounterbal ~= targetType     % If M = horizontal and line is horizontal, or if M = vertical and line is vertical
                correct = 1;
                fbStr = 'correct';
            end
            
        end
        
        if exptPhase == 1       % If this is NOT practice
            
            roundRT = round(rt);    % Divide RT by 10 and round to nearest integer. Changed so that numbers of points don't get huge.
            
            if roundRT >= zeroPayRT
                trialPay = 0;
            else
                trialPay = round((zeroPayRT - roundRT)/10) * winMultiplier(distractType); % Changed so that number of points given is (1000-RT)/10 x Multiplier
            end
            
            if winMultiplier(distractType) == bigMultiplier
                if nextBlockType == 1
                    Screen('DrawTexture', MainWindow, bonusTex, [], [scr_centre(1)-bonusWindowWidth/2   bonusWindowTop   scr_centre(1)+bonusWindowWidth/2    bonusWindowTop+bonusWindowHeight]);
                end
            end
            
            
            if correct == 0
                totalPay = totalPay - trialPay;
                if nextBlockType == 1
                    fbStr = ['Lose ', char(nf.format(trialPay)), ' points'];
                    Screen('DrawTexture', MainWindow, errorTex, errorBox, [scr_centre(1)-50-errorBoxW   scr_centre(2)-errorBoxH/2   scr_centre(1)-50    scr_centre(2)+errorBoxH/2]);
                    Screen('DrawTexture', MainWindow, errorTex', errorBox, [scr_centre(1)+50    scr_centre(2)-errorBoxH/2   scr_centre(1)+50+errorBoxW     scr_centre(2)+errorBoxH/2]);
                else
                    fbStr = 'ERROR';
                end
                trialPay = -trialPay;   % This is so it records correctly in the data file
                triggerFB = 9;
            elseif correct == 1
                totalPay = totalPay + trialPay;
                if nextBlockType == 1
                    fbStr = ['+', char(nf.format(trialPay)), ' points'];
                else
                    fbStr = 'correct';
                end
                triggerFB = 8;
            end
            
            Screen('TextSize', MainWindow, 32);
            if nextBlockType == 1
                totalStr = format_payStr(totalPay + starting_total_points);
            else
                totalStr = '???  total';
            end
            DrawFormattedText(MainWindow, totalStr, 'center', scr_centre(2)+150, white);   
        end
    end
    
    Screen('TextSize', MainWindow, 40);
    DrawFormattedText(MainWindow, fbStr, 'center', scr_centre(2) + 75, yellow);
    Screen('DrawTexture', MainWindow, fixationTex, [], fixRect);
    
    
    WaitSecs(onscreenAfterResponse-(GetSecs-et));
    % wait until 100ms after response is registered before presenting
    % feedback. Check using EEG triggers.
    
    WaitSecs(minOnscreenTime-(GetSecs-st));
    % search display must remain onscreen for at least 600ms, helps avoid
    % offset ERPs for trials with fast responses.

    Screen('Flip', MainWindow); if runEEG == 1; outp(address, triggerFB); end
    if correct == 0
        WaitSecs(correctFBDuration(exptPhase + 1));
    else
        WaitSecs(errorFBDuration(exptPhase + 1));
    end
%     removed as no blank screen ITI
%     Screen('DrawTexture', MainWindow, fixationTex, [], fixRect);
%     Screen('Flip', MainWindow);
%     WaitSecs(iti);
    
    
    if exptPhase == 0
        DATA.practrialInfo(trial,:) = [exptSession, trial, targetLoc, targetType, distractLoc, distractType, singletonType, shuffled_configArray(trialCounter), timeout, correct, rt, fix_pause, triggerOn];
    else
        DATA.expttrialInfo(trial,:) = [exptSession, block, trial, trialCounter, trials_since_break, targetLoc, targetType, distractLoc, distractType, singletonType, shuffled_configArray(trialCounter), timeout, correct, rt, roundRT, trialPay, totalPay, fix_pause, targetHem, distractHem, triggerOn];
        DATA.ifi = ifi;
        DATA.VBLTime = VBLTime;
        DATA.StimOnsetTime = StimOnsetTime;
        DATA.FlipTime = FlipTime;
        DATA.Missed = Missed;
        if mod(trial, exptTrialsPerBlock) == 0
            if exptSession == 2
                if  rem(block, preFrequency) == 0
                    nextBlockType = 1; %next block type is a pretraining block
                else
                    nextBlockType = 2; %next block type is a post-training block
                end
            else
                nextBlockType = 1;
            end
            shuffled_trialOrder = shuffleTrialorder(tempTrialOrder(:,:,nextBlockType), exptPhase);   % Calls a function to shuffle trials
            shuffled_distractArray = shuffled_trialOrder(:,1);
            shuffled_configArray = shuffled_trialOrder(:,2);
            trialCounter = 0;
            block = block + 1;
        end
        
        if (mod(trial, exptTrialsBeforeBreak) == 0 && trial ~= numTrials);
            save(datafilename, 'DATA');
            take_a_break(nextBlockType, breakDuration, initialPause, totalPay, block, maxBlocks);
            trials_since_break = 0;
        end
        
    end
    
    save(datafilename, 'DATA');
end


Screen('Close', DiamondTex);
Screen('Close', fixationTex);
Screen('Close', stimWindow);


end




function shuffArray = shuffleTrialorder(inArray,ePhase)

acceptShuffle = 0;

while acceptShuffle == 0
    shuffArray = inArray(randperm(length(inArray)),:);     % Shuffle order of distractors
    acceptShuffle = 1;   % Shuffle always OK in practice phase
    if ePhase == 1
        if shuffArray(1,1) > 2 || shuffArray(2,1) > 2
            acceptShuffle = 0;   % Reshuffle if either of the first two trials (which may well be discarded) are rare types
        end
    end
end

end



function aStr = format_payStr(ii)

global nf

if ii < 0
    aStr = [char(nf.format(ii)), '  total'];
else
    aStr = [char(nf.format(ii)), '  total'];
end

end




function take_a_break(nextBlockType, breakDur, pauseDur, currentTotal, nextBlockNum, maxBlockNum)

global MainWindow white address runEEG exptSession starting_total_points nf yellow testing

if exptSession == 2
    if nextBlockType == 1 %next block is a pre-training block
        breakText = ['Time for a break\n\nSit back, relax for a moment! The experimenter will restart the task in a few moments\n\nIn the next block, the target MAY or MAY NOT be coloured.'...
            '\n\nYou WILL be told how many points you won or lost after each trial.\n\nRemember that the faster you make correct responses, the more you will earn in this task!'];
        totalText = ['\n\nSo far you have earned ' char(nf.format(currentTotal + starting_total_points)) ' points.'];
    else %next block is a post-training block
        breakText = ['Time for a break\n\nSit back, relax for a moment! The experimenter will restart the task in a few moments\n\nIn the next block, the target WILL NEVER be coloured.'...
            '\n\nYou WILL NOT be told how many points you won or lost after each trial. But you will still be earning points!\n\nRemember that the faster you make correct responses, the more you will earn in this task!'];
        totalText = ['\n\nSo far you have earned ' char(nf.format(currentTotal + starting_total_points)) ' points.'];
    end
else
     breakText = ['Time for a break\n\nSit back, relax for a moment! You will be able to carry on in ', num2str(breakDur),' seconds\n\n\nRemember that the faster you make correct responses, the more you will earn in this task!'];
     totalText = ['\n\n\nSo far you have earned ' char(nf.format(currentTotal + starting_total_points)) ' points.'];
end
        
    
blocksLeftText = num2str(maxBlockNum-(nextBlockNum-1));

[~,ny,~] = DrawFormattedText(MainWindow, breakText, 'center', 'center', white, 50, [], [], 1.5);
DrawFormattedText(MainWindow, totalText, 'center', ny, yellow, 50, [], [], 1.5);
DrawFormattedText(MainWindow, blocksLeftText, 1870, 50, [80 80 80], [], [], [], 1.5); % Displays the number of blocks remaining in upper right corner of break screen.

Screen(MainWindow, 'Flip'); if runEEG == 1; outp(address,254); end %send break trigger

if exptSession == 1
    WaitSecs(breakDur);
    RestrictKeysForKbCheck(KbName('Space'));   % Only accept spacebar
    DrawFormattedText(MainWindow, 'Please place your right index and middle fingers on the 4 and 5 keys\n\nand press the spacebar when you are ready to continue', 'center', 'center' , white);
    Screen(MainWindow, 'Flip');
else
    RestrictKeysForKbCheck(KbName('t')); %Only accept "T", for experimenter to continue
end

if testing ~= 1
    KbWait([], 2);
end
if runEEG == 1; outp(address,255); end %send continue after break trigger
Screen(MainWindow, 'Flip');

RestrictKeysForKbCheck([KbName('4'), KbName('5')]);   % Only accept keypresses from keys 4 and 5

WaitSecs(pauseDur);

end