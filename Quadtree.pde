// list of possible colors for particles
color[] colors = {
  color(255, 0, 0),
  color(0, 255, 0),
  color(0, 0, 255),
  color(255, 255, 0),
  color(255, 0, 255),
  color(0, 255, 255)
};

/**
 * A quadtree node that stores particles inside a rectangular region.
 * A node can either be a leaf containing particles directly, or an internal
 * node divided into four child regions.
 */
class Node {
  Node parent;
  float x, y, w, h;
  ArrayList<Particle> particles;
  Node[] children;
  int capacity;
  boolean divided;
  color nodeColor;

  /**
   * Creates a new node for the given rectangle and capacity.
   *
   * @param parent   parent node, or null for the root
   * @param x        left position of the region
   * @param y        top position of the region
   * @param w        width of the region
   * @param h        height of the region
   * @param capacity maximum number of particles before subdivision
   */
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

  /** Returns true when the point is inside this node's bounds. */
  boolean contains(float px, float py) {
    return px >= x && px < x + w && py >= y && py < y + h;
  }

  /**
   * Returns the child index for a point.
   * 0 = NW, 1 = NE, 2 = SW, 3 = SE
   */
  int childIndexFor(float px, float py) {
    float midX = x + w * 0.5f;
    float midY = y + h * 0.5f;

    int idx = 0;
    if (px >= midX) idx += 1; // east
    if (py >= midY) idx += 2; // south
    return idx;
  }

  /** Returns the child node that contains the given point. */
  Node childFor(float px, float py) {
    return children[childIndexFor(px, py)];
  }

  /**
   * Inserts a particle into this node or one of its children.
   * Subdivides the node if the capacity is exceeded.
   */
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

  /** Splits this node into four children and moves particles into them. */
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

  /** Removes a particle from this node and tries to collapse ancestors. */
  boolean remove(Particle p) {
    if (!particles.remove(p)) {
      return false;
    }

    p.owner = null;
    rebalanceUpward();
    return true;
  }

  /**
   * Checks parent nodes and collapses any internal node whose subtree
   * particle count is below or equal to capacity.
   */
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

  /** Counts all particles stored in this node and its descendants. */
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

  /** Collects all particles in this subtree into the provided list. */
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

  /** Collapses this internal node back into a leaf node. */
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

  /** Draws the node bounds and optionally its particles. */
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

  /** Clears all particles and child nodes from this subtree. */
  void clear() {
    for (Particle p : particles) {
      p.owner = null;
    }

    particles.clear();

    if (divided) {
      for (Node child : children) {
        if (child != null) {
          child.clear();
        }
      }
    }

    divided = false;
    children = new Node[4];
  }

  /** Returns the particle closest to the given point within this subtree. */
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

/**
 * Quadtree container that manages the root node and provides
 * high-level insertion, update, removal, and search operations.
 */
class Quadtree {
  Node root;

  /**
   * Creates a quadtree covering the given rectangle.
   *
   * @param x        left position of the tree
   * @param y        top position of the tree
   * @param w        width of the tree
   * @param h        height of the tree
   * @param capacity maximum number of particles per leaf node
   */
  Quadtree(float x, float y, float w, float h, int capacity) {
    root = new Node(null, x, y, w, h, capacity);
  }

  /** Inserts a particle into the quadtree. */
  boolean insert(Particle p) {
    return root.insert(p);
  }

  /** Returns a flat list of every particle stored in the tree. */
  ArrayList<Particle> getParticles() {
    ArrayList<Particle> particles = new ArrayList<Particle>();
    root.collectParticles(particles);
    return particles;
  }

  /** Draws the full quadtree and optionally all particles. */
  void display(boolean showParticles) {
    root.display(showParticles);
  }

  /**
   * Updates a particle after it has moved.
   * Reinserts it if it no longer belongs to its current owner node.
   */
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

  /**
   * Attempts to insert a particle starting from a given node and moving
   * upward until a node containing the particle is found.
   */
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

  /** Removes all particles and resets the tree structure. */
  void clear() {
    root.clear();
    // root = new Node(null, x, y, w, h, capacity);
  }

  /** Finds the particle nearest to the given point. */
  Particle findNearest(float px, float py) {
    return root.findNearest(px, py);
  }

  /** Removes a particle from the tree if it has an owner node. */
  void remove(Particle p) {
    if (p.owner != null) {
      p.owner.remove(p);
    }
  }
}