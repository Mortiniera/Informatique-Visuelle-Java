
import java.util.*;
import java.lang.Math;
import processing.video.*;

class ImageProcessing extends PApplet {

  PImage img;
  PImage result;
  Movie cam;
  ArrayList<PVector> lines = new ArrayList<PVector>();
  QuadGraph graph = new QuadGraph();
  List<int[]> quads = new ArrayList<int[]>();
  TwoDThreeD rotConv;
  PVector r = new PVector(0, 0, 0);
  int j = -1;

  void settings() {
    size(600, 400);
  }
  void setup() {
    cam = new Movie(this, "D:\\EPFL\\2e année\\Semestre 2\\Introduction à l'informatique visuelle\\processing-3.0.2\\Assignments\\Game\\data\\testvideo.mp4"); //Put the video in the same directory
    cam.loop();
  }

  void draw() {

    cam.read();
    img = cam;
    result = createImage(img.width, img.height, RGB);

    rotConv = new TwoDThreeD(img.width, img.height);

    for (int i = 0; i < img.width * img.height; i++) {
      //if (i%img.width == 0) ++j;
      result.pixels[i] = img.pixels[i];

      if (hue(img.pixels[i]) >= 90 && hue(img.pixels[i]) <= 155 && brightness(img.pixels[i]) >= 0 
        && brightness(img.pixels[i]) <= 232 && saturation(img.pixels[i]) >= 105 && saturation(img.pixels[i]) <= 255) {
        result.pixels[i] = color(255);
      } else {
        result.pixels[i] = color(0);
      }
    }

    result = gBlur(result);

    for (int i = 0; i < img.width * img.height; i++) {
      if (brightness(result.pixels[i]) <= 200) {
        result.pixels[i] = color(0);
      }
    }

    result = sobel(result);
    lines = hough(result, 5);

    graph.build(lines, img.width, img.height);
    quads = graph.findCycles();
    int size = quads.size();
    for (int i = size -1; i >= 0; --i) {
      println(i);
      PVector l1 = lines.get(quads.get(i)[0]);
      PVector l2 = lines.get(quads.get(i)[1]);
      PVector l3 = lines.get(quads.get(i)[2]);
      PVector l4 = lines.get(quads.get(i)[3]);

      PVector c12 = intersection(l1, l2);
      PVector c23 = intersection(l2, l3);
      PVector c34 = intersection(l3, l4);
      PVector c41 = intersection(l4, l1);

      float area = img.width*img.height;
      if (!graph.isConvex(c12, c23, c34, c41) || !graph.validArea(c12, c23, c34, c41, area, area/10) || !graph.nonFlatQuad(c12, c23, c34, c41)) {
        quads.remove(i);
      }
    }

    result.updatePixels();
    image(img, 0, 0);
    //image(result, 1200, 0);-----------------------------------------------------------------------------------------------------------------------------------------

    if (quads.size() == 1) {
      PVector l1 = lines.get(quads.get(0)[0]);
      PVector l2 = lines.get(quads.get(0)[1]);
      PVector l3 = lines.get(quads.get(0)[2]);
      PVector l4 = lines.get(quads.get(0)[3]);

      PVector c12 = intersection(l1, l2);
      PVector c23 = intersection(l2, l3);
      PVector c34 = intersection(l3, l4);
      PVector c41 = intersection(l4, l1);   

      List<PVector> l = Arrays.asList(c12, c23, c34, c41);
      l = sortCorners(l);
      r = rotConv.get3DRotations(l);
      r.x = degrees(r.x);
      r.y = degrees(r.y);
      r.z = degrees(r.z);
      println("rX = " + r.x + ", rY = " + r.y + ", rZ = " + r.z);

      pushMatrix();
      noFill();
      stroke(204, 102, 0);
      quad(c12.x, c12.y, c23.x, c23.y, c34.x, c34.y, c41.x, c41.y);
      noStroke();
      fill(255, 128, 0);
      ellipse(c12.x, c12.y, 10, 10);
      ellipse(c23.x, c23.y, 10, 10);
      ellipse(c34.x, c34.y, 10, 10);
      ellipse(c41.x, c41.y, 10, 10);
      popMatrix();
    } else if (quads.size() > 1) {
      int maxQuad = 0;
      float area;
      float maxArea = 0;
      for (int i = 0; i < quads.size(); ++i) {
        PVector l1 = lines.get(quads.get(i)[0]);
        PVector l2 = lines.get(quads.get(i)[1]);
        PVector l3 = lines.get(quads.get(i)[2]);
        PVector l4 = lines.get(quads.get(i)[3]);

        PVector c12 = intersection(l1, l2);
        PVector c23 = intersection(l2, l3);
        PVector c34 = intersection(l3, l4);
        PVector c41 = intersection(l4, l1);

        PVector v21= PVector.sub(c12, c23);
        PVector v32= PVector.sub(c23, c34);
        PVector v43= PVector.sub(c34, c41);
        PVector v14= PVector.sub(c41, c12);

        float i1=v21.cross(v32).z;
        float i2=v32.cross(v43).z;
        float i3=v43.cross(v14).z;
        float i4=v14.cross(v21).z;

        area = abs(0.5f * (i1 + i2 + i3 + i4));

        if (area > maxArea) {
          maxArea = area;
          maxQuad = i;
        }
      }
      PVector l1 = lines.get(quads.get(maxQuad)[0]);
      PVector l2 = lines.get(quads.get(maxQuad)[1]);
      PVector l3 = lines.get(quads.get(maxQuad)[2]);
      PVector l4 = lines.get(quads.get(maxQuad)[3]);
      ArrayList<PVector> l = new ArrayList<PVector>();
      l.add(l1);
      l.add(l2);
      l.add(l3);
      l.add(l4);
      getIntersections(l);
      PVector c12 = intersection(l1, l2);
      PVector c23 = intersection(l2, l3);
      PVector c34 = intersection(l3, l4);
      PVector c41 = intersection(l4, l1);
      pushMatrix();
      noFill();
      stroke(204, 102, 0);
      quad(c12.x, c12.y, c23.x, c23.y, c34.x, c34.y, c41.x, c41.y);
      noStroke();
      fill(255, 128, 0);
      ellipse(c12.x, c12.y, 10, 10);
      ellipse(c23.x, c23.y, 10, 10);
      ellipse(c34.x, c34.y, 10, 10);
      ellipse(c41.x, c41.y, 10, 10);
      popMatrix();

      List<PVector> list = Arrays.asList(c12, c23, c34, c41);
      list = sortCorners(list);
      r = rotConv.get3DRotations(list);
      r.x = degrees(r.x);
      r.y = degrees(r.y);
      r.z = degrees(r.z);
      println("rX = " + r.x + ", rY = " + r.y + ", rZ = " + r.z);
    } else {
      println("No quads found D:");
      //getIntersections(hough(result, 4));
    }


    //getIntersections(hough(result, 5));

    //for (int[] quad : quads) {
    //  PVector l1 = lines.get(quad[0]);
    //  PVector l2 = lines.get(quad[1]);
    //  PVector l3 = lines.get(quad[2]);
    //  PVector l4 = lines.get(quad[3]);
    //  // (intersection() is a simplified version of the
    //  // intersections() method you wrote last week, that simply
    //  // return the coordinates of the intersection between 2 lines)
    //  PVector c12 = intersection(l1, l2);
    //  PVector c23 = intersection(l2, l3);
    //  PVector c34 = intersection(l3, l4);
    //  PVector c41 = intersection(l4, l1);
    //  // Choose a random, semi-transparent colour
    //  Random random = new Random();
    //  fill(color(min(255, random.nextInt(300)), 
    //    min(255, random.nextInt(300)), 
    //    min(255, random.nextInt(300)), 50));
    //  quad(c12.x, c12.y, c23.x, c23.y, c34.x, c34.y, c41.x, c41.y);
    //}


    //image(img, 0, 0);
  }

  PImage gBlur(PImage img) {
    float[][] kernel = { { 9, 12, 9 }, 
      { 12, 15, 12 }, 
      { 9, 12, 9 }};
    float weight = 99.f;
    float sum = 0;
    int N = kernel.length;
    // create a greyscale image (type: ALPHA) for output
    PImage result = createImage(img.width, img.height, ALPHA);
    // kernel size N = 3
    //
    // for each (x,y) pixel in the image:
    // - multiply intensities for pixels in the range
    // (x - N/2, y - N/2) to (x + N/2, y + N/2) by the
    // corresponding weights in the kernel matrix
    // - sum all these intensities and divide it by the weight
    // - set result.pixels[y * img.width + x] to this value

    for (int i = 0; i < img.width * img.height; i++) {
      if (i%img.width == 0) ++j;
      if (!(j == 0 || j == img.height - 1 || (i == j*img.width) || (i == (j+1)*img.width -1))) {
        for (int k = 0; k < N; ++k) {
          for (int l = 0; l < N; ++l) {
            sum += kernel[k][l]*brightness(img.pixels[i + img.width*(k - N/2) + (l - N/2)]);
          }
        }
        result.pixels[i] = color(sum/weight);
        sum = 0;
      }
    }
    j = -1;

    return result;
  }

  PImage sobel(PImage img) {
    float[][] hKernel = { { 0, 1, 0 }, 
      { 0, 0, 0 }, 
      { 0, -1, 0 } };
    float[][] vKernel = { { 0, 0, 0 }, 
      { 1, 0, -1 }, 
      { 0, 0, 0 } };
    float sum_h = 0;
    float sum_v = 0;
    float sum = 0;
    float weight = 1.f;
    int N = hKernel.length;
    PImage result = createImage(img.width, img.height, ALPHA);
    // clear the image
    for (int i = 0; i < img.width * img.height; i++) {
      result.pixels[i] = color(0);
    }
    float max=0;
    float[] buffer = new float[img.width * img.height];

    for (int i = 0; i < img.width * img.height; i++) {
      if (i%img.width == 0) ++j;
      if (!(j == 0 || j == 1 || j == img.height - 1 || j == img.height - 2 || (i == j*img.width) || (i == j*img.width +1) || (i == (j+1)*img.width - 1) || (i == (j+1)*img.width - 2))) {
        for (int k = 0; k < N; ++k) {
          for (int l = 0; l < N; ++l) {
            sum_h += hKernel[k][l]*brightness(img.pixels[i + img.width*(k - N/2) + (l - N/2)]);
            sum_v += vKernel[k][l]*brightness(img.pixels[i + img.width*(k - N/2) + (l - N/2)]);
          }
        }
        sum = sqrt(pow(sum_h/weight, 2) + pow(sum_v/weight, 2));
        buffer[i] = sum;
        if (sum > max) {
          max = sum;
        }
        sum_h = 0;
        sum_v = 0;
      }
    }
    j = -1;

    for (int y = 2; y < img.height - 2; y++) {
      for (int x = 2; x < img.width - 2; x++) {
        if (buffer[y * img.width + x] > (int)(max * 0.3f)) { // 30% of the max
          result.pixels[y * img.width + x] = color(255);
        } else {
          result.pixels[y * img.width + x] = color(0);
        }
      }
    }

    return result;
  }

  ArrayList<PVector> hough(PImage edgeImg, int nLines) {
    ArrayList<PVector> lines = new ArrayList<PVector>();
    float r;
    int rIndex;
    float phi;
    float discretizationStepsPhi = 0.06f;
    float discretizationStepsR = 2.5f;
    // dimensions of the accumulator
    int phiDim = (int) (Math.PI / discretizationStepsPhi);
    int rDim = (int) (((edgeImg.width + edgeImg.height) * 2 + 1) / discretizationStepsR);
    int rMax = rDim + 2;
    // our accumulator (with a 1 pix margin around)
    int[] accumulator = new int[(phiDim + 2) * (rDim + 2)];
    ArrayList<Integer> bestCandidates = new ArrayList <Integer>();
    // Fill the accumulator: on edge points (ie, white pixels of the edge
    // image), store all possible (r, phi) pairs describing lines going
    // through the point.

    // pre-compute the sin and cos values
    float[] tabSin = new float[phiDim];
    float[] tabCos = new float[phiDim];
    float ang = 0;
    float inverseR = 1.f / discretizationStepsR;
    for (int accPhi = 0; accPhi < phiDim; ang += discretizationStepsPhi, accPhi++) {
      // we can also pre-multiply by (1/discretizationStepsR) since we need it in the Hough loop
      tabSin[accPhi] = (float) (Math.sin(ang) * inverseR);
      tabCos[accPhi] = (float) (Math.cos(ang) * inverseR);
    }

    for (int y = 0; y < edgeImg.height; y++) {
      for (int x = 0; x < edgeImg.width; x++) {
        // Are we on an edge?
        if (brightness(edgeImg.pixels[y * edgeImg.width + x]) != 0) {
          // ...determine here all the lines (r, phi) passing through
          // pixel (x,y), convert (r,phi) to coordinates in the
          // accumulator, and increment accordingly the accumulator.
          // Be careful: r may be negative, so you may want to center onto
          // the accumulator with something like: r += (rDim - 1) / 2

          for (int i = 0; i < phiDim; ++i) {
            phi = discretizationStepsPhi * i;
            rIndex = (int) (x*tabCos[i] + y*tabSin[i]);
            rIndex += (rDim - 1) / 2;
            accumulator[(i + 1) * rMax + (rIndex + 1)] += 1;
          }
        }
      }
    }

    // size of the region we search for a local maximum
    int neighbourhood = 10;
    // only search around lines with more that this amount of votes
    // (to be adapted to your image)
    int minVotes = 166;
    for (int accR = 0; accR < rDim; accR++) {
      for (int accPhi = 0; accPhi < phiDim; accPhi++) {
        // compute current index in the accumulator
        int idx = (accPhi + 1) * (rDim + 2) + accR + 1;
        if (accumulator[idx] > minVotes) {
          boolean bestCandidate=true;
          // iterate over the neighbourhood
          for (int dPhi=-neighbourhood/2; dPhi < neighbourhood/2+1; dPhi++) {
            // check we are not outside the image
            if ( accPhi+dPhi < 0 || accPhi+dPhi >= phiDim) continue;
            for (int dR=-neighbourhood/2; dR < neighbourhood/2 +1; dR++) {
              // check we are not outside the image
              if (accR+dR < 0 || accR+dR >= rDim) continue;
              int neighbourIdx = (accPhi + dPhi + 1) * (rDim + 2) + accR + dR + 1;
              if (accumulator[idx] < accumulator[neighbourIdx]) {
                // the current idx is not a local maximum!
                bestCandidate=false;
                break;
              }
            }
            if (!bestCandidate) break;
          }
          if (bestCandidate) {
            // the current idx *is* a local maximum
            bestCandidates.add(idx);
          }
        }
      }
    }

    Collections.sort(bestCandidates, new HoughComparator(accumulator));

    for (int i = 0; i < nLines; ++i) {
      if (i < bestCandidates.size()) {
        // first, compute back the (r, phi) polar coordinates:
        int accPhi = (int) (bestCandidates.get(i) / (rDim + 2)) - 1;
        int accR = bestCandidates.get(i) - (accPhi + 1) * (rDim + 2) - 1;
        r = (accR - (rDim - 1) * 0.5f) * discretizationStepsR;
        phi = accPhi * discretizationStepsPhi;
        PVector line = new PVector(r, phi);
        lines.add(line);
        // Cartesian equation of a line: y = ax + b
        // in polar, y = (-cos(phi)/sin(phi))x + (r/sin(phi))
        // => y = 0 : x = r / cos(phi)
        // => x = 0 : y = r / sin(phi)
        // compute the intersection of this line with the 4 borders of
        // the image
        int x0 = 0;
        int y0 = (int) (r / sin(phi));
        int x1 = (int) (r / cos(phi));
        int y1 = 0;
        int x2 = edgeImg.width;
        int y2 = (int) (-cos(phi) / sin(phi) * x2 + r / sin(phi));
        int y3 = edgeImg.width;
        int x3 = (int) (-(y3 - r / sin(phi)) * (sin(phi) / cos(phi)));
        // Finally, plot the lines
        stroke(204, 102, 0);
        if (y0 > 0) {
          if (x1 > 0)
            line(x0, y0, x1, y1);
          else if (y2 > 0)
            line(x0, y0, x2, y2);
          else
            line(x0, y0, x3, y3);
        } else {
          if (x1 > 0) {
            if (y2 > 0)
              line(x1, y1, x2, y2);
            else
              line(x1, y1, x3, y3);
          } else
            line(x2, y2, x3, y3);
        }
      }
    }

    PImage houghImg = createImage(rDim + 2, phiDim + 2, ALPHA);
    for (int i = 0; i < accumulator.length; i++) {
      houghImg.pixels[i] = color(min(255, accumulator[i]));
    }
    // You may want to resize the accumulator to make it easier to see:
    houghImg.resize(400, 600);
    houghImg.updatePixels();
    //image(houghImg, 800, 0); ------------------------------------------------------------------------------------------------------------

    return lines;
  }

  ArrayList<PVector> getIntersections(List<PVector> lines) {
    float x, y, d;

    ArrayList<PVector> intersections = new ArrayList<PVector>();

    for (int i = 0; i < lines.size() - 1; i++) {
      PVector line1 = lines.get(i);
      for (int j = i + 1; j < lines.size(); j++) {
        PVector line2 = lines.get(j);
        // compute the intersection and add it to ’intersections’
        d = cos(line2.y) * sin(line1.y) - cos(line1.y) * sin(line2.y);
        x = (line2.x * sin(line1.y) - line1.x * sin(line2.y) ) / d;
        y = ((-line2.x) * cos(line1.y) + line1.x * cos(line2.y) ) / d;

        PVector cartesianVect = new PVector(x, y);
        intersections.add(cartesianVect);

        // draw the intersection
        fill(255, 128, 0);
        ellipse(x, y, 10, 10);
      }
    }

    return intersections;
  }

  PVector intersection(PVector line1, PVector line2) {
    float x, y, d;

    d = cos(line2.y) * sin(line1.y) - cos(line1.y) * sin(line2.y);
    x = (line2.x * sin(line1.y) - line1.x * sin(line2.y) ) / d;
    y = ((-line2.x) * cos(line1.y) + line1.x * cos(line2.y) ) / d;

    return new PVector(x, y);
  }

  public List<PVector> sortCorners(List<PVector> quad) {
    // Sort corners so that they are ordered clockwise
    PVector a = quad.get(0);
    PVector b = quad.get(2);
    PVector center = new PVector((a.x+b.x)/2, (a.y+b.y)/2);
    Collections.sort(quad, new CWComparator(center));
    // TODO:
    // Re-order the corners so that the first one is the closest to the
    // origin (0,0) of the image.
    //
    // You can use Collections.rotate to shift the corners inside the quad.

    float min = Float.MAX_VALUE;
    int closest = 0;
    for (int i = 0; i < quad.size(); ++i) {
      float distance = quad.get(i).x * quad.get(i).x + quad.get(i).y * quad.get(i).y;
      if (distance < min) {
        min = distance;
        closest = i;
      }
    }
    Collections.rotate(quad, -closest);

    return quad;
  }

  PVector getRotation() {
    return r;
  }
}