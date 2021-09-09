classdef CircularFlickerStimulus < handle
   properties
       tex
       stimParams
       flickerFrequency {mustBeNumeric}
       lastSwitchTime   {mustBeNumeric}
       show  {mustBeNumeric}
   end
   methods (Access = public)
      function obj = CircularFlickerStimulus(checkerStimParams,flickerFrequency)
        if nargin>1  && isfield(checkerStimParams,'mean') ...
                     && isfield(checkerStimParams,'amplitude') ...
                     && isfield(checkerStimParams,'spatialF')

            % Passed in stim params
            obj.stimParams = checkerStimParams;
        else
            % Defualt Stim Parameters:
            obj.stimParams.mean = 0.5; % mean color
            obj.stimParams.amplitude = 0.5; % contrast
            obj.stimParams.spatialF = 0.5; %cycles per d
        end
        	
		if nargin==2
            % Passed in pulse time 
			obj.flickerFrequency = flickerFrequency;
		else
            % Defualt pulse time 
			obj.flickerFrequency = 1;
		end 
	  end

      function obj = createTextures(obj, diameter,screenProperties)

        cyclePerPixel = obj.stimParams.spatialF*screenProperties.degPerPix; %spatialF in cyclesPerDeg
        [X,Y] = meshgrid(-(diameter-1)/2:1:(diameter-1)/2);
        R = sqrt(X.^2+Y.^2);
        T = atan2(-Y,X);

        % Calculation for deg/second -> frames/cycle
        % deg/second * cycles/deg * seconds/frame = cycles/frame
        % 1/cycles/frame = frames/cycle

        phase=0;
        grating = zeros([size(R), 2]);
        grating(:,:,1) = obj.stimParams.mean * ones(diameter) + obj.stimParams.amplitude*sin(2*pi* cyclePerPixel * R - phase*ones(diameter));
        grating(:,:,2) = (R <= diameter/2); % alpha mask
        obj.tex(1) = Screen('MakeTexture', screenProperties.window, grating);


        grating(:,:,1) = obj.stimParams.mean * ones(diameter) - obj.stimParams.amplitude*sin(2*pi* cyclePerPixel * R - phase*ones(diameter));
        obj.tex(2) = Screen('MakeTexture', screenProperties.window, grating);

        obj.lastSwitchTime = 0;
        obj.show = 1;
      end
      
      function texture = getNextTexture(obj, timeProperties)
          
        if obj.lastSwitchTime == 0
            obj.lastSwitchTime = timeProperties.t;
        end

        if timeProperties.t > obj.lastSwitchTime + (1/obj.flickerFrequency)/2
			obj.show = obj.show * -1;
            % offset so current frame is same number while going backwards
			obj.lastSwitchTime = timeProperties.t;
        end
                
        if obj.show == 1
            texture = obj.tex(1);
        else
            texture = obj.tex(2);     
        end
      end
      
   end
end
