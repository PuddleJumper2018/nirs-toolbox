classdef WaveletDetrend < nirs.modules.AbstractModule
  
    properties
        stdThresh = 3;
    end
    
    methods

        function obj = WaveletDetrend( prevJob )
           obj.name = 'Remove Trend w/ Wavelets';
           
           if nargin > 0
               obj.prevJob = prevJob;
           end
        end
        
        function data = runThis( obj, data )
            
            for i = 1:length(data)
                for j = 1:size(data(i).data, 2)
                    y = data(i).data(:,j);

                    % max level
                    n = wmaxlev(size(y),'sym8');

                    % decomposition
                    [w, l] = wavedec(y, n, 'sym8');

                    % cumulative indices
                    L = cumsum([0; l(1:n+1)]);

                    % thresholding
                    for k = 2:n+1
                       idx = L(k)+1:L(k+1);
                       lst = abs(w(idx)) ./ (mad(w(idx),0)/0.6745) < obj.stdThresh;
                       w(idx(lst)) = 0;
                    end

                    % estimated signal
                    t = waverec(w, l, 'sym8');

                    data(i).data(:,j) = y-t;
                end
            end
            
        end
    end
end