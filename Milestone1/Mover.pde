class Mover {
  PVector location;
  PVector velocity;
  PVector gravity;
  float gravityConstant = 0.1;
  float e = 0.75; /* Elasticity coefficient, between 0 and 1 */

  Mover() {
    /* The Mover (ball) is placed on top of the plate, with initial velocity set to 0 */
    location = new PVector(0, -21, 0);
    velocity = new PVector(0, 0, 0);
    gravity = new PVector(0, gravityConstant, 0);
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
    /* If the mover get out of the plate, we just put it (its center) on the nearest border before getting out */
    if (location.x > 125) {
      location.x = 125;
      velocity.x = -velocity.x * e;
    } else if (location.x < -125) {
      location.x = -125;
      velocity.x = -velocity.x * e;
    }

    if (location.z > 125) {
      location.z = 125;
      velocity.z = -velocity.z * e;
    } else if (location.z < -125) {
      location.z = -125;
      velocity.z = -velocity.z * e;
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
        /* We set temp to be the vector which goes from the center of the Mover to the center of the cylinder */ 
        temp.x = location.x - (cylinders[i].x);
        temp.z = location.z - (cylinders[i].y);
        if (temp.mag() <= distance) { /* If the length of this vector is smaller than the collision distance between a cylinder and the Mover, then there is collision */
          n = temp.normalize();
          scalarCopy = n.copy(); 
          nCopy = n.copy();
          /* We have 3 copies of the normal vector because dot operaton is dynamic (for nCopy), and n and scalarCopy because we don't want to modify the value of n when using it after */
          angle = acos(nCopy.dot(xNorm)); /* We calculate the angle between the normal vector and the x axis, to know how to replace the ball when collision occurs using projection  */ 
          
          /* According from where the ball came from, since n is a normal vector always pointing in the positive direction in our coordinate system, we need to replace
          it in the right direction when we came from the left, or from above (that's why we multiply by -1) */
          if (location.x < cylinders[i].x) { /* If we came from the left */
           location.x = cylinders[i].x + distance*cos(angle);
           n.x *= -1;
           scalarCopy.x *= -1;
          } else { /* If we came from the right */
           location.x = cylinders[i].x + distance*cos(angle);
          }

          if (location.z < cylinders[i].y) { /* If we came from above */
           location.z = cylinders[i].y - distance*sin(angle);
           n.z *= -1;
           scalarCopy.z *= -1;
          } else { /* If we came from below */
           location.z = cylinders[i].y + distance*sin(angle);
          }
          velocity = PVector.sub(veloCopy, PVector.mult(n, 2*veloCopy.dot(scalarCopy))); /* We use the formula given to calculate the direction and magnitude 
          of the resulting vector V2 (here velocity) */
        }
      }
    }
  }
}