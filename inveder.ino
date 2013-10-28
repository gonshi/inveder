int x;
int bottun;

void setup() {
     Serial.begin(9600);
     pinMode(7,INPUT) ;    //スイッチに接続ピンをデジタル入力に設定
     pinMode(13,OUTPUT) ;  //ＬＥＤに接続ピンをデジタル出力に設定
}
void loop() {
     x=analogRead(0);
     if (digitalRead(7) == HIGH) {     //スイッチの状態を調べる
          bottun = 1;
     } else {
          bottun = 0;
     }
      //delay(100);
      if(Serial.available()>0){
        //Xの値を出力
        Serial.print(x,DEC);
        Serial.print(",");
        //ボタンの状態を出力
        Serial.println(bottun,DEC);
        //合図用データを読み込みバッファを空に
        Serial.read();
      }
}
