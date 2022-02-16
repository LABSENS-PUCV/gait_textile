# gait_textile
"Detection of Human Gait Phases Using Textile Pressure Sensors: A Low Cost and Pervasive Approach" paper public repository. Created by Milovic, M.; Pizarro, F.; Fingerhuth, S.; Hermosilla, G.; Farías, G.; Yunge, D..

Based on the previous paper "Easy-to-build textile pressure sensor" published in Sensors. Created by Pizarro, F.; Villavicencio, P.; Yunge, D.; Rodríguez, M.; Hermosilla, G.; Leiva, A.

The structure of the repository is as follows:

1.- "Acquisition_board" directory contains all the files associated to the elaboration of the acquisition board used in the pants, considering PCB, code of the microcontroller, and 3D object files of the case used for the acquisition board.

2.- "Features_Classification" directory contains only one Jupyter Notebook file that contains the processes implemented to extract features from the data of the sensors, but also to elaborate the classification models and testing them.

3.- "Annotation_code" directory contains a file called "GaitAnnotation", which was written in Python and contains the method for labeling gait phases with a WebCam. This file requires a lot of libraries and BlazePose model to avhieve good 
results when assessing the position of different parts of the body.

4.- "Preprocessing" directory, which has all the Matlab code for preprocessing the data.