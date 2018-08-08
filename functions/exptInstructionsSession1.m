
function exptInstructionsSession1()

global keyCounterbal
global MainWindow white
global zeroPayRT oneMSvalue
global bigMultiplier
global address runEEG exptSession starting_total

if runEEG == 1; outp(address,77); end;

if keyCounterbal == 1
    word1 = 'HORIZONTAL';
    word2 = 'VERTICAL';
else
    word1 = 'VERTICAL';
    word2 = 'HORIZONTAL';
end

instructStr1 = ['The rest of this experiment is similar to the trials you have just completed. On each trial, you should respond to the line that is contained inside the UNIQUE SHAPE.\n\nIf the line is ', word1,', you should press the left button. If the line is ',word2,', you should press the right button.'];

instructStr2 = ['From now on, you will be able to earn money for correct responses, depending on how fast you respond. For every 10 ms that your response time (RT) is faster than ', num2str(zeroPayRT), 'ms, you will earn 1 point.'];

instructStr3 = ['IMPORTANT:  Some of the trials will be BONUS trials! On these trials the amount that you win or lose will be multiplied by ', num2str(bigMultiplier),'.'];

instructStr4 = 'After each response you will be told how many points you won or lost, and the total points earned so far in this experiment.\n\nAt the end of each session of the experiment, the points that you have earned will be converted into money, and you will be shown how much you have earned so far.\n\nMost participants are able to earn between $15 and $25 across both sessions of the experiment.';

if exptSession == 2
instructStr5 = ['So far, you have earned $', num2str(starting_total, '%0.2f')];
end

show_Instructions(1, instructStr1, 8);      % 8
show_Instructions(2, instructStr2, 12);     % 12
show_Instructions(3, instructStr3, 12);     % 12
show_Instructions(4, instructStr4, 6);      % 6
if exptSession == 2
    DrawFormattedText(MainWindow, instructStr5, 'center', 'center', white);
    Screen(MainWindow, 'Flip')
    RestrictKeysForKbCheck(KbName('Space'));
    KbWait([], 2);
end
DrawFormattedText(MainWindow, 'Please place your right index and middle fingers on the "4" and "5" buttons\n\nand tell the experimenter when you are ready to begin', 'center', 'center' , white);
Screen(MainWindow, 'Flip');

RestrictKeysForKbCheck(KbName('Space'));
KbWait([], 2);
if runEEG == 1; outp(address, 78); end;
Screen(MainWindow, 'Flip');


end


function show_Instructions(instrTrial, insStr, instrPause)

global MainWindow scr_centre black white yellow
global bigMultiplier

cyan = [0 255 255];

instrWin = Screen('OpenOffscreenWindow', MainWindow, black);
Screen('TextFont', instrWin, 'Courier');
Screen('TextSize', instrWin, 34);
Screen('TextStyle', instrWin, 1);

textColour = white;
if instrTrial == 3
    textColour = yellow;
end

[~, ~, instrBox] = DrawFormattedText(instrWin, insStr, 0, [] , textColour, 60, [], [], 1.5);
instrBox_width = instrBox(3) - instrBox(1);
instrBox_height = instrBox(4) - instrBox(2);
textTop = 150;
destInstrBox = [scr_centre(1) - instrBox_width / 2   textTop   scr_centre(1) + instrBox_width / 2   textTop + instrBox_height];

Screen('DrawTexture', MainWindow, instrWin, instrBox, destInstrBox);

if instrTrial == 2
    extraStr1 = 'These points will be used to calculate the amount of money that you will receive at the end of the experiment.';
    extraStr2 = '\n\nSo the faster you make correct responses, the more you will earn. However, if you make an error you will LOSE the corresponding amount.';
    [~, ny, ~] = DrawFormattedText(MainWindow, extraStr1, scr_centre(1) - instrBox_width / 2, textTop + instrBox_height + 100, yellow, 60, [], [], 1.5);
    DrawFormattedText(MainWindow, extraStr2, scr_centre(1) - instrBox_width / 2, ny, white, 60, [], [], 1.5);
end


if instrTrial == 3
    extraStr = ['So you will earn much more for correct responses on \n"', num2str(bigMultiplier), ' x bonus" trials than on standard trials. However, you will not be told whether a trial was a "', num2str(bigMultiplier), ' x bonus" trial until after you have made your response.'];
    DrawFormattedText(MainWindow, extraStr, scr_centre(1) - instrBox_width / 2, textTop + instrBox_height + 100, white, 60, [], [], 1.5);
end

Screen('Flip', MainWindow);

Screen('TextSize', MainWindow, 34);

RestrictKeysForKbCheck(KbName('Space'));   % Only accept spacebar
KbWait([], 2);

Screen('Close', instrWin);

end