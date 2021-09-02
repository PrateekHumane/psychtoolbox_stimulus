%% General Parameters
%Resultfile directory
resultdir = './Results';
gratingPath = '/home/prateek/McGill/BIC/psychtoolbox_stimulus/radial_checkers/fMRIFinal/';

%Stimulus parameters
fixRadius = 0.25; %fixation dot radius in degrees
fixColor = [1 0 0];

fovWidth        = 30;
fovHeight       = 22.5;

%% File specifc Parameters
%load in frame params


%% List of paradigms 
% List of conditions (DO NOT EDIT)
conditionNone	= 0;
conditionStim	= 1;
conditionEnd	= 2;

% paradigm 0
testParadigm = [
    0    conditionNone;
    3    conditionStim;
    5   conditionNone;
    7   conditionStim;
    9   conditionNone;
    11   conditionEnd;    
    ];

% paradigm 1
runParadigmTest = [
    0    conditionNone;
    20   conditionStim;
    30   conditionNone;
    42   conditionStim;    
    56   conditionNone;
    72   conditionEnd;    
    ];

% paradigm 2
runParadigmFinal = [
    0 conditionNone;
    15 conditionStim;
    cumsum(repmat([10;12],16,1))+15 repmat([conditionNone;conditionStim],16,1)
    ];

runParadigmFinal(end,2)=conditionEnd;

%% Generate stimulus that will show
% array of stimulus objects
% if lesss stimulus objects created than stimulus shown in paradigm,
%	stimulus objects will be presented starting from begining again

generateStimulus = @generateStim;

function stim = generateStim(paradigmNumber)
    % TODO switch to array (not cell array) and make interface
    switch paradigmNumber
        case {0,1}
			GratingStimulus1
			stim{1} = CheckerOutwardStimulus(stimParams);
			GratingStimulus5
			stim{2} = CheckerFlickerStimulus(stimParams, 8);
        case 2
			GratingStimulus1
			stim{1} = CheckerOutwardStimulus(stimParams);
			GratingStimulus2
			stim{2} = CheckerOutwardStimulus(stimParams);
			GratingStimulus3
			stim{3} = CheckerOutwardStimulus(stimParams);
			GratingStimulus4
			stim{4} = CheckerOutwardStimulus(stimParams);
			GratingStimulus5
			stim{5} = CheckerOutwardStimulus(stimParams);
			GratingStimulus6
			stim{6} = CheckerOutwardStimulus(stimParams);
			GratingStimulus7
			stim{7} = CheckerOutwardStimulus(stimParams);
			GratingStimulus8
			stim{8} = CheckerOutwardStimulus(stimParams);

            GratingStimulus1
            stim{1} = CheckerPulseStimulus(stimParams, 1);
            GratingStimulus2
            stim{2} = CheckerPulseStimulus(stimParams, 1);
            GratingStimulus3
            stim{3} = CheckerPulseStimulus(stimParams, 1);
            GratingStimulus4
            stim{4} = CheckerPulseStimulus(stimParams, 1);
            GratingStimulus5
            stim{5} = CheckerPulseStimulus(stimParams, 1);
            GratingStimulus6
            stim{6} = CheckerPulseStimulus(stimParams, 1);
            GratingStimulus7
            stim{7} = CheckerPulseStimulus(stimParams, 1);
            GratingStimulus8
            stim{8} = CheckerPulseStimulus(stimParams, 1);
    end	
end