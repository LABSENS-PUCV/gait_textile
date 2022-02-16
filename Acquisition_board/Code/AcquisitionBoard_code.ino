#include "MPU9250.h"
#include <Adafruit_BMP280.h>
#include <Wire.h>

Adafruit_BMP280 bmp; // I2C
MPU9250 IMU(Wire,0x68);
int status;
float alturaB, alturaDIF;
const int num_sensores=10;
double Rref= 2200.00;                  //Resistencia del divisor de tension
unsigned long tiempus;          // Variable para almacena el tiempo de ejecucion
int S0 = PB0;
int S1 = PA7;
int S2 = PA6;
int S3 = PA5;
int muxADC = PA3;
double textiles[num_sensores] = {0.00};
double val;
double res;                        //Resistencia del sensor
double vout;                       //Voltaje del ADC
String buff = "";                  // Buffer trama

// Muestreo
volatile unsigned mactual = 0;
volatile unsigned manterior = 0;
volatile unsigned mdelta = 0;
int ts = 10;                    //tiempo de muestreo

void muestreo_mux() {
  for (int j = 0; j < num_sensores; j++){
    digitalWrite(S0, HIGH && (j & B00000001));
    digitalWrite(S1, HIGH && (j & B00000010));
    digitalWrite(S2, HIGH && (j & B00000100));
    digitalWrite(S3, HIGH && (j & B00001000));
    val = analogRead(muxADC);
    if (val<20.00){
      textiles[j]=0.00;
    }
    else{
      vout = val* 3.30;     //Formula para convertir la salida del ADC en voltaje
      vout = vout/4096;     //Formula para convertir la salida del ADC en voltaje
      textiles[j]  = Rref*((3.30/vout) -1.00);      //Calculo de la resistencia a partir del voltaje medido 
    }
  }
}

void setup() {
  
  Serial3.begin(230400);
  
  pinMode(S0, OUTPUT);
  pinMode(S1, OUTPUT);
  pinMode(S2, OUTPUT);
  pinMode(S3, OUTPUT);
  pinMode(muxADC, INPUT);
  
  if (!bmp.begin()) {
    Serial3.println(("No se encontro na el bmp"));
    while (1) delay(10);
  }

  bmp.setSampling(Adafruit_BMP280::MODE_NORMAL,     // Modo de operacion 
                  Adafruit_BMP280::SAMPLING_X2,     // Oversampling temperatura
                  Adafruit_BMP280::SAMPLING_X16,    // Oversampling presion 
                  Adafruit_BMP280::FILTER_X16,      // Filtrado.
                  Adafruit_BMP280::STANDBY_MS_63);  // Tiempo stand by. 
                  
  status = IMU.begin();
  if (status < 0) {
    Serial3.println("IMU initialization unsuccessful");
    Serial3.println("Check IMU wiring or try cycling power");
    Serial3.print("Status: ");
    Serial3.println(status);
    while(1) {}
  }
  bmp.setSampling(Adafruit_BMP280::MODE_NORMAL,     /* Operating Mode. */
                  Adafruit_BMP280::SAMPLING_X2,     /* Temp. oversampling */
                  Adafruit_BMP280::SAMPLING_X16,    /* Pressure oversampling */
                  Adafruit_BMP280::FILTER_X16,      /* Filtering. */
                  Adafruit_BMP280::STANDBY_MS_63); /* Standby time. */

  alturaB=0;
  for (int i=0;i<100;i++){
    alturaB += bmp.readAltitude(1013.25);
    delay(10);
  }
  alturaB = alturaB/100;

}

void loop() {
  mactual = millis();
  mdelta = (double) mactual - manterior;
  if (mdelta >= ts){
      IMU.readSensor();
      alturaDIF = - alturaB + bmp.readAltitude(1013.25);
      buff = buff + String(mactual, HEX)+",";
      buff = buff + String(IMU.getAccelX_mss(),2)+ "," + String(IMU.getAccelY_mss(),2)+ "," + String(IMU.getAccelZ_mss(),2)+ ",";
      buff = buff + String(IMU.getGyroX_rads(),2)+ "," + String(IMU.getGyroY_rads(),2)+ "," + String(IMU.getGyroZ_rads(),2)+ ",";
      buff = buff + String(IMU.getMagX_uT(),2)+ "," + String(IMU.getMagY_uT(),2)+ "," + String(IMU.getMagZ_uT(),2)+ ",";
      buff = buff + String(alturaDIF)+ ","; //Altitud respecto al nivel del mar en metros, averiguar bien la presion a esta altura 
      muestreo_mux();
      for(int i = 0; i < num_sensores; i ++) {
        if(i == 9) {
          buff = buff + String(int(textiles[i]))+ "!" ;
          Serial3.println(buff);
         } 
         else {
           buff = buff + String(int(textiles[i]))+ "," ;
         }
      }
      buff = "";
      manterior = mactual;
  }
}
