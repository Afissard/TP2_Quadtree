// Node class for Quadtree
class Node {
  float x, y, w, h;
  ArrayList<Particle> particles;
  Node[] children;
  int capacity;
  boolean divided;

  Node(float x, float y, float w, float h, int capacity) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.capacity = capacity;
    this.particles = new ArrayList<Particle>();
    this.children = new Node[4];
    this.divided = false;
  }

  // Check if a point is inside this node
  boolean contains(float px, float py) {
    return px >= x && px < x + w && py >= y && py < y + h;
  }

  // Insert a particle recursively
  boolean insert(Particle p) {
    if (!contains(p.x, p.y)) {
      return false;
    }

    if (particles.size() < capacity) {
      particles.add(p);
      return true;
    } else {
      if (!divided) {
        subdivide();
      }
      
      for (Node child : children) {
        if (child.insert(p)) {
          return true;
        }
      }
    }
    return false;
  }

  // Subdivide node into 4 children
  void subdivide() {
    float nw = w / 2;
    float nh = h / 2;
    
    children[0] = new Node(x, y, nw, nh, capacity);
    children[1] = new Node(x + nw, y, nw, nh, capacity);
    children[2] = new Node(x, y + nh, nw, nh, capacity);
    children[3] = new Node(x + nw, y + nh, nw, nh, capacity);
    
    divided = true;
  }

  // Display the quadtree structure
  void display() {
    stroke(255);
    noFill();
    strokeWeight(1);
    rect(x, y, w, h);

    if (divided) {
      for (Node child : children) {
        child.display();
      }
    }

    // Display particles in this node
    fill(0, 255, 0);
    stroke(0, 255, 0);
    strokeWeight(2);
    for (Particle p : particles) {
      point(p.x, p.y);
      circle(p.x, p.y, 4);
    }

  }
}


// Quadtree class
class Quadtree {
  Node root;

  Quadtree(float x, float y, float w, float h, int capacity) {
    root = new Node(x, y, w, h, capacity);
  }

  // Insert a particle into the quadtree
  boolean insert(Particle p) {
    return root.insert(p);
  }

  // Display the entire quadtree
  void display() {
    root.display();
  }
}