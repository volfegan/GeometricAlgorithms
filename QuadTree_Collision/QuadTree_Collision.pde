// Daniel Shiffman, modified by Volfegan
// http://codingtra.in
// http://patreon.com/codingtrain
//Videos
//Part 1:
//https://www.youtube.com/watch?v=OJxEcs0w_kE
//Part 2: 
//https://www.youtube.com/watch?v=QQx_NmCIuCY

//This code is part 2 video of the challenge. 

import java.util.TreeSet;

Quadtree qtree;

public void setup () {
  size(1000, 400);
  background(0);
  Rectangle boundary = new Rectangle (width/2, height/2, width/2, height/2);
  qtree = new Quadtree (boundary, 8);
  int maxPoints = 10000;
  for (int i  = 0; i < maxPoints; i++) {
    float x = (width/4) +randomGaussian(width /4, width / 8);
    float y = (height/4) + randomGaussian(height / 4, height / 8);
    Point p = new Point (x, y);
    qtree.insert(p);
  }
  Rectangle range =new Rectangle (width/2, height/2, width*2, height*2);
  TreeSet<Point> points = qtree.query(range);
  println("Query range = Canvas size = "+width+", "+height);
  println("Points created = "+maxPoints);
  println("Points found = "+points.size());
}

public void draw () {
  background(0);
  qtree.show();

  stroke(0, 255, 0);
  rectMode(CENTER);
  
  //using mouse
  Rectangle range = new Rectangle (mouseX, mouseY, 25, 25);
  //scaning all screen for qtree points
  //Rectangle range =new Rectangle (width/2, height/2, width*2, height*2);
  
  strokeWeight(1);
  rect((float)range.x, (float) range.y, (float) range.width * 2, (float)range.height * 2);
  TreeSet<Point> points = qtree.query(range);
  for (Point p : points) {
    strokeWeight(4);
    point((float)p.x, (float)p.y);
  }
}

public float randomGaussian(float min, float max) {
  return min + randomGaussian() * (max - min);
}
