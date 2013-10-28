class Enemy {
  int x, y, v, life,enemy_num,dead_cnt;
  //life; 0:not live, 1: live, 2: dead
  Enemy(int _i) {
    x = 0;
    y = 0;
    life = 0;
    enemy_num = _i;
  }

  void init() {
    x = (int)random(8)*80 + 30;
    y = 0;
    v = (int)random(3)+1;
    life = 1;
    dead_cnt = 0;
  }

  void draw_() {
    if(life == 1){
      int _left = my_pos_x - my_size_x/2;
      int _right = my_pos_x + my_size_x/2;
      image(enemy_img, x, y);
      if (x > _left && x < _right && y > my_top && y < my_bottom && fin == 0) {//judge between enemy and my_place
        dead.rewind();
        dead.play();
        fin = 1;
      }
    }
    else if(life == 2){
      image(enemy_dead, x, y);
      dead_cnt++;
      if(dead_cnt >= 40) life = 0;
    }
  }

  void update() {
    y += v;
    for (int i = enemy_num * attack_num;i < enemy_num * attack_num + 3;i++) {
      if (enemy_attack[i].life == 0 && random(500)<5) {//create new attack
        enemy_attack[i].init(x,y + enemy_y/2);
      }
    }
  }
}
