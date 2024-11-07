+++ Multi API-CLI +++
Esse projeto é uma base para você conseguir replicar uma webapi em várias intâncias conforme a quantidade de clientes (1 container para cada cliente, todos se comunicam via nginx)

+++ Requisitos windows +++
- WSL (Instância de alguma distro linux, alpine, ubuntu ou app Docker desktop)
- gitbash (Para rodar o script start.sh, acaso não queira rodá-lo, pode usar os comandos dentro dele manualmente por um terminal do windows)

+++ Requisitos linux +++
- Docker
!!! Está subindo redis, nginx, pgsql em containers, acaso não queira usar os containers, favor instalá-los na máquina e proceder com ajustes nas configurações dos arquivos .env

+++ Como iniciar +++
!!! Não esqueça de verificar as variáveis dentro do arquivo start.sh antes de rodar (se atente aos comentários).

---
chmod +x start.sh
./start.sh
---

+++ Considerações finais +++
!!! Para verificar os redirecionamentos finais, abra a pasta nginx/nginx.conf (esse arquivo é gerado automaticamente pelo script)
!!! Acaso o contâiner da webapi não esteja rodando, tente executar a mesma manualmente no computador, antes de verificar se é um erro na montagem do contâiner (vai estar na pasta tmp)