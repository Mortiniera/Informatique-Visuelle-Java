float rotateX = 0;
float rotateZ = 0;
float speed = 0.5;
float e;
int i = -1; /* Correspond to the actual number of cylinders -1, in the plate */
boolean shiftPressed = false;
Mover mover = new Mover();
final float cylBase = 20;
final float cylHeight = 40;
final float sphereRadius = 15;
final float boxThickness = 12;
final float distance = sphereRadius + cylBase; /* Distance between the center of the sphere et the center of the cylinder when there is a collision */
PVector[] locations = new PVector[10];
Cylinder cylinder = new Cylinder(0, 0, cylBase, cylHeight, 50); /* We draw only one cylinder and keep track of the different positions of the same cylinder when adding new ones */

void settings() {
  size(500, 500, P3D);
}

void setup() {
  noStroke();
}

void draw() {
  background(200);
  directionalLight(50, 100, 125, 0, -1, 0);
  ambientLight(102, 102, 102);
  translate(width/2, height/2, 0);
  cylinder.cylinderSetup();

  if (shiftPressed) {
    /* We move to the vertical view of the box */
    rotateX(PI/2);
    fill(255, 0, 0);
    box(250, 25, 250);
    fill(0, 125, 255);
    pushMatrix();
    rotateX(-PI/2); 
    translate(mover.location.x, mover.location.z, (sphereRadius + boxThickness/2)); /* we put the ball on the plate*/
    sphere(sphereRadius);
    popMatrix();
    fill(0);
    if (cylinderInPlate(mouseX, mouseY) && !cylinderOnBall(mouseX, mouseY)) {
      /* if the mouse cursor is in the plate, and not on the ball, we have a circle drawn following the cursor to see where the new cylinder will be placed */
      pushMatrix();
      rotateX(-PI/2);
      translate(mouseX - width/2, mouseY - height/2, (sphereRadius + boxThickness/2));
      sphere(cylBase);
      popMatrix();
    }  
    if (i != -1) {
      for (int k = 0; k <= i; ++k) {
        /* At each frame, we go through the array containing all the positions of our cylinder, and draw this cylinder (in vertical view) at all these positions in the plate*/
        cylinder.location.x = locations[k].x;
        cylinder.location.y= locations[k].y;
        cylinder.drawVerticalCylinder();
      }
    }
  } else {
    fill(125);
    /* We go back to normal view */
    rotateX(-rotateX);
    rotateZ(rotateZ);
    box(250, 12, 250);
    if (i != -1) {
      for (int j = 0; j <= i; ++j) {
        /* At each frame, we go through the array containing all the positions of our cylinder, and draw this cylinder (in normal view) at all these positions in the plate*/
        cylinder.location.x = locations[j].x;
        cylinder.location.y= locations[j].y;
        cylinder.drawCylinder();
      }
    }

    mover.checkEdges(); /* At each frame, we call checkEdges() to force the ball to stay in the plate */
    mover.update(); /* We update the position and the velocity of the mover */
    mover.checkCylinderCollision(locations, distance); /* We call this method to handle the cases when there is a collision between the ball and some cylinder */
    translate(mover.location.x, -(sphereRadius + boxThickness/2), mover.location.z);
    sphere(sphereRadius);
  }
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
  /* Check whether the positions of the cylinder we want to draw are in the plate */
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
  /* Check whether the position of the cylinder we want to draw will not overlap another cylinder already drawn */
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
  /* Check whether the position of the cylinder we want to draw would not overlap another the ball */
  float xBall = mover.location.x + width/2;
  float yBall = mover.location.z + height/2;
  if ((xBall - distance < x) && (x < xBall + distance) && (yBall - distance < y) && (y < yBall + distance)) {
    return true;
  }
  return false;
}

void mouseClicked() {
  /* If the shift key is pressed, we don't have more than the maximum number of cylinders, the cylinder we want to draw will not overlap and 
  already one drawn cylinder nor the ball, then we can add a new location to the array of locations representing all the drawn cylinders*/
  
  if (shiftPressed && i < 9 && cylinderInPlate(mouseX, mouseY) && !cylinderOverlap(mouseX, mouseY) && !cylinderOnBall(mouseX, mouseY)) {
    i += 1;
    locations[i] = new PVector(mouseX - width/2, mouseY - height/2);
  }
}