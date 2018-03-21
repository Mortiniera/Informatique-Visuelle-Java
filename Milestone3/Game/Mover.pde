class Mover {
  PVector location;
  PVector velocity;
  PVector gravity;
  float gravityConstant = 0.1;
  float e = 0.75;
  float ballScore;
  float lastBallScore;

  Mover() {
    location = new PVector(0, -21, 0);
    velocity = new PVector(0, 0, 0);
    gravity = new PVector(0, 0, 0);
  }
  void update() {
    gravity.x = sin(rotateZ) * gravityConstant;
    gravity.z = sin(rotateX) * gravityConstant;
    float normalForce = 1;
    float mu = 0.01;
    float frictionMagnitude = normalForce * mu;
    PVector friction = velocity.copy();
    friction.mult(-1);
    friction.normalize();
    friction.mult(frictionMagnitude);

    velocity.add(gravity);
    velocity.add(friction);
    location.add(velocity);
  }

  void checkEdges() {
    boolean collision = false;
    if (location.x > 125) {
      collision = true;
      location.x = 125;
      velocity.x = -velocity.x * e;
    } else if (location.x < -125) {
      collision = true;
      location.x = -125;
      velocity.x = -velocity.x * e;
    }

    if (location.z > 125) {
      collision = true;
      location.z = 125;
      velocity.z = -velocity.z * e;
    } else if (location.z < -125) {
      collision = true;
      location.z = -125;
      velocity.z = -velocity.z * e;
    }
    
    if (collision) {
      lastBallScore = -velocity.mag();
      ballScore += lastBallScore;
    }
  }

  void checkCylinderCollision(PVector[] cylinders, float distance) {
    PVector temp = new PVector(0, 0, 0);
    PVector n;
    PVector nCopy;
    PVector scalarCopy;
    PVector veloCopy = velocity.copy();
    PVector xNorm = new PVector(1, 0);
    float angle;

    for (int i = 0; i < cylinders.length; ++i) {
      if (cylinders[i] != null) {
        temp.x = location.x - (cylinders[i].x);
        temp.z = location.z - (cylinders[i].y);
        if (temp.mag() <= distance) {
          lastBallScore = velocity.mag();
          ballScore += lastBallScore;
          n = temp.normalize();
          scalarCopy = n.copy();
          nCopy = n.copy();
          angle = acos(nCopy.dot(xNorm));                   

          if (location.x < cylinders[i].x) {
           location.x = cylinders[i].x + distance*cos(angle);
           n.x *= -1;
           scalarCopy.x *= -1;
          } else {
           location.x = cylinders[i].x + distance*cos(angle);
          }

          if (location.z < cylinders[i].y) {
           location.z = cylinders[i].y - distance*sin(angle);
           n.z *= -1;
           scalarCopy.z *= -1;
          } else {
           location.z = cylinders[i].y + distance*sin(angle);
          }
          velocity = PVector.sub(veloCopy, PVector.mult(n, 2*veloCopy.dot(scalarCopy)));
        }
      }
    }
  }
}