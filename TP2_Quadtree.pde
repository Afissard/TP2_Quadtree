/**
 * Main Processing sketch for the quadtree particle simulation.
 * Handles setup, rendering, user interaction, and keyboard controls.
 */

// Maximum number of particles allowed in a leaf node before subdivision.
int MAX_PARTICLES_PER_NODE = 4;

// Currently selected particle, if any.
Particle selected = null;

// Display and simulation toggles.
boolean showTree = true;
boolean moveParticles = true;
boolean showParticles = true;

// Quadtree used to store, update, and query particles.
Quadtree qt;

/** Initializes the window size. */
void settings() {
  size(800, 600);
}

/**
 * Creates the quadtree and populates it with an initial set of particles.
 */
void setup() {
  qt = new Quadtree(0, 0, width, height, MAX_PARTICLES_PER_NODE);

  for (int i = 0; i < 100; i++) {
    qt.insert(new Particle(random(width), random(height)));
  }
}

/**
 * Handles mouse clicks.
 * Left click:
 * - select a nearby particle
 * - otherwise create a new particle
 * Right click:
 * - remove a nearby particle
 */
void mousePressed() {
  if (mouseButton == LEFT) {
    Particle p = qt.findNearest(mouseX, mouseY);
    if (p != null && dist(mouseX, mouseY, p.x, p.y) < 5) {
      selected = p;
      return;
    }

    qt.insert(new Particle(mouseX, mouseY));
  } else if (mouseButton == RIGHT) {
    Particle p = qt.findNearest(mouseX, mouseY);
    if (p != null && dist(mouseX, mouseY, p.x, p.y) < 5) {
      qt.remove(p);
      if (p == selected) {
        selected = null;
      }
    }
  }
}

/** Moves the selected particle with the mouse while dragging. */
void mouseDragged() {
  if (selected != null) {
    selected.x = mouseX;
    selected.y = mouseY;
  }
}

/** Clears the current selection when the mouse is released. */
void mouseReleased() {
  selected = null;
}

/**
 * Handles keyboard shortcuts.
 * A: clear all particles
 * Z: toggle quadtree display
 * Space: pause/resume particle movement
 * E: toggle particle rendering
 */
void keyPressed() {
  if (key == 'a' || key == 'A') {
    qt.clear();
    selected = null;
  }
  if (key == 'z' || key == 'Z') {
    showTree = !showTree;
  }
  if (key == ' ') {
    moveParticles = !moveParticles;
  }
  if (key == 'e' || key == 'E') {
    showParticles = !showParticles;
  }
}

/**
 * Main draw loop.
 * Updates particle positions, keeps the quadtree in sync, and renders
 * either the tree view or the flat particle view depending on settings.
 */
void draw() {
  background(0);

  ArrayList<Particle> particles = qt.getParticles();

  for (Particle p : particles) {
    if (p != selected && moveParticles) {
      p.update(width, height);
    }
    qt.updateParticle(p);
  }

  if (showTree) {
    qt.display(showParticles);
  } else if (showParticles) {
    for (Particle p : particles) {
      p.display();
    }
  }

  textSize(15);
  fill(255);
  text("Appuyer sur Espace pour arrêter les points", 0, 20);
  text("Appuyer sur A pour supprimer tous les points", 0, 40);
  text("Appuyer sur Z pour basculer l'affichage de l'arbre", 0, 60);
  text("Appuyer sur E pour basculer l'affichage des particules", 0, 80);
  text("Clique droit pour supprimer un point", 0, 100);
  text("Clique gauche pour ajouter un point", 0, 120);
  text("Clique gauche appuyé pour déplacer un point", 0, 140);
}