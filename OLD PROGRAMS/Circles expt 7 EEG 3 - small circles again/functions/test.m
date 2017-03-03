    check = 0;
    timeout = 0;
    while check == 0
        evt = CedrusResponseBox('GetButtons', handle);
        et = CedrusResponseBox('GetBaseTimer', handle);
        if et.ptbtime - st > 2
            check = 1;
            timeout = 1;
        elseif evt.button == 1 || evt.button == 2
            check = 1;
        end
    end