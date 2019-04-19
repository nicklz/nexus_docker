# Installation Instructions

1. Install https://docs.docker.com/install/
2. git clone git@github.com:nicklz/nexus_docker.git projectname
3. cd projectname
4. cp .env.example .env && vi .env (Configure fields here)
5. make install
6. make up
7. Add 127.0.0.1 local.projectname.com to hosts file
8. Visit project website entered in .env file (example: local.projectname.com:8003)
