
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
global shortDisplayVersion

standardPriority = Priority;

timeoutDuration = 2;     % 2 timeout duration
iti = 0;            % 0.1
onscreenAfterResponse = 0.1; %time that display remains onscreen after response
minOnscreenTime = 0.6;
correctFBDuration = [0.7, 1];       % [0.7, 1]  Practice phase feedback duration  1 Main task feedback duration
errorFBDuration = [0.7, 1];       % [0.7, 1.5]  Practice phase feedback duration  1.5 Main task feedback duration

minFixation = 0.8;         % 0.8   Minimum fixation duration
maxFixation = 1.2;         % 1.2   Maximum fixation duration

initialPause = 3;   % 3 ***
breakDuration = 15;  % 15 ***

exptTrialsPerBlock = 48;    % 48. This is used to ensure people encounter the right number of each of the different types of distractors.

exptTrialsBeforeBreak = exptTrialsPerBlock;     % 2 * exptTrialsPerBlock = 64

if exptSession == 2
    preFrequency = 5; %5 - every 5th block will be a "pre-training" block. Block 5,10,15,20 
end

if testing == 1
    if exptSession == 1
        pracTrials = 8;
        maxBlocks = 10;
    else
        pracTrials = 20;
        maxBlocks = 5;
    end
else
    if exptSession == 1
        pracTrials = 8; %8;
        maxBlocks = 10; %1; % 10 * 48 = 480 pretraining trials
    else
        pracTrials = 20; %20; %increased number of practice trials for eye movement training
        maxBlocks = 29; %29; %1392 trials total. 1152 trials of post-training. 192 trials for each trial type/configuration combo (lateral D, midline T; lateral T, midline D; "junk" configurations)
    end
end

exptTrials = maxBlocks * exptTrialsBeforeBreak; 
% Session 1: 10 * exptTrialsBeforeBreak = 480;
% Session 2: 24 * exptTrialsBeforeBreak = 1152;


% Number of stimulus locations - have changed this so that there are 4 locations in the EEG session. The reason for doing this is that it will minimise the number of "lost" trials where the target and distractor are both lateral
stimLocs(1) = 6;       
stimLocs(2) = 4;

stim_size = 104;     % Matched to Expt 1. (165) Size of diamond stimulus. = Visual angle of 2.58 dva at 60cm from screen. Slightly larger than diameter of circles, but should be equal area of grey outline
circ_stim_size = 92; % Matched to Expt 1. (124) 3.3 degrees at 57cm
stim_pen = 8;      % Pen width of stimuli, 0.3 dva at 57cm
lineLength = 30;    % Matched to Expt 1. (56), 1.5 dva at 57cm. Line of target line segments
line_pen = 6;       % Matched to Expt 1. (10)Pen width of line segments

circ_diam = 200;    % Matched to Expt 1. (348) for 16:9 23 inch screen = 9.2 deg vis angle from centre. Diameter of imaginary circle on which stimuli are positioned
fix_size = 40;      % Matched to Expt 1. This is the side length of the fixation cross. Approx 1 dva

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

% Another offscreen window for the grey circle.
CircleTex(1) = Screen('OpenOffscreenWindow', MainWindow, black, [0 0 stim_size stim_size]);
Screen('FrameOval', CircleTex(1), gray, [stim_size/2-circ_stim_size/2 stim_size/2-circ_stim_size/2 stim_size/2+circ_stim_size/2 stim_size/2+circ_stim_size/2], stim_pen, stim_pen);      % Draw coloured target circle

for dd = 1:length(distract_col) %make diamonds in each distractor colour
    DiamondTex(dd+1) = Screen('OpenOffscreenWindow', MainWindow, black, [0 0 stim_size stim_size]);
    Screen('FillPoly', DiamondTex(dd+1), distract_col(dd,:), d_pts);
    Screen('FillPoly', DiamondTex(dd+1), black, small_d_pts);
    % And circles in each distractor colour
    CircleTex(dd+1) = Screen('OpenOffscreenWindow', MainWindow, black, [0 0 stim_size stim_size]);
    Screen('FrameOval', CircleTex(dd+1), distract_col(dd,:), [stim_size/2-circ_stim_size/2 stim_size/2-circ_stim_size/2 stim_size/2+circ_stim_size/2 stim_size/2+circ_stim_size/2], stim_pen, stim_pen);      % Draw coloured target circle
end

% Create an offscreen window, and draw the fixation cross in it - matched to expt 1.
fixationTex = Screen('OpenOffscreenWindow', MainWindow, black, [0 0 fix_size fix_size]);
Screen('DrawLine', fixationTex, white, 0, fix_size/2, fix_size, fix_size/2, 4);
Screen('DrawLine', fixationTex, white, fix_size/2, 0, fix_size/2, fix_size, 4);
%Screen('FillOval', fixationTex, white);

% Create a rect for the fixation cross
fixRect = [scr_centre(1) - fix_size/2    scr_centre(2) - fix_size/2   scr_centre(1) + fix_size/2   scr_centre(2) + fix_size/2];

% The oblique line segments need to have the same length as the vertical /
% horizontal target lines. Use Pythagoras to work out vertical and
% horizontal displacements of these lines (which are equal because lines
% are at 45 deg).

obliqueDisp = round(sqrt(lineLength * lineLength / 2));

% Create a matrix containing the six stimulus locations, equally spaced
% around an imaginary circle of diameter circ_diam
% Also create sets of points defining the positions of the oblique and
% target (horizontal / vertical) lines that appear inside each stimulus
stimCentre = zeros(stimLocs(1),4,2);
stimRect = zeros(stimLocs(1), 4, 2, 2);
lineRight = zeros(stimLocs(1),4,2);
lineLeft = zeros(stimLocs(1),4,2);
lineVert = zeros(stimLocs(1),4,2);
lineHorz = zeros(stimLocs(1),4,2);
lineOrientation = zeros(1,stimLocs(1));   % Used below; preallocating for speed

circRectVals = [-circ_stim_size/2 -circ_stim_size/2 circ_stim_size/2 circ_stim_size/2];
diamondRectVals = [-stim_size/2 -stim_size/2 stim_size/2 stim_size/2];


for i = 0 : stimLocs(1) - 1    % Define rects for stimuli and line segments
    stimCentre(i+1,:,1) = [scr_centre(1) - circ_diam * sin(i*2*pi/stimLocs(1))   scr_centre(2) - circ_diam * cos(i*2*pi/stimLocs(1))  scr_centre(1) - circ_diam * sin(i*2*pi/stimLocs(1))  scr_centre(2) - circ_diam * cos(i*2*pi/stimLocs(1))];
    lineVert(i+1,:,1) = [stimCentre(i+1,1,1) stimCentre(i+1,2,1) - lineLength/2 stimCentre(i+1,1,1) stimCentre(i+1,2,1)+lineLength/2];
    lineHorz(i+1,:,1) = [stimCentre(i+1,1,1) - lineLength/2 stimCentre(i+1,2,1) stimCentre(i+1,1,1)+lineLength/2 stimCentre(i+1,2,1)];
    lineRight(i+1,:,1) = [stimCentre(i+1,1,1) - obliqueDisp/2   stimCentre(i+1,2,1) + obliqueDisp/2   stimCentre(i+1,1,1) + obliqueDisp/2   stimCentre(i+1,2,1) - obliqueDisp/2];
    lineLeft(i+1,:,1) = [stimCentre(i+1,1,1) - obliqueDisp/2   stimCentre(i+1,2,1) - obliqueDisp/2   stimCentre(i+1,1,1) + obliqueDisp/2   stimCentre(i+1,2,1)  + obliqueDisp/2];
    
    stimRect(i+1,:,1,1) = stimCentre(i+1,:,1)+circRectVals; %stimRect(:,:,1,1) has all the rects for the circle stimuli in the pre-training blocks
    stimRect(i+1,:,2,1) = stimCentre(i+1,:,1)+diamondRectVals; %stimRect(:,:,2,1) has all the rects for the diamond stimuli in the pre-training blocks
    
    %     targetRect(i+1,:) = [scr_centre(1) - circ_diam * sin(i*2*pi/stimLocs) - stim_size / 2   scr_centre(2) - circ_diam * cos(i*2*pi/stimLocs) - stim_size / 2   scr_centre(1) - circ_diam * sin(i*2*pi/stimLocs) + stim_size / 2   scr_centre(2) - circ_diam * cos(i*2*pi/stimLocs) + stim_size / 2];
    %     circleRect(i+1,:) = [scr_centre(1) - circ_diam * sin(i*2*pi/stimLocs) - circ_stim_size / 2   scr_centre(2) - circ_diam * cos(i*2*pi/stimLocs) - circ_stim_size / 2   scr_centre(1) - circ_diam * sin(i*2*pi/stimLocs) + circ_stim_size / 2   scr_centre(2) - circ_diam * cos(i*2*pi/stimLocs) + circ_stim_size / 2];
    %     lineVert(i+1,:) = [targetRect(i+1,1) + stim_size/2   targetRect(i+1,2) + (stim_size-lineLength)/2    targetRect(i+1,1) + stim_size/2    targetRect(i+1,2) + stim_size/2 + lineLength/2];
    %     lineHorz(i+1,:) = [targetRect(i+1,1) + (stim_size-lineLength)/2   targetRect(i+1,2) + stim_size/2    targetRect(i+1,1) + stim_size/2 + lineLength/2    targetRect(i+1,2) + stim_size/2];  
end

for i = 0 : stimLocs(2) - 1
    stimCentre(i+1,:,2) = [scr_centre(1) - circ_diam * sin(i*2*pi/stimLocs(2))   scr_centre(2) - circ_diam * cos(i*2*pi/stimLocs(2))  scr_centre(1) - circ_diam * sin(i*2*pi/stimLocs(2))  scr_centre(2) - circ_diam * cos(i*2*pi/stimLocs(2))];
    lineVert(i+1,:,2) = [stimCentre(i+1,1,2) stimCentre(i+1,2,2) - lineLength/2 stimCentre(i+1,1,2) stimCentre(i+1,2,2)+lineLength/2];
    lineHorz(i+1,:,2) = [stimCentre(i+1,1,2) - lineLength/2 stimCentre(i+1,2,2) stimCentre(i+1,1,2)+lineLength/2 stimCentre(i+1,2,2)];
    lineRight(i+1,:,2) = [stimCentre(i+1,1,2) - obliqueDisp/2   stimCentre(i+1,2,2) + obliqueDisp/2   stimCentre(i+1,1,2) + obliqueDisp/2   stimCentre(i+1,2,2) - obliqueDisp/2];
    lineLeft(i+1,:,2) = [stimCentre(i+1,1,2) - obliqueDisp/2   stimCentre(i+1,2,2) - obliqueDisp/2   stimCentre(i+1,1,2) + obliqueDisp/2   stimCentre(i+1,2,2)  + obliqueDisp/2];
    
    stimRect(i+1,:,1,2) = stimCentre(i+1,:,2)+circRectVals; %stimRect(:,:,1,2) has all the rects for the circle stimuli in the EEG blocks
    stimRect(i+1,:,2,2) = stimCentre(i+1,:,2)+diamondRectVals; %stimRect(:,:,2,2) has all the rects for the diamond stimuli in the EEG blocks
end

% Create a full-size offscreen window that will be used for drawing all
% stimuli and targets (and fixation cross) into
stimWindow = Screen('OpenOffscreenWindow', MainWindow, black);


% Create a small offscreen window and draw the bonus multiplier into it
bonusTex = Screen('OpenOffscreenWindow', MainWindow, yellow, [0 0 bonusWindowWidth bonusWindowHeight]);
%Screen('FrameRect', bonusTex, yellow, [], 8);
Screen('TextSize', bonusTex, 40);
Screen('TextFont', bonusTex, 'Calibri');
Screen('TextStyle', bonusTex, 1);
DrawFormattedText(bonusTex, [num2str(bigMultiplier), ' x  bonus trial!'], 'center',  'center', black);

errorTex = Screen('OpenOffscreenWindow', MainWindow, black, [0 0 bonusWindowWidth bonusWindowHeight]);
Screen('TextSize', errorTex, 40);
Screen('TextFont', errorTex, 'Courier New');
Screen('TextStyle', errorTex, 1);
[~, ~, errorBox] = DrawFormattedText(errorTex, 'ERROR', 'center', 'center', white, [], [], [], 1.5);
errorBoxW = errorBox(3)-errorBox(1);
errorBoxH = errorBox(4)-errorBox(2);




if exptPhase == 0
    numTrials = pracTrials;
    DATA.practrialInfo = zeros(pracTrials, 14);    
    configArray = zeros(1, pracTrials);
    distractArray(1 : pracTrials) = 5;
    configArray(1:pracTrials) = ones(1,pracTrials)*5;
    configArrayPre = configArray;
    configArrayPost = configArray;
else
    numTrials = exptTrials;
        switch condition
            case 1
                valueLevels = [1 2]; % Only High and Low Distractors (i.e., LePelley style)
            case 2
                valueLevels = [3 4]; % Only High and Low Targets (i.e., Anderson style)
        end

    DATA.expttrialInfo = zeros(exptTrials, 22);
    
    distractArray = repmat(valueLevels,1,exptTrialsPerBlock/length(valueLevels));

    
    configArrayPre = ones(1,exptTrialsPerBlock)*5; %random configurations for pre-training blocks
    configArrayPost = [ones(1,exptTrialsPerBlock/3) ones(1,exptTrialsPerBlock/3)*2 ones(1,exptTrialsPerBlock/6)*3 ones(1,exptTrialsPerBlock/6)* 4]; % equal proportion of distractor lateral, target lateral trials, and "useless" trials (i.e., T lateral, D lateral; T midline, D midline). This is now different from Experiment 1 - Jan raised a potential issue to do with participants learning the statistical probabilities, thereby finding it easier to suppress certain locations where the distractor appeared more frequently.
end


totalPay = 0;

tempTrialOrder(:,:,1) = [distractArray' configArrayPre']; % pre-training trial order
tempTrialOrder(:,:,2) = [distractArray' configArrayPost']; % post-training trial order


if exptSession == 1
    blockType = 1; % all blocks are pre-training blocks
else
    blockType = 2; %first block is a post-training block, every 5th block will be a pre-training block
end

shuffled_trialOrder = shuffleTrialorder(tempTrialOrder(:,:,blockType), exptPhase);   % Calls a function to shuffle the first block of trials

shuffled_distractArray = shuffled_trialOrder(:,1);
shuffled_configArray = shuffled_trialOrder(:,2);

trialCounter = 0;
block = 1;
trials_since_break = 0;

%  NEED TO CHECK THAT THIS IS ACCURATE 27/07/18
rightPos = 4; %these values are only accurate for the EEG blocks (with 4 stimulus locations)
leftPos = 2;
midlinePos = [1 3];


RestrictKeysForKbCheck([KbName('4'), KbName('5')]);   % Only accept keypresses from numpad keys 4 and 5. This is changed so that participants can sit further away from the monitor and prevent lateralised motor effects.

WaitSecs(initialPause);

VBLTime = zeros(1,numTrials);
StimOnsetTime = zeros(1,numTrials);
FlipTime = zeros(1,numTrials);
Missed = zeros(1,numTrials);

for trial = 1 : numTrials

    switch blockType
    case 1
        rightPos = [5 6];
        leftPos = [2 3];
        midlinePos = [1 4];
    case 2
        %  NEED TO CHECK THAT THIS IS ACCURATE 27/07/18
        rightPos = 4; %these values are only accurate for the EEG blocks (with 4 stimulus locations)
        leftPos = 2;
        midlinePos = [1 3];
    end

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
    
    if blockType == 1 % if a pre-training trial (all of session 1 or pre-training blocks of session 2)
        singletonType = randi(2); %randomly determine whether diamond or circle target
    else
        singletonType = 1;
    end
    
    switch shuffled_configArray(trialCounter)
        case 1 %lateral target, midline distractor
            availTargetPos = [leftPos rightPos];
            targetLoc = availTargetPos(randi(length(availTargetPos)));
            availDistractorPos = midlinePos;            
        case 2 %lateral distractor, midline target
            availTargetPos = [midlinePos];
            targetLoc = availTargetPos(randi(length(availTargetPos)));
            availDistractorPos = [leftPos rightPos];
        case 3 % midline target, midline distractor
            availTargetPos = midlinePos;
            targetLoc = availTargetPos(randi(length(availTargetPos)));
            availDistractorPos = availTargetPos;
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
            availTargetPos = 1:stimLocs(blockType);
            targetLoc = availTargetPos(randi(length(availTargetPos)));
            if distractType > 2 && distractType < 5 %target = distractor
                availDistractorPos = targetLoc;
            elseif distractType == 5
                if condition == 2 && exptSession == 1 % if Anderson style, show coloured targets during practice for Session 1, but not Session 2.
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
    
    for i = 1 : stimLocs(blockType)
        if singletonType == 1 %draw grey circles
            Screen('FrameOval', stimWindow, gray, stimRect(i,:,1, blockType), stim_pen, stim_pen);       % Draw stimulus circles
        else %draw grey squares
            Screen('DrawTexture', stimWindow, DiamondTex(1), [], stimRect(i,:,2, blockType));
        end
    end
   
    if distractLoc ~= targetLoc %if distractor /= target
        if singletonType == 1
            Screen('DrawTexture', stimWindow, CircleTex(distractType+1), [], stimRect(distractLoc,:,2, blockType));      % Draw distractor circle
        else
            Screen('DrawTexture', stimWindow, DiamondTex(distractType+1), [], stimRect(distractLoc,:,2, blockType)); %draw distractor diamond
        end
    end
    
    for i = 1 : stimLocs(blockType)
        lineOrientation(i) = round(rand);
        if lineOrientation(i) == 0
            Screen('DrawLine', stimWindow, white, lineLeft(i,1,blockType), lineLeft(i,2,blockType), lineLeft(i,3,blockType), lineLeft(i,4,blockType), line_pen);
        else
            Screen('DrawLine', stimWindow, white, lineRight(i,1,blockType), lineRight(i,2,blockType), lineRight(i,3,blockType), lineRight(i,4,blockType), line_pen);
        end
    end
    
    if distractLoc ~= targetLoc %if distractor /= target
        if singletonType == 1
            Screen('FillRect', stimWindow, black, stimRect(targetLoc,:,2, blockType));
            Screen('DrawTexture', stimWindow, DiamondTex(1), [], stimRect(targetLoc,:,2, blockType)); %draw diamond target
        else
            Screen('FillRect', stimWindow, black, stimRect(targetLoc,:,2, blockType));
            Screen('DrawTexture', stimWindow, CircleTex(1), [], stimRect(targetLoc,:,2, blockType)); %draw circle target
        end
    else
        if singletonType == 1
            Screen('FillRect', stimWindow, black, stimRect(targetLoc,:,2, blockType));
            Screen('DrawTexture', stimWindow, DiamondTex(distractType+1), [], stimRect(targetLoc,:,2, blockType)); %draw diamond coloured target
        else
            Screen('FillRect', stimWindow, black, stimRect(targetLoc,:,2, blockType));
            Screen('DrawTexture', stimWindow, CircleTex(distractType+1), [], stimRect(targetLoc, :, 2, blockType)); %draw circle coloured target
        end
    end
    
    if targetType == 1
        Screen('DrawLine', stimWindow, white, lineHorz(targetLoc,1,blockType), lineHorz(targetLoc,2,blockType), lineHorz(targetLoc,3, blockType), lineHorz(targetLoc,4,blockType), line_pen);
    else
        Screen('DrawLine', stimWindow, white, lineVert(targetLoc,1,blockType), lineVert(targetLoc,2,blockType), lineVert(targetLoc,3, blockType), lineVert(targetLoc,4, blockType), line_pen);
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
            %triggerOn = triggerOn + 200; %trigger is 200 for all practice trials
        elseif exptPhase == 1
            if blockType == 2 %if post-training (EEG) block
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
    
    triggerOn
    %Now saving a bunch of timestamps for the stimulus presentation. This
    %allows us to check for timing issues from the PTB end
    [VBLTime(trial) StimOnsetTime(trial) FlipTime(trial) Missed(trial)] = Screen(MainWindow, 'Flip', fixOn + (waitframes-0.5) * ifi); 
    if runEEG == 1; outp(address, triggerOn); WaitSecs(.002); outp(address, 0); end % Send ON trigger
    
    st = VBLTime(trial); %record start time when stimuli are presented
    
     %image = Screen('GetImage', MainWindow, [scr_centre(1)-450 scr_centre(2)-450 scr_centre(1)+450 scr_centre(2)+450] );
     
    % if singletonType == 1
    %     if distractLoc == targetLoc
    %         imwrite(image, 'exampleDiamondTargetColoured.jpg') %400 x 400
    %     else
    %        imwrite(image, 'exampleDiamondTarget.jpg')
    %     end
    % else
    %    if distractLoc == targetLoc
    %        imwrite(image, 'exampleCircleTargetColoured.jpg') 
    %    else
    %        imwrite(image, 'exampleCircleTarget.jpg')
    %    end
    % end
    
    %%% FOR SCREENSHOTS
    
        % image = Screen('GetImage', MainWindow);
    
        
        % imwrite(image, 'sess2Image.png');
       
    
    Screen('DrawTexture', MainWindow, fixationTex, [], fixRect);

    if testing == 1
        Screen(MainWindow, 'Flip', st + .1);
        et = WaitSecs(0.45);
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
        while KbCheck; end %this should catch anybody holding down the button, essentially waits until all keys are released
        keyIsDown = 0;
        timeout = 0;
        searchDisplayRemoved = 0;
        while keyIsDown == 0
            timeoutCheck = GetSecs;
            [keyIsDown, et, keyCode, deltasecs] = KbCheck; %replaced KbWait with this, as KbWait checks the keyboard every 5 ms - not great for RT differences
            if timeoutCheck - st > timeoutDuration
                timeout = 1;
                break;
            elseif timeoutCheck - st > .1 && searchDisplayRemoved == 0 && blockType == 2 && shortDisplayVersion == 1
                Screen(MainWindow, 'Flip');
                searchDisplayRemoved = 1;
            end

        
        end
        %[keyCode, et, timeout] = accKbWait(st, timeoutDuration);
        keyCodePressed = find(keyCode, 1, 'first');
    end
    
    Priority(standardPriority); %Revert to standard priority level for less important stuff
  
    if keyCodePressed == 100
        5
        if runEEG == 1; outp(address, 205); WaitSecs(.002); outp(address, 0);end %left response trigger
    elseif keyCodePressed == 101
        6
        if runEEG == 1; outp(address, 206);WaitSecs(.002); outp(address, 0); end %right response trigger
    else
        7
        if runEEG == 1; outp(address, 207);WaitSecs(.002); outp(address, 0); end %no response trigger
    end
    
    keyPressed = KbName(keyCodePressed); %Get the name of the key that was pressed
    
    rt = 1000 * (et - st); %response time in ms
    
    correct = 0;
    
    if timeout == 1  % No key pressed (i.e. timeout)
        trialPay = 0;
        Beeper;
        fbStr = 'TOO SLOW\n\nPlease try to respond faster';
        triggerFB = 207;
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
            
            if roundRT >= zeroPayRT || blockType == 2 % only reward participants on pre-training blocks
                trialPay = 0;
            else
                trialPay = round((zeroPayRT - roundRT)/10) * winMultiplier(distractType); % Changed so that number of points given is (1000-RT)/10 x Multiplier
            end
            
            if winMultiplier(distractType) == bigMultiplier
                if blockType == 1
                    Screen('DrawTexture', MainWindow, bonusTex, [], [scr_centre(1)-bonusWindowWidth/2   bonusWindowTop   scr_centre(1)+bonusWindowWidth/2    bonusWindowTop+bonusWindowHeight]);
                end
            end
            
            
            if correct == 0
                totalPay = totalPay - trialPay;
                if blockType == 1
                    fbStr = ['Lose ', char(nf.format(trialPay)), ' points'];
                    Screen('DrawTexture', MainWindow, errorTex, errorBox, [scr_centre(1)-50-errorBoxW   scr_centre(2)-errorBoxH/2   scr_centre(1)-50    scr_centre(2)+errorBoxH/2]);
                    Screen('DrawTexture', MainWindow, errorTex', errorBox, [scr_centre(1)+50    scr_centre(2)-errorBoxH/2   scr_centre(1)+50+errorBoxW     scr_centre(2)+errorBoxH/2]);
                else
                    fbStr = 'ERROR';
                end
                trialPay = -trialPay;   % This is so it records correctly in the data file
                triggerFB = 209;
            elseif correct == 1
                totalPay = totalPay + trialPay;
                if blockType == 1
                    fbStr = ['+', char(nf.format(trialPay)), ' points'];
                else
                    fbStr = 'correct';
                end
                triggerFB = 208;
            end
            
%             Screen('TextSize', MainWindow, 32);
%             if blockType == 1
%                 totalStr = format_payStr(totalPay + starting_total_points);
%             else
%                 totalStr = '???  total';
%             end
%             DrawFormattedText(MainWindow, totalStr, 'center', scr_centre(2)+150, white);   
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
    triggerFB
    Screen('Flip', MainWindow); if runEEG == 1; outp(address, triggerFB); WaitSecs(.002); outp(address, 0); end
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
        DATA.practrialInfo(trial,:) = [exptSession, trial, blockType, targetLoc, targetType, distractLoc, distractType, singletonType, shuffled_configArray(trialCounter), timeout, correct, rt, fix_pause, triggerOn];
    else
        DATA.expttrialInfo(trial,:) = [exptSession, block, blockType, trial, trialCounter, trials_since_break, targetLoc, targetType, distractLoc, distractType, singletonType, shuffled_configArray(trialCounter), timeout, correct, rt, roundRT, trialPay, totalPay, fix_pause, targetHem, distractHem, triggerOn];
        DATA.ifi = ifi;
        DATA.VBLTime = VBLTime;
        DATA.StimOnsetTime = StimOnsetTime;
        DATA.FlipTime = FlipTime;
        DATA.Missed = Missed;
        if mod(trial, exptTrialsPerBlock) == 0
            block = block + 1;
            if exptSession == 2
                if  rem(block, preFrequency) == 0
                    blockType = 1; %next block type is a pretraining block
                else
                    blockType = 2; %next block type is a post-training block
                end
            else
                blockType = 1;
            end
            shuffled_trialOrder = shuffleTrialorder(tempTrialOrder(:,:,blockType), exptPhase);   % Calls a function to shuffle trials
            shuffled_distractArray = shuffled_trialOrder(:,1);
            shuffled_configArray = shuffled_trialOrder(:,2);
            trialCounter = 0;
        end
        
        if (mod(trial, exptTrialsBeforeBreak) == 0 && trial ~= numTrials);
            save(datafilename, 'DATA');
            take_a_break(blockType, breakDuration, initialPause, totalPay, block, maxBlocks);
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




function take_a_break(blockType, breakDur, pauseDur, currentTotal, nextBlockNum, maxBlockNum)

global MainWindow white address runEEG exptSession starting_total_points nf yellow testing condition

if exptSession == 2
    if blockType == 1 %next block is a pre-training block
        breakText = ['Time for a break\n\nSit back, relax for a moment! The experimenter will restart the task in a few moments\n\nIn the next block, the target is the UNIQUE SHAPE.'...
            '\n\nYou WILL be earning points in the next block.\n\nRemember that the faster you make correct responses, the more you will earn in this task!'];
        totalText = ['\n\nSo far you have earned ' char(nf.format(currentTotal + starting_total_points)) ' points.'];
    else %next block is a post-training block
        breakText = ['Time for a break\n\nSit back, relax for a moment! You will be able to carry on in ', num2str(breakDur),' seconds\n\nIn the next block, the target is the DIAMOND SHAPE.'...
            '\n\nYou will not be earning points in the next block. But you should try your best to respond quickly.'];
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

Screen(MainWindow, 'Flip'); if runEEG == 1; outp(address,254); WaitSecs(.002); outp(address, 0); end %send break trigger

if blockType == 1
    WaitSecs(breakDur);
    RestrictKeysForKbCheck(KbName('t'));   % Only accept "t", for experimenter to continue
    DrawFormattedText(MainWindow, 'Please place your right index and middle fingers on the 4 and 5 keys,\n\nThe experimenter will restart the task in a few moments', 'center', 'center' , white);
    Screen(MainWindow, 'Flip');
else
    WaitSecs(breakDur);
    RestrictKeysForKbCheck(KbName('Space')); %Only accept "spacebar", for participant to continue
    DrawFormattedText(MainWindow, 'Please place your right index and middle fingers on the 4 and 5 keys,\n\nand press spacebar to continue', 'center', 'center' , white);
    Screen(MainWindow, 'Flip');
end

if testing ~= 1
    KbWait([], 2);
end
if runEEG == 1; outp(address,255); WaitSecs(.002); outp(address, 0); end %send continue after break trigger
Screen(MainWindow, 'Flip');

RestrictKeysForKbCheck([KbName('4'), KbName('5')]);   % Only accept keypresses from keys 4 and 5

WaitSecs(pauseDur);

end