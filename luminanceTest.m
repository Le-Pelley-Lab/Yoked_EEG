function luminanceTest

MainWindow = Screen('OpenWindow', 0, [0 0 0]);

RedWindow = Screen('OpenOffscreenWindow', MainWindow);
BlueWindow = Screen('OpenOffscreenWindow', MainWindow);
GreyWindow = Screen('OpenOffscreenWindow', MainWindow);

[scrWidth, scrHeight] = Screen('WindowSize',0);
res = [scrWidth scrHeight];
scr_centre = res / 2;

Screen('FillRect', RedWindow, [225 0 0], [0 0 200 200])
Screen('FillRect', BlueWindow, [93 93 237], [0 0 200 200])
Screen('FillRect', GreyWindow, [115 115 115], [0 0 200 200])

DisplayRects(1,:) = [scr_centre(1) - 200 scr_centre(2) - 200 scr_centre(1) scr_centre(2)];
DisplayRects(2,:) = [scr_centre(1)  scr_centre(2) - 200 scr_centre(1) + 200 scr_centre(2)];
DisplayRects(3,:) = [scr_centre(1) - 200  scr_centre(2) scr_centre(1) scr_centre(2) + 200];
DisplayRects(4,:) = [scr_centre(1)  scr_centre(2) scr_centre(1) + 200 scr_centre(2) + 200];

for t = 1: 1000
    
    RectOrder = randperm(4);
    
    Screen('DrawTexture', MainWindow, RedWindow, [0 0 200 200], DisplayRects(RectOrder(1),:));
    Screen('DrawTexture', MainWindow, BlueWindow, [0 0 200 200],DisplayRects(RectOrder(2),:));
    Screen('DrawTexture', MainWindow, GreyWindow, [0 0 200 200],DisplayRects(RectOrder(3),:));
    Screen('DrawTexture', MainWindow, GreyWindow, [0 0 200 200],DisplayRects(RectOrder(4),:));
    
    Screen(MainWindow, 'Flip');
    
    KbWait([]);
    
end

end