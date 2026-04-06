// list of possible colors for particles
color[] colors = {
  color(255, 0, 0), 
  color(0, 255, 0), 
  color(0, 0, 255), 
  color(255, 255, 0), 
  color(255, 0, 255), 
  color(0, 255, 255)
};

class Node {
  Node parent;
  float x, y, w, h;
  ArrayList<Particle> particles;
  Node[] children;
  int capacity;
  boolean divided;
  color nodeColor;

  Node(Node parent, float x, float y, float w, float h, int capacity) {
    this.parent = parent;
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

  int childIndexFor(float px, float py) {
    float midX = x + w * 0.5f;
    float midY = y + h * 0.5f;

    int idx = 0;
    if (px >= midX) idx += 1; // east
    if (py >= midY) idx += 2; // south
    return idx;
  }

  Node childFor(float px, float py) {
    return children[childIndexFor(px, py)];
  }

  boolean insert(Particle p) {
    if (!contains(p.x, p.y)) {
      return false;
    }

    if (divided) {
      return childFor(p.x, p.y).insert(p);
    }

    particles.add(p);
    p.owner = this;

    if (particles.size() > capacity) {
      subdivideAndRedistribute();
    }

    return true;
  }

  void subdivideAndRedistribute() {
    if (divided) return;

    float nw = w * 0.5f;
    float nh = h * 0.5f;

    children[0] = new Node(this, x, y, nw, nh, capacity);           // NW
    children[1] = new Node(this, x + nw, y, nw, nh, capacity);      // NE
    children[2] = new Node(this, x, y + nh, nw, nh, capacity);      // SW
    children[3] = new Node(this, x + nw, y + nh, nw, nh, capacity); // SE

    divided = true;

    ArrayList<Particle> toMove = new ArrayList<Particle>(particles);
    particles.clear();

    for (Particle existing : toMove) {
      childFor(existing.x, existing.y).insert(existing);
    }
  }

  boolean remove(Particle p) {
    if (!particles.remove(p)) {
      return false;
    }

    p.owner = null;
    rebalanceUpward();
    return true;
  }

  void rebalanceUpward() {
    Node current = this;

    while (current != null) {
      if (current.divided) {
        int total = current.subtreeParticleCount();
        if (total <= current.capacity) {
          current.collapseToLeaf();
        }
      }
      current = current.parent;
    }
  }

  int subtreeParticleCount() {
    int total = particles.size();

    if (divided) {
      for (Node child : children) {
        if (child != null) {
          total += child.subtreeParticleCount();
        }
      }
    }

    return total;
  }

  void collectParticles(ArrayList<Particle> out) {
    out.addAll(particles);

    if (divided) {
      for (Node child : children) {
        if (child != null) {
          child.collectParticles(out);
        }
      }
    }
  }

  void collapseToLeaf() {
    if (!divided) return;

    ArrayList<Particle> all = new ArrayList<Particle>();
    collectParticles(all);

    divided = false;
    children = new Node[4];
    particles.clear();

    for (Particle p : all) {
      particles.add(p);
      p.owner = this;
    }
  }

  void display(boolean showParticles) {
    stroke(125);
    noFill();
    strokeWeight(1);
    rect(x, y, w, h);

    if (divided) {
      for (Node child : children) {
        if (child != null) child.display(showParticles);
      }
    } else if (showParticles) {
      for (Particle p : particles) {
        p.col = nodeColor;
        p.display();
      }
    }
  }

  void clear() {
    for (Particle p : particles) {
      p.owner = null;
    }

    if (divided) {
      for (Node child : children) {
        if (child != null) child.clear();
      }
    }

    divided = false;
    children = new Node[4];
  }

  Particle findNearest(float px, float py) {
    Particle nearest = null;
    float nearestDistSq = Float.MAX_VALUE;

    ArrayList<Particle> candidates = new ArrayList<Particle>();
    collectParticles(candidates);

    for (Particle p : candidates) {
      float distSq = sq(px - p.x) + sq(py - p.y);
      if (distSq < nearestDistSq) {
        nearestDistSq = distSq;
        nearest = p;
      }
    }

    return nearest;
  }
}

class Quadtree {
  Node root;

  Quadtree(float x, float y, float w, float h, int capacity) {
    root = new Node(null, x, y, w, h, capacity);
  }

  boolean insert(Particle p) {
    return root.insert(p);
  }

  void display(boolean showParticles) {
    root.display(showParticles);
  }

  boolean updateParticle(Particle p) {
    if (p == null) return false;

    if (p.owner != null && p.owner.contains(p.x, p.y)) {
      return true;
    }

    Node start = p.owner;

    if (start != null) {
      start.remove(p);
    } else {
      start = root;
    }

    return insertFrom(start, p);
  }

  boolean insertFrom(Node start, Particle p) {
    Node current = start;

    while (current != null && !current.contains(p.x, p.y)) {
      current = current.parent;
    }

    if (current == null) {
      current = root;
    }

    return current.insert(p);
  }

  void clear() {
    root.clear();
  }

  Particle findNearest(float px, float py) {
    return root.findNearest(px, py);
  }

  void remove(Particle p) {
    if (p.owner != null) {
      p.owner.remove(p);
    }
  }
}