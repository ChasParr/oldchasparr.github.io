
Ship player;                    // main avatar

int score;                      // game stats
float hits;
float shots;
int level;
int hiScore;

ArrayList<Asteroid> asteroids;  // contains asteroids
ArrayList<Bullet> bullets;      // contains bullets
ArrayList<PowerUp> drops;
int gameState;                  // determines the state the game is in
                                // 0-menu, 1-controls, 2-game setup, 3-game 4-game over, 

void setup(){
  ellipseMode(CENTER);
  size(1000, 700);
  gameState = 0;
  player = new Ship();
  hiScore = 0;
}

void draw(){
  background(0);
  
  // Menu screen
  if (gameState == 0){
    fill(255);
    textSize(60);
    text("ASTEROIDS", width/6, height/3);
    textSize(25);
    text("Click to play", width/6, height/3 + 50);
    text("High Score: " + hiScore, width/6, height/3 + 100);
  } 
  
  // Controls screen
  else if (gameState == 1){
    fill(255);
    textSize(50);
    text("CONTROLS", width/6, height/3);
    textSize(25);
    text("Destroy asteroids and collect powerups to increase your score", width/6, height/3 + 50);
    text("Aim with the mouse", width/6, height/3 + 100);
    text("W - move forward", width/6, height/3 + 150);
    text("S - move backward", width/6, height/3 + 200);
    textSize(15);
    text("Click to continue", width/6, height/3 + 240);
  } 
  
  // Level setup
  else if (gameState == 2){
    for (int i = 0; i < 4 + level / 2 && i < 10; i++){
      asteroids.add(new Asteroid(1, new PVector(random(3 + level / 5), 0).limit(10).rotate(random(TWO_PI)),  new PVector(random(width), random(height))));
    }
    player.invinc = 80;
    gameState = 3;
  } 
  
  // Gameplay
  else if (gameState == 3){
    
    // Update and display asteroids
    for(int i = 0; i < asteroids.size(); i++){
      asteroids.get(i).update();
      asteroids.get(i).display();
    }
    
    // Update and display bullets
    if (bullets.size() > 0){
      for(int i = bullets.size() - 1; i >= 0; i--){
        bullets.get(i).update();
        if (bullets.get(i).life > bullets.get(i).lifespan){      // Checks if bullet has expired
          bullets.remove(i);
          shots++;
        } else {
          bullets.get(i).display();
          for(int j = asteroids.size() - 1; j >= 0; j--){
            if (bullets.get(i).checkCollision(asteroids.get(j))){        // Checks if bullet hits an asteroid
              if (asteroids.get(j).destroy(bullets.get(i).position)){
                asteroids.remove(j);
              }
              bullets.remove(i);        // If the bullet hits an asteroid, the bullet is deleted and no longer checked against asteroids
              hits++;
              shots++;
              score += 10;
              j = -1;
            }
          }
        }
      }
    }
    
    // Update and display powerups
    if (drops.size() > 0){
      for (int i = drops.size() - 1; i >=0; i--){
        if (drops.get(i).update()){
          drops.remove(i);
        } else {
          drops.get(i).display();
        }
      }
    }
    
    // Update and display player
    player.update();
    player.display();
    
    
    // Display stats
    textSize(15);
    text("Level: " + level, 100, 20);
    text("Score: " + score, 200, 20);
    text("High Score: " + hiScore, 350, 20);
    if (shots > 0){
      text("Accuracy: % " + hits / shots * 100, 550, 20);
    } else {
      text("No Shots Fired", 550, 20);
    }
    
    // Check if level is complete
    if (asteroids.size() == 0){
      level++;
      gameState = 2;
    }
    
    // Check if player dies
    for (int i = 0; i < asteroids.size(); i++){
      player.checkCollision(asteroids.get(i));
    }
    
  } else if (gameState == 4){
    if (score >= hiScore){
      textSize(40);
      hiScore = score;
      text("New High Score!", width/6, height/4);
    } else {
      textSize(30);
      text("High Score: " + hiScore, width/6, height/4);
    }
    textSize(30);
    text("Score: " + score, width/6, height/4 + 50);
    text("Level Reached: " + level, width/6, height/4 + 100);
    if (shots > 0){
      text("Accuracy: % " + hits / shots * 100, width/6, height/4 + 150);
      text("Shots Fired: " + (int)shots, width/6, height/4 + 200);
    } else {
      text("No Shots Fired", width/6, height/4 + 150);
    }
    textSize(15);
    text("Click to continue", width/6, height/4 + 240);
  }
}

void mouseClicked(){
  if (gameState == 0){
    gameState = 1;
  } else if (gameState == 1){
    asteroids = new ArrayList<Asteroid>();
    bullets = new ArrayList<Bullet>();
    drops = new ArrayList<PowerUp>();
    score = 0;
    hits = 0;
    shots = 0;
    level = 1;
    player.lives = 3;
    player.ammo = 1;
    gameState = 2;
  } else if (gameState == 4){
    gameState = 0;
  }
}

class Asteroid{
  
  int tier; // determines whether the asteroid is primary or secondary
  int drop;
  PVector velocity, position;
  
  Asteroid(int t, PVector v, PVector p){
    tier = t;
    velocity = v;
    position = p;
  }
  
  void update(){
    
    position.add(velocity);
    
    if (position.x > width){
      position.x = 0;
    } else if (position.x < 0){
      position.x = width;
    } else if (position.y > height){
      position.y = 0;
    } else if (position.y < 0){
      position.y = height;
    }
    
  }
  
  void display(){
    pushMatrix();
    translate(position.x, position. y);
      stroke(0);
      fill(255);
      if (tier == 1){
        ellipse(0, 0, 70, 70);
      } else {
        ellipse(0, 0, 35, 35);
      }
    popMatrix();
  }
  
  boolean destroy(PVector bulletSpot){
    if (tier == 1){
      tier = 2;
      asteroids.add(new Asteroid(2, velocity.copy().add(new PVector((position.x - bulletSpot.x) / 25, (position.y - bulletSpot.y) / 25).rotate(-PI / 4)), position.copy()));
      velocity.add(new PVector((position.x - bulletSpot.x) / 25, (position.y - bulletSpot.y) / 25).rotate(PI / 4));
      return false;
    } else{
      drop = (int)random(10);
      if (drop >= 1 && drop <= 5){
        drops.add(new PowerUp(drop, position.copy()));
      }
      return true;
    }
  }
}

class Bullet{
  PVector velocity, position;
  int type, life, lifespan;
  // 1-normal 2-double, 3-triple, 4-mine, 5-laser
  float dist;
  
  
  Bullet(int typ, PVector vel, PVector pos){
    velocity = vel;
    position = pos;
    type = typ;
    life = 0;
    if (type == 1){
      lifespan = 70;
    } else if (type == 2){
      lifespan = 50;
    } else if (type == 3){
      lifespan = 20;
    } else if (type == 4){
      lifespan = 600;
    } else if (type == 5){
      lifespan = 3;
    }
  }
  
  void update(){
    life++;
    position.add(velocity);
      if (position.x > width){
      position.x -= width;
    } else if (position.x < 0){
      position.x += width;
    } else if (position.y > height){
      position.y -= height;
    } else if (position.y < 0){
      position.y += height;
    }
  }
  
  void display(){
    pushMatrix();
    stroke(255);
      translate(position.x, position.y);
      if (type == 4){
        fill(0);
        ellipse(0, 0, 10, 10);
      }
      fill(255);
      if (type == 5){
        if (abs(player.position.x - position.x) < 400 && abs(player.position.y - position.y) < 400 ){
        line(0, 0, player.position.x - position.x, player.position.y - position.y);
        }
      } else {
        ellipse(0, 0, 2, 2);
      }
    popMatrix();
  }
  
  // returns true if bullet hits an asteroid, false if not
  boolean checkCollision(Asteroid ast){
    
    // find the distance to asteroid
    dist = sqrt(sq(ast.position.x - position.x)+sq(ast.position.y - position.y));
    
    // home in if bullet is a mine
    if (type == 4 && ((ast.tier == 1 && dist < 150) || (ast.tier == 2 && dist < 125))){
      velocity.add(new PVector((ast.position.x - position.x), (ast.position.y - position.y)).normalize());
    }
    
    // check for collision
    if ((ast.tier == 2 && dist < 25) || (ast.tier == 1 && dist < 50)){
      return true;
    } else {
      return false;
    }
  }
}

class PowerUp{
  int type;
  int life;
  PVector position;
  
  
  PowerUp(int t, PVector pos){
    type = t;
    position = pos;
  }
  
  // Returns true if drop should be deleted
  boolean update(){
    
    // Checks for collision and changes ammo if so
    if (sqrt(sq(player.position.x - position.x)+sq(player.position.y - position.y)) <= 20){
      for (int i = bullets.size() - 1; i >= 0; i--){
        bullets.remove(i);
      }
      player.ammo = type;
      score += 5;
      return true;
    }
    if (type == player.ammo){
      return true;
    }
    life++;
    if (life >= 400){
      return true;
    }
    return false;
  }
  void display(){
    pushMatrix();
      translate(position.x, position.y);
      fill(0);
      stroke(255);
      ellipse(0, 0, 16, 16);
      if (type == 4){
        ellipse(0, 0, 10, 10);
        fill(255);
        ellipse(0, 0, 2, 2);
      }
      fill(255);
      if (type == 1){
        ellipse(0, 0, 2, 2);
      }
      if (type == 2){
        ellipse(-3, 0, 2, 2);
        ellipse(3, 0, 2, 2);
      }
      if (type == 3){
        ellipse(-4, 2, 2, 2);
        ellipse(4, 2, 2, 2);
        ellipse(0, -4, 3, 2);
      }
      if (type == 5){
        line(-4, 0, 4, 0);
      }
    popMatrix();
  }
}

class Ship{
  
  PVector[] body = new PVector[4];
  PVector acceleration, velocity, position;
  float dist;
  int ammo; // determines ammo type
            // 1-single 2-double 3-triple 4-mine 5-laser
  int cooldown; // counts time between shots
  int lives;
  int invinc;
  
  Ship(){
    cooldown = 0;
    acceleration = new PVector(0, 0);
    velocity = new PVector(0, 0);
    position = new PVector(width / 2, height / 2);
    body = new PVector[4];
    body[0] = new PVector(10, 0);
    body[1] = new PVector(-10,-10);
    body[2] = new PVector(-5, 0);
    body[3] = new PVector(-10, 10);
  }
  
  void update(){
    
    // Determine acceleration
    if (keyPressed && key == 'w'){
      acceleration = new PVector(.2, 0);
      acceleration.rotate(atan2(mouseY - position.y, mouseX - position.x));
    } else if (keyPressed && key == 's'){
      acceleration = new PVector(.1, 0);
      acceleration.rotate(atan2(mouseY - position.y, mouseX - position.x) + PI);
    }
    velocity.add(acceleration);
    
    // Apply with drag and speed limit
    velocity.mult(.98);
    velocity.limit(15);
    position.add(velocity);
    
    // Wrap if position leaves screen
    if (position.x > width){
      position.x = 0;
    } else if (position.x < 0){
      position.x = width;
    } else if (position.y > height){
      position.y = 0;
    } else if (position.y < 0){
      position.y = height;
    }
    
    // reset acceleration
    acceleration.mult(0);
    
    // Increment cooldown
    if (cooldown > 0){
      cooldown--;
    }
    // Fire if able
    if (cooldown <= 0 && mousePressed && invinc <= 0){
      fire();
    }
    
    // Increment invincibility
    if (invinc > 0){
      invinc--;
    }
  }
  
  void display(){
    stroke(0);
    fill(255);
    if (invinc == 0 || (invinc >= 10 && invinc < 20) || (invinc >= 30 && invinc < 40) || (invinc >= 50 && invinc < 60) || (invinc >= 70 && invinc < 80)){
      pushMatrix();
        translate(position.x, position.y);
        rotate(atan2(mouseY - position.y, mouseX - position.x));
        beginShape();
        for(int i = 0; i <= body.length - 1; i++){
          PVector v = body[i];
          vertex(v.x, v.y);
        }
        endShape();
      popMatrix();
    }
    pushMatrix();
    translate(20, 20);
    rotate(-HALF_PI);
      for (int i = 0; i < lives; i++){
        beginShape();
        for(int j = 0; j <= body.length - 1; j++){
          PVector v = body[j];
          vertex(v.x, v.y);
        }
        endShape();
        translate(0, 20);
      }
    popMatrix();
  }
  
  void fire(){
    if (cooldown <= 0){
      
      // Single Shot
      if (ammo == 1 && bullets.size() <= 6){
        bullets.add(new Bullet(1, velocity.copy().add(new PVector(18, 0).rotate(atan2(mouseY - position.y, mouseX - position.x))), position.copy()));
        cooldown = 15;
      } 
      
      // Double Shot
      else if (ammo == 2 && bullets.size() <= 6){
        bullets.add(new Bullet(2, velocity.copy().add(new PVector(25, 0).rotate(atan2(mouseY - position.y, mouseX - position.x))), position.copy().add(new PVector(0, 4).rotate(atan2(mouseY - position.y, mouseX - position.x)))));
        bullets.add(new Bullet(2, velocity.copy().add(new PVector(25, 0).rotate(atan2(mouseY - position.y, mouseX - position.x))), position.copy().add(new PVector(0, -4).rotate(atan2(mouseY - position.y, mouseX - position.x)))));
        cooldown = 28;
      } 
      
      // Triple Shot
      else if (ammo == 3 && bullets.size() <= 6){
        bullets.add(new Bullet(3, velocity.copy().add(new PVector(15, 0).rotate(atan2(mouseY - position.y, mouseX - position.x) + PI / 5)), position.copy()));
        bullets.add(new Bullet(3, velocity.copy().add(new PVector(15, 0).rotate(atan2(mouseY - position.y, mouseX - position.x))), position.copy()));
        bullets.add(new Bullet(3, velocity.copy().add(new PVector(15, 0).rotate(atan2(mouseY - position.y, mouseX - position.x) - PI / 5)), position.copy()));
        cooldown = 15;
      } 
      
      // Mines
      else if (ammo == 4){
        if (bullets.size() > 6){
          bullets.remove(0);
        }
        bullets.add(new Bullet(4, velocity.copy(), position.copy()));
        cooldown = 50;
      } 
      
      // Laser
      else if (ammo == 5){     
        bullets.add(new Bullet(5, velocity.copy().add(new PVector(20, 0).rotate(atan2(mouseY - position.y, mouseX - position.x))), position.copy().add(new PVector(0, 0).rotate(atan2(mouseY - position.y, mouseX - position.x)))));
        bullets.add(new Bullet(5, velocity.copy().add(new PVector(20, 0).rotate(atan2(mouseY - position.y, mouseX - position.x))), position.copy().add(new PVector(60, 0).rotate(atan2(mouseY - position.y, mouseX - position.x)))));
        bullets.add(new Bullet(5, velocity.copy().add(new PVector(20, 0).rotate(atan2(mouseY - position.y, mouseX - position.x))), position.copy().add(new PVector(120, 0).rotate(atan2(mouseY - position.y, mouseX - position.x)))));
        bullets.add(new Bullet(5, velocity.copy().add(new PVector(20, 0).rotate(atan2(mouseY - position.y, mouseX - position.x))), position.copy().add(new PVector(180, 0).rotate(atan2(mouseY - position.y, mouseX - position.x)))));
        bullets.add(new Bullet(5, velocity.copy().add(new PVector(20, 0).rotate(atan2(mouseY - position.y, mouseX - position.x))), position.copy().add(new PVector(250, 0).rotate(atan2(mouseY - position.y, mouseX - position.x)))));
        bullets.add(new Bullet(5, velocity.copy().add(new PVector(20, 0).rotate(atan2(mouseY - position.y, mouseX - position.x))), position.copy().add(new PVector(310, 0).rotate(atan2(mouseY - position.y, mouseX - position.x)))));
       cooldown = 28;
      }
    }
  }
  
  // returns true if player loses last life
  void checkCollision(Asteroid ast){
    
    // checks for invincibility
    if (invinc == 0){
      
      // find the distance to asteroid
      dist = sqrt(sq(ast.position.x - position.x)+sq(ast.position.y - position.y));
      
      // check for collision
      if ((ast.tier == 2 && dist < 45) || (ast.tier == 1 && dist < 60)){
        // ends game if player loses last life
        if (lives == 0){
          gameState = 4;
        }
        lives--;
        cooldown = 0;
        invinc = 80;
        acceleration = new PVector(0, 0);
        velocity = new PVector(0, 0);
        position = new PVector(width / 2, height / 2);
      }
    }
  }
}
