import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import SimpleOpenNI.*; 
import ddf.minim.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class processing extends PApplet {

/*
Created by: AdverseDeviant
Version: 0.9
*/

/**----------------------------------------------------------
Classes to import.
-----------------------------------------------------------*/
 


/**----------------------------------------------------------
Variables.
-----------------------------------------------------------*/
// Vector values for hands
PVector SKEL_LEFT_HAND = new PVector();
PVector SKEL_RIGHT_HAND = new PVector();

// XYZ coordinates of hands
float SKEL_LEFT_HANDX;
float SKEL_LEFT_HANDY;
float SKEL_LEFT_HANDZ;
float SKEL_RIGHT_HANDX;
float SKEL_RIGHT_HANDY;
float SKEL_RIGHT_HANDZ;

// Size of drawn dot on each jint  
float dotSize = 30;
// Vector to scalar ratio
float vectorScalar = 525;

// Image variable
PImage img;

// Kinect object to interact with kinect
SimpleOpenNI kinect;

// Audio player variables
Minim minim;
AudioPlayer player;

// boolean vlaues of hand on drum
boolean leftTopDrum = false;
boolean rightTopDrum = false;
boolean rightBottomDrum = false;
boolean snareDrum = false;
boolean hihatDrum = false;
boolean leftCrashDrum = false;
boolean centerCrashDrum = false;
boolean rightCrashDrum = false;
boolean kickDrum = false;
/**----------------------------------------------------------
Setup method. Sets up kinect and draw window. Loads image
and audio player.
-----------------------------------------------------------*/
public void setup() 
{ 
  // create a new kinect object
  kinect = new SimpleOpenNI(this); 
  // mirrors image of kinect to get natural mirror effect
  kinect.setMirror(true); 
  // enable depthMap generation 
  kinect.enableDepth(); 
  // enable rgb sensor
  kinect.enableRGB();
  // enable skeleton generation for all joints
  kinect.enableUser(SimpleOpenNI.SKEL_PROFILE_ALL);
  
  // create a window the size of the depth information
  size(kinect.depthWidth(), kinect.depthHeight()); 
  // window background color
  background(200,0,0);
  // drawer color is red
  stroke(255,0,0);
  // thickness of drawer is small
  strokeWeight(1);
  // smooth out drawer
  smooth();
  
  // load image
  img = loadImage("drumset.png");
  // load sound player
  minim = new Minim(this);
} // void setup()

/**----------------------------------------------------------
Draw Method. Loops forever.  Updates kinect cameras amd
draws image in window.  If kinect is tracking then get
coordinates of hands and prints them.  Checks to see if
user hands are in range of drums.
-----------------------------------------------------------*/
public void draw() 
{ 
  //update kinect camera
  kinect.update(); 
  //draw rgb image at coordinates (0,0)
  image(kinect.rgbImage(),0,0);
  //draw drum image at coordinates (100,200)
  image(img,100,200);
  
  // if kinect is tracking user 01
  if (kinect.isTrackingSkeleton(1)) 
  { 
    getCoordinates();
    printHandCoordinates();
    //check each drum to see if hands are in proximity
    leftTopDrum();
    rightTopDrum();
    rightBottomDrum();
    snareDrum();
    hihatDrum();
    leftCrashDrum();
    centerCrashDrum();
    rightCrashDrum();
    kickDrum();
  } // if tracking draw skeleton, update joint angles, and print angles
} // void draw() 

/**----------------------------------------------------------
Called when new user is found.  Prints new user ID and
starts pose detection if skeleton tracking is not enabled.
If it is then end method. Input is int user ID of new user.
-----------------------------------------------------------*/
public void onNewUser(int userId) 
{ 
  println("onNewUser - userId: " + userId); 
  
  if (kinect.isTrackingSkeleton(1)) 
    return; 
    
  println(" start pose detection"); 
  kinect.startPoseDetection("Psi", userId);
  
} // void onNewUser(int userId)

/**----------------------------------------------------------
Called when a user is lost. Prints the user ID of user lost.
Input is int userId of lost user.
-----------------------------------------------------------*/
public void onLostUser(int userId) 
{ 
  println("onLostUser - userId: " + userId); 
}

/**----------------------------------------------------------
Called when pose is detected.  Stops pose detection and
requests for a skeleton calibration. Input is String of
the pose detected and int user ID.
-----------------------------------------------------------*/
public void onStartPose(String pose, int userId) 
{ 
  println("onStartPose - userId: " + userId + ", pose: " + pose); 
  println(" stop pose detection"); 
  kinect.stopPoseDetection(userId); 
  kinect.requestCalibrationSkeleton(userId, true); 
}

/**----------------------------------------------------------
Called when a pose has ended.  Input is String pose detected
and int user ID.
-----------------------------------------------------------*/
public void onEndPose(String pose, int userId)
{ 
  println("onEndPose - userId: " + userId + ", pose: " + pose); 
} 

/**----------------------------------------------------------
Called when skeleton calibration starts. Input is int user ID.
-----------------------------------------------------------*/
public void onStartCalibration(int userId) 
{ 
  println("onStartCalibration - userId: " + userId); 
} 

/**----------------------------------------------------------
Called when skeleton calibration has ended.  If calibration
has been successful, then start tracking skeleton otherwise
start pose detection again. Input is int user ID and boolean
if user has been successfully calibrated.
-----------------------------------------------------------*/
public void onEndCalibration(int userId, boolean successfull)
{ 
  println("onEndCalibration - userId: " + userId + ", successfull: " + successfull); 
  if (successfull) 
  { 
    println(" User calibrated !!!"); 
    kinect.startTrackingSkeleton(userId); 
  } 
  else 
  { 
    println(" Failed to calibrate user !!!"); 
    println(" Start pose detection"); 
    kinect.startPoseDetection("Psi", userId); 
  } 
}

/**----------------------------------------------------------
Gets XYZ coordinates of tracked hands.
-----------------------------------------------------------*/ 
public void getCoordinates() 
{
  // get postion of hands
  kinect.getJointPositionSkeleton(1,SimpleOpenNI.SKEL_LEFT_HAND,SKEL_LEFT_HAND);
  kinect.getJointPositionSkeleton(1,SimpleOpenNI.SKEL_RIGHT_HAND,SKEL_RIGHT_HAND);

  // convert real world point to projective space
  kinect.convertRealWorldToProjective(SKEL_LEFT_HAND,SKEL_LEFT_HAND);
  kinect.convertRealWorldToProjective(SKEL_RIGHT_HAND,SKEL_RIGHT_HAND);

  // scale z vector of each joint to scalar form
  SKEL_LEFT_HANDX = (vectorScalar/SKEL_LEFT_HAND.x);
  SKEL_RIGHT_HANDX = (vectorScalar/SKEL_RIGHT_HAND.x);
  SKEL_LEFT_HANDY = (vectorScalar/SKEL_LEFT_HAND.y);
  SKEL_RIGHT_HANDY = (vectorScalar/SKEL_RIGHT_HAND.y);
  SKEL_LEFT_HANDZ = (vectorScalar/SKEL_LEFT_HAND.z);
  SKEL_RIGHT_HANDZ = (vectorScalar/SKEL_RIGHT_HAND.z);
  
  // fill  the dot color as red
  fill(255,0,0); 
  ellipse(SKEL_LEFT_HAND.x,SKEL_LEFT_HAND.y, SKEL_LEFT_HANDZ*dotSize,SKEL_LEFT_HANDZ*dotSize);
  ellipse(SKEL_RIGHT_HAND.x,SKEL_RIGHT_HAND.y, SKEL_RIGHT_HANDZ*dotSize,SKEL_RIGHT_HANDZ*dotSize);
} // void getCoordinates()

/*-----------------------------------------------------------
Prints XYZ coordinates to serial monitor. For debugging.
-----------------------------------------------------------*/
public void printHandCoordinates()
{
  println("Left hand XYZ: " + SKEL_LEFT_HAND.x + " " + SKEL_LEFT_HAND.y + " "
          + SKEL_LEFT_HAND.z);
  println("right hand XYZ: " + SKEL_RIGHT_HAND.x + " " + SKEL_RIGHT_HAND.y + " "
          + SKEL_RIGHT_HAND.z);
} // void getHandCoordinates()

/**----------------------------------------------------------
If user tracked hands are in left top drum's area, then
play sound.
-----------------------------------------------------------*/
public void leftTopDrum()
{
  if((SKEL_LEFT_HAND.x > 250 & SKEL_LEFT_HAND.x < 260
    & SKEL_LEFT_HAND.y > 280 & SKEL_LEFT_HAND.y < 290 
    & leftTopDrum == false) 
    | (SKEL_RIGHT_HAND.x > 250 & SKEL_RIGHT_HAND.x < 260
    & SKEL_RIGHT_HAND.y > 280 & SKEL_RIGHT_HAND.y < 290 
    & leftTopDrum == false))
    {
      // load sound
      player = minim.loadFile("leftTopDrum.wav");
      // play the file
      player.play();
      leftTopDrum = true;
    }
    else
    {
      leftTopDrum = false;
    }
} // void leftTopDrum()

/**----------------------------------------------------------
If user tracked hands are in right top drum's area, then
play sound.
-----------------------------------------------------------*/
public void rightTopDrum()
{
  if((SKEL_LEFT_HAND.x > 325 & SKEL_LEFT_HAND.x < 335
    & SKEL_LEFT_HAND.y > 285 & SKEL_LEFT_HAND.y < 295
    & rightTopDrum == false) 
    | (SKEL_RIGHT_HAND.x > 325 & SKEL_RIGHT_HAND.x < 335
    & SKEL_RIGHT_HAND.y > 285 & SKEL_RIGHT_HAND.y < 295 
    & rightTopDrum == false))
    {
      // load sound
      player = minim.loadFile("rightTopDrum.wav");
      // play the file
      player.play();
      rightTopDrum = true;
    }
    else
    {
      rightTopDrum = false;
    }
} // void rightTopDrum()

/**----------------------------------------------------------
If user tracked hands are in right bottom drum's area, then
play sound.
-----------------------------------------------------------*/
public void rightBottomDrum()
{
  if((SKEL_LEFT_HAND.x > 385 & SKEL_LEFT_HAND.x < 395
    & SKEL_LEFT_HAND.y > 340 & SKEL_LEFT_HAND.y < 350
    & rightBottomDrum == false) 
    | (SKEL_RIGHT_HAND.x > 385 & SKEL_RIGHT_HAND.x <395
    & SKEL_RIGHT_HAND.y > 340 & SKEL_RIGHT_HAND.y < 350 
    & rightBottomDrum == false))
    {
      // load sound
      player = minim.loadFile("rightBottomDrum.wav");
      // play the file
      player.play();
      rightBottomDrum = true;
    }
    else
    {
      rightBottomDrum = false;
    }
} // void rightBottomDrum()

/**----------------------------------------------------------
If user tracked hands are in snare drum's area, then
play sound.
-----------------------------------------------------------*/
public void snareDrum()
{
  if((SKEL_LEFT_HAND.x > 215 & SKEL_LEFT_HAND.x < 225
    & SKEL_LEFT_HAND.y > 325 & SKEL_LEFT_HAND.y < 335
    & snareDrum == false) 
    | (SKEL_RIGHT_HAND.x > 215 & SKEL_RIGHT_HAND.x < 225
    & SKEL_RIGHT_HAND.y > 325 & SKEL_RIGHT_HAND.y < 335 
    & snareDrum == false))
    {
      // load sound
      player = minim.loadFile("snareDrum.wav");
      // play the file
      player.play();
      snareDrum = true;
    }
    else
    {
      snareDrum = false;
    }
} // void snareDrum()

/**----------------------------------------------------------
If user tracked hands are in hihat drum's area, then
play sound.
-----------------------------------------------------------*/
public void hihatDrum()
{
  if((SKEL_LEFT_HAND.x > 145 & SKEL_LEFT_HAND.x < 155
    & SKEL_LEFT_HAND.y > 275 & SKEL_LEFT_HAND.y < 285
    & hihatDrum == false) 
    | (SKEL_RIGHT_HAND.x > 145 & SKEL_RIGHT_HAND.x < 155
    & SKEL_RIGHT_HAND.y > 275 & SKEL_RIGHT_HAND.y < 285 
    & hihatDrum == false))
    {
      // load sound
      player = minim.loadFile("hihatDrum.wav");
      // play the file
      player.play();
      hihatDrum = true;
    }
    else
    {
      hihatDrum = false;
    }
} // void hihatDrum()

/**----------------------------------------------------------
If user tracked hands are in left crash drum's area, then
play sound.
-----------------------------------------------------------*/
public void leftCrashDrum()
{
  if((SKEL_LEFT_HAND.x > 210 & SKEL_LEFT_HAND.x < 220
    & SKEL_LEFT_HAND.y > 220 & SKEL_LEFT_HAND.y < 230
    & leftCrashDrum == false) 
    | (SKEL_RIGHT_HAND.x > 210 & SKEL_RIGHT_HAND.x < 220
    & SKEL_RIGHT_HAND.y > 220 & SKEL_RIGHT_HAND.y < 230 
    & leftCrashDrum == false))
    {
      // load sound
      player = minim.loadFile("leftCrashDrum.wav");
      // play the file
      player.play();
      leftCrashDrum = true;
    }
    else
    {
      leftCrashDrum = false;
    }
} // void leftCrashDrum()

/**----------------------------------------------------------
If user tracked hands are in center crash drum's area, then
play sound.
-----------------------------------------------------------*/
public void centerCrashDrum()
{
  if((SKEL_LEFT_HAND.x > 280 & SKEL_LEFT_HAND.x < 290
    & SKEL_LEFT_HAND.y > 220 & SKEL_LEFT_HAND.y < 230
    & centerCrashDrum == false) 
    | (SKEL_RIGHT_HAND.x > 280 & SKEL_RIGHT_HAND.x < 290
    & SKEL_RIGHT_HAND.y > 220 & SKEL_RIGHT_HAND.y < 230 
    & centerCrashDrum == false))
    {
      // load sound
      player = minim.loadFile("centerCrashDrum.wav");
      // play the file
      player.play();
      centerCrashDrum = true;
    }
    else
    {
      centerCrashDrum = false;
    }
} // void centerCrashDrum()

/**----------------------------------------------------------
If user tracked hands are in right crash drum's area, then
play sound.
-----------------------------------------------------------*/
public void rightCrashDrum()
{
  if((SKEL_LEFT_HAND.x > 395 & SKEL_LEFT_HAND.x < 405
    & SKEL_LEFT_HAND.y > 225 & SKEL_LEFT_HAND.y < 235
    & rightCrashDrum == false) 
    | (SKEL_RIGHT_HAND.x > 395 & SKEL_RIGHT_HAND.x < 405
    & SKEL_RIGHT_HAND.y > 225 & SKEL_RIGHT_HAND.y < 235 
    & rightCrashDrum == false))
    {
      // load sound
      player = minim.loadFile("rightCrashDrum.wav");
      // play the file
      player.play();
      rightCrashDrum = true;
    }
    else
    {
      rightCrashDrum = false;
    }
} // void rightCrashDrum()

/**----------------------------------------------------------
If user tracked hands are in kick drum's area, then
play sound.
-----------------------------------------------------------*/
public void kickDrum()
{
  if((SKEL_LEFT_HAND.x > 295 & SKEL_LEFT_HAND.x < 305
    & SKEL_LEFT_HAND.y > 385 & SKEL_LEFT_HAND.y < 395
    & kickDrum == false) 
    | (SKEL_RIGHT_HAND.x > 295 & SKEL_RIGHT_HAND.x < 305
    & SKEL_RIGHT_HAND.y > 385 & SKEL_RIGHT_HAND.y < 395 
    & kickDrum == false))
    {
      // load sound
      player = minim.loadFile("kickDrum.wav");
      // play the file
      player.play();
      kickDrum = true;
    }
    else
    {
      kickDrum = false;
    }
} // void kickDrum()
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "processing" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
