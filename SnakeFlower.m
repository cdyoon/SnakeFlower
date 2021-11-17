// SnakeFlower: Threat Detection and Visual Salience
clear all;

// %% Enter subject information
Data.Subject_Number = input('Enter Subject Number: ');
Data.Date = datestr(now);

// %% create data file 
folder = cd;
fname = (['SnakeFlower_DateFile_' num2str(Data.Subject_Number) '.txt']);
filename = fopen(fullfile(folder, fname), 'w'); 
fprintf(filename, '\nSubject Number: %d\nDate: %s\n\r\n\r\n', Data.Subject_Number, Data.Date); //write subject info
fprintf(filename, 'TrialNo\tCondition\tAccuracy\tRT\n')//create header row 

// %% Initialize Psychotoolbox parameters


Screen('Preference', 'SkipSyncTests', 1);
screenNum = 0; //set screen number
flipSpd = 0; //should flip screen every time key is pressed
res = [0 0 1800  1200];//switch to [] once debugging is completed
[w, rect] = Screen('OpenWindow', screenNum, 0, res); //switch res to [] after debugging
monitorFlipInterval = Screen('GetFlipInterval', w);
black = BlackIndex(w); white = WhiteIndex(w);
Screen ('FillRect', w, white); //fill white screen
vbl = Screen('Flip', w);
WaitSecs(1);

// %% Read, resize, and create cell array of the 48 images of snakes and flowers

siz = 100; //use for size of image
for i = 1:24
    nrssIMG{i} = imread(['Snake ', num2str(i), '.jpg']); //nonresized snake image
    sIMG{i} = imresize([nrssIMG{i}], [siz, siz]); //resized snake img
    nrsfIMG{i} = imread(['Flower ', num2str(i), '.jpg']); //nonresized flower img
    fIMG{i} = imresize([nrsfIMG{i}], [siz, siz]); //resized flower img
end

// %% Initalize Positions for lines and images.
 
// %Initalizing line borders
count = 0;
x_1 = res(1);
x_2 = res(3);
y_1 = res(2);
y_2 = res(4);
x_first_coord = (x_2)/3;
x_second_coord = 2*((x_2)/3);
y_first_coord = (y_2)/3;
y_second_coord = 2*((y_2)/3);
[xc, yc] = RectCenter(rect); //start coordinate based on center of Rect
Length = 300;

//Add positions of the 9 images in cell array Position{} in 3x3
Position{1} = [xc/3 - Length/2, yc/3 - Length/2, xc/3 + Length/2, yc/3 + Length/2]; //lower left
Position{2} = [xc/3 - Length/2, yc - Length/2, xc/3 + Length/2, yc + Length/2]; //mid left
Position{3} = [xc/3 - Length/2, (yc + (2*yc/3) - Length/2), xc/3 + Length/2, (yc + (2*yc/3) + Length/2)]; //upper left
Position{4} = [xc- Length/2, yc/3 - Length/2, xc+ Length/2, yc/3 + Length/2]; //lower middle
Position{5} = [xc- Length/2, yc - Length/2, xc+ Length/2, yc + Length/2]; //mid middle
Position{6} = [xc- Length/2, yc + (2*yc/3) - Length/2, xc+ Length/2, yc + (2*yc/3) + Length/2]; //upper middle
Position{7} = [xc + (2*xc/3)- Length/2, yc/3 - Length/2, xc + (2*xc/3)+ Length/2, yc/3 + Length/2]; //lower right
Position{8} = [xc + (2*xc/3)- Length/2, yc - Length/2, xc + (2*xc/3)+ Length/2, yc + Length/2]; //mid right
Position{9} = [xc + (2*xc/3)- Length/2, yc + (2*yc/3) - Length/2, xc + (2*xc/3)+ Length/2, yc + (2*yc/3) + Length/2]; //upper right



// %% Initialize Trial Variables and Load KbCheck
numtrials = 120; //total number of trials  (minimum = 16);
conditions = 4; //the four conditions are 8 snakes, 8 flowers...
levelsofconditions = numtrials/conditions; //evens out number of trials
sIMG2 = {}; //initializesoriginal snake image array
fIMG2 = {}; //initializesoriginal flower image array
tsIMG2 = {}; //initializes temporary variable for snake image array
tfIMG2 = {}; //initializes temporary variable for flower image array
RTArray = []; //initializes an array that holds the reaction times
resptime = 0; //initializes response time 
response = ''; //initializes response key
waittime = 2; //initializes stimulus duration 
iti = 1; //initializes intertrial interval
Data.Accuracy = []; //intializes struct for accuracy
Data.Accuracy.Snake = [];
Data.Accuracy.SnakeGrey = [];
Data.Accuracy.Flower = [];
Data.Accuracy.FlowerGrey = [];
Data.Accuracy.OneSnake = [];
Data.Accuracy.OneSnakeGrey = [];
Data.Accuracy.OneFlower = [];
Data.Accuracy.OneFlowerGrey = [];
Data.RT = []; //intializes struct for reaction time
RTSnake = [];
RTSnakeGrey = [];
RTFlower = [];
RTFlowerGrey = [];
RTOneSnake = [];
RTOneSnakeGrey = [];
RTOneFlower = [];
RTOneFlowerGrey = [];
Data.TrialType = []; //intialize struct for trial type
RT = [];
trials = [];
accuracy = [];
AccSnake = [];
AccSnakeGrey = [];
AccFlower = [];
AccFlowerGrey = [];
AccOneSnake = [];
AccOneSnakeGrey = [];
AccOneFlower = [];
AccOneFlowerGrey = [];

while KbCheck; end //load KbCheck


// %% DISPLAY INTRO AND DIRECTIONS

Text_Beginning = ['Please press ''s'' on the keyboard if all images'...
     'are from the same category, or press ''d'' on the keyboard if one'...
     'image is different from the rest of the images.'];
DrawFormattedText (w,'Please press ''s'' if all images are from the same category, ''d'' if one image is from a different category' , 'center', 'center', black);
Screen('Flip',w); 
pause(); //starts task once key is pressed



// %% RANDOMIZED IMAGE DISPLAY, RT, ACCURACY

for i = 1:(numtrials) //i from 1 to 16
    
//INITIALIZE LOOP VARIABLES
    a = randperm(numtrials); 
    sIMG(:) = sIMG(randperm(numel(sIMG)));
    fIMG(:) = fIMG(randperm(numel(fIMG)));
    tsIMG = sIMG; //create temp array: 1x24
    tfIMG = fIMG; //create temp array: 1x24
    tsIMG2 = tsIMG(1:9);
    tfIMG2 = tfIMG(1:9);
    
// %9 SNAKES CONDITION COLOR
    if a(i) <= (levelsofconditions/2)// <=15
        sIMG2 = sIMG(1:9);
        for i = 1:numel(sIMG2) 
            snaketex = Screen('MakeTexture', w, sIMG2{i}); 
            Screen('DrawLine', w, black, x_first_coord, res(2), x_first_coord, res(4), 3) ;
            Screen('DrawLine', w, black, x_second_coord, res(2), x_second_coord, res(4), 3) ;
            Screen('DrawLine', w, black, res(1), y_first_coord, res(3), y_first_coord, 3) ;
            Screen('DrawLine', w, black, res(1), y_second_coord, res(3), y_second_coord, 3) ;
            Screen('DrawTexture', w, snaketex, [], Position{i},0);
        end
// %9 SNAKES CONDITION GRAYSCALE
    elseif a(i) <= (levelsofconditions) && a(i) > (levelsofconditions./2) //<=30 and >15
        sIMG2 = sIMG(1:9);
        for i = 1:numel(sIMG2) 
            sIMG2{i} = rgb2gray(sIMG2{i}); 
            snaketex= Screen('MakeTexture', w, sIMG2{i});
            Screen('DrawLine', w, black, x_first_coord, res(2), x_first_coord, res(4), 3) ;
            Screen('DrawLine', w, black, x_second_coord, res(2), x_second_coord, res(4), 3) ;
            Screen('DrawLine', w, black, res(1), y_first_coord, res(3), y_first_coord, 3) ;
            Screen('DrawLine', w, black, res(1), y_second_coord, res(3), y_second_coord, 3) ;
            Screen('DrawTexture', w, snaketex, [], Position{i},0); 
        end
        
// %9 FLOWERS CONDITION COLOR 
    elseif a(i) <= (levelsofconditions*1.5) && a(i) > levelsofconditions //30:45
        fIMG2 = fIMG(1:9);
        for i = 1:numel(fIMG2) 
            flowertex = Screen('MakeTexture', w, fIMG2{i});
            Screen('DrawLine', w, black, x_first_coord, res(2), x_first_coord, res(4), 3) ;
            Screen('DrawLine', w, black, x_second_coord, res(2), x_second_coord, res(4), 3) ;
            Screen('DrawLine', w, black, res(1), y_first_coord, res(3), y_first_coord, 3) ;
            Screen('DrawLine', w, black, res(1), y_second_coord, res(3), y_second_coord, 3) ;
            Screen('DrawTexture', w, flowertex, [], Position{i},0);
        end
        
// %9 FLOWERS CONDITION GRAYSCALE
    elseif a(i) <= (levelsofconditions*2) && a(i) > (levelsofconditions*1.5) //45:60
        fIMG2 = fIMG(1:9);
        for i = 1:numel(fIMG2) 
            fIMG2{i} = rgb2gray(fIMG2{i}); 
            flowertex = Screen('MakeTexture', w, fIMG2{i}); 
            Screen('DrawLine', w, black, x_first_coord, res(2), x_first_coord, res(4), 3) ;
            Screen('DrawLine', w, black, x_second_coord, res(2), x_second_coord, res(4), 3) ;
            Screen('DrawLine', w, black, res(1), y_first_coord, res(3), y_first_coord, 3) ;
            Screen('DrawLine', w, black, res(1), y_second_coord, res(3), y_second_coord, 3) ;
            Screen('DrawTexture', w, flowertex, [], Position{i},0); 
        end

// %1 SNAKE 8 FLOWERS CONDITION COLOR
    elseif a(i) <= (levelsofconditions*2.5) && a(i) > (levelsofconditions*2) // 60:75
        osefIMG = {tfIMG2{1:8} tsIMG2{1}};
        osefIMG(:) = osefIMG(randperm(numel(osefIMG)));
        for i = 1:numel(osefIMG) 
            snaketex = Screen('MakeTexture', w, osefIMG{i}); //Each loop, add texture of snake
            Screen('DrawLine', w, black, x_first_coord, res(2), x_first_coord, res(4), 3) ;
            Screen('DrawLine', w, black, x_second_coord, res(2), x_second_coord, res(4), 3) ;
            Screen('DrawLine', w, black, res(1), y_first_coord, res(3), y_first_coord, 3) ;
            Screen('DrawLine', w, black, res(1), y_second_coord, res(3), y_second_coord, 3) ;
            Screen('DrawTexture', w, snaketex, [], Position{i},0); //Each loop, add to screen
        end

// %1 SNAKE 8 FLOWERS CONDITION GRAYSCALE 
    elseif a(i) <= (levelsofconditions*3) && a(i) > (levelsofconditions*2.5) // 75:90
        osefIMG = {tfIMG2{1:8} tsIMG2{1}};
        osefIMG(:) = osefIMG(randperm(numel(osefIMG)));
        for i = 1:numel(osefIMG) //Loop through the array
            osefIMG{i} = rgb2gray(osefIMG{i});
            snaketex = Screen('MakeTexture', w, osefIMG{i}); //Each loop, add texture of snake
            Screen('DrawLine', w, black, x_first_coord, res(2), x_first_coord, res(4), 3) ;
            Screen('DrawLine', w, black, x_second_coord, res(2), x_second_coord, res(4), 3) ;
            Screen('DrawLine', w, black, res(1), y_first_coord, res(3), y_first_coord, 3) ;
            Screen('DrawLine', w, black, res(1), y_second_coord, res(3), y_second_coord, 3) ;
            Screen('DrawTexture', w, snaketex, [], Position{i},0); 
        end


// %8 SNAKES 1 FLOWER CONDITION COLOR    
    elseif a(i) <= (levelsofconditions*3.5)&& a(i) > (levelsofconditions*3) //90:105
        esofIMG = {tfIMG2{1} tsIMG2{1:8}};
        esofIMG(:) = esofIMG(randperm(numel(esofIMG)));        
        for i = 1:numel(esofIMG) //Loop through the array
            snaketex = Screen('MakeTexture', w, esofIMG{i});
            Screen('DrawLine', w, black, x_first_coord, res(2), x_first_coord, res(4), 3) ;
            Screen('DrawLine', w, black, x_second_coord, res(2), x_second_coord, res(4), 3) ;
            Screen('DrawLine', w, black, res(1), y_first_coord, res(3), y_first_coord, 3) ;
            Screen('DrawLine', w, black, res(1), y_second_coord, res(3), y_second_coord, 3) ;
            Screen('DrawTexture', w, snaketex, [], Position{i},0);
        end
    
    
// %8 SNAKES 1 FLOWER CONDITION GRAYSCALE   
    elseif a(i) <= (levelsofconditions*4) && a(i) > (levelsofconditions*3.5) //105:120
        esofIMG = {tfIMG2{1} tsIMG2{1:8}}; 
        esofIMG(:) = esofIMG(randperm(numel(esofIMG)));        
        for i = 1:numel(esofIMG) 
            esofIMG{i} = rgb2gray(esofIMG{i});
            snaketex = Screen('MakeTexture', w, esofIMG{i}); 
            Screen('DrawLine', w, black, x_first_coord, res(2), x_first_coord, res(4), 3) ;
            Screen('DrawLine', w, black, x_second_coord, res(2), x_second_coord, res(4), 3) ;
            Screen('DrawLine', w, black, res(1), y_first_coord, res(3), y_first_coord, 3) ;
            Screen('DrawLine', w, black, res(1), y_second_coord, res(3), y_second_coord, 3) ;
            Screen('DrawTexture', w, snaketex, [], Position{i},0); 
        end
    
    Screen('Flip',w);

// %new trial images takes over
// % ACCURACY AND RESPONSE TIME


    starttime = GetSecs; //get the current time for reaction times
    while GetSecs < starttime + waittime
        [keyIsDown, secs, keycode] = KbCheck;
        if keyIsDown
            response = KbName (keycode);//get the key
            resptime = secs - starttime; //calculate the response time
            Screen('FillRect', w, 255); // make background white
            Screen('Flip',w); 
            break; //break once a key is pressed  
        end
    end
    while KbCheck; end //get out of keyboard checking mode
    
   //trial type into an array
    if a(i) <= (levelsofconditions/2) // <=15
        trial_condition = 1; //trials that show all snakes
    elseif a(i) <= (levelsofconditions) && a(i) > (levelsofconditions/2) //<=30 and >15
        trial_condition = 2; //trials that show all grey snakes
    elseif a(i) <= (levelsofconditions*1.5) && a(i) > levelsofconditions //30:45
        trial_condition = 3; //trials that show all flower
    elseif a(i) <= (levelsofconditions*2) && a(i) > (levelsofconditions*1.5) //45:60
        trial_condition = 4; //trials that show all grey flowers
    elseif a(i) <= (levelsofconditions*2.5) && a(i) > (levelsofconditions*2) // 60:75
        trial_condition = 5; //trials that show one snake
    elseif a(i) <= (levelsofconditions*3) && a(i) > (levelsofconditions*2.5) // 75:90
        trial_condition = 6; //trials that show one grey snake
    elseif a(i) <= (levelsofconditions*3.5)&& a(i) > (levelsofconditions*3) //90:105
        trial_condition = 7; //trials that show one flower
    elseif a(i) <= (levelsofconditions*4) && a(i) > (levelsofconditions*3.5) //105:120
        trial_condition = 8; //trials that show one grey flower 
    end
    trials = [trials trial_condition];
    Data(i).TrialType = trials;
    
    if a(i) <= (levelsofconditions*2) //1:60
        if response == 's' //if response is s for same pics
            acc = 1; //it is correct 
        elseif response == 'd'
            acc = 2; //it is wrong 
        else
            acc = 0; //if response is wrong a
        end
    elseif a(i) <= (levelsofconditions*4) && a(i) > (levelsofconditions*2) //61:120
        if response == 'd' //if response is d for diff pics
            acc = 1; //it's correct
        elseif response == 's' 
            acc = 2; //it's wrong
        else
            acc = 0;
        end
    end

    accuracy = [accuracy acc];
    Data(i).Accuracy = accuracy;//record accuracy into array
    
    RT = [RT resptime];
    Data(i).RT = RT; //record RT into array

    if a(i) <= (levelsofconditions/2) // <=15
        RTSnake = [RTSnake resptime];
        AccSnake = [AccSnake acc];
    elseif a(i) <= (levelsofconditions) && a(i) > (levelsofconditions/2) //<=30 and >15
        RTSnakeGrey = [RTSnakeGrey resptime];
        AccSnakeGrey = [AccSnakeGrey acc];
    elseif a(i) <= (levelsofconditions*1.5) && a(i) > levelsofconditions //30:45
        RTFlower = [RTFlower resptime];
        AccFlower = [AccFlower acc];
    elseif a(i) <= (levelsofconditions*2) && a(i) > (levelsofconditions*1.5) //45:60
        RTFlowerGrey = [RTFlowerGrey resptime];
        AccFlowerGrey = [AccFlowerGrey acc];
    elseif a(i) <= (levelsofconditions*2.5) && a(i) > (levelsofconditions*2) // 60:75
        RTOneSnake = [RTOneSnake resptime];
        AccOneSnake = [AccOneSnake acc];
    elseif a(i) <= (levelsofconditions*3) && a(i) > (levelsofconditions*2.5) // 75:90
        RTOneSnakeGrey = [RTOneSnakeGrey resptime];
        AccOneSnakeGrey = [AccOneSnakeGrey acc];
    elseif a(i) <= (levelsofconditions*3.5)&& a(i) > (levelsofconditions*3) //90:105
        RTOneFlower = [RTOneFlower resptime];
        AccOneFlower = [AccOneFlower acc];
    elseif a(i) <= (levelsofconditions*4) && a(i) > (levelsofconditions*3.5) //105:120
        RTOneFlowerGrey = [RTOneFlowerGrey resptime];
        AccOneFlowerGrey = [AccOneFlowerGrey acc];
    end
    count = count + 1;
 

     fprintf(filename, '%d\t\t%d\t\t%d\t\t%.5f\n', count, trial_condition, ...
         acc, resptime);
     
   

 //INTERTRIAL INTERVAL
 WaitSecs (iti);
 
end


 


// Close out data file 
fprintf(filename, '\r\n');
fclose(filename);
// DISPLAY EXIT

Text_End = 'Thank you for participating in this experiment';
DrawFormattedText (w, Text_End, 'center', 'center', black);
Screen('Flip',w); 
WaitSecs(2);
sca;
