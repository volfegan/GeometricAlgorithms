// author Volfegan [Daniel L Lacerda] 

import java.util.TreeSet;
import java.util.*;
import java.util.Collections;

SpatialHash spatialGrid;
String queryMode = "grid";

public void keyPressed() {
  if (key == 'g') {
    queryMode = "grid";
  }
  if (key == 'r') {
    queryMode = "rectangle";
  }
  if (key == 'c') {
    queryMode = "circle";
  }
}

public void setup () {
  size(1000, 400);
  background(0);

  int cellSize = width/20;

  spatialGrid = new SpatialHash(width, height, cellSize);

  int maxPoints = 10000;
  for (int i  = 0; i < maxPoints; i++) {
    float x = (width/4) +randomGaussian(width /4, width / 8);
    float y = (height/4) + randomGaussian(height / 4, height / 8);
    Point p = new Point (x, y);
    spatialGrid.add(p);
  }

  Rectangle boundary = new Rectangle(width/2, height/2, width/2, height/2);
  TreeSet<Point> points = spatialGrid.query(boundary);

  println("Canvas size = "+width+", "+height+", cellSize = "+cellSize);
  println("Points created = "+maxPoints);
  println("Points found = "+points.size());

  //look-up at the hash keys generated for the space width x height
  println("HashKeys genereated =");
  ArrayList keys = new ArrayList<Integer>();
  for (int key : spatialGrid.buckets.keySet()) {
    keys.add(key);
  }
  Collections.sort(keys);
  println(keys);
}

public void draw () {
  background(0);

  spatialGrid.show();

  stroke(0, 255, 0);
  rectMode(CENTER);

  TreeSet<Point> points = new TreeSet<Point>();

  //Scan points from each grid
  if (queryMode.equals("grid")) {
    points = spatialGrid.getFromBucket((double)mouseX, (double)mouseY);
  } 
  //Scan points using rectangle
  if (queryMode.equals("rectangle")) {
    //Rectangle range = new Rectangle (mouseX, mouseY, width/20, height/20);
    Rectangle range = new Rectangle (mouseX, mouseY, 25, 25);
    points = spatialGrid.query(range);
    rect((float)range.x, (float)range.y, (float)range.width * 2, (float)range.height * 2);
  }
  //Scan points using circle
  if (queryMode.equals("circle")) {
    double r =25;
    Circle range = new Circle (mouseX, mouseY, r);
    points = spatialGrid.query(range);
    circle((float)range.x, (float)range.y, (float)r * 2);
  }
  strokeWeight(1);
  for (Point p : points) {
    strokeWeight(4);
    point((float)p.x, (float)p.y);
  }
}

public float randomGaussian(float min, float max) {
  return min + randomGaussian() * (max - min);
}
