function printProgress(currIdx,totalIdx, msg)
%% Print progress.

progress = currIdx/totalIdx*100;
if currIdx == 1
    fprintf('%s. Progress:    ', msg);
elseif currIdx ~= totalIdx
    fprintf('\b\b\b\b%3.0f%%',progress); % update progress
else
    fprintf('...Done!\n');  % if 100% is reached
end



