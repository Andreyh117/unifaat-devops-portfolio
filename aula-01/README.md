# Aula 01 — Fundamentos de Git e Docker

## O que aprendi

- Uma branch isola uma funcionalidade para que ela possa ser desenvolvida e revisada sem afetar a versão principal.
- Commits devem registrar mudanças pequenas e objetivas; o padrão Conventional Commits facilita entender o histórico.
- `git merge` incorpora uma branch concluída à branch principal, preservando o registro do workflow utilizado.
- Uma imagem Docker reúne a aplicação e o ambiente necessário para executá-la de forma reproduzível.
- O `Dockerfile` descreve como criar a imagem, enquanto um container é uma instância dessa imagem em execução.
- O `.dockerignore` reduz o contexto enviado ao build e impede que `node_modules`, logs e variáveis locais sejam copiados para a imagem.

## Comandos Git praticados

- `git init` — inicialização do repositório local.
- `git status` — verificação dos arquivos alterados e pendentes.
- `git checkout -b feature/aula-01-app` — criação da branch da funcionalidade.
- `git add` e `git commit` — preparação e registro das alterações.
- `git log --oneline --all` — consulta do histórico e das branches.
- `git merge feature/aula-01-app` — integração da funcionalidade à branch principal.
- `git push` — publicação do histórico e das branches no GitHub.

## Comandos Docker praticados

- `docker build -t portfolio-aula01:1.0 .` — criação da imagem da API.
- `docker run -d --name portfolio-test -p 3000:3000 portfolio-aula01:1.0` — execução do container em segundo plano.
- `docker ps` — verificação do container em execução.
- `docker logs portfolio-test` — consulta dos logs da aplicação.
- `docker stop portfolio-test` e `docker rm portfolio-test` — interrupção e remoção do container de teste.

## Como executar este container

```bash
cd aula-01/app
docker build -t portfolio-aula01:1.0 .
docker run -d -p 3000:3000 portfolio-aula01:1.0
curl http://localhost:3000
curl http://localhost:3000/health
```

## Dificuldades e como resolvi

A principal dificuldade foi garantir que a imagem tivesse somente o necessário para a aplicação funcionar. Para resolver, configurei o `.dockerignore`, copiei primeiro os arquivos de dependências no `Dockerfile` e usei uma instalação de produção. Assim, o build aproveita melhor o cache e não leva arquivos locais desnecessários para o container.
