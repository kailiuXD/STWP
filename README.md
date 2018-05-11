# STWP
matlab code for 3D skeleton action recognition
# [Spatio-Temporal Weighted Posture Motion Features for Skeleton-Based Action Recognition] 
# by DING Chong-Yang and LIQ Kai(http://web.xidian.edu.cn/kailiu/).
# Our recent work on 3D action recognition based on Raviteja Vemulapalli's work:
************************************************************************************
   Raviteja Vemulapalli, Felipe Arrate, and Rama Chellappa, "Human Action Recognition 
   by Representing 3D Human Skeletons as Points in a Lie Group", CVPR, 2014.
************************************************************************************

please cite it if you are going to use it.

************************************************************************************
The code is implemented by Raviteja Vemulapalli and developed by us to mainly comparing the 
performance of some different feature-extract methods, such as Joint locations, Joint angles, 
Lie group and STWP(proposed by us, and turned out to be a better approach compared with others).

This code has been implemented in Matlab R2017a and tested in both Linux (ubuntu) and Windows 7.


# Experimental setting:

Cross-subject - half of the subjects used for training and the remaining half used for testing.
Results are averaged over 10 different training and test subject combinations.


# Datasets

We provide pre-computed skeleton sequences for all the datasets supported:
* [MSR Action 3D](http://research.microsoft.com/en-us/um/people/zliu/ActionRecoRsrc)
* [UTKinect Action 3D](http://cvrc.ece.utexas.edu/KinectDatasets/HOJ3D.html)
* [Florence 3D Actions](https://www.micc.unifi.it/resources/datasets/florence-3d-actions-dataset)


# Run

The matlab file "run.m" runs the experiments for UTKinect-Action, Florence3D-Action and MSRAction3D datasets using 5 
different skeletal representations: 'JP', 'RJP', 'JA', 'Lie Group' and 'STWP'.

The file "skeletal_action_classification.m" contains the code for entire pipeline:
Step 1: Skeletal representation ('JP' or 'RJP' or 'JA' or 'Lie Group' or 'STWP')
Step 2: Temporal modeling (DTW and Fourier Temporal Pyramid)
Step 3: Classification: One-vs-All linear SVM (implemented as kernel SVM with linear kernel)

# Results

On the MSRAction3D dataset, which we have downloaded into this file, the recognition rates of  different skeletal 
representations: 'JP', 'RJP', 'JA', 'Lie Group' and 'STWP' are:

88.75%, 88.87%, 75.39%, 89.55%, 92.79%


# Contact us

For any query please contact us for more information (kailiu@mail.xidian.edu.cn).
