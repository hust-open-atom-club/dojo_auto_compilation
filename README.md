# dojo_auto_compilation
Compile challenages written by C in a dojo automatically since these challenges will be executed in the challenge docker. Note that, this repository would update according to the challenge Dockerfile
以’pwntools-dojo’仓库为例，在Dockerfile所在的目录下运行‘sudo docker build -t pwntools’构建镜像，再执行‘sudo docker run -v  "$(pwd)/pwntools-dojo:/dojos/pwntools-dojo" pwntools’运行容器，此时会在有Makefile的目录自动执行‘make’指令。成功运行的结果如图：
![](images/1.png)
