class My_attack {
  int x, y, v, life;
  My_attack() {
    life = 0;
  }

  void init(int _x) {
    x = _x;
    y = my_top;
    v = -7;
    life = 1;
  }
  void draw_() {
    noStroke();
    image(attack_img,x,y);
    
  }

  void update() {
    y += v;
  }
}
