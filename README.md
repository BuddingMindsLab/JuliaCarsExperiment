## JuliaCarsExperiment

To run this code, open Terminal and clone: `git clone https://github.com/BuddingMindsLab/JuliaCarsExperiment.git`, then open the .xcodeproj file and upload to the iPad.

#### Parameters
The following parameters can be adjusted from the app's home screen.

- `Button Delay`
    In seconds, the time for "next" button to show after crown has been shown
    Default: 0.5s
- `Cars`
    In seconds, the time for just the cars (no crown)
    Default: 0.5s
- `Cars & Crown`
    In seconds, the time for both the cars and the crown
    Default: 4.0s
- `Between Trials`
    In seconds, the time for the white screen before next set of stimuli
    Default: 0.5s
- `Max stimuli`
    Number of stimuli to be presented in Study Phase. This is actually the index number in the input .csv file
    Default: 51
    
#### Input Files
The sequence of study and test images are detailed in ./data/group*.csv. The particular group chosen is calculated by `Subject ID % 10`. 

#### Data Output
The output data is saved under <subjectID>.csv. Make sure to use unique subject IDs for each participant. This csv file will be seen as an attachment in the Email dialog at the end of the experiment. In case the experiment ends prematurely, you can still recover partial data using the iMazing app. 
  
#### Debugging
Please contact tianyu.lu@mail.utoronto.ca if there are any issues.
