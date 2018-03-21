void settings() {
  size(500, 500, P3D);
}

void setup() {
  noStroke();
}

float value = 1.0;
float valX = 0.0;
float valY = 0.0;
float depth = 2000;

void draw() {
  background(255, 255, 255);
  My3DPoint eye = new My3DPoint(0, 0, -5000);
  My3DPoint origin = new My3DPoint(0, 0, 0); //The first vertex of your cuboid
  My3DBox input3DBox = new My3DBox(origin, 100, 150, 300);

  float[][] transformX = rotateXMatrix(valX);
  input3DBox = transformBox(input3DBox, transformX);
  projectBox(eye, input3DBox);

  float[][] transformY = rotateYMatrix(valY);
  input3DBox = transformBox(input3DBox, transformY);
  projectBox(eye, input3DBox);

  float[][] transform2 = translationMatrix(200, 200, 0);
  input3DBox = transformBox(input3DBox, transform2);
  projectBox(eye, input3DBox);

  float[][] transform3 = scaleMatrix(value, value, value);
  input3DBox = transformBox(input3DBox, transform3);
  projectBox(eye, input3DBox).render();
}

void mouseDragged() {
 if (mouseY < pmouseY && value < 7) {
   value += 0.1;
 } else if (mouseY > pmouseY && value > 1) {
   value -= 0.1;
 }
}

void keyPressed() {
 if (key == CODED) {
   if (keyCode == UP) {
     valY += 0.1;
   } else if (keyCode == DOWN) {
     valY -= 0.1;
   } else if (keyCode == LEFT) {
     valX -= 0.1;
   } else if (keyCode == RIGHT) {
     valX += 0.1;
   }
 }
}

class My2DPoint {
  float x;
  float y;
  My2DPoint(float x, float y) {
    this.x = x;
    this.y = y;
  }
}

class My3DPoint {
  float x;
  float y;
  float z;
  My3DPoint(float x, float y, float z) {
    this.x = x;
    this.y = y;
    this.z = z;
  }
}

My2DPoint projectPoint(My3DPoint eye, My3DPoint p) {
  float xp = (eye.z * (p.x - eye.x)) / (eye.z - p.z);
  float yp = (eye.z * (p.y - eye.y)) / (eye.z - p.z);

  return new My2DPoint(xp, yp);
}

class My2DBox {
  My2DPoint[] s;
  My2DBox(My2DPoint[] s) {
    this.s = s;
  }
  void render() {
    stroke(0, 255, 0);
    line(s[0].x, s[0].y, s[1].x, s[1].y);
    line(s[1].x, s[1].y, s[2].x, s[2].y);
    line(s[2].x, s[2].y, s[3].x, s[3].y);
    line(s[3].x, s[3].y, s[0].x, s[0].y);
    stroke(0, 0, 255);
    line(s[5].x, s[5].y, s[1].x, s[1].y);
    line(s[3].x, s[3].y, s[7].x, s[7].y);
    line(s[6].x, s[6].y, s[2].x, s[2].y);
    line(s[4].x, s[4].y, s[0].x, s[0].y);    
    stroke(255, 0, 0);
    line(s[7].x, s[7].y, s[4].x, s[4].y);
    line(s[7].x, s[7].y, s[6].x, s[6].y);
    line(s[6].x, s[6].y, s[5].x, s[5].y);   
    line(s[5].x, s[5].y, s[4].x, s[4].y);
  }
}

class My3DBox {
  My3DPoint[] p;
  My3DBox(My3DPoint origin, float dimX, float dimY, float dimZ) {
    float x = origin.x;
    float y = origin.y;
    float z = origin.z;
    this.p = new My3DPoint[]{new My3DPoint(x, y+dimY, z+dimZ), 
      new My3DPoint(x, y, z+dimZ), 
      new My3DPoint(x+dimX, y, z+dimZ), 
      new My3DPoint(x+dimX, y+dimY, z+dimZ), 
      new My3DPoint(x, y+dimY, z), 
      origin, 
      new My3DPoint(x+dimX, y, z), 
      new My3DPoint(x+dimX, y+dimY, z)
    };
  }
  My3DBox(My3DPoint[] p) {
    this.p = p;
  }
}

My2DBox projectBox (My3DPoint eye, My3DBox box) {
  My2DPoint[] s = new My2DPoint[8];
  for (int i = 0; i < box.p.length; i++)
    s[i] = projectPoint(eye, (box.p)[i]);

  return new My2DBox(s);
}

float[] homogeneous3DPoint (My3DPoint p) {
  float[] result = {p.x, p.y, p.z, 1};
  return result;
}

float[][] rotateXMatrix(float angle) {
  return(new float[][] {
    {1, 0, 0, 0}, 
    {0, cos(angle), sin(angle), 0}, 
    {0, -sin(angle), cos(angle), 0}, 
    {0, 0, 0, 1}});
}
float[][] rotateYMatrix(float angle) {
  return(new float[][] {
    {cos(angle), 0, -sin(angle), 0}, 
    {0, 1, 0, 0}, 
    {sin(angle), 0, cos(angle), 0}, 
    {0, 0, 0, 1}});
}
float[][] rotateZMatrix(float angle) {
  return(new float[][] { 
    {cos(angle), sin(angle), 0, 0}, 
    {-sin(angle), cos(angle), 0, 0}, 
    {0, 0, 1, 0}, 
    {0, 0, 0, 1}});
}
float[][] scaleMatrix(float x, float y, float z) {
  return(new float[][] {
    {x, 0, 0, 0}, 
    {0, y, 0, 0}, 
    {0, 0, z, 0}, 
    {0, 0, 0, 1}});
}
float[][] translationMatrix(float x, float y, float z) {
  return(new float[][] {
    {1, 0, 0, x}, 
    {0, 1, 0, y}, 
    {0, 0, 1, z}, 
    {0, 0, 0, 1}});
}

float[] matrixProduct(float[][] a, float[] b) {
  float[] result = new float[a.length];
  float sum;
  for (int i = 0; i < a.length; ++i) {
    sum = 0.0;       
    for (int j = 0; j < a[i].length; ++j) {
      sum += a[i][j]*b[j];
    }        
    result[i] = sum;
  }
  return result;
}

My3DPoint euclidian3DPoint (float[] a) {
  My3DPoint result = new My3DPoint(a[0]/a[3], a[1]/a[3], a[2]/a[3]);
  return result;
}

My3DBox transformBox(My3DBox box, float[][] transformMatrix) {
  My3DPoint[] result = new My3DPoint[box.p.length];
  for (int i = 0; i < box.p.length; ++i) {
    result[i] = euclidian3DPoint(matrixProduct(transformMatrix, homogeneous3DPoint(box.p[i])));
  }  
  return new My3DBox(result);
}