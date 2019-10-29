/* author Volfegan [Daniel L Lacerda]
 * Spatial hashing implementation based at:
 * http://conkerjo.wordpress.com/2009/06/13/spatial-hashing-implementation-for-fast-2d-collisions/
 */
import java.util.TreeSet;
import java.util.HashMap;

public class SpatialHash {

  private int NUM_BUCKETS;
  private int w;
  private int h;
  private int cols;
  private int rows;
  private float cellSize;
  public HashMap<Integer, TreeSet<Point>> buckets;

  /**
   * Constructor
   * @param int width_, int height_ of Canvas
   * @param int cellSize_ -> how much to divide the Canvas width|height to make the grid
   */
  public SpatialHash(int width_, int height_, int cellSize_) {
    w = width_;
    h = height_;
    cols = width_ / cellSize_;
    rows = height_ / cellSize_;
    cellSize = cellSize_;
    NUM_BUCKETS = cols * rows;

    buckets = new HashMap<Integer, TreeSet<Point>>(NUM_BUCKETS);
  }

  /**
   * This hash works with any 'width' and 'height' sizes to generate a 'HashKey'
   * @param double x_, double y_ position
   * return an unique int 'HashKey' index for the bucket
   */
  public int getBucketIndex(double x_, double y_) {
    int bindex;
    if (w >= h)
      bindex = Math.round(Math.round(x_ / cellSize)*cols + Math.round(y_ / cellSize));
    else
      bindex = Math.round(Math.round(x_ / cellSize) + Math.round(y_ / cellSize)*rows);

    return bindex;
  }

  public boolean add(Point p) {
    try {
      int bindex = getBucketIndex(p.getX(), p.getY());

      TreeSet<Point> list = buckets.get(bindex);
      if (list == null) {
        list = new TreeSet<Point>();
      }
      list.add(p);
      buckets.put(bindex, list);
      return true;
    }
    catch(Exception e) {
      return false;
    }
  }

  public boolean remove(Point p) {
    try {
      boolean operation = false;
      int bindex = getBucketIndex(p.getX(), p.getY());
      TreeSet<Point> list = buckets.get(bindex);
      if (list != null) {
        operation = list.remove(p);
        if (operation == true) {
          buckets.put(bindex, list);
        }
      }
      return operation;
    }
    catch(Exception e) {
      return false;
    }
  }
  
  public void clear() {
    buckets.clear();
  }

  public boolean contains(Point p) {
    int bindex = getBucketIndex(p.getX(), p.getY());
    TreeSet<Point> list = buckets.get(bindex);
    return list.contains(p);
  }

  /**
   * Get all points from the bucket for that position
   * @param double x_, double y
   * return TreeSet<Point>> points
   */
  public TreeSet<Point> getFromBucket(double x_, double y_) {
    int bindex = getBucketIndex(x_, y_);
    TreeSet<Point> points = buckets.get(bindex);
    if (points == null) points = new TreeSet<Point>();
    return points;
  }

  public TreeSet<Point> query(Rectangle range) {
    TreeSet<Point> findPoints = new TreeSet<Point>();

    //get the 4 extreme points from the rectangle range
    Point upperLeft = new Point(range.x - range.width, range.y - range.height);
    Point upperRight = new Point(range.x + range.width, range.y - range.height);
    Point bottomLeft = new Point(range.x - range.width, range.y + range.height);
    //Point bottomRight = new Point(range.x + range.width, range.y + range.height);

    int leftPosX= (int)upperLeft.getX();
    int rightPosX = (int)upperRight.getX();
    int upperPosY = (int)upperLeft.getY();
    int bottomPosY = (int)bottomLeft.getY();

    //edge case ckeck when the range size is less than the cellSize
    float growFactorX = 0;
    if ((rightPosX-leftPosX) < cellSize) {
      growFactorX = rightPosX-leftPosX;
    } else {
      growFactorX = cellSize;
    }
    float growFactorY = 0;
    if ((bottomPosY-upperPosY) < cellSize) {
      growFactorY = bottomPosY-upperPosY;
    } else {
      growFactorY = cellSize;
    }
    //loop through all the buckets where the rectangle range intersects
    for (int cellX = leftPosX; cellX <= rightPosX; cellX+=growFactorX) {
      for (int cellY = upperPosY; cellY <= bottomPosY; cellY+=growFactorY) {
        TreeSet<Point> points = getFromBucket(cellX, cellY);
        for (Point p : points) {
          if (range.contains(p))
            findPoints.add(p);
        }
      }
    }
    return findPoints;
  }

  public TreeSet<Point> query(Circle range) {
    TreeSet<Point> findPoints = new TreeSet<Point>();

    //get the 4 extreme points from the circle range
    Point mostLeft = new Point(range.x - range.r, range.y);
    Point mostRight = new Point(range.x + range.r, range.y);
    Point top = new Point(range.x, range.y - range.r);
    Point bottom = new Point(range.x, range.y + range.r);

    int leftPosX= (int)mostLeft.getX();
    int rightPosX = (int)mostRight.getX();
    int upperPosY = (int)top.getY();
    int bottomPosY = (int)bottom.getY();

    //edge case ckeck when the range size is less than the cellSize
    float growFactorX = 0;
    if ((rightPosX-leftPosX) < cellSize) {
      growFactorX = rightPosX-leftPosX;
    } else {
      growFactorX = cellSize;
    }
    float growFactorY = 0;
    if ((bottomPosY-upperPosY) < cellSize) {
      growFactorY = bottomPosY-upperPosY;
    } else {
      growFactorY = cellSize;
    }
    //loop through all the buckets where the circle range intersects
    for (int cellX = leftPosX; cellX <= rightPosX; cellX+=growFactorX) {
      for (int cellY = upperPosY; cellY <= bottomPosY; cellY+=growFactorY) {
        TreeSet<Point> points = getFromBucket(cellX, cellY);
        for (Point p : points) {
          if (range.contains(p))
            findPoints.add(p);
        }
      }
    }
    return findPoints;
  }

  //this method requires Processing functions
  public void show() {
    stroke(255);
    strokeWeight(1);
    noFill();
    //vertical lines
    for (int a = 0; a <= w/cellSize; a++) {
      line(cellSize*(a+0.5), 0, cellSize*(a+0.5), h);
    }
    //horizontal lines
    for (int a = 0; a <= h/cellSize; a++) {
      line(0, cellSize*(a+0.5), w, cellSize*(a+0.5));
    }
    //show selected quadrant (mouse hover)
    Rectangle boundary = null;
    for (int u = 0; u <= cols; u++) {
      for (int v = 0; v <= rows; v++) {
        //create a rectangle boundary around one bucket cell
        float x = u * cellSize;
        float y = v * cellSize;
        boundary = new Rectangle(x, y, cellSize/2, cellSize/2);
        Point mouse = new Point(mouseX, mouseY);
        if (boundary.contains(mouse)) {
          stroke(0, 255, 0);
          rectMode(CENTER);
          rect(x, y, cellSize, cellSize);
        }
      }
    }
    //show points
    for (TreeSet<Point> points : buckets.values()) {
      for (Point p : points) {
        point((float)p.getX(), (float)p.getY());
      }
    }
  }
}
