
function totalPay = runTrials(exptPhase)

global MainWindow scr_centre DATA datafilename
global keyCounterbal starting_total_points
global distract_col
global white black gray yellow
global bigMultiplier smallMultiplier
global zeroPayRT
global stim_size stim_pen
global address exptSession nf
global runEEG



timeoutDuration = 2;     % 2 timeout duration
iti = 0.5;            % 0.5
correctFBDuration = [0.7, 1];       %[0.001, 0.001]    [0.7, 1]  Practice phase feedback duration  1 Main task feedback duration
errorFBDuration = [0.7, 1.5];       %[0.001, 0.001]      [0.7, 1.5]  Practice phase feedback duration  1.5 Main task feedback duration

minFixation = 0.8;         % 0.8   Minimum fixation duration
maxFixation = 1.0;         % 1.0   Maximum fixation duration

initialPause = 3;   % 3 ***
breakDuration = 15;  % 15 ***

exptTrialsPerBlock = 32;    % 32. This is used to ensure people encounter the right number of each of the different types of distractors.

exptTrialsBeforeBreak = 2 * exptTrialsPerBlock;     % 2 * exptTrialsPerBlock = 64

pracTrials = 8;    % 8
if exptSession == 1
    exptTrials = 8 * exptTrialsBeforeBreak; % 8 * exptTrialsBeforeBreak = 512;
else
    exptTrials = 16 * exptTrialsBeforeBreak;    % 16 * exptTrialsBeforeBreak = 1024
end

stimLocs = 6;       % Number of stimulus locations
stim_size = 104;     % 104 Size of diamond stimulus. = Visual angle of 2.58 dva at 60cm from screen. Slightly larger than diameter of circles, but should be equal area of grey outline
circ_stim_size = 92;
stim_pen = 8;      % Pen width of stimuli
lineLength = 30;    % Line of target line segments
line_pen = 6;       % Pen width of line segments

circ_diam = 200;    % 200 for 16:9 24 inch screen = 4.97 deg vis angle from centre. Diameter of imaginary circle on which stimuli are positioned
fix_size = 40;      % This is the side length of the fixation cross. Approx 1 dva

bonusWindowWidth = 400;
bonusWindowHeight = 100;
bonusWindowTop = 230;

roundRT = 0;

winMultiplier = zeros(2);
winMultiplier(1) = bigMultiplier;         % Common distractor associated with big win
winMultiplier(2) = smallMultiplier;     % Common distractor associated with small win

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
diamondTex = Screen('OpenOffscreenWindow', MainWindow, black, [0 0 stim_size stim_size]);
Screen('FillPoly', diamondTex, gray, d_pts);
Screen('FillPoly', diamondTex, black, small_d_pts);

% Create an offscreen window, and draw the fixation cross in it.
fixationTex = Screen('OpenOffscreenWindow', MainWindow, black, [0 0 fix_size fix_size]);
Screen('DrawLine', fixationTex, white, 0, fix_size/2, fix_size, fix_size/2, 4);
Screen('DrawLine', fixationTex, white, fix_size/2, 0, fix_size/2, fix_size, 4);


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
targetRect = zeros(stimLocs,4);
circleRect = zeros(stimLocs, 4);
lineRight = zeros(stimLocs,4);
lineLeft = zeros(stimLocs,4);
lineVert = zeros(stimLocs,4);
lineHorz = zeros(stimLocs,4);
lineOrientation = zeros(1,stimLocs);   % Used below; preallocating for speed

for i = 0 : stimLocs - 1    % Define rects for stimuli and line segments
    targetRect(i+1,:) = [scr_centre(1) - circ_diam * sin(i*2*pi/stimLocs) - stim_size / 2   scr_centre(2) - circ_diam * cos(i*2*pi/stimLocs) - stim_size / 2   scr_centre(1) - circ_diam * sin(i*2*pi/stimLocs) + stim_size / 2   scr_centre(2) - circ_diam * cos(i*2*pi/stimLocs) + stim_size / 2];
    circleRect(i+1,:) = [scr_centre(1) - circ_diam * sin(i*2*pi/stimLocs) - circ_stim_size / 2   scr_centre(2) - circ_diam * cos(i*2*pi/stimLocs) - circ_stim_size / 2   scr_centre(1) - circ_diam * sin(i*2*pi/stimLocs) + circ_stim_size / 2   scr_centre(2) - circ_diam * cos(i*2*pi/stimLocs) + circ_stim_size / 2];
    lineVert(i+1,:) = [targetRect(i+1,1) + stim_size/2   targetRect(i+1,2) + (stim_size-lineLength)/2    targetRect(i+1,1) + stim_size/2    targetRect(i+1,2) + stim_size/2 + lineLength/2];
    lineHorz(i+1,:) = [targetRect(i+1,1) + (stim_size-lineLength)/2   targetRect(i+1,2) + stim_size/2    targetRect(i+1,1) + stim_size/2 + lineLength/2    targetRect(i+1,2) + stim_size/2];
    
    lineRight(i+1,:) = [targetRect(i+1,1) + (stim_size-obliqueDisp)/2   targetRect(i+1,2) + stim_size/2 + obliqueDisp/2   targetRect(i+1,1) + stim_size/2 + obliqueDisp/2   targetRect(i+1,2) + (stim_size-obliqueDisp)/2];
    lineLeft(i+1,:) = [targetRect(i+1,1) + (stim_size-obliqueDisp)/2   targetRect(i+1,2) + (stim_size-obliqueDisp)/2   targetRect(i+1,1) + stim_size/2 + obliqueDisp/2   targetRect(i+1,2) + stim_size/2 + obliqueDisp/2];
end


% Create a full-size offscreen window that will be used for drawing all
% stimuli and targets (and fixation cross) into
stimWindow = Screen('OpenOffscreenWindow', MainWindow, black);


% Create a small offscreen window and draw the bonus multiplier into it
bonusTex = Screen('OpenOffscreenWindow', MainWindow, yellow, [0 0 bonusWindowWidth bonusWindowHeight]);
%Screen('FrameRect', bonusTex, yellow, [], 8);
Screen('TextSize', bonusTex, 40);
Screen('TextFont', bonusTex, 'Calibri');
Screen('TextStyle', bonusTex, 0);
DrawFormattedText(bonusTex, [num2str(bigMultiplier), ' x  bonus trial!'], 'center', 15, black);




if exptPhase == 0
    numTrials = pracTrials;
    configTypes = 4;
    DATA.practrialInfo = zeros(pracTrials, 11);
    
    distractArray = zeros(1, pracTrials);
    configArray = zeros(1, pracTrials);
    distractArray(1 : pracTrials) = 5;
    configArray(1:pracTrials) = randi(configTypes,[1,pracTrials]);
    
else
    numTrials = exptTrials;
    configTypes = 2; %Distractor Lateral, Target Midline. Target Lateral, Distractor Midline.
    valueLevels = 2;
    DATA.expttrialInfo = zeros(exptTrials, 17);
    
    distractArray = zeros(1,exptTrialsPerBlock);
    tempDistractArray = [ones(1,(exptTrialsPerBlock/configTypes)/valueLevels) repmat(2,1,(exptTrialsPerBlock/configTypes)/valueLevels)];
    distractArray(1 : exptTrialsPerBlock) = repmat(tempDistractArray,1,configTypes);
    
    configArray = zeros(1,exptTrialsPerBlock);
    configArray(1 : exptTrialsPerBlock / configTypes) = 1; %lateral target, midline distractor
    configArray(1 + exptTrialsPerBlock / configTypes: 2 * exptTrialsPerBlock / configTypes) = 2; %lateral distractor, midline target
    
    
    
end

totalPay = 0;

tempTrialOrder = [distractArray' configArray'];
shuffled_trialOrder = shuffleTrialorder(tempTrialOrder, exptPhase);   % Calls a function to shuffle trials
shuffled_distractArray = shuffled_trialOrder(:,1);
shuffled_configArray = shuffled_trialOrder(:,2);

trialCounter = 0;
block = 1;
trials_since_break = 0;

rightPos = [5 6];
leftPos = [2 3];
midlinePos = [1 4];

RestrictKeysForKbCheck([KbName('c'), KbName('m')]);   % Only accept keypresses from keys C and M

WaitSecs(initialPause);

for trial = 1 : numTrials
    
    targetHem = 0; %used to track the hemifield of the target, 1 = left, 2 = right.
    distractHem = 0; %used to track the hemifield of the distractor, 1 = left, 2 = right.
    
    trialCounter = trialCounter + 1;    % This is used to set distractor type below; it can cycle independently of trial
    trials_since_break = trials_since_break + 1;
    
    switch shuffled_configArray(trialCounter)
        case 1 %lateral target, midline distractor
            availTargetPos = [leftPos rightPos];
            targetLoc = availTargetPos(randi(length(availTargetPos)));
            availDistractorPos = midlinePos;
        case 2 %lateral distractor, midline target
            availTargetPos = [midlinePos];
            targetLoc = availTargetPos(randi(length(availTargetPos)));
            availDistractorPos = [leftPos rightPos];
        case 3 % same side
            availTargetPos = [leftPos rightPos];
            targetLoc = availTargetPos(randi(length(availTargetPos)));
            if ismember(targetLoc, leftPos) == 1
                availDistractorPos = [leftPos];
            else
                availDistractorPos = [rightPos];
            end
        case 4 % opposite sides
            availTargetPos = [leftPos rightPos];
            targetLoc = availTargetPos(randi(length(availTargetPos)));
            if ismember(targetLoc, leftPos) == 1
                availDistractorPos = [rightPos];
            else
                availDistractorPos = [leftPos];
            end
    end
    
    switch targetLoc
        case {2, 3}
            targetHem = 1; %target on left
        case {5, 6}
            targetHem = 2; %target on right
        case {1, 4}
            targetHem = 3; %target on midline
    end
    
    distractLoc = targetLoc;
    while distractLoc == targetLoc
        distractLoc = availDistractorPos(randi(length(availDistractorPos)));
    end
    
    switch distractLoc
        case {2, 3}
            distractHem = 1; %distractor left
        case {5, 6}
            distractHem = 2; %distractor right
        case {1, 4}
            distractHem = 3; %distractor on midline
    end
    
    targetType = 1 + round(rand);   % Gives random number, either 1 or 2
    distractType = shuffled_distractArray(trialCounter);
    
    fix_pause = roundn(minFixation + rand*(maxFixation - minFixation), -1);    % Creates random fixation interval in range minFixation to maxFixation, rounded to 100ms
   
    Screen('FillRect', stimWindow, black);  % Clear the screen from the previous trial by drawing a black rectangle over the whole thing
    Screen('DrawTexture', stimWindow, fixationTex, [], fixRect); %draw fixation cross
    for i = 1 : stimLocs
        Screen('FrameOval', stimWindow, gray, circleRect(i,:), stim_pen, stim_pen);       % Draw stimulus circles
    end
    Screen('FrameOval', stimWindow, distract_col(distractType,:), circleRect(distractLoc,:), stim_pen, stim_pen);      % Draw distractor circle
    
    for i = 1 : stimLocs
        lineOrientation(i) = round(rand);
        if lineOrientation(i) == 0
            Screen('DrawLine', stimWindow, white, lineLeft(i,1), lineLeft(i,2), lineLeft(i,3), lineLeft(i,4), line_pen);
        else
            Screen('DrawLine', stimWindow, white, lineRight(i,1), lineRight(i,2), lineRight(i,3), lineRight(i,4), line_pen);
        end
    end
    
    Screen('DrawTexture', stimWindow, diamondTex, [], targetRect(targetLoc,:));
    
    if targetType == 1
        Screen('DrawLine', stimWindow, white, lineHorz(targetLoc,1), lineHorz(targetLoc,2), lineHorz(targetLoc,3), lineHorz(targetLoc,4), line_pen);
    else
        Screen('DrawLine', stimWindow, white, lineVert(targetLoc,1), lineVert(targetLoc,2), lineVert(targetLoc,3), lineVert(targetLoc,4), line_pen);
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%% STIMULUS EVENT CODES %%%%%%%%%%%%%%%%%%%%%%%%%
    %%%                                                                 %%%
    %%% Hundreds Place %%%
    % 0 = Low Val Trial
    % 1 = High Val Trial
    % 2 = Practice Trial
    %%% Tens Place %%%
    % 1 = Left Side Target, Left Side Distractor
    % 2 = Left Side Target, Right Side Distractor
    % 3 = Left Side Target, Midline Distractor
    % 4 = Right Side Target, Left Side Distractor
    % 5 = Right Side Target, Right Side Distractor
    % 6 = Right Side Target, Midline Distractor
    % 7 = Midline Target, Left Side Distractor
    % 8 = Midline Target, Right Side Distractor
    %%% Ones Place %%%
    % 1 = Left Response correct
    % 2 = Right Response correct
    %%% EG - 122 = High Val, LS Target, RS Distractor, R resp correct
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
    
    triggerOn = 0;
    triggerFB = 0;
    if exptPhase == 0
        triggerOn = triggerOn + 200; %trigger is 200 for all practice trials
    elseif exptPhase == 1
        if distractType == 1
            triggerOn = triggerOn + 100;
        end
        if targetHem == 1
            if distractHem == 1
                triggerOn = triggerOn + 10;
            elseif distractHem == 2
                triggerOn = triggerOn + 20;
            elseif distractHem == 3
                triggerOn = triggerOn + 30;
            end
        elseif targetHem == 2
            if distractHem == 1
                triggerOn = triggerOn + 40;
            elseif distractHem == 2
                triggerOn = triggerOn + 50;
            elseif distractHem == 3
                triggerOn = triggerOn + 60;
            end
        elseif targetHem == 3
            if distractHem == 1
                triggerOn = triggerOn + 70;
            elseif distractHem == 2
                triggerOn = triggerOn + 80;
            end
        end
        if targetType == 1
            triggerOn = triggerOn + 1;
        elseif targetType == 2
            triggerOn = triggerOn + 2;
        end
    end
    
    Screen('FillRect',MainWindow, black);
    Screen('DrawTexture', MainWindow, fixationTex, [], fixRect);
    Screen(MainWindow, 'Flip');     % Clear screen
    WaitSecs(iti);
    
    Screen('DrawTexture', MainWindow, fixationTex, [], fixRect);
    Screen(MainWindow, 'Flip');     % Present fixation cross
    WaitSecs(fix_pause);
     
    Screen('DrawTexture', MainWindow, stimWindow);
    
    st = Screen(MainWindow, 'Flip'); if runEEG == 1; outp(address, triggerOn); end % Send ON trigger    % Present stimuli, and record start time (st) when they are presented.
    
    image = Screen('GetImage', MainWindow);
    
    if targetHem == 1
        imwrite(image, 'targetImage.png');
    elseif distractHem == 1
        imwrite(image, 'distractImage.png');
    end
    
    
    
    [keyCode, et, timeout] = accKbWait(st, timeoutDuration);  
     
    keyCodePressed = find(keyCode, 1, 'first');
    if keyCodePressed == 67
            if runEEG == 1; outp(address, 5); end %left response trigger
    elseif keyCodePressed == 77
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
        
        if keyPressed == 'c'
            if keyCounterbal == targetType     % If C = horizontal and line is horizontal, or if C = vertical and line is vertical
                correct = 1;
                fbStr = 'correct';
            end
            
        elseif keyPressed == 'm'
            if keyCounterbal ~= targetType     % If M = horizontal and line is horizontal, or if M = vertical and line is vertical
                correct = 1;
                fbStr = 'correct';
            end
            
        end
        
        if exptPhase == 1       % If this is NOT practice
            
            roundRT = round(rt);    % Round RT to nearest integer
            
            if roundRT >= zeroPayRT
                trialPay = 0;
            else
                trialPay = (zeroPayRT - roundRT) * winMultiplier(distractType); % Changed so that number of points given is 1000-RT x Multiplier
            end
            
            if winMultiplier(distractType) == bigMultiplier
                Screen('DrawTexture', MainWindow, bonusTex, [], [scr_centre(1)-bonusWindowWidth/2   bonusWindowTop   scr_centre(1)+bonusWindowWidth/2    bonusWindowTop+bonusWindowHeight]);
            end
            
            
            if correct == 0
                totalPay = totalPay - trialPay;
                fbStr = ['Lose ', char(nf.format(trialPay)), ' points'];
                %Beeper;
                Screen('TextSize', MainWindow, 40);
                DrawFormattedText(MainWindow, 'ERROR', 'center', bonusWindowTop + bonusWindowHeight + 80 , white);
                trialPay = -trialPay;   % This is so it records correctly in the data file
                triggerFB = 9;
                
            elseif correct == 1
                totalPay = totalPay + trialPay;
                fbStr = ['+', char(nf.format(trialPay)), ' points'];
                triggerFB = 8;
            end
            
            Screen('TextSize', MainWindow, 26);
            DrawFormattedText(MainWindow, format_payStr(totalPay + starting_total_points), 'center', 740, white);
            
        end
    end
    
    
    Screen('TextSize', MainWindow, 40);
    DrawFormattedText(MainWindow, fbStr, 'center', scr_centre(2) + 75, yellow);
    Screen('DrawTexture', MainWindow, fixationTex, [], fixRect);
    
    
    Screen('Flip', MainWindow); if runEEG == 1; outp(address, triggerFB); end
    if correct == 0
        WaitSecs(correctFBDuration(exptPhase + 1));
    else
        WaitSecs(errorFBDuration(exptPhase + 1));
    end
    
    Screen('DrawTexture', MainWindow, fixationTex, [], fixRect);
    Screen('Flip', MainWindow);
    WaitSecs(iti);
    
    
    if exptPhase == 0
        DATA.practrialInfo(trial,:) = [exptSession, trial, targetLoc, targetType, distractLoc, distractType, shuffled_configArray(trialCounter), timeout, correct, rt, fix_pause];
    else
        DATA.expttrialInfo(trial,:) = [exptSession, block, trial, trialCounter, trials_since_break, targetLoc, targetType, distractLoc, distractType, shuffled_configArray(trialCounter), timeout, correct, rt, roundRT, trialPay, totalPay, fix_pause];
        
        if mod(trial, exptTrialsPerBlock) == 0
            shuffled_trialOrder = shuffleTrialorder(tempTrialOrder, exptPhase);   % Calls a function to shuffle trials
            shuffled_distractArray = shuffled_trialOrder(:,1);
            shuffled_configArray = shuffled_trialOrder(:,2);
            trialCounter = 0;
            block = block + 1;
        end
        
        if (mod(trial, exptTrialsBeforeBreak) == 0 && trial ~= numTrials);
            save(datafilename, 'DATA');
            take_a_break(breakDuration, initialPause);
            trials_since_break = 0;
        end
        
    end
    
    save(datafilename, 'DATA');
end


Screen('Close', diamondTex);
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
    aStr = ['-', char(nf.format(ii)), '  total'];
else
    aStr = [char(nf.format(ii)), '  total'];
end

end




function take_a_break(breakDur, pauseDur)

global MainWindow white address runEEG

DrawFormattedText(MainWindow, ['Time for a break\n\nSit back, relax for a moment! You will be able to carry on in ', num2str(breakDur),' seconds\n\n\nRemember that the faster you make correct responses, the more you will earn in this task!'], 'center', 'center', white, 50, [], [], 1.5);

Screen(MainWindow, 'Flip'); if runEEG == 1; outp(address,254); end %send break trigger
WaitSecs(breakDur);

RestrictKeysForKbCheck(KbName('Space'));   % Only accept spacebar

DrawFormattedText(MainWindow, 'Please place your index fingers on the C and M keys\n\nand press the spacebar when you are ready to continue', 'center', 'center' , white);
Screen(MainWindow, 'Flip');

KbWait([], 2);
if runEEG == 1; outp(address,255); end %send continue after break trigger
Screen(MainWindow, 'Flip');

RestrictKeysForKbCheck([KbName('c'), KbName('m')]);   % Only accept keypresses from keys C and M

WaitSecs(pauseDur);

end