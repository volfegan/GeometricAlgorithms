/**
 * Event points that hold point position, value (for sorting purposes)
 * segments involved and type (start (left point of s)|end (right point of s)|intersection)
 * 
 * @author Volfegan [Daniel L Lacerda]
 * 
 */
import java.util.ArrayList;
import java.util.Arrays;

public class Event implements Comparable<Event> {

  private String type; //start|end|intersection
  private Point eventPt;
  private ArrayList<Segment> segments;
  private double value; //some x position for sorting purposes

  Event(String type, Point p, Segment s) {
    this.type = type; //start (left point)|end (right point)|intersection
    this.eventPt = p;
    this.segments = new ArrayList<>(Arrays.asList(s));
    this.value = p.get_x();
  }
  Event(String type, Point p, ArrayList<Segment> s) {
    this.type = type; //start|end|intersection
    this.eventPt = p;
    this.segments = s;
    this.value = p.get_x();
  }

  public void set_eventPt(Point p) {
    this.eventPt = p;
  }

  public Point get_eventPt() {
    return this.eventPt;
  }

  public ArrayList<Segment> get_segments() {
    return this.segments;
  }

  public String toString() {
    return this.type+" " + this.eventPt;
  }

  public String get_type() {
    return this.type;
  }

  public void set_value(double value) {
    this.value = value;
  }

  public double get_value() {
    return this.value;
  }

  public int compareTo(Event e) {
    if (this.get_value() < e.get_value())
      return -1;
    if (this.get_value() > e.get_value())
      return 1;
    return 0;
  }

  //some event is equal when their points are the same coord and same type (left|right|intersection)
  public boolean equals(Object e) {
    Event evt_x = (Event) e;
    if (this.type.equals(evt_x.type) && this.eventPt.equals(evt_x.eventPt))
      return true;
    else
      return false;
  }
}
