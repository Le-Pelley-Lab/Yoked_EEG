MainWindow = Screen('OpenWindow', 0);
[scrWidth, scrHeight] = Screen('WindowSize',0);
res = [scrWidth scrHeight];
scr_centre = res / 2;

Screen('FillRect', MainWindow, [216 102 25], [scr_centre(1) - 200, scr_centre(2) - 200, scr_centre(1), scr_centre(2)]);
Screen('FillRect', MainWindow, [29 134 247], [scr_centre(1), scr_centre(2) - 200, scr_centre(1)+200, scr_centre(2)]);
Screen('FillRect', MainWindow, [135 135 135], [scr_centre(1) - 200, scr_centre(2), scr_centre(1), scr_centre(2) + 200]);


Screen(MainWindow, 'Flip')
