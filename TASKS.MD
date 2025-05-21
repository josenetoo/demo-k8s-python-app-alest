TASKS: Deploying Hello-World Application to Kubernetes
Este documento fornece instruções passo a passo para conteinerizar uma aplicação "hello-world" usando Docker (se necessário) e implantá-la em um cluster Kubernetes, tornando-a acessível externamente na porta 8080.

Pré-requisitos 📋
Docker Instalado: Certifique-se de que o Docker Desktop ou Docker Engine esteja instalado e em execução.

Verificar:

docker --version

Instalação: Obter Docker

kubectl Instalado: A ferramenta de linha de comando do Kubernetes.

Verificar:

kubectl version --client

Instalação: Instalar kubectl

Acesso a um Cluster Kubernetes: kubectl deve estar configurado para se comunicar com seu cluster.

Verificar:

kubectl cluster-info

ou

kubectl get nodes

Pode ser Minikube, kind, Kubernetes do Docker Desktop ou um serviço Kubernetes de provedor de nuvem (GKE, EKS, AKS).

Conta em um Registro de Contêiner (Opcional, mas Recomendado):

Uma conta no Docker Hub se você planeja construir e enviar uma imagem personalizada. Para usar uma imagem pública pré-construída como nginxdemos/hello, isso não é estritamente necessário para puxar a imagem, mas é uma boa prática para futuras aplicações personalizadas.

Se estiver usando um registro privado, certifique-se de que seu cluster Kubernetes esteja configurado com segredos de pull de imagem (image pull secrets).

Editor de Texto: Para criar e editar o Dockerfile (se necessário) e os arquivos de manifesto YAML do Kubernetes.

Passo 1: Preparar a Aplicação (Usando uma Imagem Pré-construída)
Para simplificar e focar nos aspectos do Docker e Kubernetes, usaremos uma imagem "hello-world" pré-construída do Nginx: nginxdemos/hello. Esta imagem serve uma página HTML simples na porta 80 dentro do contêiner.

Se você fosse usar uma aplicação personalizada (ex.: uma aplicação Python Flask):

Crie o código da sua aplicação (ex.: app.py).

Crie um requirements.txt (para Python).

Prossiga para o Passo 2 para criar um Dockerfile.

Passo 2: Conteinerizar a Aplicação (Ignorado se estiver usando nginxdemos/hello)
Este passo só é necessário se você estiver construindo uma aplicação personalizada. Como estamos usando nginxdemos/hello, esta imagem já está construída e disponível no Docker Hub.

Se você estivesse construindo uma imagem personalizada (ex.: de uma aplicação Python ouvindo na porta 5000):

2.1. Criar Dockerfile
No diretório raiz da sua aplicação, crie um arquivo chamado Dockerfile.

# Exemplo para uma aplicação Python Flask
FROM python:3.9-slim

WORKDIR /app
COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt
COPY . .

EXPOSE 5000
CMD ["python", "app.py"]

2.2. Construir a Imagem Docker
Navegue até o diretório que contém seu Dockerfile.

docker build -t seu-usuario-dockerhub/meu-app-hello:v1 .

(Substitua seu-usuario-dockerhub e meu-app-hello:v1 apropriadamente.)

2.3. Testar Localmente (Opcional, mas Recomendado)

docker run -p 5000:5000 seu-usuario-dockerhub/meu-app-hello:v1

Acesse http://localhost:5000.

2.4. Enviar para o Registro de Contêiner

docker login # Autentique-se com o Docker Hub ou seu registro escolhido
docker push seu-usuario-dockerhub/meu-app-hello:v1

Passo 3: Criar Manifesto de Deployment do Kubernetes 📜
Um Deployment do Kubernetes gerencia aplicações stateless, garantindo que um número especificado de réplicas (Pods) esteja em execução.

Crie um arquivo chamado hello-deployment.yaml:

apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-world-deployment      # Nome único para o Deployment
  labels:
    app: hello-world               # Rótulo para identificar recursos relacionados a esta app
spec:
  replicas: 2                      # Número desejado de instâncias da aplicação (Pods)
  selector:
    matchLabels:
      app: hello-world             # Seletor para encontrar Pods gerenciados por este Deployment
                                   # Deve corresponder aos rótulos no template do Pod
  template:                        # Template do Pod: define os Pods a serem criados
    metadata:
      labels:
        app: hello-world           # Rótulos aplicados a cada Pod
    spec:
      containers:
      - name: hello-world-container
        image: nginxdemos/hello:latest # A imagem Docker a ser usada.
                                       # Substitua pela sua imagem personalizada se você construiu uma
                                       # ex.: seu-usuario-dockerhub/meu-app-hello:v1
        ports:
        - containerPort: 80        # Porta em que a aplicação *dentro do contêiner* escuta.
                                   # Para nginxdemos/hello, é 80.
                                   # Para uma app Python personalizada na porta 5000, seria 5000.
        resources:                   # Opcional: Define requisições e limites de recursos
          requests:
            memory: "64Mi"
            cpu: "100m" # 0.1 núcleo de CPU
          limits:
            memory: "128Mi"
            cpu: "250m" # 0.25 núcleo de CPU

Campos chave:

metadata.name: Nome do objeto Deployment.

spec.replicas: Número de Pods a serem executados.

spec.selector.matchLabels: Como o Deployment encontra quais Pods gerenciar.

spec.template.metadata.labels: Rótulos aplicados aos Pods. Devem corresponder a spec.selector.matchLabels.

spec.template.spec.containers.image: A imagem Docker a ser executada.

spec.template.spec.containers.ports.containerPort: A porta exposta pelo contêiner. Isso é crucial.

Passo 4: Criar Manifesto de Service do Kubernetes 🌐
Um Service do Kubernetes fornece um ponto de extremidade de rede estável (endereço IP e porta) para acessar os Pods da aplicação. Queremos expor a aplicação externamente na porta 8080.

Crie um arquivo chamado hello-service.yaml:

apiVersion: v1
kind: Service
metadata:
  name: hello-world-service       # Nome único para o Service
  labels:
    app: hello-world              # Rótulo para identificar recursos relacionados a esta app
spec:
  type: LoadBalancer              # Expõe o Service externamente usando o balanceador de carga de um provedor de nuvem.
                                  # Alternativas: NodePort (para configurações não-nuvem ou específicas), ClusterIP (apenas interno)
  selector:
    app: hello-world              # Seleciona Pods com este rótulo para rotear o tráfego.
                                  # Deve corresponder aos rótulos dos Pods no Deployment.
  ports:
    - name: http                  # Nome para a porta (opcional, mas boa prática)
      protocol: TCP
      port: 8080                  # Porta em que o Service estará disponível *externamente*
                                  # e internamente no cluster no ClusterIP do Service.
      targetPort: 80              # Porta nos *Pods* para a qual o tráfego deve ser encaminhado.
                                  # DEVE corresponder ao containerPort no seu Deployment (ex.: 80 para nginxdemos/hello).
                                  # Se sua app dentro do contêiner escuta na 5000, defina como 5000.
      # nodePort: 30080           # Se type: NodePort, especifica a porta no IP de cada Node.
                                  # Intervalo: 30000-32767. Usado apenas se type for NodePort.
                                  # Se type for LoadBalancer, o provedor de nuvem geralmente escolhe isso ou é gerenciado.

Campos chave:

spec.type: LoadBalancer é preferível para acesso externo em plataformas de nuvem. Se indisponível, mude para NodePort.

spec.selector: Deve corresponder aos rótulos dos Pods gerenciados pelo seu Deployment.

spec.ports.port: A porta na qual o Service é exposto. Clientes externos se conectarão a esta porta (ex.: http://<IP-LoadBalancer>:8080).

spec.ports.targetPort: A porta no contêiner para a qual o Service encaminha o tráfego.

Passo 5: Implantar no Cluster Kubernetes 🚀
Certifique-se de que kubectl esteja configurado para o seu cluster de destino.

5.1. Aplicar o Manifesto de Deployment

kubectl apply -f hello-deployment.yaml

Saída esperada: deployment.apps/hello-world-deployment created

5.2. Verificar o Deployment
Verifique o status do Deployment:

kubectl get deployments hello-world-deployment

Aguarde até que as colunas READY e AVAILABLE mostrem a contagem de réplicas desejada (ex.: 2/2).

Verifique os Pods:

kubectl get pods -l app=hello-world

Você deve ver Pods com status Running. Pode levar um momento para as imagens serem puxadas e os contêineres iniciarem.
Se houver problemas, use kubectl describe pod <nome-do-pod> e kubectl logs <nome-do-pod> para solucionar problemas.

5.3. Aplicar o Manifesto de Service

kubectl apply -f hello-service.yaml

Saída esperada: service/hello-world-service created

5.4. Verificar o Service e Obter IP/Porta Externa
Verifique o status do Service:

kubectl get services hello-world-service
# ou abreviado: kubectl get svc hello-world-service

Se TYPE for LoadBalancer:
Procure por EXTERNAL-IP. Pode levar alguns minutos para os provedores de nuvem atribuírem um IP. Inicialmente, mostrará <pending>.
Saída de exemplo:

NAME                  TYPE           CLUSTER-IP    EXTERNAL-IP      PORT(S)          AGE
hello-world-service   LoadBalancer   10.96.45.30   34.XXX.YYY.ZZZ   8080:30080/TCP   2m

O ponto de acesso externo é http://34.XXX.YYY.ZZZ:8080. A parte 30080 é a nodePort atribuída automaticamente pelo provedor de nuvem para o LoadBalancer.

Se TYPE for NodePort (porque LoadBalancer não é suportado ou você o alterou):
O EXTERNAL-IP provavelmente será <none>. A coluna PORT(S) mostrará o mapeamento, ex.: 8080:30080/TCP. Você usará o endereço IP de um Node e a nodePort (ex.: 30080).
Para obter um IP de Node (use um IP externo se disponível, caso contrário, interno para clusters locais como Minikube):

kubectl get nodes -o wide

Passo 6: Acessar a Aplicação Externamente 🌐
Se estiver usando LoadBalancer com um EXTERNAL-IP:
Abra seu navegador ou use curl:

curl http://<EXTERNAL-IP-DO-GET-SVC>:8080

Exemplo: curl http://34.XXX.YYY.ZZZ:8080

Se estiver usando NodePort:
Acesse usando o IP de qualquer Node e a nodePort (ex.: 30080 de 8080:30080/TCP):

curl http://<IP_DO_NODE>:<NODE_PORT_DO_GET_SVC>

Exemplo: curl http://192.168.49.2:30080 (se 192.168.49.2 for um IP de node do Minikube e 30080 for a nodePort).

Você deve ver a mensagem "Hello world!" ou a página de boas-vindas do Nginx.

Passo 7: Escalar a Aplicação (Opcional) 📈
Para alterar o número de Pods em execução:

kubectl scale deployment hello-world-deployment --replicas=3

Verifique com kubectl get pods -l app=hello-world. Você deve ver 3 Pods.
O Service distribuirá automaticamente o tráfego para os novos Pods.

Para reduzir a escala:

kubectl scale deployment hello-world-deployment --replicas=1

Passo 8: Limpeza 🧹
Para remover a aplicação implantada e seus recursos do seu cluster:

kubectl delete service hello-world-service
kubectl delete deployment hello-world-deployment

Se você enviou uma imagem personalizada para um registro, talvez queira excluí-la de lá também (passo manual através da interface do registro).

Solução de Problemas Comuns 🔍
ImagePullBackOff / ErrImagePull:

kubectl describe pod <nome-do-pod> para detalhes.

Verifique se o nome e a tag da imagem estão corretos em hello-deployment.yaml.

Certifique-se de que a imagem seja pública ou que o cluster tenha segredos de pull para registro privado.

Verifique a conectividade de rede dos nodes do cluster para o registro.

CrashLoopBackOff:

kubectl logs <nome-do-pod> para ver os logs do contêiner em busca de erros da aplicação.

kubectl describe pod <nome-do-pod> para motivos de reinicialização.

Certifique-se de que containerPort no Deployment corresponda à porta em que sua aplicação realmente escuta.

Verifique as requisições/limites de recursos; a app pode estar sendo OOMKilled (Out Of Memory Killed).

Service Não Acessível / Connection Refused:

Verifique se selector em hello-service.yaml corresponde aos rótulos nos Pods (app: hello-world).

Verifique se targetPort em hello-service.yaml corresponde a containerPort em hello-deployment.yaml E à porta em que sua app dentro do contêiner escuta.

Para LoadBalancer, certifique-se de que EXTERNAL-IP esteja provisionado e não <pending>.

Verifique as regras de firewall do provedor de nuvem se o IP do LoadBalancer estiver inacessível.

Para NodePort, certifique-se de que o firewall do node permita tráfego na nodePort.

kubectl describe service hello-world-service para eventos ou erros.

kubectl get endpoints hello-world-service - verifique se há IPs de Pods de backend saudáveis listados. Caso contrário, o seletor do serviço ou a saúde do Pod é um problema.