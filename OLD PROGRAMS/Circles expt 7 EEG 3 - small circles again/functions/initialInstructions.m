
function initialInstructions()

global keyCounterbal MainWindow white
global address runEEG

if runEEG == 1; outp(address,77); end%start of initial instructions trigger

instructStr1 = 'On each trial a cross will appear, to warn you that the trial is about to start. Then a set of shapes will appear; an example is shown below.';
if keyCounterbal == 1
    word1 = 'HORIZONTAL';
    word2 = 'VERTICAL';
else
    word1 = 'VERTICAL';
    word2 = 'HORIZONTAL';
end

instructStr2 = ['Each of these shapes contains a line. Your task is to respond to the line that is contained inside the DIAMOND shape.\n\nIf the line inside the diamond is ', word1,', you should press the "C" button. If the line is ',word2,', you should press the "M" button.'];

if runEEG == 1
    instructStr3 = 'You should respond as fast as you can, but you should try to avoid making errors.\n\nPlease keep your eyes fixated on the cross in the centre of the screen while locating and responding to the target. This allows us to get better EEG recordings, and is also quickest way to locate the target.';
else
    instructStr3 = 'You should respond as fast as you can, but you should try to avoid making errors.\n\nPlease keep your eyes fixated on the cross in the centre of the screen while locating and responding to the target. This will allow us to get better EEG recordings in the second session, so it is important to practice now. It is also quickest way to locate the target.';
end
show_Instructions(1, instructStr1);
show_Instructions(2, instructStr2);
show_Instructions(3, instructStr3);

DrawFormattedText(MainWindow, 'Tell the experimenter when you are ready to begin', 'center', 'center' , white);
Screen(MainWindow, 'Flip');

RestrictKeysForKbCheck(KbName('t'));   % Only accept t key
KbWait([], 2);
if runEEG == 1; outp(address, 78); end% end of initial instructions trigger
Screen(MainWindow, 'Flip');


end

function show_Instructions(instrTrial, insStr)

global MainWindow scr_centre black white

ima=imread('example.jpg', 'jpg');
y = size(ima,1);
x = size(ima,2);

exImageRect = [scr_centre(1) - x/2    scr_centre(2)    scr_centre(1) + x/2   scr_centre(2) + y];



instrWin = Screen('OpenOffscreenWindow', MainWindow, black);
Screen('TextSize', instrWin, 32);
Screen('TextStyle', instrWin, 1);

[~, ~, instrBox] = DrawFormattedText(instrWin, insStr, 0, 0 , white, 60, [], [], 1.5);
instrBox_width = instrBox(3) - instrBox(1);
instrBox_height = instrBox(4) - instrBox(2);
textTop = 100;
destInstrBox = [scr_centre(1) - instrBox_width / 2   textTop   scr_centre(1) + instrBox_width / 2   textTop +  instrBox_height];
Screen('DrawTexture', MainWindow, instrWin, instrBox, destInstrBox);
Screen('PutImage', MainWindow, ima, exImageRect); % put image on screen
Screen(MainWindow, 'Flip');

 RestrictKeysForKbCheck(KbName('Space'));   % Only accept spacebar
KbWait([], 2);

Screen('Close', instrWin);

end