int MAX_PARTICLES_PER_NODE = 4;

// Particle class
class Particle {
  float x, y;
  
  Particle(float x, float y) {
    this.x = x;
    this.y = y;
  }
}

Quadtree qt;

void settings() {
  size(800, 600);
}

void setup() {
  qt = new Quadtree(0, 0, width, height, MAX_PARTICLES_PER_NODE);
  
  // Add random particles
  /*for (int i = 0; i < 100; i++) {
    qt.insert(new Particle(random(width), random(height)));
  }*/
}

void mousePressed() {
  // On crée un nouveau point aux coordonnées de la souris
  Particle p = new Particle(mouseX, mouseY);
  
  // On l'insère dans le Quadtree
  qt.insert(p);
}

void draw() {
  background(0);
  qt.display();
}