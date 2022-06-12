/*
 * Simple triangulation of any convex/non-convex polygon with ordered clockwise/anti-clockwise points
 * @author Volfegan Geist [Daniel Leite Lacerda]
 * https://github.com/volfegan/GeometricAlgorithms
 * 
 */
PVector[] polygon;
ArrayList<PVector[]> triangles = new ArrayList<PVector[]>();
color[] colours;
float time = 0;

void setup() {
  size(1280, 720);
  colorMode(HSB, 255);
  PVector centre = new PVector(width/2, height/2);
  int vertices = int(random(15, 25));
  float maxRadius = height/2 - 10;
  polygon = buildPolygon(centre, vertices, maxRadius);
  //println("Is polygon clockwise? "+isClockwise(polygon));

  triangles = triangulatePolygon(polygon);
  //Generate colour palette
  colours = new color[triangles.size()];
  for (int i=0; i<triangles.size(); i++) {
    color c = color(random(255), 255, 255, i%2==0?0:255);
    colours[i] = c;
  }
}

void draw() {
  clear();

  //Draw polygon
  beginShape();
  stroke(100, 255, 255);//green
  noFill();
  for (int i=polygon.length; i>=0; i--) {
    float x = polygon[i%polygon.length].x;
    float y = polygon[i%polygon.length].y;
    vertex(x, y);
  }
  endShape();


  //Draw triangles from polygon vertices
  int colourIndex= int((frameCount*.04))%colours.length;
  for (PVector[] triangle : triangles) {

    if (millis() < 2000+time) {
      noFill();
      noStroke();
    } else {
      fill(colours[colourIndex]);
    }
    colourIndex++;
    colourIndex%=colours.length;

    beginShape();
    for (int i=0; i<=triangles.size(); i++) {
      float x = triangle[i%triangle.length].x;
      float y = triangle[i%triangle.length].y;
      vertex(x, y);
    }
    endShape();
  }
  //saveFrame("frame_######.png");
}
//Spacebar to reset polygon
void keyPressed() {
  if (key == ' ') {
    PVector centre = new PVector(width/2, height/2);
    int vertices = int(random(15, 25));
    float maxRadius = height/2 - 10;
    polygon = buildPolygon(centre, vertices, maxRadius);
    //println("Is polygon clockwise? "+isClockwise(polygon));

    triangles = triangulatePolygon(polygon);
    colours = new color[triangles.size()];
    for (int i=0; i<triangles.size(); i++) {
      color c = color(random(255), 255, 255, i%2==0?0:255);
      colours[i] = c;
    }
    noFill();
    time=millis();
  }
}

/*
 * Build a possible non-convex polygon shape with a given number of vertices
 * @param PVector centre (polygon "centre" location)
 * @param float polygonSize (number of vertices)
 * @param float maxRadius (max distance from "centre" to one of the vertices)
 * @return PVector[] vertices (points in clockwise order)
 */
public PVector[] buildPolygon(PVector centre, int polygonSize, float maxRadius) {
  PVector[] vertices = new PVector[polygonSize];
  for (int i = 0; i < polygonSize; i++) {
    float radius = maxRadius*(random(0.2, 1));
    float angle = (((float)i)/polygonSize)*TAU;

    PVector point = new PVector(radius * sin(angle), radius *cos(angle));
    vertices[i] = PVector.add(centre, point);
  }
  return vertices;
}

/*
 * Triangulates any convex/non-convex polygon with ordered clockwise/anti-clockwise points
 * Reference:
 * https://github.com/leonardo-ono/Java2DTriangulationAlgorithmTest1/blob/master/src/View.java
 * @param PVector[] polygon
 * @return ArrayList<PVector[]> triangles
 */
public ArrayList<PVector[]> triangulatePolygon(PVector[] polygon) {
  ArrayList<PVector> points = new ArrayList<PVector>();
  ArrayList<PVector[]> triangles = new ArrayList<PVector[]>();

  //Collect points from the polygon and check their clockwise order
  for (PVector point : polygon) {
    points.add(point);
  }
  boolean clockwise = isClockwise(polygon);

  int index = 0;
  while (points.size() > 2) {

    PVector p1 = points.get((index + 0) % points.size());
    PVector p2 = points.get((index + 1) % points.size());
    PVector p3 = points.get((index + 2) % points.size());

    PVector v1 = new PVector(p2.x - p1.x, p2.y - p1.y);
    PVector v2 = new PVector(p3.x - p1.x, p3.y - p1.y);
    float v1Xv2 = v1.x * v2.y - v1.y * v2.x;

    PVector[] triangle = new PVector[3];
    triangle[0]=new PVector(p1.x, p1.y);
    triangle[1]=new PVector(p2.x, p2.y);
    triangle[2]=new PVector(p3.x, p3.y);

    if (!clockwise && v1Xv2 >= 0 && isValidTriangle(triangle, points)) {
      points.remove(p2);
      triangles.add(triangle);
    } else if (clockwise && v1Xv2 <= 0 && isValidTriangle(triangle, points)) {
      points.remove(p2);
      triangles.add(triangle);
    } else {
      index++;
    }
  }

  if (points.size() < 3) {
    points.clear();
  }

  return triangles;
}

/*
 * A valid triangle has no points from the polygon other vertices points
 * @param PVector[] triangle
 * @param ArrayList<PVector> points
 * @return boolean
 */
public boolean isValidTriangle(PVector[] triangle, ArrayList<PVector> vertices) {
  PVector p1 = triangle[0];
  PVector p2 = triangle[1];
  PVector p3 = triangle[2];
  for (PVector p : vertices) {
    //Check if there is no points from the polygon inside the triangle
    if (p.x != p1.x && p.y != p1.y && 
      p.x != p2.x && p.y != p2.y && 
      p.x != p3.x && p.y != p2.y && 
      isPointInTriangle(triangle, p)) {
      return false;
    }
  }
  return true;
}

/*
 * Fast & efficient check if a point is inside a triangle (Good for collision detection for triangles)
 * Uses similar logic of the GJK algorithm
 * Reference: https://stackoverflow.com/questions/2049582/how-to-determine-if-a-point-is-in-a-2d-triangle
 * @param PVector[] triangle
 * @param PVector p
 * @return boolean
 */
public boolean isPointInTriangle(PVector[] triangle, PVector p) {
  PVector a = triangle[0];
  PVector b = triangle[1];
  PVector c = triangle[2];

  float as_x = p.x-a.x;
  float as_y = p.y-a.y;

  boolean s_ab = (b.x-a.x)*as_y-(b.y-a.y)*as_x > 0;

  if ((c.x-a.x)*as_y-(c.y-a.y)*as_x > 0 == s_ab) return false;

  if ((c.x-b.x)*(p.y-b.y)-(c.y-b.y)*(p.x-b.x) > 0 != s_ab) return false;

  return true;
}

/*
 * Determines if a list of polygon vertices points is in clockwise order
 * Reference:
 * https://stackoverflow.com/questions/1165647/how-to-determine-if-a-list-of-polygon-points-are-in-clockwise-order
 * @param PVector[] vertices
 * @return boolean
 */
public boolean isClockwise(PVector[] vertices) {
  int sum = 0;
  for (int i = 0; i < vertices.length; i++) {
    int j = (i+1)%vertices.length;
    PVector p1 = vertices[i];
    PVector p2 = vertices[j];
    sum += (p2.x - p1.x) * (p2.y + p1.y);
  }
  return sum >= 0;
}
