import cv2
import mediapipe as mp
import time
import math
import os 

#Initializations and definitions
mp_drawing = mp.solutions.drawing_utils
mp_pose = mp.solutions.pose
mp_holistic = mp.solutions.holistic

datos = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
last_datos = [0,0,0,0,0,0,0,0] #Se inicializa variable para calculo de velocidad
mediciones = ""
time_i = time.time()
last_time = 0
prevTime = 0
lclass = "NC"

#If you're not using an external webcam, change the 1 for a 0.
cap = cv2.VideoCapture(1, cv2.CAP_DSHOW)

def make_720p():
    cap.set(3, 1280)
    cap.set(4, 720)

make_720p()

def rescale_frame(frame, percent=75):
    width = int(frame.shape[1] * percent/ 100)
    height = int(frame.shape[0] * percent/ 100)
    dim = (width, height)
    return cv2.resize(frame, dim, interpolation =cv2.INTER_AREA)

with mp_pose.Pose(min_detection_confidence=0.8, min_tracking_confidence=0.5) as pose:
    while cap.isOpened():
        success, image = cap.read()

        # resize image
        image = rescale_frame(image, percent=150)
        if not success:
            print("Theres no person or ghost in the camera")
            continue

        # Convert the BGR image to RGB.
        image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)

        # To improve performance, optionally mark the image as not writeable to
        # pass by reference.
        image.flags.writeable = False
        results = pose.process(image)
        # Draw the pose annotation on the image.
        image.flags.writeable = True
        image = cv2.cvtColor(image, cv2.COLOR_RGB2BGR)
        mp_drawing.draw_landmarks(image, results.pose_landmarks, mp_pose.POSE_CONNECTIONS)

        if results.pose_landmarks is not None:
            datos = []
            for j in range(23, 33): 
                datos.append(results.pose_landmarks.landmark[j].x)
                datos.append(results.pose_landmarks.landmark[j].y)
            time_a = time.time() - time_i
            
            # Velocities calculated for the classification
            # t= heels, p=toes, i=left, d=right (Im sorry, but some variable names were in spanish)
            velti = pow(pow((datos[12]-last_datos[0])/(time_a-last_time),2)+pow((datos[13]-last_datos[1])/(time_a-last_time) ,2) ,0.5)
            veltd = pow(pow((datos[14]-last_datos[2])/(time_a-last_time),2)+pow((datos[15]-last_datos[3])/(time_a-last_time),2), 0.5)
            velpi = pow(pow((datos[16] - last_datos[4])/(time_a-last_time),2)+pow((datos[17]-last_datos[5])/(time_a-last_time),2), 0.5)
            velpd = pow(pow((datos[18] - last_datos[6])/(time_a-last_time),2)+pow((datos[19]-last_datos[7])/(time_a-last_time), 2), 0.5)
            last_datos = datos[12:20]
            last_time = time_a

            # Classification criteria
        
            lclass = ""
            if (datos[0]<0.2) or (datos[0]>0.8):
                lclass = "NC"
                print(4)
            else: 
                if (veltd>0.1) and (velpd>0.15) and (velpi<0.1) and (velti<0.2):
                    lclass = lclass + "RSW"
                    print(0)
                else:
                    lclass = lclass + "RST"
                    print(1)
                    
                # LEFT
                if (velti>0.1) and (velpi>0.15) and (veltd<0.1) and (velpd<0.15):
                    lclass = lclass + "LSW"
                    print(2)
                else:
                    lclass = lclass + "LST"
                    print(3)
            
            # Se agrega medicion al string junto con la hora
            mediciones = mediciones + "{0},{1}\n".format(time_a,lclass)
            
        # Creation of the window
        cv2.imshow('Im a window', image)
        if cv2.waitKey(5) & 0xFF == 27:
            break
cap.release()
cv2.destroyAllWindows()

#Timestamp for the filename
timestr = time.strftime("%Y-%m-%d_%H-%M-%S")
#Saving the data in the textfile
with open("Etiquetas_"+timestr+".txt", "w") as file:
  file.write(mediciones)
  file.close()
  print("Archivo Guardado")
