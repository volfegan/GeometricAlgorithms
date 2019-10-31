// author Volfegan [Daniel L Lacerda] 

import java.util.TreeSet;
import java.util.HashSet;
import java.util.Arrays;
import java.util.Collections;

ArrayList<Line> lines = new ArrayList<Line>();
HashSet<Point> showPoints = new HashSet<Point>(); //intersection points
Segment[] lineSegment;
SpatialHash spatialGrid;
String queryMode = "grid"; //how to retriave points/segments from the SpatialHash

public void keyPressed() {
  if (key == 'g') {
    queryMode = "grid";
  }
  if (key == 'r') {
    queryMode = "rectangle";
  }
}

public void setup () {
  size(1000, 400);
  background(0);


  int linesQty = 25;
  println(linesQty + " random segments lines created:");
  String[] filetxt = new String[linesQty];
  lineSegment = new Segment[linesQty];
  //generate points method 01 (eval efficiency random segments)
  for (int i = 0; i < linesQty; i++) {
    int x0 = int(random(0, 1000));
    int y0 = int(random(0, 400));
    int x1 = int(random(0, 1000));
    int y1 = int(random(0, 400));
    filetxt[i] = x0+" "+y0+" "+x1+" "+y1;
  }
  for (int i = 0; i < filetxt.length; i++) {
    String line = filetxt[i];
    ArrayList<String> coordenates = new ArrayList<String>(Arrays.asList(line.split(" ")));
    int x0 = Integer.parseInt(coordenates.get(0));
    int y0 = Integer.parseInt(coordenates.get(1));
    int x1 = Integer.parseInt(coordenates.get(2));
    int y1 = Integer.parseInt(coordenates.get(3));
    //println("(" + x0 + ", " + y0 + ")->(" + x1 + ", " + y1 + ")");

    //create the lines from the points and put them in a list o lines
    lines.add(new Line(new PVector(x0, y0), new PVector(x1, y1)));

    Point pointA = new Point(x0, y0);
    Point pointB = new Point(x1, y1);

    lineSegment[i] = new Segment(pointA, pointB);
  }



  int cellSize = width/20;

  spatialGrid = new SpatialHash(width, height, cellSize);

  for (Segment s : lineSegment) {
    spatialGrid.add(s);
  }

  Rectangle boundary = new Rectangle(width/2, height/2, width/2, height/2);
  TreeSet<Point> points = spatialGrid.query(boundary);

  println("Canvas size = "+width+", "+height+", cellSize = "+cellSize);
  println("Segment lines created = "+linesQty);
  println("Points created = "+points.size());

  //look-up at the hash keys generated for the space width x height
  ArrayList keys = new ArrayList<Integer>();
  for (int key : spatialGrid.buckets.keySet()) {
    keys.add(key);
  }
  Collections.sort(keys);
  println(keys.size()+" HashKeys genereated =");
  println(keys);

  //show Line segments
  for (Line line : lines) {
    line.display();
  }
}

public void draw () {
  background(0);
  color cyanFade = color(0, 255, 255, 150);

  spatialGrid.show();

  //show Line segments
  for (Line line : lines) {
    line.display();
  }

  stroke(0, 255, 0);
  rectMode(CENTER);

  TreeSet<Point> points = new TreeSet<Point>();

  //Scan points from each grid
  if (queryMode.equals("grid")) {
    points = spatialGrid.getFromBucket((double)mouseX, (double)mouseY);
  } 
  //Scan points using rectangle
  if (queryMode.equals("rectangle")) {
    //Rectangle range = new Rectangle (mouseX, mouseY, width/20, height/10);
    Rectangle range = new Rectangle (mouseX, mouseY, 25, 25);
    points = spatialGrid.query(range);
    rect((float)range.x, (float)range.y, (float)range.width * 2, (float)range.height * 2);
  }

  for (Point p : points) {
    strokeWeight(6);
    point((float)p.x, (float)p.y);

    Segment lineSegment = p.getData();

    int x0 = int((float)lineSegment.startPoint().x);
    int y0 = int((float)lineSegment.startPoint().y);
    int x1 = int((float)lineSegment.endPoint().x);
    int y1 = int((float)lineSegment.endPoint().y);
    strokeWeight(1);
    selectLine(x0, y0, x1, y1, cyanFade, 10);
  }
}

public float randomGaussian(float min, float max) {
  return min + randomGaussian() * (max - min);
}

//creates a box around a segment line
void selectLine(int x0_, int y0_, int x1_, int y1_, color color_, int box_size) {
  int x1, y1, x2, y2, x3, y3, x4, y4;
  int offsetX, offsetY;
  stroke(color_);
  double angle = Math.toDegrees(Math.atan2(y1_-y0_, x1_-x0_));
  if (angle > 90) angle -= 180;
  if (angle < -45) angle += 180;
  if (angle < 45) {
    offsetX = 0;
    offsetY = box_size;
    x1 = x0_ - offsetX;
    y1 = y0_ + offsetY;

    x2 = x0_ - offsetX;
    y2 = y0_ - offsetY;

    x3 = x1_ + offsetX;
    y3 = y1_ - offsetY;

    x4 = x1_ + offsetX;
    y4 = y1_ + offsetY;
  } else {
    offsetX = box_size;
    offsetY = 0;
    x1 = x0_ + offsetX;
    y1 = y0_ + offsetY;

    x2 = x0_ - offsetX;
    y2 = y0_ - offsetY;

    x3 = x1_ - offsetX;
    y3 = y1_ - offsetY;

    x4 = x1_ + offsetX;
    y4 = y1_ + offsetY;
  }
  quad(x1, y1, x2, y2, x3, y3, x4, y4);
}
