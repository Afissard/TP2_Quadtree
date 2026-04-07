int MAX_PARTICLES_PER_NODE = 4;
Particle selected = null;
boolean showTree = true;
boolean moveParticles = true;
boolean showParticles = true;

Quadtree qt;

void settings() {
  size(800, 600);
}

void setup() {
  qt = new Quadtree(0, 0, width, height, MAX_PARTICLES_PER_NODE);

  for (int i = 0; i < 100; i++) {
    qt.insert(new Particle(random(width), random(height)));
  }
}

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
    qt.clear();
    selected = null;
  }
  if (key == 'q' || key == 'Q') {
    showTree = !showTree;
  }
  if (key == 'b' || key == 'B') {
    moveParticles = !moveParticles;
  }
  if (key == 'p' || key == 'P') {
    showParticles = !showParticles;
  }
}

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
  text("Appuyer sur B pour arrêter les points", 0, 20);
  text("Appuyer sur C pour supprimer tous les points", 0, 40);
  text("Appuyer sur Q pour basculer l'affichage de l'arbre", 0, 60);
  text("Appuyer sur P pour basculer l'affichage des particules", 0, 80);
  text("Clique droit pour supprimer un point", 0, 100);
  text("Clique gauche pour ajouter un point", 0, 120);
  text("Clique gauche appuyé pour déplacer un point", 0, 140);
}