
#define Ny 3
#define Nx 3

class {
  public:
    int GPIO_entrada = 0;
    int GPIO_saida = 5;// 3, 5, 6, 9, 10 and 11 esses possui pwm,The frequency of PWM signal on pins 5 and 6 will be about 980Hz and on other pins will be 490Hz

    int ts = 10;//tempo de amostragem em milissegundos
    double a[Ny] = {1.000000,-1.941765,0.941765}; // deve ser da forma a0 + a1 z^-1 + a2 z^-2
    double b[Nx] ={ 0.241604,-0.372311,0.131495}; // deve ser da forma b0 + b1 z^-1 + b2 z^-2
    double y[Ny] = {0}, x[Nx] = {0};
    double minIn = -20, maxIn = 20, minO = -10, maxO = 10;
    double target = 0;
    int bitsincronise = 0;
    void setup() {
      pinMode(GPIO_saida, OUTPUT);
      analogWrite(GPIO_saida, 0);
      for (int i = 0; i < Nx;   b[i]/= a[0], i++);
      for (int i = 1; i < Ny;  a[i]/=a[0], i++);
    }
    void run() {
      //aquisicao
     
      int aq ;
      memmove(x + 1, x, (Nx - 1)*sizeof(double));
      aq = analogRead(GPIO_entrada);
     
      x[0] = aq/1023.0*(maxIn-minIn) + minIn ;
      x[0] = target - x[0];
      // eq dif
      memmove(y + 1, y, (Ny - 1)*sizeof(double));
      double sum = 0;
      for (int i = 0; i < Nx;  sum += b[i] * x[i], i++);
      for (int i = 1; i < Ny; sum -= a[i] * y[i], i++);
      sum = sum > maxO ? maxO :sum < sum ? minO : sum;
      y[0] = sum ;
      // pwm saida
      int  saida = (int)floor((sum - minO) * 255.0/(maxO-minO));
      saida = saida>255?255:saida<0?0:saida;
      analogWrite(GPIO_saida, saida);
      Serial.write((unsigned char)floor(aq /1023.0* 255.0));
      Serial.write((unsigned char)floor((target+20)/40 * 255.0));
      Serial.write((unsigned char)saida);
      
    }
} Compensador;
void setup() {
  Serial.begin(115200);
  Compensador.setup();
}

void loop() {
  Compensador.run();
  delay(Compensador.ts);
}
void serialEvent() {
  unsigned char rx =  Serial.read();
  Compensador.target = rx / 255.0 * 20 - 10;

}
