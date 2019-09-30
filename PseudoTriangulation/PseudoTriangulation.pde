/**
 * This program implements some pseudoTriangulation using Point nodes and Line class.
 * The pseudoTriangulation is limited by some maxDist and the triangles intersect one another
 * @author Volfegan [Daniel L Lacerda]
 * 
 */

ArrayList<Line> lines = new ArrayList<Line>();
ArrayList<Node> nodePoints = new ArrayList<Node>();
int maxDist = 100; //any distance above, the points will not connect
int pointsQty = 150;

boolean showFrameRate = true;

public void keyPressed() {
  //show/hide frame rate
  if (key == 'f') {
    if (showFrameRate) {
      showFrameRate = false;
    } else {
      showFrameRate = true;
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
  //Add more points
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

  width = 960;
  height = 720;

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
          lines.add(new Line(nodeA.getPVector(), nodeB.getPVector(), alpha));
        }
      }
    }
    if (a < repeatProcess - 1) lines.clear(); //reset to repeat
    //end of brute force process
  }
  endTime = System.nanoTime();
  long executionTime = (endTime - startTime); // nano seconds
  //printing to file
  output = createWriter("output.txt");
  output.println("Number of points = "+pointsQty);
  output.println("Triangulation distance = "+maxDist);
  output.println("Number of line segments = "+lines.size());
  output.println();
  output.println("Number of checks = "+number_of_checks);
  output.println("Execution Time ("+repeatProcess+"x) = "+(float)executionTime/1000000 + " milliseconds");
  output.flush();
  output.close();
  lines.clear();
  //end of eval

  size(width, height);
  println("width="+width +", height="+height);
}

void setup() {
  //initial canvas size is set on settings
  background(0);
  for (Node p : nodePoints) {
    p.display();
  }
  //creates the lines between nodes when they are less than maxDist
  //the double loop is efficient bruteforce search - never repeats the nodes
  for (int i = 0; i < nodePoints.size()-1; i++) {
    Node nodeA = nodePoints.get(i);
    for (int j = i+1; j < nodePoints.size(); j++) {
      Node nodeB = nodePoints.get(j);
      float dist = dist(nodeA.getX(), nodeA.getY(), nodeB.getX(), nodeB.getY());
      if (dist < maxDist) {
        int alpha = round((1 - dist/maxDist)*255);
        lines.add(new Line(nodeA.getPVector(), nodeB.getPVector(), alpha));
      }
    }
  }

  for (Line line : lines) {
    line.display();
  }
}

void draw() {  
  //show frame rate, frameCount % number is to reduce the rate of println
  if (frameCount % 10 == 0) {
    //println(String.format("%.2f", frameRate) + " frameRate ");
  }

  color green = color(0, 255, 0);

  lines.clear();
  background(0);
  for (Node p : nodePoints) {
    p.display();
    p.update();


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
  //creates the lines between nodes when they are less than maxDist
  //the double loop is efficient bruteforce search - never repeats the nodes
  for (int i = 0; i < nodePoints.size()-1; i++) {
    Node nodeA = nodePoints.get(i);
    for (int j = i+1; j < nodePoints.size(); j++) {
      Node nodeB = nodePoints.get(j);
      float dist = dist(nodeA.getX(), nodeA.getY(), nodeB.getX(), nodeB.getY());
      if (dist < maxDist) {
        int alpha = round((1 - dist/maxDist)*255);
        lines.add(new Line(nodeA.getPVector(), nodeB.getPVector(), alpha));
      }
    }
  }
  for (Line line : lines) {
    line.display();
  }

  //Show framerate on display
  if (showFrameRate) 
    text(" FrameRate=" +String.format("%.1f", frameRate) + " / points="+pointsQty+" / Triangulation dist="+maxDist, 5, 18);
}
