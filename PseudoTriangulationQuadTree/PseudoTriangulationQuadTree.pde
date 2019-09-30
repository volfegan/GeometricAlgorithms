/**
 * This program implements some pseudoTriangulation using Point nodes and Line class.
 * The pseudoTriangulation is limited by some maxDist and the triangles intersect one another
 * @author Volfegan [Daniel L Lacerda]
 * 
 */
import java.util.TreeSet;
import java.util.TreeMap;
import java.util.Collection;

TreeMap<Double, Line> lines = new TreeMap<Double, Line>(); //using TreeMap to guarantee no duplicate lines
ArrayList<Node> nodePoints = new ArrayList<Node>();
int maxDist = 40; //any distance above, the points will not connect
int pointsQty = 1000;

Quadtree quadtree;
boolean showQuadtree = false; //show Quadtree structure and the point nodes 
boolean showFrameRate = true;
boolean pause = false;

public void keyPressed() {
  //show/hide frame rate
  if (key == 'f') {
    if (showFrameRate) {
      showFrameRate = false;
    } else {
      showFrameRate = true;
    }
  }
  if (key == 'q') {
    if (showQuadtree) {
      showQuadtree = false;
    } else {
      showQuadtree = true;
    }
  }
  //pause animation
  if (key == 'p') {
    if (pause) {
      loop();
      pause = false;
    } else {
      noLoop();
      pause = true;
    }
  }
  //reset all points
  if (key == 'r') {
    nodePoints.clear();
    for (int i = 0; i < pointsQty; i++) {
      int x0 = int(random(0, width));
      int y0 = int(random(0, height));
      nodePoints.add(new Node(x0, y0));
    }
  }
  //Triangulation Distance
  if (key == '+') {
    maxDist += 10;
  }
  if (key == '-') {
    maxDist -= 10;
  }
  //Add points
  if (key == 'a') {
    int addPoints = 10;
    pointsQty += addPoints;
    for (int i = 0; i < addPoints; i++) {
      int x0 = int(random(0, width));
      int y0 = int(random(0, height));
      nodePoints.add(new Node(x0, y0));
    }
  }
  //Subtract points
  if (key == 's') {
    int removePoints = 10;
    pointsQty -= removePoints;
    for (int i = 0; i < removePoints; i++) {
      nodePoints.remove((nodePoints.size()-1));
    }
  }
}


void settings() {
  println("Loading points... "+pointsQty);
  //adding the points to display on screen
  for (int i = 0; i < pointsQty; i++) {
    int x0 = int(random(0, 960));
    int y0 = int(random(0, 720));
    //print("(" + x0 + ", " + y0 + "); ");

    //create the points and put them in a list
    nodePoints.add(new Node(x0, y0));
  }

  width = 970;
  height = 730;

  /*
   //Brute force method for calculating connecting line-points
   //evaluation performance
   */
  long startTime = 0;
  long endTime = 0;
  PrintWriter output;
  int number_of_checks = 0;
  //creates the lines between nodes when they are less than maxDist
  //the double loop is efficient bruteforce search - never repeats the nodes
  startTime = System.nanoTime();
  //To better measure the processing time it is better to repeat the process at least 1000 time 
  int repeatProcess = 1000;
  for (int a = 0; a < repeatProcess; a++) {
    number_of_checks = 0;
    for (int i = 0; i < nodePoints.size()-1; i++) {
      Node nodeA = nodePoints.get(i);
      for (int j = i+1; j < nodePoints.size(); j++) {
        Node nodeB = nodePoints.get(j);
        float dist = dist(nodeA.getX(), nodeA.getY(), nodeB.getX(), nodeB.getY());
        number_of_checks++;
        if (dist < maxDist) {
          int alpha = round((1 - dist/maxDist)*255);
          PVector pA = nodeA.getPVector();
          PVector pB = nodeB.getPVector();
          double line_id = (double)(pA.x*width+pA.y)*(pB.x*width+pB.y);
          Line l = new Line(pA, pB, alpha); 
          lines.put(line_id, l);
        }
      }
    }
    //reset to repeat
    if (a < repeatProcess - 1) {
      lines.clear();
    }
    //end of brute force process
  }
  endTime = System.nanoTime();
  long executionTime = (endTime - startTime); // nano seconds
  //printing to file
  output = createWriter("output.txt");
  output.println("Number of points = "+pointsQty);
  output.println("Triangulation distance = "+maxDist);
  output.println();
  output.println("Brute Force Method");
  output.println("Number of line segments = "+lines.size());
  output.println("Number of checks = "+number_of_checks);
  output.println();

  println("Triangulation distance = "+maxDist);
  println();
  println("Brute Force Method");
  println("Number of line segments = "+lines.size());
  println("Number of checks = "+number_of_checks);
  println("Execution Time ("+repeatProcess+"x) = "+(float)executionTime/1000000 + " milliseconds");

  lines.clear();
  /*
   //QuadTree method for calculating connecting line-points
   //evaluation performance
   */
  startTime = System.nanoTime();
  Rectangle boundary = new Rectangle (width/2, height/2, width/2, height/2);
  //To better measure the processing time it is better to repeat the process at least 1000 time 
  for (int a = 0; a < repeatProcess; a++) {
    quadtree = new Quadtree (boundary, 4);
    number_of_checks = 0;
    //Create the Quadtree AND insert the Node points as references
    for (Node p : nodePoints) {
      Point point = new Point (p.getX(), p.getY(), p);
      quadtree.insert(point);
    }

    TreeSet<Point> pointsNearby = new TreeSet<Point>();
    //as we don't get a smarter way to only insert once lines as the efficent brute force
    //we need to catalogue what lines were already inserted using some id for the lines
    TreeSet<Double> LineInserted = new TreeSet<Double>();
    for (Node nodeA : nodePoints) {
      PVector pA = nodeA.getPVector();
      double nodeA_id = (double)(pA.x*width+pA.y);

      Circle range = new Circle ((double)nodeA.getX(), (double)nodeA.getY(), maxDist);    
      pointsNearby = quadtree.query(range);

      for (Point p : pointsNearby) {
        Node nodeB = p.getData();
        PVector pB = nodeB.getPVector();
        double nodeB_id = (double)(pB.x*width+pB.y);
        double line_id = nodeA_id*nodeB_id;

        if (nodeA_id == nodeB_id || LineInserted.contains(line_id)) continue;
        else LineInserted.add(line_id);

        float dist = dist(nodeA.getX(), nodeA.getY(), nodeB.getX(), nodeB.getY());
        number_of_checks++;
        int alpha = round((1 - dist/maxDist)*255);
        Line l = new Line(pA, pB, alpha); 
        lines.put(line_id, l);
      }
      pointsNearby.clear();
    }
    //reset to repeat
    pointsNearby.clear();
    LineInserted.clear();
    if (a < repeatProcess - 1) {
      lines.clear();
    }
    //end of Quadtree process
  }
  endTime = System.nanoTime();
  executionTime = (endTime - startTime); // nano seconds
  //printing to file
  output.println("Quadtree Method");
  output.println("Number of line segments = "+lines.size());
  output.println("Number of checks = "+number_of_checks);
  output.println();
  output.flush();
  output.close();

  println("\nQuadtree Method");
  println("Number of line segments = "+lines.size());
  println("Number of checks = "+number_of_checks);
  println("Execution Time ("+repeatProcess+"x) = "+(float)executionTime/1000000 + " milliseconds");
  lines.clear();
  //end of eval

  size(width, height);
  println("width="+width +", height="+height);
}

void setup() {
  //initial canvas size is set on settings
  background(0);
  //Create the Quadtree AND insert the Node points as references
  Rectangle boundary = new Rectangle (width/2, height/2, width/2, height/2);
  quadtree = new Quadtree (boundary, 8);
  for (Node p : nodePoints) {
    p.display();
    Point point = new Point (p.getX(), p.getY(), p);
    quadtree.insert(point);
  }

  for (Node nodeA : nodePoints) {
    PVector pA = nodeA.getPVector();
    double nodeA_id = (double)(pA.x*width+pA.y);

    Circle range = new Circle ((double)nodeA.getX(), (double)nodeA.getY(), maxDist);     
    TreeSet<Point> pointsNearby = quadtree.query(range);

    TreeSet<Double> LineInserted = new TreeSet<Double>();
    for (Point p : pointsNearby) {
      Node nodeB = p.getData();
      PVector pB = nodeB.getPVector();
      double nodeB_id = (double)(pB.x*width+pB.y);

      double line_id = nodeA_id*nodeB_id;

      if (LineInserted.contains(line_id)) continue;
      else LineInserted.add(line_id);


      float dist = dist(nodeA.getX(), nodeA.getY(), nodeB.getX(), nodeB.getY());
      int alpha = round((1 - dist/maxDist)*255);
      Line l = new Line(pA, pB, alpha); 
      lines.put(line_id, l);
    }
    pointsNearby.clear();
  }

  for (Line line : lines.values()) {
    line.display();
  }
}

void draw() {  
  //show frame rate, frameCount % number is to reduce the rate of println
  if (frameCount % 10 == 0) {
    //println(String.format("%.2f", frameRate) + " frameRate ");
  }

  color green = color(0, 255, 0);

  //reset lists to redraw
  lines.clear();

  background(0);
  //Create the Quadtree AND insert the Node points as references
  Rectangle boundary = new Rectangle (width/2, height/2, width/2, height/2);
  quadtree = new Quadtree (boundary, 4);
  for (Node p : nodePoints) {
    p.display();
    p.update();
    Point point = new Point (p.getX(), p.getY(), p);
    quadtree.insert(point);

    //Rectangule crosshairs
    if (p.lifespan < 100) {
      stroke(green);
      strokeWeight(0);
      noFill();
      rectMode(CENTER);
      rect(p.getX(), p.getY(), 20, 20, 1);
    }

    //if point is expired, respawn it
    if (p.isDead()) {
      //println(p + " is dead -> respawn");
      p.revive();
    }
  }

  for (Node nodeA : nodePoints) {
    PVector pA = nodeA.getPVector();
    double nodeA_id = (double)(pA.x*width+pA.y);

    Circle range = new Circle ((double)nodeA.getX(), (double)nodeA.getY(), maxDist);     
    TreeSet<Point> pointsNearby = quadtree.query(range);

    TreeSet<Double> LineInserted = new TreeSet<Double>();
    for (Point p : pointsNearby) {
      Node nodeB = p.getData();
      PVector pB = nodeB.getPVector();
      double nodeB_id = (double)(pB.x*width+pB.y);

      double line_id = nodeA_id*nodeB_id;

      if (LineInserted.contains(line_id)) continue;
      else LineInserted.add(line_id);


      float dist = dist(nodeA.getX(), nodeA.getY(), nodeB.getX(), nodeB.getY());
      int alpha = round((1 - dist/maxDist)*255);
      Line l = new Line(pA, pB, alpha); 
      lines.put(line_id, l);
    }
    pointsNearby.clear();
  }

  for (Line line : lines.values()) {
    line.display();
  }

  if (showQuadtree) {
    quadtree.show();
  }

  //Show framerate on display
  if (showFrameRate) 
    text(" FrameRate=" +String.format("%.1f", frameRate) + " / points="+pointsQty+" / Triangulation dist="+maxDist, 5, 18);
}
