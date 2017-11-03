import java.util.ArrayList;
import java.util.Collections;

//these are variables you should probably leave alone
int index = 0;
int trialCount = 8; //this will be set higher for the bakeoff
float border = 0; //have some padding from the sides
int trialIndex = 0; //what trial are we on
int errorCount = 0;  //used to keep track of errors
float errorPenalty = 0.5f; //for every error, add this to mean time
int startTime = 0; // time starts when the first click is captured
int finishTime = 0; //records the time of the final click
boolean userDone = false;

final int screenPPI = 72; //what is the DPI of the screen you are using
//you can test this by drawing a 72x72 pixel rectangle in code, and then confirming with a ruler it is 1x1 inch. 

//These variables are for my example design. Your input code should modify/replace these!
float screenTransX = 0; //current x coord of the cursor square (center)
float screenTransY = 0; //current y coord of the cursor square (center)
float screenRotation = 0;
float screenZ = 50f;

boolean rotationSizePhase;
boolean xyPhase;
float startClickX, startClickY;
boolean mouseInSquare;
float lastClick;
boolean doubleClick;

int red, blue, green; 

private class Target
{
  float x = 0;
  float y = 0;
  float rotation = 0;
  float z = 0;
}

ArrayList<Target> targets = new ArrayList<Target>();

float inchesToPixels(float inch)
{
  return inch*screenPPI;
}

void setup() {
  size(700, 700); 

  rectMode(CENTER);
  textFont(createFont("Arial", inchesToPixels(.2f))); //sets the font to Arial that is .3" tall
  textAlign(CENTER);

  //don't change this! 
  border = inchesToPixels(.2f); //padding of 0.2 inches
  
  rotationSizePhase = true;
  xyPhase = false;
  mouseInSquare = false;
  lastClick = 0;
  doubleClick = false;
  
  red = 255;
  green = 0;
  blue = 0;
  
  for (int i=0; i<trialCount; i++) //don't change this! 
  {
    Target t = new Target();
    t.x = random(-width/2+border, width/2-border); //set a random x with some padding
    t.y = random(-height/2+border, height/2-border); //set a random y with some padding
    t.rotation = random(0, 360); //random rotation between 0 and 360
    int j = (int)random(20);
    t.z = ((j%20)+1)*inchesToPixels(.15f); //increasing size from .15 up to 3.0" 
    targets.add(t);
    println("created target with " + t.x + "," + t.y + "," + t.rotation + "," + t.z);
  }

  Collections.shuffle(targets); // randomize the order of the button; don't change this.
}

void draw() {
  background(60); //background is dark grey
  fill(200);
  noStroke();

  //shouldn't really modify this printout code unless there is a really good reason to
  if (userDone)
  {
    text("User completed " + trialCount + " trials", width/2, inchesToPixels(.2f));
    text("User had " + errorCount + " error(s)", width/2, inchesToPixels(.2f)*2);
    text("User took " + (finishTime-startTime)/1000f/trialCount + " sec per target", width/2, inchesToPixels(.2f)*3);
    text("User took " + ((finishTime-startTime)/1000f/trialCount+(errorCount*errorPenalty)) + " sec per target inc. penalty", width/2, inchesToPixels(.2f)*4);
    return;
  }

  Target t = targets.get(trialIndex);
  //===========DRAW TARGET SQUARE=================
  if(xyPhase) {
    if(checkDistance(t)) {
      red = 0;
      blue = 255;
      green = 127;
    } else {
      red = 255;
      blue = 0;
      green = 0;
    }
    pushMatrix();
    translate(width/2, height/2); //center the drawing coordinates to the center of the screen
    translate(t.x, t.y); //center the drawing coordinates to the center of the screen
    rotate(radians(t.rotation));
    fill(red, blue, green); //blue and green values are swapped by accident... 
    rect(0, 0, t.z, t.z);
    popMatrix();
  }
  
  //===========DRAW SHADOW TARGET SQUARE=================
  if(rotationSizePhase) {
    if(checkRotation(t) && checkZ(t)) {
      red = 0;
      blue = 255;
      green = 127;
    } else {
      red = 255;
      blue = 0;
      green = 0;
    }
    pushMatrix();
    translate(width/2, height/2); //center the drawing coordinates to the center of the screen
    translate(screenTransX, screenTransY); //center the drawing coordinates to the center of the screen
    rotate(radians(t.rotation));
    fill(red, blue, green); //blue and green values are swapped by accident... 
    rect(0, 0, t.z, t.z);
    stroke(46, 139, 87);
    popMatrix();  
  }
  
  //===========DRAW CURSOR SQUARE=================
  pushMatrix();
  translate(width/2, height/2); //center the drawing coordinates to the center of the screen
  translate(screenTransX, screenTransY);
  rotate(screenRotation);
  noFill();
  strokeWeight(3f);
  stroke(160);
  rect(0,0, screenZ, screenZ);
  popMatrix();
  
  if(xyPhase) {
    stroke(255, 215, 0); // yellow
    line(width/2 + screenTransX, height/2 + screenTransY, width/2 + t.x, height/2 + t.y);
    if(checkDistance(targets.get(trialIndex))) {
      red = 0;
      blue = 255;
      green = 127;
    } else {
      red = 255;
      green = 0;
      blue = 0;
    }
  }
  
  //===========DRAW EXAMPLE CONTROLS=================
  fill(255);
  text("Trial " + (trialIndex+1) + " of " +trialCount, width/2, inchesToPixels(.5f));
}

//on cursor square. bottom left corner.
void dragSquareCorner() {
  //float margin = 7;
  //drag bottom left corner
  rotationSizePhase = true;
  screenZ = 2*sqrt(pow((mouseY-(height/2)), 2)+pow((mouseX-(width/2)), 2));
  pushMatrix();
  translate(width/2, height/2);
  //screenRotation = atan2(mouseY-height/2, mouseX-width/2);
  float endDiff = atan2(mouseY-(height/2), mouseX-(width/2));
  float startDiff = atan2(startClickY-(height/2), startClickX-(width/2));
  screenRotation = endDiff - startDiff;
  popMatrix();
  Target t = targets.get(trialIndex);
  if(checkRotation(t) && checkZ(t)) {
    red = 0;
    blue = 255;
    green = 127;
  } else {
    red = 255;
    blue = 0;
    green = 0;
  }
}

boolean mouseInTargetSquare() {
  Target t = targets.get(trialIndex);
  float radius = dist(t.x, t.y, t.x+t.z, t.y+t.z);
  float thisDist = dist(mouseX, mouseY, (width/2)+screenTransX, (height/2)+screenTransY);
  return thisDist <= radius;
}

boolean mouseInCursorSquare() {
  float radius = dist((width/2)+screenTransX, (height/2)+screenTransY, (width/2)+screenTransX-(screenZ/2), (height/2)+screenTransY-(screenZ/2));
  float thisDist = dist(mouseX, mouseY, (width/2)+screenTransX, (height/2)+screenTransY);
  return thisDist <= radius;
}

void mousePressed()
{
  if (startTime == 0) //start time on the instant of the first user click
  {
    startTime = millis();
    println("time started!");
  }
  
  float doubleDist = 5f;
  if(millis()-lastClick < 500 && abs(mouseX - startClickX) < doubleDist && abs(mouseY - startClickY) < doubleDist) {
    doubleClick = true;
  }
  lastClick = millis();
  
  startClickX = mouseX;
  startClickY = mouseY;
  
  mouseInSquare = mouseInCursorSquare();
}

void nextTrial() {
  rotationSizePhase = true;
  xyPhase = false;
  if (userDone==false && !checkForSuccess())
    errorCount++;

  //and move on to next trial
  trialIndex++;
  //reset
  screenZ = 50f;
  screenRotation = 0; 
  screenTransX = 0;
  screenTransY = 0;
  red = 255;
  green = 0;
  blue = 0;
  
  if (trialIndex==trialCount && userDone==false)
  {
    userDone = true;
    finishTime = millis();
  }
}

void mouseReleased()
{
  if(trialIndex >= trialCount) return;
  if(doubleClick) {
    //double click to skip
    if(mouseInTargetSquare()) {
      if(rotationSizePhase && mouseInSquare) {
        rotationSizePhase = false;
        xyPhase = true;
      } else if(xyPhase && mouseInSquare) {
        nextTrial();
      }
    } else {
      nextTrial();
    }
    doubleClick = false;
    lastClick = 0;
  }
  mouseInSquare = false;
}

void mouseDragged() {
  if(rotationSizePhase) {
    if(mouseInSquare)
      dragSquareCorner();
  }
  else {
    if(mouseInSquare) {
      screenTransX = mouseX - (width/2);
      screenTransY = mouseY - (height/2);
    }
  }
}
  
boolean checkDistance(Target t) {
  return dist(t.x,t.y,screenTransX,screenTransY)<inchesToPixels(.05f); //has to be within .1"
}
boolean checkRotation(Target t) {
  return calculateDifferenceBetweenAngles(t.rotation,degrees(screenRotation))<=5;
}
//z is size
boolean checkZ(Target t) {
  return abs(t.z - screenZ)<inchesToPixels(.05f); //has to be within .1"
}

//probably shouldn't modify this, but email me if you want to for some good reason.
public boolean checkForSuccess()
{
	Target t = targets.get(trialIndex);	
	boolean closeDist = checkDistance(t);
  boolean closeRotation = checkRotation(t);
	boolean closeZ = checkZ(t);	
	
  println("Close Enough Distance: " + closeDist + " (cursor X/Y = " + t.x + "/" + t.y + ", target X/Y = " + screenTransX + "/" + screenTransY +")");
  println("Close Enough Rotation: " + closeRotation + " (rot dist="+calculateDifferenceBetweenAngles(t.rotation,degrees(screenRotation))+")");
 	println("Close Enough Z: " +  closeZ + " (cursor Z = " + t.z + ", target Z = " + screenZ +")");
	
	return closeDist && closeRotation && closeZ;	
}

//utility function I include
double calculateDifferenceBetweenAngles(float a1, float a2)
{
   double diff=abs(a1-a2);
    diff%=90;
    if (diff>45)
      return 90-diff;
    else
      return diff;
 }