import processing.serial.*;
import ddf.minim.*;
PFont font;
Serial port;
int num, attack_num, cnt, create, enemy_x, enemy_y, attack_x, attack_y, start, score; //enemy_x&y means their size
float img_cnt;
int my_size_x, my_size_y, my_pos_x, my_pos_y;
int my_top, my_bottom;
int fin = 0;  //0: not fin, 1: player was dead , 2: time over, 3:clear
PImage plane, left_plane, right_plane, bg, enemy_img, enemy_dead, enemy_attack_dead, enemy_attack_img, attack_img, clear;
int space = 0;  //this is "attack controler"; 0: prepare, 1: launch, 2:suspend
float keyleft, keyright;
boolean first = true;
Enemy[] enemy;
Enemy_attack[] enemy_attack;
My_attack[] my_attack;
Minim minim;
AudioPlayer main, hit, dead,clear_sound;

void setup() {
  frameRate(60);
  font = loadFont("FAMania-48.vlw");
  textFont(font,16);
  //setup of port
  // List all the available serial ports:
  println(Serial.list());
  port = new Serial(this, Serial.list()[0], 9600);
  port.clear();
  //「10」(ラインフィード)が来る度にserialEvent()作動
  port.bufferUntil(10); 
  //合図用データ送信して通信開始m
  port.write(65);
  
  //setup of sound
  minim = new Minim(this);
  main = minim.loadFile("main.mp3");
  hit = minim.loadFile("hit.mp3");
  dead = minim.loadFile("dead.mp3");
  clear_sound = minim.loadFile("clear.mp3");
  main.loop();

  plane = loadImage("plane.png");
  left_plane = loadImage("left_plane.png");
  right_plane = loadImage("right_plane.png");
  bg = loadImage("back.jpg");
  enemy_dead = loadImage("enemy_dead.png");
  enemy_attack_dead = loadImage("dead.png");
  enemy_img = loadImage("enemy.png");
  enemy_attack_img = loadImage("enemy_attack.png");
  attack_img = loadImage("attack.png");
  clear = loadImage("clear.png");
  size(640, 480);
  score = 0;
  enemy_x = 50;
  enemy_y = 50;
  attack_x = 30;
  attack_y = 30;
  my_size_x = 50;
  my_size_y = 50;
  my_pos_x = width/2;
  my_pos_y = 420;
  my_top = my_pos_y - my_size_y;
  my_bottom = my_pos_y + my_size_y;
  num = 30;
  attack_num = 3;  //The number of attacks per a enemy.
  cnt = 0;
  img_cnt = -height/2;
  rectMode(CENTER_DIAMETER);
  ellipseMode(CENTER_DIAMETER);
  imageMode(CENTER_DIAMETER);
  textAlign(CENTER);
  enemy = new Enemy[num];
  my_attack = new My_attack[attack_num];
  enemy_attack = new Enemy_attack[num * attack_num];
  for(int i=0;i<attack_num;i++){
     my_attack[i] = new My_attack();
  }
  for (int i=0;i<num;i++) {
    enemy[i] = new Enemy(i);
  }
  for (int i=0;i<attack_num * num;i++) {
    enemy_attack[i] = new Enemy_attack();
  }
}

void draw() {
  //background image
  image(bg, width/2, img_cnt);
  image(bg, width/2, img_cnt+height);
  img_cnt += 0.5;
  if (img_cnt >= height/2) img_cnt = -height/2;
  create = 0;
  for (int i=0;i<num;i++) {  //update of enemy & enemy_attack
    if (cnt >= 40 && create == 0 && enemy[i].life == 0) {  //cnt >= 40 means a span of creating enemy.
      cnt = 0;
      enemy[i].init();
      create = 1;
    }
    else if (enemy[i].life != 0) {
      fill(255, 0, 0);
      enemy[i].draw_();
      if (enemy[i].life == 1) enemy[i].update();
      if (enemy[i].y > 480) enemy[i].life = 0;
    }
    for (int j = i * attack_num;j < i * attack_num + 3;j++) {
      if (enemy_attack[j].life != 0) {
        fill(255, 0, 0);
        enemy_attack[j].draw_();
        if (enemy_attack[j].life == 1) enemy_attack[j].update();
        if (enemy_attack[j].y > height) enemy_attack[j].life = 0;
      }
    }
  }
  
  for(int i = 0; i < attack_num; i++){//update of my attack
    if (my_attack[i].life == 1) {
      fill(255);
      my_attack[i].draw_();
      my_attack[i].update();

      int _left, _right;
      for (int j=0;j<num;j++) {
        if (enemy[j].life == 1) {
          _left = enemy[j].x - enemy_x;
          _right = enemy[j].x + enemy_x;
          if ( my_attack[i].x > _left && my_attack[i].x < _right && my_attack[i].y < enemy[j].y + enemy_y/2 && enemy[j].y < my_pos_y) { //judge between enemy and my_attack
            score++;
            if(score == 30) fin = 3;//clear
            hit.rewind();
            hit.play();
            my_attack[i].life = 0;
            enemy[j].life = 2;
          }
        }
        for (int k = 0; k < 3; k++) { //judge between enemy_attack and my_attack
          _left = enemy_attack[j+k].x - attack_x;
          _right = enemy_attack[j+k].x + attack_x;
          if (enemy_attack[j+k].life == 1 && my_attack[i].x > _left && my_attack[i].x < _right && my_attack[i].y < enemy_attack[j+k].y) {
            my_attack[i].life = 0;
            enemy_attack[j+k].life = 2;
          }
        }
      }
      if (my_attack[i].y < 0) my_attack[i].life = 0;
    }
  }
  
  if (space == 1 && fin == 0) {//my_attack
    space = 2;
    for (int i=0;i<attack_num;i++) {
      if (my_attack[i].life == 0) {
        my_attack[i].init(my_pos_x);
        break;
      }
    }
  }
  if (keyleft != 0 && my_pos_x > my_size_x/2) {
    my_pos_x -= 3 * keyleft;
  }
  else if (keyright != 0 && my_pos_x < width - my_size_x/2) {
    my_pos_x += 3 * keyright;
  }
  fill(255);
  cnt++;
  if (fin != 0) {// if dead
    fill(0, 0, 0, 170);
    rect(width/2, height/2, width, height);
    fill(255);
    if(fin == 1) text("Game Over!\nClick Enter to Continue", width/2, height/2);
    else if(fin == 2) text("Time Up!\nClick Enter to Continue", width/2, height/2);
    else if(fin == 3){
      main.pause();
      clear_sound.play();
      textSize(30);
      text("Clear!\nCongratulations!",width/2,height/6);
      image(clear,width/2,(height/5)*3);
      textSize(16);
    }
    if(keyPressed){
        if(key == '\n' && fin != 3){
          //reset-----------------------------
            score = 0;
            for(int i=0;i<attack_num;i++){
               my_attack[i] = new My_attack();
            }
            for (int i=0;i<num;i++) {
              enemy[i] = new Enemy(i);
            }
            for (int i=0;i<attack_num * num;i++) {
              enemy_attack[i] = new Enemy_attack();
            }
            my_pos_x = width/2;
            first = true;
            fin = 0;
         //-----------------------------------
        }
    }
  }
  else {// if live
    if(first){
      start = millis();
      first = false;
    }
    int m = millis() - start;
    int time = 60 - m/1000;  //60 is limit tim
    if(time <= 0){
        dead.rewind();
        dead.play();
        fin = 2;
    }
    fill(255);
    text("time:"+time, 60, 30);
    text("score:"+score,60,50);
    if(keyleft != 0) image(left_plane, my_pos_x, my_pos_y);
    else if(keyright != 0) image(right_plane,my_pos_x,my_pos_y);
    else image(plane, my_pos_x, my_pos_y);
  }
}

void stop() {
  main.close();
  hit.close();
  dead.close();
  minim.stop();
  super.stop();
}

//シリアル通信
void serialEvent(Serial p) {
  //文字列用変数を用意し、
  //「10」(ラインフィード）が来るまで読み込む
  String stringData=port.readStringUntil(10);

  //改行記号を取り除く
  stringData=trim(stringData);
  //コンマで区切ってデータを分解、整数化
  int data[]=int(split(stringData, ','));

  if (data[0] < 320) {//left tilt
    keyleft = (340 - (float)data[0]) / 50;
    if(keyleft > 3.0) keyleft = 3.0; //limit
    keyright = 0;
  }
  else if(data[0] > 360){
    keyright = ((float)data[0] - 340) / 50;
    if(keyright > 3.0) keyright = 3.0; //limit
    keyleft = 0;
  }
  else{
      keyleft = 0;
      keyright = 0;
  }

  if (data[1] == 1 && space == 0) {
    space = 1;
  }
  else if (data[1] == 0) {
    space = 0;
  }
  //合図用データを送信
  port.write(65);
}
