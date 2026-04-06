int MAX_PARTICLES_PER_NODE = 4;


Quadtree qt;

void settings() {
  size(800, 600);
}

void setup() {
  qt = new Quadtree(0, 0, width, height, MAX_PARTICLES_PER_NODE);
  
  // Add random particles
  for (int i = 0; i < 100; i++) {
    // choose a random color from the list
    color col = colors[int(random(colors.length))];
    qt.insert(new Particle(random(width), random(height), col));
  }
}

void draw() {
  background(0);
  qt.display();
}