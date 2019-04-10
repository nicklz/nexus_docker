1. Install https://docs.docker.com/install/
2. git clone git@github.com:nicklz/nexus_docker.git project_name
3. cd project_name
4. cp .env.example .env && vi .env (Configure fields here)
5. make install
6. make up
7. Add 127.0.0.1 project_name.com to hosts file
7. Visit project website entered in .env file (example: local.project_name.com:8000)
