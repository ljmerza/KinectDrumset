/*-----------------------------------------------------------
Created by: AdverseDeviant
Version: 2.3

0 = leftTopDrum
1 - rightTopDrum
2 - rightBottomDrum
3 - snareDrum
4 - hitHatDrum
5 - leftCrashDrum
6 - centerCrashDrum
7 - rightCrashDrum
8 - kickDrum
-----------------------------------------------------------*/

/**----------------------------------------------------------
Classes to import.
-----------------------------------------------------------*/
import SimpleOpenNI.*; 
import ddf.minim.*;

/**----------------------------------------------------------
Variables.
-----------------------------------------------------------*/
// Vector values for hands
PVector SKEL_LEFT_HAND = new PVector();
PVector SKEL_RIGHT_HAND = new PVector();
PVector SKEL_RIGHT_KNEE = new PVector();
PVector SKEL_LEFT_FOOT = new PVector();
PVector SKEL_RIGHT_FOOT = new PVector();

// XYZ coordinates of hands
float SKEL_LEFT_HANDX;
float SKEL_LEFT_HANDY;
float SKEL_LEFT_HANDZ;
float SKEL_RIGHT_HANDX;
float SKEL_RIGHT_HANDY;
float SKEL_RIGHT_HANDZ;
float SKEL_RIGHT_KNEEX;
float SKEL_RIGHT_KNEEY;
float SKEL_RIGHT_KNEEZ;
float SKEL_LEFT_FOOTX;
float SKEL_LEFT_FOOTY;
float SKEL_LEFT_FOOTZ;
float SKEL_RIGHT_FOOTX;
float SKEL_RIGHT_FOOTY;
float SKEL_RIGHT_FOOTZ;

// boolean values of drum hits
int numberOfDrums = 9;

boolean[] hitLeft = new boolean[numberOfDrums];
boolean[] hitRight = new boolean[numberOfDrums];

int[] minX = new int[numberOfDrums];
int[] minY = new int[numberOfDrums];
int[] maxX = new int[numberOfDrums];
int[] maxY = new int[numberOfDrums];
int[] minZ = new int[numberOfDrums];
int[] maxZ = new int[numberOfDrums];

// Size of drawn dot on each joint  
float dotSize = 30;
// Vector to scalar ratio
float vectorScalar = 525;

// Image variable
PImage img;
PImage kinectRGB;

// Kinect object to interact with kinect
SimpleOpenNI kinect;

// Audio player variables
Minim m;
AudioPlayer[] drumSounds= new AudioPlayer[numberOfDrums];

// threshold of level of confidence
float confidenceLevel = 0.1;
// the current confidence level that the kinect is tracking
float confidence;
// vector of tracked head for confidence checking
PVector confidenceVector = new PVector();

// boolean if kinect is tracking
boolean tracking = false;
// current userid of tracked user
int userID;
// mapping of users
int[] userMapping;
// background image
PImage backgroundImage;
// image from rgb camera
PImage rgbImage;

/**----------------------------------------------------------
Setup method. Sets up kinect and draw window. Loads image
and audio player.
-----------------------------------------------------------*/
void setup() 
{ 
  // set proximity variables
  
  // bottom right drum
  minX[2] = 345;
  minY[2] = 330;
  maxX[2] = 430;
  maxY[2] = 350;
  minZ[2] = -180;
  maxZ[2] = -30;
  // snare drum
  minX[3] = 170;
  minY[3] = 320;
  maxX[3] = 260;
  maxY[3] = 345;
  minZ[3] = -180;
  maxZ[3] = -30;
  
  // top left drum
  minX[0] = 225;
  minY[0] = 270;
  maxX[0] = 285;
  maxY[0] = 295;
  minZ[0] = -30;
  maxZ[0] = 120;
  // top right drum
  minX[1] = 300;
  minY[1] = 275;
  maxX[1] = 365;
  maxY[1] = 295;
  minZ[1] = -30;
  maxZ[1] = 120;

  // left crash
  minX[5] = 165;
  minY[5] = 210;
  maxX[5] = 250;
  maxY[5] = 235;
  minZ[5] = 120;
  maxZ[5] = 270;
  // center crash
  minX[6] = 270;
  minY[6] = 230;
  maxX[6] = 320;
  maxY[6] = 245;
  minZ[6] = 120;
  maxZ[6] = 270;
  // right crash
  minX[7] = 350;
  minY[7] = 220;
  maxX[7] = 460;
  maxY[7] = 240;
  minZ[7] = 120;
  maxZ[7] = 270;
  
    // hi hat
  minX[4] = 125;
  minY[4] = 270;
  maxX[4] = 175;
  maxY[4] = 280;
  minZ[4] = 0;
  maxZ[4] = 0;
  // kick drum
  minX[8] = 295;
  minY[8] = 385;
  maxX[8] = 305;
  maxY[8] = 395;
  minZ[8] = 0;
  maxZ[8] = 0;
  
  // set all booleans to false
  for(int i=0;i<numberOfDrums;i++) {
    hitLeft[i] = false;
  } // for(int i=0;i<hitLeft.length();i++)
  for(int i=0;i<numberOfDrums;i++) {
    hitRight[i] = false;
  } // for(int i=0;i<hitLeft.length();i++)

  // create a new kinect object
  kinect = new SimpleOpenNI(this); 
  // mirrors image of kinect to get natural mirror effect
  kinect.setMirror(true); 
  // enable depthMap generation 
  kinect.enableDepth(); 
  // enable rgb sensor
  kinect.enableRGB();
  // enable skeleton generation for joints
  kinect.enableUser();

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
  m = new Minim(this);
  
  // load sounds into AudioPlayer array
  drumSounds[0] = m.loadFile("leftTopDrum.wav");
  drumSounds[1] = m.loadFile("rightTopDrum.wav");
  drumSounds[2] = m.loadFile("rightBottomDrum.wav");
  drumSounds[3] = m.loadFile("snareDrum.wav");
  drumSounds[4] = m.loadFile("hihatDrum.wav");
  drumSounds[5] = m.loadFile("rightCrashDrum.wav");
  drumSounds[6] = m.loadFile("centerCrashDrum.wav");
  drumSounds[7] = m.loadFile("leftCrashDrum.wav");
  drumSounds[8] = m.loadFile("kickDrum.wav");
  
   // turn on depth-color alignment
  kinect.alternativeViewPointDepthToImage(); 

  // load the background image
  backgroundImage = loadImage("qwe.jpg"); 
  
} // void setup()
  
/**----------------------------------------------------------
Draw Method. Loops forever.  Updates kinect cameras amd
draws image in window.  If kinect is tracking then get
coordinates of hands and prints them.  Checks to see if
user hands are in range of drums.
-----------------------------------------------------------*/
void draw() 
{ 
  // display the background image first at (0,0)
  image(backgroundImage, 0, 0);
  
  //update kinect camera
  kinect.update(); 
  //get rgb and depth data
   
// get the Kinect color image
  rgbImage = kinect.rgbImage(); 
  // prepare the color pixels
  loadPixels();
  // get pixels for the user tracked
  userMapping = kinect.userMap();
    
  // for the length of the pixels tracked, color them
  // in with the rgb camera
  for (int i =0; i < userMapping.length; i++) {
    // if the pixel is part of the user
    if (userMapping[i] != 0) {
      // set the sketch pixel to the rgb camera pixel
      pixels[i] = rgbImage.pixels[i]; 
    } // if (userMap[i] != 0)
  } // (int i =0; i < userMap.length; i++)
   
  // update any changed pixels
  updatePixels();
  
  //draw drum image at coordinates (100,200)
  image(img,100,200);
  
  int[] userList = kinect.getUsers();
  
 for(int i=0;i<userList.length;i++)
  {
    // if kinect is tracking ceratin user then get joint vectors
    if(kinect.isTrackingSkeleton(userList[i]))
    {
      // get condidence level that kinect is tracking hip
      confidence = kinect.getJointPositionSkeleton(userList[i],
                          SimpleOpenNI.SKEL_RIGHT_KNEE,confidenceVector);
      // if confidence of tracking is beyond threshold, then track user
      if(confidence > confidenceLevel)
      {
        getCoordinates(userList[i]);
        printHandCoordinates();
      
      //check each drum to see if hands are in proximity
        for(int j=0;j<4;j++)
        {
          checkDrums(j);
        } // for(int j=2;j<4;j++)
        
      } // if(confidence > confidenceLevel)
    } // if(kinect.isTrackingSkeleton(userList[i]))
  } // for(int i=0;i<userList.length;i++)
  
} // void draw() 

/*---------------------------------------------------------------
When a new user is found, print new user detected along with
userID and start pose detection.  Input is userID
----------------------------------------------------------------*/
void onNewUser(SimpleOpenNI curContext, int userId){
  println("New User Detected - userId: " + userId);
  // start tracking of user id
  curContext.startTrackingSkeleton(userId);
} //void onNewUser(SimpleOpenNI curContext, int userId)
   
/*---------------------------------------------------------------
Print when user is lost. Input is int userId of user lost
----------------------------------------------------------------*/
void onLostUser(SimpleOpenNI curContext, int userId){
  // print user lost and user id
  println("User Lost - userId: " + userId);
} //void onLostUser(SimpleOpenNI curContext, int userId)


/**----------------------------------------------------------
Gets XYZ coordinates of tracked hands. Input is user ID.
-----------------------------------------------------------*/ 
void getCoordinates(int userID) 
{
  // get postion of hands
  kinect.getJointPositionSkeleton(userID,SimpleOpenNI.SKEL_LEFT_HAND,SKEL_LEFT_HAND);
  kinect.getJointPositionSkeleton(userID,SimpleOpenNI.SKEL_RIGHT_HAND,SKEL_RIGHT_HAND);
  kinect.getJointPositionSkeleton(userID,SimpleOpenNI.SKEL_RIGHT_KNEE,SKEL_RIGHT_KNEE);
  kinect.getJointPositionSkeleton(userID,SimpleOpenNI.SKEL_RIGHT_FOOT,SKEL_RIGHT_FOOT);
  kinect.getJointPositionSkeleton(userID,SimpleOpenNI.SKEL_LEFT_FOOT,SKEL_LEFT_FOOT);

  // convert real world point to projective space
  kinect.convertRealWorldToProjective(SKEL_LEFT_HAND,SKEL_LEFT_HAND);
  kinect.convertRealWorldToProjective(SKEL_RIGHT_HAND,SKEL_RIGHT_HAND);
  kinect.convertRealWorldToProjective(SKEL_RIGHT_KNEE,SKEL_RIGHT_KNEE);
  kinect.convertRealWorldToProjective(SKEL_RIGHT_FOOT,SKEL_RIGHT_FOOT);
  kinect.convertRealWorldToProjective(SKEL_LEFT_FOOT,SKEL_LEFT_FOOT);

  // scale z vector of each joint to scalar form
  SKEL_LEFT_HANDX = (vectorScalar/SKEL_LEFT_HAND.x);
  SKEL_RIGHT_HANDX = (vectorScalar/SKEL_RIGHT_HAND.x);
  SKEL_LEFT_HANDY = (vectorScalar/SKEL_LEFT_HAND.y);
  SKEL_RIGHT_HANDY = (vectorScalar/SKEL_RIGHT_HAND.y);
  SKEL_LEFT_HANDZ = (vectorScalar/SKEL_LEFT_HAND.z);
  SKEL_RIGHT_HANDZ = (vectorScalar/SKEL_RIGHT_HAND.z);
  SKEL_RIGHT_KNEEX = (vectorScalar/SKEL_RIGHT_KNEE.x);
  SKEL_RIGHT_KNEEY = (vectorScalar/SKEL_RIGHT_KNEE.y);
  SKEL_RIGHT_KNEEZ = (vectorScalar/SKEL_RIGHT_KNEE.z);
  SKEL_LEFT_FOOTX = (vectorScalar/SKEL_LEFT_FOOT.x);
  SKEL_LEFT_FOOTY = (vectorScalar/SKEL_LEFT_FOOT.y);
  SKEL_LEFT_FOOTZ = (vectorScalar/SKEL_LEFT_FOOT.z);
  SKEL_RIGHT_FOOTX = (vectorScalar/SKEL_RIGHT_FOOT.x);
  SKEL_RIGHT_FOOTY = (vectorScalar/SKEL_RIGHT_FOOT.y);
  SKEL_RIGHT_FOOTZ = (vectorScalar/SKEL_RIGHT_FOOT.z);
  
  // fill  the dot color as red
  fill(255,0,0); 
  ellipse(SKEL_LEFT_HAND.x,SKEL_LEFT_HAND.y, SKEL_LEFT_HANDZ*dotSize,SKEL_LEFT_HANDZ*dotSize);
  ellipse(SKEL_RIGHT_HAND.x,SKEL_RIGHT_HAND.y, SKEL_RIGHT_HANDZ*dotSize,SKEL_RIGHT_HANDZ*dotSize);
  ellipse(SKEL_RIGHT_KNEE.x,SKEL_RIGHT_KNEE.y, SKEL_RIGHT_KNEEZ*dotSize,SKEL_RIGHT_KNEEZ*dotSize);
  ellipse(SKEL_RIGHT_FOOT.x,SKEL_RIGHT_FOOT.y, SKEL_RIGHT_FOOTZ*dotSize,SKEL_RIGHT_FOOTZ*dotSize);
  ellipse(SKEL_LEFT_FOOT.x,SKEL_LEFT_FOOT.y, SKEL_LEFT_FOOTZ*dotSize,SKEL_LEFT_FOOTZ*dotSize);

} // void getCoordinates()

/*-----------------------------------------------------------
Prints XYZ coordinates to serial monitor. For debugging.
-----------------------------------------------------------*/
void printHandCoordinates()
{
  println("Left hand XYZ: " + SKEL_LEFT_HAND.x + " " + SKEL_LEFT_HAND.y + " "
          + SKEL_LEFT_HAND.z);
  println("right hand XYZ: " + SKEL_RIGHT_HAND.x + " " + SKEL_RIGHT_HAND.y + " "
          + SKEL_RIGHT_HAND.z);
  println("right knee XYZ: " + SKEL_RIGHT_KNEE.x + " " + SKEL_RIGHT_KNEE.y + " "
          + SKEL_RIGHT_KNEE.z);
  println("right foot XYZ: " + SKEL_RIGHT_FOOT.x + " " + SKEL_RIGHT_FOOT.y + " "
          + SKEL_RIGHT_FOOT.z);
  println("left foot XYZ: " + SKEL_LEFT_FOOT.x + " " + SKEL_LEFT_FOOT.y + " "
          + SKEL_LEFT_FOOT.z);
} // void getHandCoordinates()  

/*-----------------------------------------------------------
Method input is an int of the type of drum.  Checks each hand
to make sure they are above drum to make noise.  Also make
sure noise only happens once until user lifts hands back up.
-----------------------------------------------------------*/ 
void checkDrums(int i)
{
  
    if(SKEL_LEFT_HAND.y < minY[i])
    {
      hitLeft[i] = false;
    } // if left hand is above drum then allow hit
    
    if(SKEL_RIGHT_HAND.y < minY[i])
    {
      hitRight[i] = false;
    } // if right hand is above drum then allow hit
    
    if(SKEL_LEFT_HAND.x > minX[i] & SKEL_LEFT_HAND.x < maxX[i]
    & SKEL_LEFT_HAND.y > minY[i] & SKEL_LEFT_HAND.y < maxY[i]
    & (SKEL_RIGHT_KNEE.z - SKEL_LEFT_HAND.z) > minZ[i] 
    & (SKEL_RIGHT_KNEE.z - SKEL_LEFT_HAND.z) < maxZ[i]
    & !(hitLeft[i]))
    {
        // play the file
        drumSounds[i].play();
        drumSounds[i].rewind();
        hitLeft[i] = true;
    } // if left hand is in drum box then try to make noise
   
    if(SKEL_RIGHT_HAND.x > minX[i] & SKEL_RIGHT_HAND.x < maxX[i]
    & SKEL_RIGHT_HAND.y > minY[i] & SKEL_RIGHT_HAND.y < maxY[i]
    & (SKEL_RIGHT_KNEE.z - SKEL_RIGHT_HAND.z) > minZ[i] 
    & (SKEL_RIGHT_KNEE.z - SKEL_RIGHT_HAND.z) < maxZ[i]
    & !(hitRight[i]))
    {
        // play the file
        drumSounds[i].play();
        drumSounds[i].rewind();
        hitRight[i] = true;
    } // if right hand is in drum box then try to make noise
} // void checkDrums(int i)
