% ============================================================
% == This function is to help display the correct Width units 
% == used in Actuator, QCS Bin and CD Bin widths.  Internally
% == the App is using mm, this is for display and reporting.
% ============================================================

function result = ifelse(cond, a, b)
    if cond
        result = a;
    else
        result = b;
    end
end
