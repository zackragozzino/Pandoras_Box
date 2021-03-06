                                                                                                                                                                                                                                                                                                                                                                                                                         import ddf.minim.*;
import ddf.minim.analysis.*;

int MAX_SQUARES = 200;

int colorwheel = 0; //Determines background and creates dynamic color changes 
boolean incColor = true; //Determines if the colorwheel is increasing or decreasing
float x, y = 0; //Values for the PVector history list
int radius = 10; //Radius of the ellipse. The ellipse is only used for visual reference when coding

int xDirection = 1; //The x direction of the ellipse (either 1 or -1)
int yDirection = 1; //The y direction of the ellipse (either 1 or -1)
float xSpeed = 5.0; //The x speed of the ellipse. Changing these values DOES affect the squares
float ySpeed = 3.0; //The y speed of the ellipse. Changing these values DOES affect the squares

float lineX; //Creates variety in the noise values for the rectangle

float heightMix; //The buffer values stored as a float value
int colorMin, colorMax; //The min and max values for the colorlerp of the boxes. The colorwheel changes between these values

boolean cubeBool = true, playerBool = true; //Used for the while loop of the core of the visualizer

ArrayList<PVector> history = new ArrayList(); //Stores vectors that are used for creating the squares. The default maximum is 200 values
ArrayList<Float> bufferVal = new ArrayList(); //A similar list for storing buffervalues that are read by the squares

int startTime; //A timer that measure extended moments of quietness in a song (used for the shapes class)
boolean timerBegin = false; //Signifies that the timer has begun
boolean startShapes = false; //Signifies that the shapes class is in effect
int interval = 0; //Determines the length of startTime
ArrayList<Shape> shapeList = new ArrayList(); //Used to create X amount of circle shape objects
boolean runOnce = false; //Ensures that theres only one instance of circles appearing on the screen
boolean bgRunOnce = false; //This and bgTimer ensure that the circles change direction at an appropriate time
int bgTimer;

Minim minim;
AudioPlayer player;
String filename = "";
BeatDetect beat;

color from = color(0), to = color(0); //The colors used by lerp to create a gradient between all rectangles on screen

void setup()
{
  colorMode(HSB, 360, 100, 100);
  newColors();

  y = height/3;
  x = width/2;
  frameRate(60);
  beat = new BeatDetect();
  beat.setSensitivity(300); 
  size(1920, 1080,P3D);
  selectInput("Select song:", "fileSelected");
  minim = new Minim(this);
  player = minim.loadFile("A_Airbrushed.mp3", 512);
  loop();
  smooth(6);
  ellipseMode(RADIUS);
}

void draw()
{
  int m = millis();
  background(colorwheel, 40, 40);
  
  //println(colorMin, colorMax);
  //println("COLORWHEEL: "+colorwheel);

  if (colorwheel == colorMin) {
    incColor = true;
  }
  if (colorwheel > colorMax) {
    incColor = false;
  }
  if (incColor == true) { 
    colorwheel++;
  } else { 
    colorwheel--;
  }
  if (colorwheel > 358) {
    colorwheel = 1;
  }
  if (colorwheel<0) {
    incColor=true;
  }

  float lineX = 0;

  PVector circ = new PVector(x, y);
  history.add(circ);

  if (history.size() > MAX_SQUARES)
  {
    history.remove(0);
  }


  x = x + (xSpeed*xDirection);
  y = y + (ySpeed*yDirection);

  if (x > width-radius*5 || x < radius*5) {
    xDirection *= -1;
  }
  if (y > height-radius*5 || y < radius*5) {
    yDirection *= -1;
  }

  if (x>width-10 || y > height-10) {
    x -= 30;
    y -= 30;
  }
  if (x<10 || y<10) {
    x+=30;
    y+=30;
  }

  noFill();
  noStroke();
  //ellipse(x, y, radius, radius);

  int i = 0, j = 0;
  cubeBool = true;
  playerBool = true;

  while (cubeBool == true && playerBool == true)
  {
    if (i > player.bufferSize()) { 
      playerBool = false;
    }
    if (j >= history.size()-1) { 
      cubeBool = false;
    } 
    heightMix = player.mix.get(i);
    line(i, 50 + heightMix*50, i+1, 50 + heightMix*50);

    bufferVal.add(heightMix);
    if (bufferVal.size()>MAX_SQUARES) {
      bufferVal.remove(0);
    }

    beat.detect(player.left);
    
    if ( beat.isOnset() ) 
      {
      if (x<width*0.75) {
        xDirection*=-1;
      if(startShapes==true && bgRunOnce == false)
        reverseDirection(shapeList); 
        bgRunOnce = true;
      }
    }

    to = color(colorwheel, j/2, j);
    pushMatrix();
    PVector position = history.get(j);
    float bufferOffset = bufferVal.get(j);
    if (abs(bufferOffset) < 0.18) {
      bufferOffset*=0.5;
    }

    translate(width/2, height/2);
    if (bufferOffset!=0) {
      xSpeed = 6 * abs(bufferOffset*8) + 2;
      ySpeed = 4 * abs(bufferOffset*8) + 2;
    }


    if (abs(xSpeed) < 6 && timerBegin == false && m > 3000)
    {
      startTime = m;
      timerBegin = true;
    }
    
    if(abs(xSpeed) > 25 && startShapes==true && bgRunOnce == false)
      {
        reverseDirection(shapeList);
        bgRunOnce = true;
        bgTimer = m;
      }
   
    if(abs(xSpeed) < 3 && bgTimer != -1 && m-bgTimer > 1000)
      bgRunOnce = false;
    
    if (abs(xSpeed) > 9)
    {
      if (startTime != -1 && m-startTime>500)
      { 
        if(startShapes == true && shapeList.size() > 0){
        startTime = -1;
        timerBegin = false;
        }
        else{
        interval = m-startTime;
        shapeList = setupShapeList(shapeList,interval);
        startShapes=true;
        startTime = -1;
        timerBegin = false;
        updateColors();
        }
      } 
      else
      {
        startTime = -1;
        timerBegin = false;
      }
    }
    
    stroke(lerpColor(from, to, (float)j/MAX_SQUARES));
    if (bufferOffset > 0.7) {
      updateColors();
    }
    if(m%20000==0)
      updateColors();
    
    noFill(); 
    rectMode(CENTER);
    
    //*OPTIONAL - Adding any combination of these creates different visuals
    //rotateZ(radians(position.x));
    //rotateY(radians(position.x));
    //rotateX(radians(position.x));
    //fill(lerpColor(from,to,(float)i/MAX_SQUARES));
    
    strokeWeight(1);
    rect(0, 0, position.x*0.8+bufferOffset*50, position.y*noise((lineX)/50)+bufferOffset*50);

    popMatrix();
    lineX+=1;
    
    if(startShapes==true && runOnce == false)
    {
      makeShapes(shapeList, xSpeed, ySpeed, bufferOffset);
      runOnce = true;
    }

    i++;
    j++;
  }
  runOnce = false;


}


void newColors() {
  
  colorMin = (int)random(0, 360);
  colorMax = (int)random(100, 150)+colorMin;

  to = color(colorMin, 70, 100);
  from = color(colorMax, 70, 100);

  if (colorMax>360) {
    colorMin-=colorMax-colorMin;
    colorMax-=colorMax-colorMin;

    if (abs(colorMax-colorMin)<30) { 
      colorMax+=150;
    }
  }
}

void updateColors() {
  //colorMin += 20;
  //colorMax += 1;
  colorMax=(int)(colorMin+random(40, 200));
  if (colorMax > colorMin+150) {
    colorMin+=5;
  }
  if (colorMax>360) {
    colorMin-=50;
    updateColors();
  }
  if (colorMin > 360) {
    colorMin -= 360;
  }
}

public ArrayList<Shape> setupShapeList(ArrayList<Shape> shapeList, int interval)
{
    shapeList = new ArrayList<Shape>();
    
    if(interval/50 > 30)
      interval = 1500;
    
    if((interval/50)%2 == 1)
      interval+=50;
    
    for(int b = 0; b < interval/50; b++)
    {
      shapeList.add(new Shape(b,interval/50)); 
    }
    return shapeList;
}

void makeShapes(ArrayList<Shape> shapeList, float xSpeed, float ySpeed, float bufferOffset)
{
    if(shapeList.size()>0)
    for(int r = 0; r<shapeList.size(); r++)
    {
      shapeList.get(r).displayShape(xSpeed, ySpeed);
      shapeList.get(r).moveShape(xSpeed,ySpeed, bufferOffset);
      if(shapeList.get(r).checkEdge() == true)
        shapeList.remove(r);

    }
}
void reverseDirection(ArrayList<Shape> shapeList)
{ 
  if(shapeList.size() > 0 &&
  shapeList.get(0).getPosition().x < width*0.7 && shapeList.get(0).getPosition().x > width*0.3 && shapeList.get(0).getPosition().y < height*0.7 && shapeList.get(0).getPosition().y > height*0.3)
  {
  for(int r = 0; r<shapeList.size(); r++)
    {
      shapeList.get(r).reverse(); 
    }
  }
}


class Shape {
 
  PVector position;
  PVector speed;
  float maxSpeed = 4;
  float musicVelX = 0;
  float musicVelY = 0;
  int opacity = 200;
  
  Shape(){
  position = new PVector(width/2,height/2);
  speed = PVector.random2D();
  speed.mult(maxSpeed);
  }
  
  Shape(int place, int totalShapes)
  {
    position = new PVector(width/2,height/2);
    speed = PVector.fromAngle(TWO_PI * place / totalShapes);
    speed.mult(maxSpeed);
  }
  
  public PVector getPosition()
  {
    return position; 
  }
  
  void displayShape(float xSpeed, float ySpeed){
    noFill();
    musicVelX += xSpeed;
    musicVelY += ySpeed;
    opacity--;
    stroke(365*noise(musicVelX/500),90,90, opacity);
    strokeWeight(5);
    ellipse(position.x, position.y, 50, 50);
  }
  
  public void reverse()
  {
  speed.mult(-1); 
  }
  
  public boolean checkEdge()
  {
    if(opacity < 0)
      return true;
    if(position.x-100 > width || position.x+100 < 0 || position.y-100 > height || position.y+100 < 0)
      return true; 
    else
      return false;
  }
  
  void moveShape(float xSpeed, float ySpeed, float bufferOffset)
  {
    position.add(speed);
  }
  
}

void fileSelected(File selection) {
  if (selection == null) {
    selectInput("Select song:", "fileSelected");
  } else {
    filename = selection.toString();
    print(filename);
    player.close();
    player = minim.loadFile(filename);
    player.play();
    loop();
  }
}
