float rotateX = 0;
float rotateZ = 0;
float speed = 0.5;
float e;
int i = -1;
boolean shiftPressed = false;
Mover mover = new Mover();
PVector[] locations = new PVector[10];
final float cylBase = 20;
final float cylHeight = 40;
final float sphereRadius = 15;
final float boxThickness = 12;
final float distance = sphereRadius + cylBase;
Cylinder cylinder = new Cylinder(0, 0, cylBase, cylHeight, 50);
PGraphics dataBackground;
PGraphics topView;
PGraphics scoreBoard;
PGraphics barChart;
float score;
float lastScoreGained;
int frames = 0;
int rectNumber = 0;
ArrayList<Integer> rectTab = new ArrayList<Integer>();
int shiftNumber = 0;
HScrollbar bar = new HScrollbar(205, 485, 285, 10);
ImageProcessing imgproc;
PVector rot;

void settings() {
  size(500, 500, P3D);
}

void setup() {
  noStroke();
  imgproc = new ImageProcessing();
  String []args = {"Image processing window"};
  PApplet.runSketch(args, imgproc);
  //rot = imgproc.getRotation();
  //println(rot.x);

  dataBackground = createGraphics(500, 100, P2D);
  topView = createGraphics(80, 80, P2D);
  scoreBoard = createGraphics(90, 90, P2D);
  barChart = createGraphics(285, 70, P2D);
}

void draw() {
  rot = imgproc.getRotation();
  if (rot.x> PI/3)
    rot.x = PI/3;
  else if (rot.x < (-PI)/3)
    rot.x = (-PI)/3;

  if (rot.y > PI/3)
    rot.y = PI/3;
  else if (rot.y < (-PI)/3)
    rot.y = (-PI)/3;

  println("rX = " + rot.x + ", rY = " + rot.y + ", rZ = " + rot.z);
  background(200);
  drawDataBackground();
  drawTopView();
  drawScoreBoard();
  drawBarChart();
  image(dataBackground, 0, 400);
  image(topView, 10, 410);
  image(scoreBoard, 100, 405);
  image(barChart, 205, 405);
  bar.update();
  bar.display();
  directionalLight(50, 100, 125, 0, -1, 0);
  ambientLight(102, 102, 102);
  //translate à supprimer (reasons: Sheitan)
  translate(width/2, height/2, 0);
  cylinder.cylinderSetup();
  score = mover.ballScore;
  lastScoreGained = mover.lastBallScore;

  if (shiftPressed) {
    rotateX(PI/2);
    fill(255, 0, 0);
    box(250, 25, 250);
    fill(0, 125, 255);
    pushMatrix();
    rotateX(-PI/2);
    translate(mover.location.x, mover.location.z, (sphereRadius + boxThickness/2));
    sphere(sphereRadius);
    popMatrix();
    fill(0);
    if (cylinderInPlate(mouseX, mouseY) && !cylinderOnBall(mouseX, mouseY)) {      
      pushMatrix();
      rotateX(-PI/2);
      translate(mouseX - width/2, mouseY - height/2, (sphereRadius + boxThickness/2));
      sphere(cylBase);
      popMatrix();
    }  
    if (i != -1) {
      for (int k = 0; k <= i; ++k) {
        cylinder.location.x = locations[k].x;
        cylinder.location.y= locations[k].y;
        cylinder.drawVerticalCylinder();
      }
    }
  } else {
    fill(125);
    rotateX(rot.x);
    rotateZ(rot.y);
    box(250, 12, 250);
    if (i != -1) {
      for (int j = 0; j <= i; ++j) {
        cylinder.location.x = locations[j].x;
        cylinder.location.y= locations[j].y;
        cylinder.drawCylinder();
      }
    }

    mover.update();
    mover.checkEdges();  
    mover.checkCylinderCollision(locations, distance);
    translate(mover.location.x, -(sphereRadius + boxThickness/2), mover.location.z);
    sphere(sphereRadius);
  }
}

void drawDataBackground() {
  dataBackground.beginDraw();
  dataBackground.background(240, 230, 140);
  dataBackground.endDraw();
}

void drawTopView() {
  float scale = 250.0/80.0;
  topView.beginDraw();
  topView.background(24, 116, 205);
  topView.fill(205, 55, 0);
  topView.ellipse((mover.location.x) / scale + topView.width/2, (mover.location.z) / scale + topView.height/2, 9.6, 9.6);
  topView.fill(255, 246, 143);
  if (i != -1) {
    for (int j = 0; j <= i; ++j) {
      topView.ellipse(locations[j].x / scale + topView.width/2, locations[j].y / scale + topView.height/2, 12.8, 12.8);
    }
  }
  topView.endDraw();
}

void drawScoreBoard() {
  String s = "Total score: " + score;
  String v = "Velocity: " + mover.velocity.mag();
  String h = "Last score: " + lastScoreGained;
  scoreBoard.beginDraw();
  scoreBoard.background(200);
  scoreBoard.text(s, 10, 3, scoreBoard.width - 10, scoreBoard.height/3);
  scoreBoard.text(v, 10, 3 + scoreBoard.height/3, scoreBoard.width - 10, scoreBoard.height/3);
  scoreBoard.text(h, 10, 2*scoreBoard.height/3, scoreBoard.width - 10, scoreBoard.height/3);
  scoreBoard.endDraw();
}

void drawBarChart() {
  float barScale = 0.1 + 2*bar.getPos();
  barChart.beginDraw();
  barChart.background(255, 250, 205);

  if (frames % 90 == 0) {
    if (score >= 0) {
      rectNumber = score > 1000 ? 20 : (int) score / 50;  //20 box max
    } else {
      rectNumber = 0;
    }
    rectTab.add(rectNumber);
    shiftNumber = frames / 90;
  }

  barChart.fill(0, 0, 255);
  for (int i = 0; i < rectTab.size(); ++i) {
    for (int j = 0; j < rectTab.get(i); ++j) {
      barChart.rect(i*barScale*(3.5 + 0.35), barChart.height - 3.5 - j*(3.5+0.35), 3.5*barScale, 3.5);
    }
  }

  barChart.endDraw();
  frames += 1;
}

void mouseDragged() {
  rotateX += (map(mouseY, 0, width, 5*(-PI)/3, 5*PI/3) - map(pmouseY, 0, width, 5*(-PI)/3, 5*PI/3)) * speed;
  rotateZ += (map(mouseX, 0, height, 5*(-PI)/3, 5*PI/3) - map(pmouseX, 0, height, 5*(-PI)/3, 5*PI/3)) * speed;

  if (rotateX > PI/3)
    rotateX = PI/3;
  else if (rotateX < (-PI)/3)
    rotateX = (-PI)/3;

  if (rotateZ > PI/3)
    rotateZ = PI/3;
  else if (rotateZ < (-PI)/3)
    rotateZ = (-PI)/3;
}

void mouseWheel(MouseEvent event) {
  e = event.getCount();
  if (speed + e/10 > 0.2 && speed + e/10 < 0.8) {
    speed += e/10;
  }
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == SHIFT) {
      shiftPressed = true;
    }
  }
}

void keyReleased() {
  if (key == CODED) {
    shiftPressed = false;
  }
}

boolean cylinderInPlate(float x, float y) {
  if (width/2 - 125 + cylinder.cylinderBaseSize <= x && x <= width/2 + 125 - cylinder.cylinderBaseSize) {
    if (height/2 - 125 + cylinder.cylinderBaseSize <= y && y <= height/2 + 125 - cylinder.cylinderBaseSize)
      return true;
    else
      return false;
  } else {
    return false;
  }
}

boolean cylinderOverlap(float x, float y) {
  for (int i = 0; i < locations.length; ++i) {
    if (locations[i] != null) {
      if ((locations[i].x + width/2 - 2*cylBase < x) && (x < locations[i].x + width/2 + 2*cylBase) && (locations[i].y + height/2 - 2*cylBase < y) && (y < locations[i].y + height/2 + 2*cylBase)) {
        return true;
      }
    }
  }
  return false;
}

boolean cylinderOnBall(float x, float y) {
  float xBall = mover.location.x + width/2;
  float yBall = mover.location.z + height/2;
  if ((xBall - distance < x) && (x < xBall + distance) && (yBall - distance < y) && (y < yBall + distance)) {
    return true;
  }
  return false;
}

void mouseClicked() {

  if (shiftPressed && i < 9 && cylinderInPlate(mouseX, mouseY) && !cylinderOverlap(mouseX, mouseY) && !cylinderOnBall(mouseX, mouseY)) {
    i += 1;
    locations[i] = new PVector(mouseX - width/2, mouseY - height/2);
  }
}