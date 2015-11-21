Crime Eye
===================
An iOS app that allows users to view crime in a postcode. Various implementations of this service already exist in webapp form, however we wanted to make a truly native iOS app that runs smoothly.

### To setup the project

#### Prerequisites
1. [CocoaPods](https://cocoapods.org/).
2. Xcode 7.7.1+.
3. iOS 9.1+ if running on a device.
4. Swift 2.1.
5. Git command line.

#### Run the project

Clone the project.

```
$ git clone git@gitlab.com:gurpreet-/crime-eye.git
```

Install the pods.

```
$ pod install
```

Open the workspace file and **not** the `.xcodeproj` file.

```
$ open CrimeEye.xcworkspace
```

#### Troubleshooting

+ **I can't install cocoapods**
```
$ sudo gem install cocoapods
ERROR:  While executing gem ... (Errno::EPERM)
    Operation not permitted - /usr/bin/xcodeproj
```
The above error occurs as a result of the new System integrity protection feature introduced in El Capitan. It restricts even administrators from writing to `/usr/bin`. 

To get around the problem, define a new place where your OS looks for `gems`. As an example, I have used the folder `.gems` in my home directory:

```
echo "export GEM_HOME=~/.gems" >> ~/.bashrc
echo "export PATH=$PATH:~/.gems/bin" >> ~/.bashrc
```

+ **Opening CrimeEye.xcodeproj does nothing!**

Open `CrimeEye.xcworkspace` instead!

### Credits
+ Gurpreet Paul
+ Khen Cruzat
+ Kieran Haden
+ Any library authors.

### License 
We give anyone permission to modify the software to do good and for good, under The MIT License. See the file `LICENSE` for more info.

Copyright (c) 2015 Crime Eye