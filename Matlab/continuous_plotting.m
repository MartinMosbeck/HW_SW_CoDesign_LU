for count = 1 : 8
       for phaseStep = 1 : 12
           %figure
           plot(biphasesymbols(:,count,phaseStep),'b.');
           string = sprintf('count: %d phaseStep: %d', count, phaseStep);
           title(string);
           waitforbuttonpress
       end
end