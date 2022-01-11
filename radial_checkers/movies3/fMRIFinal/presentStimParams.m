%% General Parameters
%Resultfile directory
resultdir = './Results';

runs = 1;

%Stimulus parameters
fixRadius = 0.25; %fixation dot radius in degrees
fixColor = [1 0 0];

screenDiagonalSize = 81.28; % screen diagonal size in cm
viewingDistance = 100; %subject distance to screen in cm

%% File specifc Parameters
%load in frame params


%% List of paradigms 
% List of conditions (DO NOT EDIT)
conditionNone	= 0;
conditionStim	= 1;
conditionEnd	= 2;

% paradigm 0
% for test triggers (no fMRI)
% testParadigm = [
%     0    conditionNone;
%     3    conditionStim;
%     5   conditionNone;
%     7   conditionStim;
%     9   conditionNone;
%     11   conditionEnd;    
%     ];
firstBaselineEnd = 3;
numCycles 		 = 14;
cycleStim		 = 1;
cycleBaseline	 = 1;

testParadigm = [
    0 conditionNone;
    firstBaselineEnd conditionStim;
    cumsum(repmat([cycleStim;cycleBaseline],numCycles,1))+firstBaselineEnd repmat([conditionNone;conditionStim],numCycles,1)
    ];

% paradigm 1
% for testing with fMRI
runParadigmTest = [
    0    conditionNone;
    20   conditionStim;
    30   conditionNone;
    42   conditionStim;    
    56   conditionNone; 
    72   conditionEnd;    
    ];

% paradigm 2
% for running with fMRI
% 15 volume baseline
% then 16 cycles of 10 volumes stimulus then 12 baseline
firstBaselineEnd = 18;
numCycles 		 = 14;
cycleStim		 = 12;
cycleBaseline	 = 12;

runParadigmFinal = [
    0 conditionNone;
    firstBaselineEnd conditionStim;
    cumsum(repmat([cycleStim;cycleBaseline],numCycles,1))+firstBaselineEnd repmat([conditionNone;conditionStim],numCycles,1)
    ];

runParadigmFinal(end,2)=conditionEnd;
runParadigmFinal(end,1)=runParadigmFinal(end,1)+5;

%% Generate stimulus that will show
% order of stimulus presentation:

stimRunIndices(:,:,1) = [
    2, 3, 4, 6, 7, 8, 11, 12,15, 16, 18, 20, 22,24;
];

stimRunIndices(:,:,2) = [
    24, 22, 20,18, 16 ,15,12, 11, 8, 7, 6, 4, 3, 2;
];
% save orentations
[c tf] = clock
Stim_order_elected = stimRunIndices(:,:,stimOrder);
save([resultdir '/' num2str(c) '_' comment '_stimRunIndices_operator_selected_' num2str(stimOrder)],'Stim_order_elected');


% array of stimulus objects
% if lesss stimulus objects created than stimulus shown in paradigm,
%	stimulus objects will be presented starting from begining again

generateStimulus = @generateStim;

function stim = generateStim(paradigmNumber)
    % TODO switch to array (not cell array) and make interface
    switch paradigmNumber
        case {0,1}
            GratingStimulus1
            stim{1} = CheckerPulseStimulus(stimParams, 2);
            GratingStimulus2
            stim{2} = CheckerPulseStimulus(stimParams, 2);
            GratingStimulus3
            stim{3} = CheckerPulseStimulus(stimParams, 2);
            GratingStimulus4
            stim{4} = CheckerPulseStimulus(stimParams, 2);

            GratingStimulus1
			stim{5} = CheckerFlickerStimulus(stimParams,8);
			GratingStimulus2
			stim{6} = CheckerFlickerStimulus(stimParams,1);
			GratingStimulus3
			stim{7} = CheckerFlickerStimulus(stimParams,8);
			GratingStimulus4
			stim{8} = CheckerFlickerStimulus(stimParams,2);

            GratingStimulus5
            stim{9} = CheckerPulseStimulus(stimParams, 2);
            GratingStimulus6
            stim{10} = CheckerPulseStimulus(stimParams, 2);
            GratingStimulus7
            stim{11} = CheckerPulseStimulus(stimParams, 2);
            GratingStimulus8
            stim{12} = CheckerPulseStimulus(stimParams, 2);
            
			GratingStimulus5
			stim{13} = CheckerFlickerStimulus(stimParams, 8);
			GratingStimulus6
			stim{14} = CheckerFlickerStimulus(stimParams, 2);
			GratingStimulus7
			stim{15} = CheckerFlickerStimulus(stimParams, 8);
			GratingStimulus8
			stim{16} = CheckerFlickerStimulus(stimParams, 2);
            
            GratingStimulus9
            stim{17} = CheckerPulseStimulus(stimParams, 2);
            GratingStimulus10
            stim{18} = CheckerPulseStimulus(stimParams, 2);
            GratingStimulus11
            stim{19} = CheckerPulseStimulus(stimParams, 2);
            GratingStimulus12
            stim{20} = CheckerPulseStimulus(stimParams, 2);

            GratingStimulus9
			stim{21} = CheckerFlickerStimulus(stimParams,8);
			GratingStimulus10
			stim{22} = CheckerFlickerStimulus(stimParams,1);
			GratingStimulus11
			stim{23} = CheckerFlickerStimulus(stimParams,8);
			GratingStimulus12
			stim{24} = CheckerFlickerStimulus(stimParams,2);
        case 2
            GratingStimulus1
            stim{1} = CheckerPulseStimulus(stimParams, 2);
            GratingStimulus2
            stim{2} = CheckerPulseStimulus(stimParams, 2);
            GratingStimulus3
            stim{3} = CheckerPulseStimulus(stimParams, 2);
            GratingStimulus4
            stim{4} = CheckerPulseStimulus(stimParams, 2);

            GratingStimulus1
			stim{5} = CheckerFlickerStimulus(stimParams,8);
			GratingStimulus2
			stim{6} = CheckerFlickerStimulus(stimParams,1);
			GratingStimulus3
			stim{7} = CheckerFlickerStimulus(stimParams,8);
			GratingStimulus4
			stim{8} = CheckerFlickerStimulus(stimParams,2);

            GratingStimulus5
            stim{9} = CheckerPulseStimulus(stimParams, 2);
            GratingStimulus6
            stim{10} = CheckerPulseStimulus(stimParams, 2);
            GratingStimulus7
            stim{11} = CheckerPulseStimulus(stimParams, 2);
            GratingStimulus8
            stim{12} = CheckerPulseStimulus(stimParams, 2);
            
			GratingStimulus5
			stim{13} = CheckerFlickerStimulus(stimParams, 8);
			GratingStimulus6
			stim{14} = CheckerFlickerStimulus(stimParams, 2);
			GratingStimulus7
			stim{15} = CheckerFlickerStimulus(stimParams, 8);
			GratingStimulus8
			stim{16} = CheckerFlickerStimulus(stimParams, 2);
            
            GratingStimulus9
            stim{17} = CheckerPulseStimulus(stimParams, 2);
            GratingStimulus10
            stim{18} = CheckerPulseStimulus(stimParams, 2);
            GratingStimulus11
            stim{19} = CheckerPulseStimulus(stimParams, 2);
            GratingStimulus12
            stim{20} = CheckerPulseStimulus(stimParams, 2);

            GratingStimulus9
			stim{21} = CheckerFlickerStimulus(stimParams,8);
			GratingStimulus10
			stim{22} = CheckerFlickerStimulus(stimParams,1);
			GratingStimulus11
			stim{23} = CheckerFlickerStimulus(stimParams,8);
			GratingStimulus12
			stim{24} = CheckerFlickerStimulus(stimParams,2);
    end	
end