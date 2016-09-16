
function initialInstructionsSession1()

global keyCounterbal MainWindow white
global address runEEG

if runEEG == 1; outp(address,77); end %start of initial instructions trigger

instructStr1 = 'On each trial a dot will appear, this to warn you that the trial is about to start. Then a set of shapes will appear; two examples are shown below.';
if keyCounterbal == 1
    word1 = 'HORIZONTAL';
    word2 = 'VERTICAL';
else
    word1 = 'VERTICAL';
    word2 = 'HORIZONTAL';
end

instructStr2 = ['Each of these shapes contains a line. Your task is to respond to the line that is contained inside the UNIQUE SHAPE. On some trials, this target shape will be a DIAMOND. On other trials, this target shape will be a CIRCLE.\n\nEach trial will also contain a coloured shape, on some trials one of the NON-TARGET SHAPES will be coloured. On other trials, the TARGET will be coloured.'];
instructStr3 = ['If the line inside the target is ', word1,', you should press the "4" button on the number pad with your right index finger. If the line is ',word2,', you should press the "5" button on the number pad with your right middle finger.'];

if runEEG == 1
    instructStr4 = 'You should respond as fast as you can, but you should try to avoid making errors.\n\nPlease keep your eyes fixated on the dot in the centre of the screen throughout the task. This allows us to get better EEG recordings, and is also quickest way to locate the target.';
else
    instructStr4 = 'You should respond as fast as you can, but you should try to avoid making errors.\n\nPlease keep your eyes fixated on the dot in the centre of the screen throughout the task. This will allow us to get better EEG recordings in the second session, so it is important to practice now. It is also quickest way to locate the target.';
end
show_Instructions(1, instructStr1);
show_Instructions(2, instructStr2);
show_Instructions(3, instructStr3);
show_Instructions(4, instructStr4);

DrawFormattedText(MainWindow, 'Tell the experimenter when you are ready to begin', 'center', 'center' , white);
Screen(MainWindow, 'Flip');

RestrictKeysForKbCheck(KbName('t'));   % Only accept t key
KbWait([], 2);
if runEEG == 1; outp(address, 78); end% end of initial instructions trigger
Screen(MainWindow, 'Flip');


end

function show_Instructions(instrTrial, insStr)

global MainWindow scr_centre black white

imaLDcoloured=imread('exampleDiamondTarget.jpg', 'jpg');
imaRDcoloured = imread('exampleCircleTarget.jpg', 'jpg');
imaLDcolouredTarget=imread('exampleDiamondTarget-T.jpg', 'jpg');
imaRDcolouredTarget = imread('exampleCircleTarget-T.jpg', 'jpg');
imaLTcolouredTarget=imread('exampleDiamondTargetColoured-T.jpg', 'jpg');
imaRTcolouredTarget = imread('exampleCircleTargetColoured-T.jpg', 'jpg');
gap = 200;
y = 500;
x = 500;

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
    Screen('PutImage', MainWindow, imaLDcoloured, exImageRectLeft); % put left image on screen
    Screen('PutImage', MainWindow, imaRDcoloured, exImageRectRight); % put right image on screen
elseif instrTrial == 2
    Screen('PutImage', MainWindow, imaLDcolouredTarget, exImageRectLeft); % put left image on screen
    Screen('PutImage', MainWindow, imaRDcolouredTarget, exImageRectRight); % put right image on screen
else
    Screen('PutImage', MainWindow, imaLTcolouredTarget, exImageRectLeft); % put left image on screen
    Screen('PutImage', MainWindow, imaRTcolouredTarget, exImageRectRight); % put right image on screen
end

Screen(MainWindow, 'Flip');

if instrTrial == 2
    
    Screen('DrawTexture', MainWindow, instrWin, instrBox, destInstrBox);
    
    Screen('PutImage', MainWindow, imaLTcolouredTarget, exImageRectLeft); % put left image on screen
    Screen('PutImage', MainWindow, imaRTcolouredTarget, exImageRectRight); % put right image on screen
    
    RestrictKeysForKbCheck(KbName('Space'));   % Only accept spacebar
    KbWait([], 2);
    Screen(MainWindow, 'Flip');
end
    
    RestrictKeysForKbCheck(KbName('Space'));   % Only accept spacebar
    KbWait([], 2);
    
    Screen('Close', instrWin);
    
end