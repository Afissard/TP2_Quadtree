// list of possible colors for particles
color[] colors = {
    color(255, 0, 0), 
    color(0, 255, 0), 
    color(0, 0, 255), 
    color(255, 255, 0), 
    color(255, 0, 255), 
    color(0, 255, 255)
};

// Node class for Quadtree
class Node {
  float x, y, w, h;
  ArrayList<Particle> particles;
  Node[] children;
  int capacity;
  boolean divided;
  color nodeColor;

  Node(float x, float y, float w, float h, int capacity) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.capacity = capacity;
    this.particles = new ArrayList<Particle>();
    this.children = new Node[4];
    this.divided = false;
    int index = int((x + y) % colors.length);
    this.nodeColor = colors[index];
  }

  boolean contains(float px, float py) {
    return px >= x && px < x + w && py >= y && py < y + h;
  }

  // Insert so that ONLY leaves contain particles
  boolean insert(Particle p) {
    if (!contains(p.x, p.y)) {
      return false;
    }

    // If already subdivided, push directly to children
    if (divided) {
      for (Node child : children) {
        if (child.insert(p)) return true;
      }
      return false;
    }

    // Leaf with room
    if (particles.size() < capacity) {
      particles.add(p);
      return true;
    }

    // Leaf is full -> subdivide and redistribute existing particles
    subdivide();

    for (int i = particles.size() - 1; i >= 0; i--) {
      Particle existing = particles.get(i);
      boolean moved = false;
      for (Node child : children) {
        if (child.insert(existing)) {
          moved = true;
          break;
        }
      }
      if (moved) {
        particles.remove(i);
      }
    }

    // Insert the new particle into one child
    for (Node child : children) {
      if (child.insert(p)) return true;
    }

    return false;
  }

  void subdivide() {
    float nw = w / 2;
    float nh = h / 2;

    children[0] = new Node(x, y, nw, nh, capacity);             // NW
    children[1] = new Node(x + nw, y, nw, nh, capacity);        // NE
    children[2] = new Node(x, y + nh, nw, nh, capacity);        // SW
    children[3] = new Node(x + nw, y + nh, nw, nh, capacity);   // SE

    divided = true;
  }

  void display() {
    stroke(255);
    noFill();
    strokeWeight(1);
    rect(x, y, w, h);

    if (divided) {
      for (Node child : children) {
        child.display();
      }
    } else {
      for (Particle p : particles) {
        p.col = nodeColor;
        p.display();
      }
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
