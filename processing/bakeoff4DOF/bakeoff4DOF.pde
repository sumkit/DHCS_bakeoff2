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

// new created global variables
boolean initialCheck = false;
boolean secondCheck = false;
int redT = 255, blueT = 0, greenT = 0;
int redS = 0, blueS = 255, greenS = 127;

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
  size(800, 800); 

  rectMode(CENTER);
  textFont(createFont("Arial", inchesToPixels(.2f))); //sets the font to Arial that is .3" tall
  textAlign(CENTER);

  //don't change this! 
  border = inchesToPixels(.2f); //padding of 0.2 inches
  
  for (int i=0; i < trialCount; i++) //don't change this! 
  {    
    Target t = new Target();
    t.x = random(-width/2+border, width/2-border); //set a random x with some padding
    t.y = random(-height/2+border, height/2-border); //set a random y with some padding
    t.rotation = random(0, 360); //random rotation between 0 and 360
    int j = (int)random(20);
    t.z = ((j%20)+1)*inchesToPixels(.15f); //increasing size from .15 up to 3.0" 
    targets.add(t);
    //println("created target with " + t.x + "," + t.y + "," + t.rotation + "," + t.z);
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

  //===========DRAW TARGET SQUARE=================
  pushMatrix();
  translate(width/2, height/2); //center the drawing coordinates to the center of the screen
  Target t = targets.get(trialIndex);
  translate(t.x, t.y); //center the drawing coordinates to the center of the screen
  rotate(radians(t.rotation));
  fill(redT, blueT, greenT); //set color to semi translucent
  rect(0, 0, t.z, t.z);
  popMatrix();
  
  //===========DRAW SHADOW TARGET SQUARE=================
  if (!secondCheck) {
    pushMatrix();
    translate(width/2, height/2); //center the drawing coordinates to the center of the screen
    translate(screenTransX, screenTransY); //center the drawing coordinates to the center of the screen
    rotate(radians(t.rotation));
    fill(redS, blueS, greenS); //green
    if (!initialCheck) {
      rect(0, 0, 200.0, 200.0);
      stroke(46, 139, 87);
      line(-width/2, -height/2, width/2, height/2);
      line(-width/2, height/2, width/2, -height/2);
    } else {
      rect(0, 0, t.z, t.z);
    }
    popMatrix();
  }
  
  if (secondCheck) {
    stroke(255, 215, 0); // yellow
    line(width/2 + screenTransX, height/2 + screenTransY, width/2 + t.x, height/2 + t.y);
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
  if (!initialCheck) {
    line(-width/2, -height/2, width/2, height/2);
    line(-width/2, height/2, width/2, -height/2);
  }
  popMatrix();
  
    //===========DRAW EXAMPLE CONTROLS=================
  fill(255);
  text("Trial " + (trialIndex+1) + " of " +trialCount, width/2, inchesToPixels(.5f));
}

void mousePressed()
{
    if (startTime == 0) //start time on the instant of the first user click
    {
      startTime = millis();
      println("time started!");
    }
}


void mouseReleased()
{  
  Target t = targets.get(trialIndex);
  
  if (!initialCheck && checkRotation(t)) {
    initialCheck = true;
    redS = 0;
    blueS = 255;
    greenS = 127;
    return;
  }
  
  if (initialCheck && !secondCheck && checkZ(t)) {
    secondCheck = true;
    redS = 0;
    blueS = 255;
    greenS = 127;
    return;
  }
  
  if (initialCheck && secondCheck) {
    if (userDone==false && !checkForSuccess()) {
      errorCount++;
    }
    
    //and move on to next trial
    trialIndex++;
    
    if (trialIndex==trialCount && userDone==false)
    {
      userDone = true;
      finishTime = millis();
    }
    
    initialCheck = false;
    secondCheck = false;
    
    screenTransX = 0;
    screenTransY = 0;
    
    redT = 255;
    blueT = 0;
    greenT = 0;
  }
}

void mouseDragged() {
  Target t = targets.get(trialIndex);
  if (!initialCheck) {
    screenRotation = atan2(mouseY-height/2, mouseX-width/2);
    if (checkRotation(t)) {
      redS = 255;
      blueS = 0;
      greenS = 0;
    } else {
      redS = 0;
      blueS = 255;
      greenS = 127;
    }
  } else if (!secondCheck) {
    screenZ = 2*sqrt(pow((mouseY-(height/2)), 2)+pow((mouseX-(width/2)), 2));
    if (checkZ(t)) {
      redS = 255;
      blueS = 0;
      greenS = 0;
    } else {
      redS = 0;
      blueS = 255;
      greenS = 127;
    }
  } else {
    screenTransX = mouseX - width/2;
    screenTransY = mouseY - height/2;
    if (checkDistance(t)) {
      redT = 0;
      blueT = 255;
      greenT = 127;
    } else {
      redT = 255;
      blueT = 0;
      greenT = 0;
    }
  }
}
  
boolean checkDistance(Target t) {
  return dist(t.x,t.y,screenTransX,screenTransY)<inchesToPixels(.05f); //has to be within .1"
}
boolean checkRotation(Target t) {
  // I've modified it, since screenRotation shows in pi not degrees
  return calculateDifferenceBetweenAngles(t.rotation,degrees(screenRotation))<=5;
}
//z is size
boolean checkZ(Target t) {
  return abs(t.z - screenZ)<inchesToPixels(.05f); //has to be within .1"
}
  
//control the initial bottom left corner of cursor square
void getCursorSquareSide() {
  float xdiff = pow(mouseX-(width/2), 2);
  float ydiff = pow(mouseY-(height/2), 2);
  float diag = sqrt(xdiff + ydiff);
  diag *= 2;
  float side = sqrt(pow(diag, 2)/2);
  screenZ = side;
}

//probably shouldn't modify this, but email me if you want to for some good reason.
public boolean checkForSuccess()
{
	Target t = targets.get(trialIndex);	
	boolean closeDist = checkDistance(t);
  boolean closeRotation = checkRotation(t);
	boolean closeZ = checkZ(t);	
	
  println("Close Enough Distance: " + closeDist + " (cursor X/Y = " + t.x + "/" + t.y + ", target X/Y = " + screenTransX + "/" + screenTransY +")");
  println("Close Enough Rotation: " + closeRotation + " (rot dist="+calculateDifferenceBetweenAngles(t.rotation,screenRotation)+")");
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