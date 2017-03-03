
clear all

%Screen('Preference', 'SkipSyncTests', 2 );      % Skips the Psychtoolbox calibrations - REMOVE THIS WHEN RUNNING FOR REAL!
Screen('CloseAll');

Beeper;

clc;

addpath('functions');

global MainWindow scr_centre DATA datafilename
global keyCounterbal starting_total starting_total_points exptSession
global distract_col colourName
global white black gray yellow
global bigMultiplier smallMultiplier
global zeroPayRT oneMSvalue
global address nf runEEG

nf = java.text.DecimalFormat;

screenNum = 0;


zeroPayRT = 1000;       % 1000
fullPayRT = 500;        % 500


bigMultiplier = 10;    % Points multiplier for trials with high-value distractor
smallMultiplier = 1;   % Points multiplier for trials with low-value distractor

KbName('UnifyKeyNames');    % Important for some reason to standardise keyboard input across platforms / OSs.

% Initialize Cedrus reponse box and run it virtually on serial port 'COM5'
% handle = CedrusResponseBox('Open', 'COM5'); % the handle is a unique identifier for the Cedrus box
% CedrusResponseBox('FlushEvents', handle);
% dev = CedrusResponseBox('GetDeviceInfo', handle);

% Set up the parallel port for receiving the triggers
config_io;
address = hex2dec('378');

starting_total = 0;
starting_total_points = 0;
keyCounterbal = 1;

if exist('ExptData', 'dir') == 0
    mkdir('ExptData');
end

inputError = 1;

while inputError == 1
    inputError = 0;
    
    p_number = input('Participant number  ---> ');
    exptSession = input('Session number ---> ');
    
    datafilename = ['ExptData\CirclesEEGmultiDataP', num2str(p_number), 'S'];
    
    if exist([datafilename, num2str(exptSession), '.mat'], 'file') == 2
        disp(['Session ', num2str(exptSession), ' data for participant ', num2str(p_number),' already exist'])
        inputError = 1;
    end
    
    if exptSession > 1
        if exist([datafilename, num2str(exptSession - 1), '.mat'], 'file') == 0
            disp(['No session ', num2str(exptSession - 1), 'data for participant ', num2str(p_number)])
            inputError = 1;
        end
    end
       
end



if exptSession == 1
    colBalance = 0;
    while colBalance < 1 || colBalance > 2
        colBalance = input('Counterbalance (1-2)---> ');
    end

    p_age = input('Participant age ---> ');
    p_sex = 'a';
    while p_sex ~= 'm' && p_sex ~= 'f' && p_sex ~= 'M' && p_sex ~= 'F'
        p_sex = input('Participant gender (M/F) ---> ', 's');
    end

    p_hand = 'a';
    while p_hand ~= 'r' && p_hand ~= 'l' && p_hand ~= 'R' && p_hand ~= 'L'
        p_hand = input('Participant hand (R/L) ---> ','s');
    end
else
    
    load([datafilename, num2str(exptSession - 1), '.mat'])
    colBalance = DATA.counterbal;
    p_age = DATA.age;
    p_sex = DATA.sex;
    p_hand = DATA.hand;
    if isfield(DATA, 'bonusDollarsSoFar')
        starting_total = DATA.bonusDollarsSoFar;
        starting_total_points = DATA.bonusPointsSoFar;
    else
        starting_total = 0;
        starting_total_points = 0;
    end
   
    disp (['Age:  ', num2str(p_age)])
    disp (['Sex:  ', p_sex])
    disp (['Hand:  ', p_hand])
    
    y_to_continue = 'a';
    while y_to_continue ~= 'y' && y_to_continue ~= 'Y'
        y_to_continue = input('Is this OK? (y = continue, n = quit) --> ','s');
        if y_to_continue == 'n'
            Screen('CloseAll');
            clear all;
            error('Quitting program');
        end
    end
    
end
    

DATA.subject = p_number;
DATA.session = exptSession;
DATA.counterbal = colBalance;
DATA.age = p_age;
DATA.sex = p_sex;
DATA.hand = p_hand;
DATA.start_time = datestr(now,0);

if exptSession == 1
    runEEG = 0;
else
    runEEG = 1; %this should be 1 os that EEG triggers are sent in session 2
end

% generate a random seed using the clock, then use it to seed the random
% number generator
rng('shuffle');
randSeed = randi(30000);
DATA.rSeed = randSeed;
rng(randSeed);

datafilename = [datafilename, num2str(exptSession),'.mat'];

% Get screen resolution, and find location of centre of screen
[scrWidth, scrHeight] = Screen('WindowSize',screenNum);
res = [scrWidth scrHeight];
scr_centre = res / 2;



MainWindow = Screen(screenNum, 'OpenWindow', [], [0 0 1920 1080], 32);

DATA.frameRate = round(Screen(MainWindow, 'FrameRate'));

HideCursor;

Screen('Preference', 'DefaultFontName', 'Courier New');

Screen('TextSize', MainWindow, 34);
Screen('TextStyle', MainWindow, 1);

% now set colors
white = WhiteIndex(MainWindow);
black = BlackIndex(MainWindow);
gray = [115 115 115];
red = [225 0 0];
green = [0 143 0];
blue = [93 93 237];
yellow = [255 255 0];
Screen('FillRect',MainWindow, black);

distract_col = zeros(5,3);

distract_col(5,:) = yellow;       % Practice colour
if colBalance == 1
    distract_col(1,:) = red;      % High-value distractor colour
    distract_col(2,:) = blue;      % Low-value distractor colour
elseif colBalance == 2
    distract_col(1,:) = blue;
    distract_col(2,:) = red;
end

distract_col(3,:) = gray;
distract_col(4,:) = gray;

for i = 1 : 2
    if distract_col(i,:) == red
        colName = 'RED       ';           % All entries need to have the same length. We'll strip the blanks off later.
    elseif distract_col(i,:) == green
        colName = 'GREEN     ';
    elseif distract_col(i,:) == blue
        colName = 'BLUE      ';
    elseif distract_col(i,:) == yellow
        colName = 'YELLOW    ';
    end
    
    if i == 1
        colourName = char(colName);
    else
        colourName = char(colourName, colName);
    end
end

if runEEG == 1; outp(address, 1); end %start experiment trigger
initialInstructions;

%[~] = runTrials(0);     % Practice phase

save(datafilename, 'DATA');

if exptSession == 1
    DrawFormattedText(MainWindow, 'Please let the experimenter know\n\nyou are ready to continue', 'center', 'center' , white);
    Screen(MainWindow, 'Flip');

    RestrictKeysForKbCheck(KbName('t'));   % Only accept T key to continue
    KbWait([], 2);
end

exptInstructions;

bonus_points = runTrials(1);
if runEEG == 1; outp(address, 2); end %end experiment trigger

if exptSession == 2
    awareInstructions;
    awareTest;
end

bonus_payment = bonus_points * 0.0009; % convert points into cents at rate of 1 point = 0.0009 cents
bonus_payment = 10 * ceil(bonus_payment/10);        % ... round this value UP to nearest 10 cents
bonus_payment = bonus_payment / 100;    % ... then convert back to dollars

DATA.bonusSessionPoints = bonus_points;
DATA.bonusSessionDollars = bonus_payment;
DATA.bonusPointsSoFar = bonus_points + starting_total_points;
DATA.bonusDollarsSoFar = bonus_payment + starting_total;
DATA.end_time = datestr(now,0);

if exptSession == 2
    if bonus_payment + starting_total < 20
        actual_money = 20.10;
    else
        actual_money = bonus_payment + starting_total;
    end
    DATA.actual_money = actual_money;
end

save(datafilename, 'DATA');

if exptSession == 1
    finalStr = ['Session complete - please fetch the experimenter\n\nTotal bonus so far = $', num2str(bonus_payment + starting_total , '%0.2f')];
else
    finalStr = ['Experiment complete - please fetch the experimenter\n\nTotal bonus = $', num2str(actual_money , '%0.2f')];
end

DrawFormattedText(MainWindow, finalStr, 'center', 'center' , white);
Screen(MainWindow, 'Flip');

RestrictKeysForKbCheck(KbName('q'));   % Only accept Q key to quit
KbWait([], 2);


rmpath('functions');
Snd('Close');

%Screen('Preference', 'SkipSyncTests',0);
%CedrusResponseBox('Close', handle);
Screen('CloseAll');

clear all


