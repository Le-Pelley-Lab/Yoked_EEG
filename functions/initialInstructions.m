
function initialInstructions()

global keyCounterbal MainWindow white
global address runEEG exptSession condition

if runEEG == 1; outp(address,77); end %start of initial instructions trigger

instructStr1 = 'Each trial will start with a cross on the screen. This is to warn you that the trial is about to start, you should keep your eyes fixed on the cross. Then a set of shapes will appear; two examples are shown below.';
if keyCounterbal == 1
    word1 = 'HORIZONTAL';
    word2 = 'VERTICAL';
else
    word1 = 'VERTICAL';
    word2 = 'HORIZONTAL';
end

if exptSession == 1
    targetStr = 'UNIQUE SHAPE. On some trials, this target shape will be a DIAMOND. On other trials, this target shape will be a CIRCLE';
else
    targetStr = 'DIAMOND SHAPE';
end

instructStr2 = ['Each of these shapes contains a line. Your task is to respond to the line that is contained inside the ', targetStr,'. '];
instructStr3 = ['If the line inside the target is ', word1,', you should press the "4" button on the number pad with your right index finger. If the line is ',word2,', you should press the "5" button on the number pad with your right middle finger.'];
instructStr3a = ['In this version of the task, the shapes will disappear after 100ms, so you will need to make sure that you are paying attention at the start of the trial.'];

if exptSession == 2
    instructStr4 = 'You should respond as fast as you can, but you should try to avoid making errors.\n\nPlease keep your eyes fixated on the cross in the centre of the screen throughout the task. This allows us to get better EEG recordings, and is also quickest way to locate the target.\n\nThe experimenter will give you feedback on how many eye movements you are making. If you make too many eye movements, the experimenter will cancel the rest of the experiment and you will not be able to earn more points later in the experiment.';
else
    instructStr4 = 'You should respond as fast as you can, but you should try to avoid making errors.\n\nPlease keep your eyes fixated on the cross in the centre of the screen throughout the task. This will allow us to get better EEG recordings in the second session, so it is important to practice now. It is also quickest way to locate the target.';
end
show_Instructions(1, instructStr1);
show_Instructions(2, instructStr2);
show_Instructions(3, instructStr3);
if exptSession == 2
    show_Instructions(3, instructStr3a);
end
show_Instructions(4, instructStr4);

DrawFormattedText(MainWindow, 'Tell the experimenter when you are ready to begin', 'center', 'center' , white);
Screen(MainWindow, 'Flip');

RestrictKeysForKbCheck(KbName('t'));   % Only accept t key
KbWait([], 2);
if runEEG == 1; outp(address, 78); end% end of initial instructions trigger
Screen(MainWindow, 'Flip');


end

function show_Instructions(instrTrial, insStr)

global MainWindow scr_centre black white instrWin condition exptSession yellow

if condition == 2
    imL1 = imread('exampleDiamondTargetColoured.jpg', 'jpg');
    imR1 = imread('exampleCircleTargetColoured.jpg', 'jpg');
    imL2 = imread('exampleDiamondTargetColoured-T.jpg', 'jpg');
    imR2 = imread('exampleCircleTargetColoured-T.jpg', 'jpg');
else
    imL1 = imread('exampleDiamondTarget.jpg', 'jpg');
    imR1 = imread('exampleCircleTarget.jpg', 'jpg');
    imL2 = imread('exampleDiamondTarget-T.jpg', 'jpg');
    imR2 = imread('exampleCircleTarget-T.jpg', 'jpg');
end

gap = 200;
y = 500;
x = 500;

if exptSession == 1
    colourStr = '';
else
    colourStr = 'IMPORTANT: In this version of the task, the target will never be coloured. So you should try your best to avoid looking at the coloured shape.'
end

exImageRectLeft = [scr_centre(1) - gap/2 - x    scr_centre(2)    scr_centre(1) - gap/2    scr_centre(2) + y];
exImageRectRight = [scr_centre(1) + gap/2    scr_centre(2)    scr_centre(1) + gap/2 + x    scr_centre(2) + y];


instrWin = Screen('OpenOffscreenWindow', MainWindow, black);
Screen('TextFont', instrWin, 'Courier');
Screen('TextSize', instrWin, 32);
Screen('TextStyle', instrWin, 1);

[~, ~, instrBox] = DrawFormattedText(instrWin, insStr, [], [] , white, 60, [], [], 1.5);
instrBox_width = instrBox(3) - instrBox(1);
instrBox_height = instrBox(4) - instrBox(2);
textTop = 100;
destInstrBox = [scr_centre(1) - instrBox_width / 2   textTop   scr_centre(1) + instrBox_width / 2   textTop +  instrBox_height];
Screen('DrawTexture', MainWindow, instrWin, instrBox, destInstrBox);
if instrTrial < 2
    Screen('PutImage', MainWindow, imL1, exImageRectLeft); % put left image on screen
    Screen('PutImage', MainWindow, imR1, exImageRectRight); % put right image on screen
elseif instrTrial == 2
    Screen('PutImage', MainWindow, imL2, exImageRectLeft); % put left image on screen
    Screen('PutImage', MainWindow, imR2, exImageRectRight); % put right image on screen
    [~, ny, ~] = DrawFormattedText(MainWindow, colourStr, scr_centre(1) - instrBox_width / 2, textTop + instrBox_height + 100, yellow, 60, [], [], 1.5);
elseif instrTrial == 3
    Screen('PutImage', MainWindow, imL2, exImageRectLeft); % put left image on screen
    Screen('PutImage', MainWindow, imR2, exImageRectRight); % put right image on screen
end

if instrTrial > 1
    RestrictKeysForKbCheck(KbName('Space'));   % Only accept spacebar
    KbWait([], 2);
end

Screen(MainWindow, 'Flip'); 
    
    
    if instrTrial == 4
        RestrictKeysForKbCheck(KbName('Space'));   % Only accept spacebar
        KbWait([], 2);
        Screen('Close', instrWin);
    end
    
end