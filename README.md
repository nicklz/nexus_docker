1. Install https://docs.docker.com/install/
2. git clone git@github.com:nicklz/nexus_docker.git
3. cd nexus_docker
4. cp .env.example .env && vi .env (Configure fields here)
5. make install
6. make up
7. Manually edit hosts file and visit website entered in .env file (example: local.projetname.com:8000)