class Enemy_attack{
  int v, x, y, life,dead_cnt;
  int[] attack = new int[attack_num];
  int[] attack_v = new int[attack_num];
  
  Enemy_attack(){
    life = 0;
    v = 0;
  }
  
  void init(int _x,int _y) {
    x = _x;
    y = _y;
    v = (int)random(8)+4;
    life = 1;
    dead_cnt = 0;
  }

  void draw_() {
    if(life == 1){
      int _left = my_pos_x - my_size_x/2;
      int _right = my_pos_x + my_size_x/2;
      image(enemy_attack_img, x, y);
      if (x > _left && x < _right && y > my_top && y < my_bottom && fin == 0) {// judge between enemy_attack and my_plane
        dead.rewind();
        dead.play();
        fin = 1;
      }
    }
    else if(life == 2){
      image(enemy_attack_dead, x, y);
      dead_cnt++;
      if(dead_cnt >= 20) life = 0;
    }
  }

  void update() {
    y += v;
  }
}
