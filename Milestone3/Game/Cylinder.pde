class Cylinder {
  PVector location;
  float cylinderBaseSize;
  float cylinderHeight;
  int cylinderResolution;
  PShape openCylinder = new PShape();
  PShape bottomSurface = new PShape();
  PShape topSurface = new PShape();

  Cylinder(float x, float y, float base, float cylHeight, int reso) {
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
    pushMatrix();
    rotateX(-PI/2);
    translate(location.x, location.y, 0);
    shape(openCylinder);
    shape(bottomSurface);
    shape(topSurface);
    popMatrix();
  }
}