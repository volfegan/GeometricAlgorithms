/**
 * Search for intersection on Array of segments
 * Based on Plane Sweep Line Bentley-Ottmann Algorithm
 * pseudo code: http://geomalgorithms.com/a09-_intersect-3.html
 * pseudo code: https://en.wikipedia.org/wiki/Bentley%E2%80%93Ottmann_algorithm#Detailed_algorithm
 * 
 * @author Volfegan [Daniel L Lacerda]
 * 
 */
import java.util.ArrayList;
import java.util.Arrays;
import java.util.TreeSet;
import java.util.Queue;
import java.util.NavigableSet;
import java.util.PriorityQueue;
import java.util.Iterator;

public class IntersectionFinder {

  private Queue<Event> eventQ;
  private NavigableSet<Segment> statusT;
  private ArrayList<Point> outX; //hold intersections found
  private int event_counter;

  IntersectionFinder(Segment[] input_data) {
    /*
     1. Initialize an empty event queue, EventQ. Next, insert the segment endpoints into EventQ;
     When an endpoint is inserted, the corresponding segment should be stored with it.
     The EventQ is sorted using the compareTo() from Event class by the 'value' field
     */
    this.eventQ = new PriorityQueue<>();
    this.statusT = new TreeSet<>(); //2. Initialize an empty status structure Tau.
    this.outX = new ArrayList<Point>(); //intersections
    this.event_counter = 0; //counts the number of event

    Event eS; //start point
    Event eE; //end point
    for (Segment s : input_data) {
      eS = new Event("start", s.startPoint(), s);
      eE = new Event("end", s.endPoint(), s);
      this.eventQ.add(eS);
      this.eventQ.add(eE);
    }
  }

  //
  public ArrayList<Point> find_intersections() {
    this.event_counter = 0;
    //3. while EventQ is not empty
    while (!this.eventQ.isEmpty()) {

      this.event_counter++;
      //4. Determine the next event point p in EventQ and delete it.
      Event e = this.eventQ.poll();
      double loc = e.get_value(); //value location of segment used on Status line T

      //5. handleEventPoint(p)
      //Events are handled at endpoints of segments (start, end & intersection)
      switch(e.get_type()) {

      case "start":
        //System.out.println(this.event_counter+". Start point event");
        for (Segment s : e.get_segments()) {
          this.recalculate(loc);
          this.statusT.add(s); //Insert segment in sweepline Status

          //check if I = Intersect(event segment s with left segment r) exists -> insert it to eventQ
          if (this.statusT.lower(s) != null) {
            Segment r = this.statusT.lower(s);
            this.report_intersection(r, s, loc);
          }
          //check if I = Intersect(event segment s with right segment t) exists -> insert it to eventQ
          if (this.statusT.higher(s) != null) {
            Segment t = this.statusT.higher(s);
            this.report_intersection(t, s, loc);
          }
          //if the crossing of r and t (the neighbours of s in the statusT) forms a potential future event
          //in the eventQ, remove this possible future event from the eventQ
          if (this.statusT.lower(s) != null && this.statusT.higher(s) != null) {
            Segment r = this.statusT.lower(s);
            Segment t = this.statusT.higher(s);
            this.remove_future_event(r, t);
          }
        }
        break; //break from start point case

      case "end":
        //System.out.println(this.event_counter+". End point event");
        for (Segment s : e.get_segments()) {

          //check if I = Intersect(left segment r with right segment t) exists -> insert it to eventQ
          if (this.statusT.lower(s) != null && this.statusT.higher(s) != null) {
            Segment r = this.statusT.lower(s);
            Segment t = this.statusT.higher(s);
            this.report_intersection(r, t, loc);
          }
          this.statusT.remove(s); //Delete segment from  sweepline Status
        }
        break; //break from end point case

      case "intersection":
        //System.out.println(this.event_counter+". Intersection point event");
        Segment s1 = e.get_segments().get(0);
        Segment s2 = e.get_segments().get(1);
        //The swap position is done to reveal new possible intersection from new neighbour segments
        this.swap(s1, s2);
        //Find the segment from[s1, s2] that is bellow the other in statusT
        //check for intersection with the bellow segment with a segment even more lower
        //check for intersection with the higher segment with a segment even more higher
        if (s1.get_value() < s2.get_value()) {
          if (this.statusT.higher(s1) != null) {
            Segment t = this.statusT.higher(s1);
            this.report_intersection(t, s1, loc);
            this.remove_future_event(t, s2);
          }
          if (this.statusT.lower(s2) != null) {
            Segment r = this.statusT.lower(s2);
            this.report_intersection(r, s2, loc);
            this.remove_future_event(r, s1);
          }
        } else {
          if (this.statusT.higher(s2) != null) {
            Segment t = this.statusT.higher(s2);
            this.report_intersection(t, s2, loc);
            this.remove_future_event(t, s1);
          }
          if (this.statusT.lower(s1) != null) {
            Segment r = this.statusT.lower(s1);
            this.report_intersection(r, s1, loc);
            this.remove_future_event(r, s2);
          }
        }
        this.outX.add(e.get_eventPt());
        break; //break from intersection point case
      }
      //
      //System.out.println("EventQ = "+this.eventQ);
    }
    return outX;
  }

  public ArrayList<Point> get_intersections() {
    return this.outX;
  }

  public int get_event_qty() {
    return this.event_counter;
  }

  private void recalculate(double location) {
    Iterator<Segment> iter = this.statusT.iterator();
    while (iter.hasNext()) {
      iter.next().calculate_value(location);
    }
  }
  //Find any intersections between s1, s2 and add it to eventQ
  //return true if found an intersection or false otherwise
  private boolean report_intersection(Segment s1, Segment s2, double loc) {
    Point intersection = s1.intersect(s2);
    //only add new intersections that are after the current 'location' loc
    if (intersection != null && intersection.get_x() > loc) {
      this.eventQ.add(new Event("intersection", intersection, new ArrayList<>(Arrays.asList(s1, s2))));
      //System.out.println("Intersection included into eventQ: "+intersection);
      return true;
    }
    return false;
  }

  /*Never used this function
   
   //check if a event intersection point exists at eventQ
   boolean containsX(Point intersection) {
   for (Event e : this.eventQ) {
   if (e.get_type().equals("intersection")) {
   if (intersection.equals(e.get_eventPt()))
   return true;
   }
   }
   return false;
   }
   */

  //removes any possible duplicated intersecton between s1, s2 from eventQ
  //return true if found a possible future duplicated intersection or false otherwise
  private boolean remove_future_event(Segment s1, Segment s2) {
    for (Event e : this.eventQ) {
      if (e.get_type().equals("intersection")) {
        //if ((e.get_segments().get(0) == s1 && e.get_segments().get(1) == s2) || 
        //  (e.get_segments().get(0) == s2 && e.get_segments().get(1) == s1)) {
        if ((e.get_segments().get(0).equals(s1) && e.get_segments().get(1).equals(s2)) || 
          (e.get_segments().get(0).equals(s2) && e.get_segments().get(1).equals(s1))) {
          this.eventQ.remove(e);
          return true;
        }
      }
    }
    return false;
  }

  //To swap position we delete from statusT the segments and exchange their 'value' field
  //and re-insert them. They will swap position as the 'value' is auto sort im the binary tree
  private void swap(Segment s1, Segment s2) {
    this.statusT.remove(s1);
    this.statusT.remove(s2);
    double value = s1.get_value();
    s1.set_value(s2.get_value());
    s2.set_value(value);
    this.statusT.add(s1);
    this.statusT.add(s2);
  }
}
