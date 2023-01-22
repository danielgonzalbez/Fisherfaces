# Fisherfaces
Facial recognition system with fisherfaces in MATLAB.

In this project I will be using the Yale Database. It contains 165 images in GIF format of 15 individuals. There are 11 images per person. Each photo was taken with a different expression, illumination or pose and there is one where the person is wearing glasses. This variability in the images is very important, as it will force the algorithm to identify the traits of the available faces that distinguish each other, regardless of how the pictures were taken. The size of each image is 243x320 grayscale. I set the size of each image for computational reasons to 80x80.

I use as training set a total of 150 images, while the test set consists of 15 pictures (a random photo of each individual). This project also offers the pos- sibility of using a GUI, so that the users can check the performance of the algorithm.

The GUI offers the possibility of choosing a random image among the ones in the test set in order to find a significant match in the training set. The user will obtain the identity of the subject that corresponds to the chosen image according to the method used. If there is no a significant match found, the GUI will report it to the user. Apart from that, the user has the option of changing the threshold of significance (within a fixed interval) it is required to consider a potential match as a real match.

I wanted to make the GUI applicable in a real world scenario. That’s why I decided to give the option to the users of adding their own pictures to the available training set (to register a new individual in the database) or of pre- dicting the identity of an image that is not in the initial test set (more than one image may be necessary to find a significant match in the training set). Every new image sent by the user will be preprocessed so that it is resized to the size of the rest of images in the database.

### faces.m
Contains the main code that implements the user interface and interacts with the user.

### faces.fig
Design of the GUI figure.

### test.m
Script that predicts the identity of 15 test images a total of 50 times and measures the accuracy of the algorithm.

