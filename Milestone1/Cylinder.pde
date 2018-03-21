class Cylinder {
  PVector location; 
  float cylinderBaseSize;
  float cylinderHeight;
  int cylinderResolution;
  /* We use 3 Pshape to create our cylinder */
  PShape openCylinder = new PShape();
  PShape bottomSurface = new PShape();
  PShape topSurface = new PShape();

  Cylinder(float x, float y, float base, float cylHeight, int reso) {
    /* Initialisation of a new Cylinder built with its locations, its radius (base), its height and its resolution */
    location = new PVector(x, y);
    cylinderBaseSize = base;
    cylinderHeight = cylHeight;
    cylinderResolution = reso;
  }

  void cylinderSetup() {
    float angle;
    float[] abs = new float[cylinderResolution + 1];
    float[] ord = new float[cylinderResolution + 1];
    //get the x and y position on a circle for all the sides
    for (int i = 0; i < abs.length; i++) {
      angle = (TWO_PI / cylinderResolution) * i;
      abs[i] = sin(angle) * cylinderBaseSize;
      ord[i] = cos(angle) * cylinderBaseSize;
    }
    openCylinder = createShape();
    openCylinder.beginShape(QUAD_STRIP);
    //draw the border of the cylinder
    for (int i = 0; i < abs.length; i++) {
      openCylinder.vertex(abs[i], ord[i], 0);
      openCylinder.vertex(abs[i], ord[i], cylinderHeight);
    }
    openCylinder.endShape();
    
    /* The same process but here for the bottom and the top surface of the cylinder */
    bottomSurface = createShape();
    topSurface = createShape();
    bottomSurface.beginShape(TRIANGLE_FAN);
    topSurface.beginShape(TRIANGLE_FAN);
    bottomSurface.vertex(0, 0, 0);
    topSurface.vertex(0, 0, cylinderHeight);
    for (int i  = 0; i < abs.length; i++) {
      bottomSurface.vertex(abs[i], ord[i], 0);
      topSurface.vertex(abs[i], ord[i], cylinderHeight);
    }
    bottomSurface.endShape();
    topSurface.endShape();
  }

  void drawCylinder() {
    pushMatrix();
    rotateX(PI/2);
    translate(location.x, location.y, 0);
    shape(openCylinder);
    shape(bottomSurface);
    shape(topSurface);
    popMatrix();
  }
  
  void drawVerticalCylinder() {
    /* The same as drawCylinder() except we are in vertical view here */
    pushMatrix();
    rotateX(-PI/2);
    translate(location.x, location.y, 0);
    shape(openCylinder);
    shape(bottomSurface);
    shape(topSurface);
    popMatrix();
  }
}