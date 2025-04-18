# ADHD Screener

## What is this app?
Over 80% of people with ADHD are left untreated, with many of them being undiagnosed. This is a concept for a ADHD Screener that can be accessed through common devices like a phone or iPad. 

It is programmed in **Swift** and later transitioned from **XCode** to **Swift Playgrounds.**

## How does it work?
According to many sources such as this study: https://pubmed.ncbi.nlm.nih.gov/24863585/, people with ADHD tend to have many **more microsaccades and blinks** in anticipation of visual stimuli, whilst fixated at a point for more than a few seconds. 

The eye-tracking part of the app works by asking the user to stare at a certain point in the screen whilst having dots with random colors appear at random parts of the screen, acting as a distraction. 

A **"score"** is kept throughout the program, calculating it through a comparison in number of microsaccades and blinks in the time period, and also through the ASRS v1.1 ADHD testing survey.

The number of microsaccades are found simply by calculating the user's eye's **velocity** and **displacement**, comparing them with thresholds (that can be adjusted): 

```swift
let velocity_threshold = average_velocity * 6
let displacement_threshold = 0.1

data.velocity > velocity_threshold && data.displacement > displacement_threshold
```

The number of blinks are found using apple's built-in ARKit library.
Here, a numerical value means how **deeply** a person is blinking (this can also be adjusted).

```swift
let blinkThreshold = 0.75

if leftEyeBlink > blinkThreshold && rightEyeBlink > blinkThreshold {
	if !self.isWinking {
	    self.blinkCount += 1
	}      
	self.isWinking = false
} else {  
	self.isWinking = true
}
```


In addition, the ASRS v1.1 ADHD testing survey was implemented in the app, to provide more accuracy together with the eye-tracking part of the app. It is also compared with an average score for people with ADHD, and a value is added to the “score”. Lastly, the “adhd score” is compared to some boundaries to determine how likely ADHD is for the user.

## Why Swift playgrounds?
Swift playgrounds offers much faster and easier testing as apps can be directly programmed on the device that that app is being tested on. It also offers much more simplicity! Although a major caveat of this is that it has issues with flexibility and features compared to XCode, it offers more than enough for the purpose of this app to be fulfilled. 

This app was programmed and tested on an iPad Pro M1, and also tested on an iPhone 14 while on development in XCode.

## Frameworks used
ARKit - For Eye tracking
SwiftUI - App UI

## Credits
**Shiru99**'s ARKit tutorial in medium was *extremely* helpful in teaching me how to implement eye tracking. Parts of his eye tracking code were used as the basis of my project! 
Here is his eye tracking code: https://github.com/Shiru99/AR-Eye-Tracker

**ASRS v1.1** - A standard ADHD testing survey was used.

**Unsplash** and **public domain vectors** images
