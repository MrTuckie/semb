# Código em python para ilustrar uma das lógicas do filtro

# ====================
# Segue o COLAB pois lá está mais atualizado
# https://colab.research.google.com/drive/1cTAUvuG8Ol5Q3slofeF3nyhACgAepuUk#scrollTo=ZTo9KyKAX7Fc&uniqifier=2
# ====================




# Supondo que o sinal x é do tipo 'lista' contendo em cada célula, número em decimal
# ex: x = [-123,-120,-110,-90,-80,0,10,126,...,42]
# y é o sinal de saída da convolução y[n]=h[k]*convol*x[n-k]
# y[n] = h[0]*x[n-0] + h[1]*x[n-1] + h[2]*x[n-2] + h[3]*x[n-3] +
#        h[4]*x[n-4] + h[5]*x[n-5] + h[6]*x[n-6] + h[7]*x[n-7] + 
#        h[8]*x[n-8]      
# Logo: y[0] = h[0]*x[0], y[1] = h[0]*x[1] + h[1]*x[0] e assim vai
#
# sendo h = [-1, -5, 1, 30, 49, 30, 1, -5, -1] (No caso do FIR 1 - Passa baixa)

# os valores dentro de x vão de -128 a +127 (8 bits)
x = [-123,-120,-110,-90,-80,0,10,126,42,-120,-110,-90,-80,0,10,126,42,-120,-110,-90,-80,0,10,126,42]
# estou partindo o pressuposto que o x[0] é o primeiro sinal

h = [-1, -5, 1, 30, 49, 30, 1, -5, -1] # note que ele é simétrico, então tanto faz a ordem que vc vai.
y = []
k = 0
y_aux = 0
n = 0

x_arquivo = []
x_aux = ''

with open("/home/arthur/GitHub/ufes/Sistemas-Embarcados-1/2021/TC/sinaltc.txt","r") as arquivo:
    sinal = arquivo.read()
    sinal_split = sinal.split(" ") # separando atraveś de ' '


# convertendo e colocando em um vetor
for valor_sinal in sinal_split:
    x_arquivo.append(float(valor_sinal))
#print(x_arquivo)


while(n!=len(x_arquivo)):
    y_aux=0
    while(n-k>=0 and k<=8):
        #print(k)
        y_aux += h[k]*x_arquivo[n-k]
        k+=1
    k=0
    n+=1
    #print(f"n={n}")
    y.append(y_aux)

print(y)