int starfield = 2000, max_mass = 1000;
int universe_bounded = 0;
int colcount = 0;
int min_distance = -1;
int big_mass = 0;
int flagged_star = -1;
float universe_center_x = 0, universe_center_y = 0;
float old_universe_center_x, old_universe_center_y;
float radius = 1000, master_scale = .03;
float speed = .001;
float drag = .90;
float atmosphere = 0.8;
boolean ball = false;
PFont font;

star_class[] star_array = new star_class[starfield];
window_class window = new window_class(640, 480);

 
 void setup() {
   font = loadFont("Serif-12.vlw");
   textFont(font, 12);
   window.rescale(master_scale);
   frameRate(320);
   size(640, 480);
   background(0);
   for(int i=0;i<starfield;i++) {
     float position = (i / float(starfield)) * 2 * PI; 
     star_array[i] = new star_class(radius, position, speed, i);
   }   
 }
 
void fade(int opacity) {
     stroke(0);
     fill(0,opacity);
     rectMode(CORNER);       
     rect(0,0,width,height);
} 
 
 void draw() {
     if (window.locked) {
        window.realign(star_array[flagged_star].pos_x, star_array[flagged_star].pos_y);
     }
     fade(70);
     for(int i=0;i<starfield;i++) {
       if (!star_array[i].dead) {
         star_array[i].render();
         for(int j=0;j<starfield;j++) {
           if (i != j) {
             if (!star_array[j].dead) star_array[i].attraction(star_array[j]);
           }
         }
         star_array[i].compute_position(drag);
         if (star_array[i].mass > star_array[big_mass].mass) big_mass = i;
         if (star_array[i].flagged) {
           String display_text;
           if (window.locked) {
             display_text = "Flagged Star ID #" + str(i) + " Mass " + str(int(star_array[i].mass)) + " [LOCKED]";
           } else {
             display_text = "Flagged Star ID #" + str(i) + " Mass " + str(int(star_array[i].mass));
           }
           stroke(255, 255, 0);
           fill(255, 255, 0);
           text(display_text, 10, 20);
         }
       }
    }
    window.center_o_x = window.center_x;
    window.center_o_y = window.center_y;
    
 } 

 class window_class {
   int real_height, real_width;
   float scaled_height, scaled_width, center_x, center_y, center_o_x, center_o_y;
   boolean locked = false;
   window_class(int w, int h) {
     real_height = h;
     real_width = w;
     center_x = 0;
     center_y = 0;
     scaled_width = real_width;
     scaled_height = real_height;
   }
   void realign(float new_center_x, float new_center_y) {
     center_o_x = center_x;
     center_o_y = center_y;
     center_x = new_center_x;
     center_y = new_center_y;
   }
   void rescale(float ratio) {
     scaled_width = scaled_width * ratio;
     scaled_height = scaled_height * ratio;
     window.clear();
   }
   float[] xlate(float x, float y) {
     float[] coords = new float[2];
     coords[0] = (real_width/scaled_width) * (x - real_width/2) + center_x;
     coords[1] = (real_height/scaled_height) * (y - real_height/2) + center_y;
     return coords;
   }
   void renderStar(float x, float y, float o_x, float o_y, float w) {
     float display_x = scaled_width / real_width * (x - center_x) + real_width/2;
     float display_y = scaled_height / real_height * (y - center_y) + real_height/2;
     float display_o_x = scaled_width / real_width * (o_x - center_o_x) + real_width/2;
     float display_o_y = scaled_height / real_height * (o_y - center_o_y) + real_height/2;
     ellipse(display_x, display_y, w * scaled_height / real_height, w * scaled_height / real_height);
     line(display_x, display_y, display_o_x, display_o_y);    
   }
   void setLock() {
     this.locked = !this.locked;
     if (flagged_star == -1) flagged_star = 0;
   }
   void moveUp() {
     window.realign(center_x, center_y - 25*real_height/scaled_height);
   }
   void moveDown() {
     window.realign(center_x, center_y + 25*real_height/scaled_height);
   }
   void moveLeft() {
     window.realign(center_x - 25*real_width/scaled_width, center_y);
   }
   void moveRight() {
     window.realign(center_x + 25*real_width/scaled_width, center_y);
   }
   void clear() {
     fade(100);
   }
 }
 
 int sign(float number) {
   if (number >= 0) return 1;
   return -1;
 }
 
 class star_class {
   float pos_x, pos_y, mass, old_pos_x, old_pos_y, d_x, d_y, speed, velocity;
   int c = 255, id;
   boolean dead = false, stationary, flagged = false;
   
   star_class(float radius, float position, float speed, int i) {
     id = i;
      mass = max_mass * pow(random(2, max_mass),3)/pow(max_mass, 3);
     if (ball) {
       pos_x = -radius*sin(position);
       pos_y = radius*cos(position);
       d_x = cos(position) * speed;
       d_y = sin(position) * speed;
     } else {
       int nexis = floor(random(0, 3));
       float base_x = 0;
       float base_y = 0;
       if (nexis == 0) {
         base_x = -radius;
         base_y = -radius;
       } else if (nexis == 1) {
         base_x = radius;
         base_y = radius; 
       } else {
         base_x = 0;
         base_y = sqrt(2) * radius;
       }            
       pos_x = random(-radius, radius) * -sin(position) + base_x;
       pos_y = random(-radius, radius) * cos(position) + base_y;
       d_x = sqrt(pow(pos_x, 2) + pow(pos_y, 2)) * cos(position) * speed;
       d_y = sqrt(pow(pos_x, 2) + pow(pos_y, 2)) * sin(position) * speed;
     }
     old_pos_x = pos_x;
     old_pos_y = pos_y;
   }
   void flag() {
     for(int i=0;i<starfield;i++) {
       if (i != this.id) {
         star_array[i].flagged = false;
       } else {
         this.flagged = true;
         flagged_star = i;
       }
     }
   }
   void render() {
     if (!this.dead) {
       float clr = this.mass * this.velocity;
       if (clr > 255) clr = 255;
       if (!this.flagged) {
         stroke(clr, 255-clr, 255-clr);   
       } else {
         stroke(255, 255, 0);   
       }
       fill(clr, 255-clr, 255-clr);   
       window.renderStar(pos_x, pos_y, old_pos_x, old_pos_y, 2*this.mass/max_mass);
       old_pos_x = pos_x;
       old_pos_y = pos_y;
     }

   }
   float vel() {
     return sqrt(pow(d_x, 2) + pow(d_y, 2));
   }
   float distance_from_point(float x, float y) {
     return sqrt(pow(this.pos_x - x, 2) + pow(this.pos_y - y, 2));
   }
   void attraction(star_class other_star) {
     float distance_squared = (pow(this.pos_x - other_star.pos_x, 2) + pow(this.pos_y - other_star.pos_y, 2));
     if (sqrt(distance_squared) < this.mass/max_mass + other_star.mass/max_mass + atmosphere) {
       this.collide(other_star);
     } else {
       float force_x = ((this.pos_x - other_star.pos_x) * other_star.mass) / (this.mass * distance_squared);
       float force_y = ((this.pos_y - other_star.pos_y) * other_star.mass) / (this.mass * distance_squared);
       d_x -= force_x;
       d_y -= force_y;
       this.velocity = this.vel();
     }
   }
   void compute_position(float drag) {
     if (!this.dead) {
       old_pos_x = pos_x;
       old_pos_y = pos_y;
       pos_x += d_x;
       pos_y += d_y;

       if (universe_bounded == 1) {
         if (pos_x > width) {
           pos_x = pos_x - width;
           old_pos_x = pos_x;
         }
         if (pos_x < 0) {
           pos_x = pos_x + width;
           old_pos_x = pos_x;
         }
         if (pos_y > height) {
           pos_y = pos_y - height;
           old_pos_y = pos_y;
         }
         if (pos_y < 0) {
           pos_y = pos_y + height;
           old_pos_y = pos_y;
         }
       }
       if (universe_bounded == 2) {       
         if (pos_x > width) d_x = -d_x * drag;
         if (pos_x < 0) d_x = -d_x * drag;
         if (pos_y > height) d_y = -d_y * drag;
         if (pos_y < 0) d_y = -d_y * drag;
       }
      
     }
   }
   void collide(star_class remote_star) {
     if (remote_star.mass > this.mass) {
       remote_star.mass += this.mass;
       remote_star.d_x = remote_star.d_x + (this.mass / remote_star.mass * this.d_x);
       remote_star.d_y = remote_star.d_y + (this.mass / remote_star.mass * this.d_y);
       if (this.flagged) remote_star.flag();
       this.clear();
     } else {
       this.mass += remote_star.mass;
       this.d_x = this.d_x + (remote_star.mass / this.mass * remote_star.d_x);
       this.d_y = this.d_y + (remote_star.mass / this.mass * remote_star.d_y);
       if (remote_star.flagged) this.flag();
       remote_star.clear();
     }
     colcount++;
   }
   void clear() {
     this.dead = true;
     this.pos_x = -1000000000 + random(-1000, 1000);
     this.pos_y = -1000000000 + random(-1000, 1000);
   }
 }
 
 void keyPressed() {
   if (key == CODED) {
    if (keyCode == 38) {
      window.moveUp();
    }
    if (keyCode == 40) {
      window.moveDown();
    }
    if (keyCode == 37) {
      window.moveLeft();
    }
    if (keyCode == 39) {
      window.moveRight();
    }
   } else {
     if ((key == 45) || (keyCode == 45)) window.rescale(.6);
     if ((key == 61) || (keyCode == 61)) window.rescale(1.4);
     if (key == 99) {
       window.realign(star_array[big_mass].pos_x, star_array[big_mass].pos_y);
     }
     if (keyCode == 77) {
       println(star_array[big_mass].mass + " " + colcount);
       star_array[big_mass].flag();
     }
     if (keyCode == 76) {
       if (flagged_star == -1) {
         star_array[big_mass].flag();
       }
       window.setLock();
     }
   }
}

void mousePressed() {
  int x = mouseX;
  int y = mouseY;
  min_distance = 0;
  float[] coords = window.xlate(x, y);
  
  for(int i=0;i<starfield;i++) {
    if (star_array[i].distance_from_point(coords[0], coords[1]) < star_array[min_distance].distance_from_point(coords[0], coords[1])) min_distance = i;
  }
  println(min_distance + " " + star_array[min_distance].mass + " " + star_array[min_distance].vel());
  star_array[min_distance].flag();
} 

 

