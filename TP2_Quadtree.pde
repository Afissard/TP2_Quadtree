int MAX_PARTICLES_PER_NODE = 4;

ArrayList<Particle> allParticles = new ArrayList<Particle>();

Particle selected = null;
boolean showTree = true;


Quadtree qt;

void settings() {
  size(800, 600);
}

void setup() {
  qt = new Quadtree(0, 0, width, height, MAX_PARTICLES_PER_NODE);
  
  // Add random particles
  for (int i = 0; i < 100; i++) {
    Particle p = new Particle(random(width), random(height));
    allParticles.add(p);
  }
}

void mousePressed() {
  if (mouseButton == LEFT) {

    for (Particle p : allParticles) {
      if (dist(mouseX, mouseY, p.x, p.y) < 5) {
        selected = p;
        return;
      }
    }

    Particle p = new Particle(mouseX, mouseY);
    allParticles.add(p);
  }

  if (mouseButton == RIGHT) {
    for (int i = allParticles.size() - 1; i >= 0; i--) {
      Particle p = allParticles.get(i);
      if (dist(mouseX, mouseY, p.x, p.y) < 5) {
        allParticles.remove(i);
        break;
      }
    }
  }
}

void mouseDragged() {
  if (selected != null) {
    selected.x = mouseX;
    selected.y = mouseY;
  }
}

void mouseReleased() {
  selected = null;
}

void keyPressed() {
  if (key == 'c' || key == 'C') {
    allParticles.clear();
  }

  if (key == 'q' || key == 'Q') {
    showTree = !showTree;
  }
}

void draw() {
  background(0);

  qt = new Quadtree(0, 0, width, height, MAX_PARTICLES_PER_NODE);

  for (Particle p : allParticles) {
    qt.insert(p);
  }

  if (showTree) {
    qt.display();
  } else {
    for (Particle p : allParticles) {
      p.display();
    }
  }
}

